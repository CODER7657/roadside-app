// advanceDispatch: the one idempotent step every dispatch path calls (PLAN §11 steps 2, 4, 5).
// Called on booking create, by the 30 s Cloud Task, by the 1-minute sweep and after a decline.
//
// For a `requested` booking:
//   - current offer still pending and not expired → nothing to do;
//   - otherwise expire it and offer the nearest free candidate, widening 3 → 5 → 10 km;
//   - nobody left at 10 km → `no_mechanic_found`.
// All writes happen in a transaction that re-checks the booking hasn't moved on, so the
// timer, the sweep and a decline running at once can't create two offers.

import { getFunctions } from 'firebase-admin/functions';
import { getMessaging } from 'firebase-admin/messaging';
import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { db, ensureAdminApp, REGION } from '../lib/admin.js';
import { assertTransition } from '../models/status.js';
import { SCHEMA_VERSION } from '../models/enums.js';
import type { BookingDoc, OfferDoc, PresenceDoc, ServiceAreaDoc } from '../models/documents.js';
import {
  findCandidates,
  hasLiveOffer,
  PRESENCE_STALE_MS,
  RADII_KM,
  type Candidate,
  type RadiusKm,
} from './candidates.js';

export const OFFER_TTL_SECONDS = 30;
const MAX_ATTEMPTS = 5;

/** Side effects outside Firestore. Tests replace these. */
export interface DispatchDeps {
  notifyOffer(mechanicId: string, offerId: string, bookingId: string): Promise<void>;
  scheduleTimeout(bookingId: string, delaySeconds: number): Promise<void>;
  /** Tells a mechanic their open offer is gone (the customer cancelled), so the app closes it. */
  notifyOfferWithdrawn(mechanicId: string, offerId: string, bookingId: string): Promise<void>;
}

async function mechanicToken(mechanicId: string): Promise<string | null> {
  return ((await db().doc(`mechanics/${mechanicId}`).get()).get('fcmToken') as string | null | undefined) ?? null;
}

export const defaultDeps: DispatchDeps = {
  async notifyOffer(mechanicId, offerId, bookingId) {
    const token = await mechanicToken(mechanicId);
    if (!token) return;
    // Data-only, high priority: the app shows the full-screen offer on its `offers` channel.
    // No address, phone or coordinates in the payload.
    ensureAdminApp();
    await getMessaging().send({
      token,
      data: { type: 'offer', offerId, bookingId },
      android: { priority: 'high', ttl: OFFER_TTL_SECONDS * 1000 },
    });
  },
  async scheduleTimeout(bookingId, delaySeconds) {
    ensureAdminApp();
    await getFunctions()
      .taskQueue(`locations/${REGION}/functions/offerTimeout`)
      .enqueue({ bookingId }, { scheduleDelaySeconds: delaySeconds });
  },
  async notifyOfferWithdrawn(mechanicId, offerId, bookingId) {
    const token = await mechanicToken(mechanicId);
    if (!token) return;
    ensureAdminApp();
    await getMessaging().send({
      token,
      data: { type: 'offer_withdrawn', offerId, bookingId },
      android: { priority: 'high', ttl: OFFER_TTL_SECONDS * 1000 },
    });
  },
};

let deps: DispatchDeps = defaultDeps;
/** Test hook. */
export function setDispatchDeps(d: DispatchDeps): void {
  deps = d;
}
export function dispatchDeps(): DispatchDeps {
  return deps;
}

export type AdvanceResult =
  | { result: 'inactive' } // booking gone or not `requested`
  | { result: 'waiting'; offerId: string } // current offer still live
  | { result: 'offered'; offerId: string; mechanicId: string; radiusKm: RadiusKm }
  | { result: 'no_mechanic_found' }
  | { result: 'gave_up' }; // lost every race; the sweep retries

interface Pick {
  candidate: Candidate;
  radiusKm: RadiusKm;
}

async function pickCandidate(booking: BookingDoc, nowMs: number): Promise<Pick | null> {
  for (const radiusKm of RADII_KM) {
    if (radiusKm < booking.searchRadiusKm) continue;
    for (const candidate of await findCandidates(booking, radiusKm, nowMs)) {
      if (!(await hasLiveOffer(candidate.uid, nowMs))) return { candidate, radiusKm };
    }
  }
  return null;
}

export async function advanceDispatch(bookingId: string, nowMs: number = Date.now()): Promise<AdvanceResult> {
  const fs = db();
  const bookingRef = fs.doc(`bookings/${bookingId}`);

  for (let attempt = 0; attempt < MAX_ATTEMPTS; attempt++) {
    const snap = await bookingRef.get();
    const booking = snap.data() as BookingDoc | undefined;
    if (!booking || booking.status !== 'requested') return { result: 'inactive' };

    const currentId = booking.currentOfferId;
    if (currentId) {
      const current = (await fs.doc(`offers/${currentId}`).get()).data() as OfferDoc | undefined;
      if (current?.state === 'pending' && current.expiresAt.toMillis() > nowMs) {
        return { result: 'waiting', offerId: currentId };
      }
    }

    const pick = await pickCandidate(booking, nowMs);
    const areaName = pick
      ? (((await fs.doc(`serviceAreas/${booking.cityId}`).get()).data() as ServiceAreaDoc | undefined)?.name?.en ??
        booking.cityId)
      : '';

    const offerRef = fs.collection('offers').doc();
    const outcome = await fs.runTransaction(async (tx): Promise<AdvanceResult | 'retry'> => {
      // Reads first.
      const b = (await tx.get(bookingRef)).data() as BookingDoc | undefined;
      if (!b || b.status !== 'requested') return { result: 'inactive' };
      if (b.currentOfferId !== currentId) return 'retry'; // someone else advanced it
      const currentRef = currentId ? fs.doc(`offers/${currentId}`) : null;
      const current = currentRef ? ((await tx.get(currentRef)).data() as OfferDoc | undefined) : undefined;
      if (current?.state === 'pending' && current.expiresAt.toMillis() > nowMs) {
        return { result: 'waiting', offerId: currentId! };
      }
      const presence = pick
        ? ((await tx.get(fs.doc(`presence/${pick.candidate.uid}`))).data() as PresenceDoc | undefined)
        : undefined;
      if (
        pick &&
        (!presence?.isOnline ||
          presence.activeBookingId ||
          nowMs - presence.updatedAt.toMillis() > PRESENCE_STALE_MS)
      ) {
        return 'retry'; // candidate went offline or got a job meanwhile
      }

      // Writes.
      if (currentRef && current?.state === 'pending') {
        tx.update(currentRef, { state: 'expired', updatedAt: FieldValue.serverTimestamp() });
      }

      if (!pick) {
        assertTransition('requested', 'no_mechanic_found', 'system');
        tx.update(bookingRef, {
          status: 'no_mechanic_found',
          statusHistory: FieldValue.arrayUnion({
            status: 'no_mechanic_found',
            at: Timestamp.fromMillis(nowMs),
            by: 'system',
          }),
          currentOfferId: null,
          searchRadiusKm: RADII_KM[RADII_KM.length - 1],
          updatedAt: FieldValue.serverTimestamp(),
        });
        return { result: 'no_mechanic_found' };
      }

      const offer: Omit<OfferDoc, 'createdAt' | 'updatedAt'> & { createdAt: FieldValue; updatedAt: FieldValue } = {
        bookingId,
        mechanicId: pick.candidate.uid,
        vehicleType: b.vehicle.type,
        problemType: b.problemType,
        regNo: b.vehicle.regNo,
        distanceKm: Math.round(pick.candidate.distanceKm * 10) / 10,
        areaName,
        priceEstimate: b.priceEstimate,
        expiresAt: Timestamp.fromMillis(nowMs + OFFER_TTL_SECONDS * 1000),
        state: 'pending',
        schemaVersion: SCHEMA_VERSION,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      };
      tx.create(offerRef, offer);
      tx.update(bookingRef, {
        currentOfferId: offerRef.id,
        triedMechanicIds: FieldValue.arrayUnion(pick.candidate.uid),
        searchRadiusKm: pick.radiusKm,
        updatedAt: FieldValue.serverTimestamp(),
      });
      return { result: 'offered', offerId: offerRef.id, mechanicId: pick.candidate.uid, radiusKm: pick.radiusKm };
    });

    if (outcome === 'retry') continue;
    logger.info('advanceDispatch', { bookingId, result: outcome.result });

    if (outcome.result === 'offered') {
      // Best effort: if either fails, the 1-minute sweep still moves the booking on.
      await Promise.all([
        deps.notifyOffer(outcome.mechanicId, outcome.offerId, bookingId).catch((err: unknown) =>
          logger.warn('offer push failed', { bookingId, errorName: (err as Error)?.name }),
        ),
        deps.scheduleTimeout(bookingId, OFFER_TTL_SECONDS + 1).catch((err: unknown) =>
          logger.warn('offer timer failed', { bookingId, errorName: (err as Error)?.name }),
        ),
      ]);
    }
    return outcome;
  }

  logger.warn('advanceDispatch gave up', { bookingId });
  return { result: 'gave_up' };
}

