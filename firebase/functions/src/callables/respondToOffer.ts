// respondToOffer (PLAN §9 `accepted`, §11 step 3). Approved mechanics only.
//
// Accept, in one transaction: the offer is theirs, still pending and not expired; the
// booking is `requested` and this is its current offer; the mechanic is online and free.
// Then the booking becomes `accepted` with mechanicCard / customerCard snapshots and
// presence.activeBookingId is set. Only one accept can win.
// Decline: the offer is marked declined and dispatch moves on to the next mechanic.

import { getAuth } from 'firebase-admin/auth';
import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { HttpsError } from 'firebase-functions/v2/https';
import { z } from 'zod';
import { db, ensureAdminApp } from '../lib/admin.js';
import { secureCall } from '../lib/secureCall.js';
import { advanceDispatch } from '../dispatch/advance.js';
import { assertTransition } from '../models/status.js';
import type {
  BookingDoc,
  Contact,
  MechanicCard,
  MechanicDoc,
  MechanicKycDoc,
  OfferDoc,
  PresenceDoc,
  UserDoc,
} from '../models/documents.js';

const input = z.object({
  offerId: z.string().min(1).max(128),
  accept: z.boolean(),
});

export interface RespondToOfferResult {
  bookingId: string;
  state: 'accepted' | 'declined';
}

export function buildMechanicCard(m: MechanicDoc, kyc: MechanicKycDoc, phone: string): MechanicCard {
  const independent = m.mechanicType === 'independent';
  return {
    name: m.name,
    photoUrl: m.profilePhotoUrl,
    mechanicType: m.mechanicType,
    shopName: independent ? null : (m.shopName ?? null),
    experienceYears: independent ? (m.experienceYears ?? null) : null,
    travelVehicleRegNo: independent ? (m.travelVehicle?.regNo ?? null) : null,
    rating: m.rating ?? 0,
    jobsCompleted: m.jobsCompleted ?? 0,
    phone,
    upiId: kyc.upiId,
    upiName: kyc.upiName,
  };
}

async function phoneOf(uid: string): Promise<string> {
  ensureAdminApp();
  return (await getAuth().getUser(uid)).phoneNumber ?? '';
}

const unavailable = () => new HttpsError('failed-precondition', 'error_offer_unavailable');

export const respondToOffer = secureCall(
  {
    name: 'respondToOffer',
    roles: ['mechanic'],
    mechanicStatuses: ['approved'],
    input,
    rateLimit: { max: 20, windowSeconds: 60 },
  },
  async ({ uid, data }): Promise<RespondToOfferResult> => {
    const fs = db();
    const offerRef = fs.doc(`offers/${data.offerId}`);

    const result = await fs.runTransaction(async (tx): Promise<RespondToOfferResult> => {
      const nowMs = Date.now();
      const offer = (await tx.get(offerRef)).data() as OfferDoc | undefined;
      // Someone else's offer looks the same as a missing one.
      if (!offer || offer.mechanicId !== uid) throw unavailable();
      if (offer.state !== 'pending') throw unavailable();
      if (offer.expiresAt.toMillis() <= nowMs) {
        throw new HttpsError('failed-precondition', 'error_offer_expired');
      }

      const bookingRef = fs.doc(`bookings/${offer.bookingId}`);
      const booking = (await tx.get(bookingRef)).data() as BookingDoc | undefined;
      if (!booking || booking.status !== 'requested' || booking.currentOfferId !== data.offerId) {
        throw unavailable();
      }

      if (!data.accept) {
        tx.update(offerRef, { state: 'declined', updatedAt: FieldValue.serverTimestamp() });
        return { bookingId: offer.bookingId, state: 'declined' };
      }

      const presenceRef = fs.doc(`presence/${uid}`);
      const [presenceSnap, mechanicSnap, kycSnap, customerSnap] = await tx.getAll(
        presenceRef,
        fs.doc(`mechanics/${uid}`),
        fs.doc(`mechanics/${uid}/private/kyc`),
        fs.doc(`users/${booking.customerId}`),
      );
      const presence = presenceSnap!.data() as PresenceDoc | undefined;
      if (!presence?.isOnline || presence.activeBookingId) {
        throw new HttpsError('failed-precondition', 'error_not_available');
      }
      const mechanic = mechanicSnap!.data() as MechanicDoc | undefined;
      const kyc = kycSnap!.data() as MechanicKycDoc | undefined;
      if (!mechanic || !kyc) throw new HttpsError('failed-precondition', 'error_profile_incomplete');
      const customer = customerSnap!.data() as UserDoc | undefined;

      const [mechanicPhone, customerPhone] = await Promise.all([phoneOf(uid), phoneOf(booking.customerId)]);
      const customerCard: Contact = { name: customer?.name ?? '', phone: customerPhone };

      assertTransition('requested', 'accepted', 'mechanic');
      tx.update(offerRef, { state: 'accepted', updatedAt: FieldValue.serverTimestamp() });
      tx.update(bookingRef, {
        status: 'accepted',
        mechanicId: uid,
        mechanicCard: buildMechanicCard(mechanic, kyc, mechanicPhone),
        customerCard,
        'timestamps.accepted': FieldValue.serverTimestamp(),
        statusHistory: FieldValue.arrayUnion({ status: 'accepted', at: Timestamp.fromMillis(nowMs), by: uid }),
        updatedAt: FieldValue.serverTimestamp(),
      });
      tx.update(presenceRef, { activeBookingId: offer.bookingId });
      return { bookingId: offer.bookingId, state: 'accepted' };
    });

    logger.info('respondToOffer', { uid, bookingId: result.bookingId, state: result.state });

    if (result.state === 'declined') {
      // Offer the next mechanic now; the sweep covers it if this fails.
      await advanceDispatch(result.bookingId).catch((err: unknown) =>
        logger.warn('advance after decline failed', { bookingId: result.bookingId, errorName: (err as Error)?.name }),
      );
    }
    return result;
  },
);
