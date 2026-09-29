// cancelBooking (PLAN §9 `cancelled` and `requested` re-dispatch rows, §12.9).
//
//   Customer: any time before `in_progress`                      → cancelled
//   Mechanic: before arrival (accepted / arriving)               → back to requested, re-dispatch
//             after arrival (arrived), with a reason             → cancelled
//   Admin:    any time before `in_progress`                      → cancelled
// Everything runs in one transaction against the §9 table, so a cancel racing an accept,
// a status step or the dispatch sweep can't leave the booking half-changed.

import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { HttpsError } from 'firebase-functions/v2/https';
import { z } from 'zod';
import { db } from '../lib/admin.js';
import { secureCall } from '../lib/secureCall.js';
import { advanceDispatch, dispatchDeps } from '../dispatch/advance.js';
import { assertTransition } from '../models/status.js';
import type { Actor, BookingStatus, Role } from '../models/enums.js';
import type { BookingDoc, BookingOtpDoc, OfferDoc } from '../models/documents.js';
import { newStartCode } from './createBooking.js';

const input = z.object({
  bookingId: z.string().min(1).max(128),
  /** Required when the booking ends up `cancelled`; optional for a mechanic's pre-arrival re-dispatch. */
  reason: z
    .strictObject({
      // Codes come from the apps' cancel sheets (roadside_core keeps `code` a free string).
      code: z.string().regex(/^[a-z][a-z0-9_]{1,39}$/),
      text: z.string().trim().max(300).optional(),
    })
    .optional(),
});

export type CancelOutcome = 'cancelled' | 'redispatched';

export interface CancelBookingResult {
  bookingId: string;
  outcome: CancelOutcome;
}

/**
 * What a cancel by `actor` does at `status`. Throws `failed-precondition` when §9 doesn't allow it
 * (e.g. anyone once work has started, or a mechanic cancelling a booking that's still `requested`).
 */
export function decideCancel(status: BookingStatus, actor: Actor): CancelOutcome {
  if (actor === 'mechanic' && (status === 'accepted' || status === 'arriving')) {
    assertTransition(status, 'requested', actor);
    return 'redispatched';
  }
  assertTransition(status, 'cancelled', actor);
  return 'cancelled';
}

/** The caller's side on this booking, or null if it isn't theirs. */
function actorFor(role: Role, uid: string, b: BookingDoc): Actor | null {
  if (role === 'admin') return 'admin';
  if (role === 'customer' && b.customerId === uid) return 'customer';
  if (role === 'mechanic' && b.mechanicId === uid) return 'mechanic';
  return null;
}

interface Withdrawn {
  mechanicId: string;
  offerId: string;
}

export const cancelBooking = secureCall(
  {
    name: 'cancelBooking',
    roles: ['customer', 'mechanic', 'admin'],
    // A mechanic can only cancel a booking they're assigned to, which needs approval anyway.
    mechanicStatuses: ['approved'],
    input,
    rateLimit: { max: 10, windowSeconds: 600 },
  },
  async ({ uid, role, data }): Promise<CancelBookingResult> => {
    const fs = db();
    const bookingRef = fs.doc(`bookings/${data.bookingId}`);
    let withdrawn: Withdrawn | null = null;

    const outcome = await fs.runTransaction(async (tx): Promise<CancelOutcome> => {
      withdrawn = null;
      const nowMs = Date.now();

      // Reads.
      const booking = (await tx.get(bookingRef)).data() as BookingDoc | undefined;
      // Someone else's booking looks the same as a missing one.
      const actor = booking ? actorFor(role, uid, booking) : null;
      if (!booking || !actor) throw new HttpsError('not-found', 'error_booking_not_found');

      const result = decideCancel(booking.status, actor);
      if (result === 'cancelled' && !data.reason) {
        throw new HttpsError('invalid-argument', 'error_reason_required');
      }

      const offerRef = booking.currentOfferId ? fs.doc(`offers/${booking.currentOfferId}`) : null;
      const offer = offerRef ? ((await tx.get(offerRef)).data() as OfferDoc | undefined) : undefined;
      const assigned = booking.mechanicId;
      const presenceRef = assigned ? fs.doc(`presence/${assigned}`) : null;
      const presence = presenceRef ? (await tx.get(presenceRef)).data() : undefined;

      // Writes.
      const history = FieldValue.arrayUnion({
        status: result === 'cancelled' ? 'cancelled' : 'requested',
        at: Timestamp.fromMillis(nowMs),
        by: uid,
      });

      // An offer still waiting for an answer is withdrawn.
      if (offerRef && offer?.state === 'pending') {
        tx.update(offerRef, { state: 'expired', updatedAt: FieldValue.serverTimestamp() });
        withdrawn = { mechanicId: offer.mechanicId, offerId: offerRef.id };
      }

      // The assigned mechanic is free again.
      if (presenceRef && presence?.activeBookingId === data.bookingId) {
        tx.update(presenceRef, { activeBookingId: null });
      }

      if (result === 'cancelled') {
        tx.update(bookingRef, {
          status: 'cancelled',
          cancelledBy: actor,
          cancelReason: data.reason!.text ? data.reason! : { code: data.reason!.code },
          'timestamps.cancelled': FieldValue.serverTimestamp(),
          statusHistory: history,
          updatedAt: FieldValue.serverTimestamp(),
        });
        return 'cancelled';
      }

      // Mechanic cancelled before arrival: back to `requested` without them. The mechanic's
      // details come off the booking, the search restarts at 3 km, and the start code is
      // regenerated (§12.9) so the old mechanic can't use it.
      tx.update(bookingRef, {
        status: 'requested',
        mechanicId: null,
        mechanicCard: null,
        customerCard: null,
        currentOfferId: null,
        triedMechanicIds: FieldValue.arrayUnion(uid),
        searchRadiusKm: 3,
        statusHistory: history,
        updatedAt: FieldValue.serverTimestamp(),
      });
      const otp: BookingOtpDoc = { code: newStartCode(), attempts: 0, lockedUntil: null };
      tx.set(bookingRef.collection('private').doc('otp'), otp);
      return 'redispatched';
    });

    logger.info('cancelBooking', { uid, bookingId: data.bookingId, outcome });

    // Best effort after the commit; the dispatch sweep covers both if they fail.
    const w = withdrawn as Withdrawn | null;
    if (w) {
      await dispatchDeps()
        .notifyOfferWithdrawn(w.mechanicId, w.offerId, data.bookingId)
        .catch((err: unknown) =>
          logger.warn('offer withdrawn push failed', { bookingId: data.bookingId, errorName: (err as Error)?.name }),
        );
    }
    if (outcome === 'redispatched') {
      await advanceDispatch(data.bookingId).catch((err: unknown) =>
        logger.warn('re-dispatch failed', { bookingId: data.bookingId, errorName: (err as Error)?.name }),
      );
    }
    return { bookingId: data.bookingId, outcome };
  },
);
