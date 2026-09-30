// completeJob (PLAN §9 `completed` row, §12.10; issue #117). Assigned mechanic only.
//
// in_progress → completed, in one transaction:
//   - at least 1 after photo; every photo must be a download URL for this booking's
//     bookings/{id}/work/ folder (the only place Storage lets the mechanic upload them, #102)
//   - finalAmount (whole rupees) within 0.5× the estimate's min to 3× its max, otherwise a
//     reason is required
//   - the mechanic's jobsCompleted goes up by one, they're free again (presence), and the
//     live location is set to expire 24 h from now
// Payment then starts at `pending` (see payments.ts).

import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { HttpsError } from 'firebase-functions/v2/https';
import { z } from 'zod';
import { db } from '../lib/admin.js';
import { secureCall } from '../lib/secureCall.js';
import { assertTransition } from '../models/status.js';
import type { BookingDoc, PriceRange } from '../models/documents.js';

export const MAX_WORK_PHOTOS = 5;
export const LIVE_LOCATION_TTL_MS = 24 * 60 * 60 * 1000;
const STORAGE_HOST = 'firebasestorage.googleapis.com';

/** True if `url` is a Firebase Storage download URL for an object in bookings/{bookingId}/work/. */
export function isWorkPhotoUrl(url: string, bookingId: string): boolean {
  let u: URL;
  try {
    u = new URL(url);
  } catch {
    return false;
  }
  if (u.protocol !== 'https:' || u.hostname !== STORAGE_HOST) return false;
  // /v0/b/{bucket}/o/{url-encoded object path}
  const m = u.pathname.match(/^\/v0\/b\/[^/]+\/o\/([^/]+)$/);
  if (!m) return false;
  let path: string;
  try {
    path = decodeURIComponent(m[1]!);
  } catch {
    return false;
  }
  const prefix = `bookings/${bookingId}/work/`;
  return path.startsWith(prefix) && path.length > prefix.length && !path.slice(prefix.length).includes('/');
}

/** PLAN §9: the final amount must be 0.5× the estimate's min to 3× its max. */
export function amountInRange(amount: number, estimate: PriceRange): boolean {
  return amount >= 0.5 * estimate.min && amount <= 3 * estimate.max;
}

const photoList = z.array(z.string().max(2048)).max(MAX_WORK_PHOTOS);

const input = z.object({
  bookingId: z.string().min(1).max(128),
  finalAmount: z.number().int().positive().max(1_000_000),
  afterPhotoUrls: photoList.min(1),
  beforePhotoUrls: photoList.default([]),
  /** Required when finalAmount is outside the range (no §8 field stores it yet; see the PR). */
  amountReason: z
    .strictObject({
      code: z.string().regex(/^[a-z][a-z0-9_]{1,39}$/),
      text: z.string().trim().max(300).optional(),
    })
    .optional(),
});

export interface CompleteJobResult {
  bookingId: string;
  status: 'completed';
}

export const completeJob = secureCall(
  {
    name: 'completeJob',
    roles: ['mechanic'],
    mechanicStatuses: ['approved'],
    input,
    rateLimit: { max: 10, windowSeconds: 60 },
  },
  async ({ uid, data }): Promise<CompleteJobResult> => {
    const fs = db();
    const bookingRef = fs.doc(`bookings/${data.bookingId}`);
    const mechanicRef = fs.doc(`mechanics/${uid}`);
    const presenceRef = fs.doc(`presence/${uid}`);
    const liveRef = fs.doc(`liveLocations/${data.bookingId}`);

    for (const url of [...data.afterPhotoUrls, ...data.beforePhotoUrls]) {
      if (!isWorkPhotoUrl(url, data.bookingId)) throw new HttpsError('invalid-argument', 'error_photo_invalid');
    }

    let outOfRange = false;
    await fs.runTransaction(async (tx) => {
      const nowMs = Date.now();
      const booking = (await tx.get(bookingRef)).data() as BookingDoc | undefined;
      // Someone else's booking looks the same as a missing one.
      if (!booking || booking.mechanicId !== uid) throw new HttpsError('not-found', 'error_booking_not_found');
      assertTransition(booking.status, 'completed', 'mechanic');

      outOfRange = !amountInRange(data.finalAmount, booking.priceEstimate);
      if (outOfRange && !data.amountReason) {
        throw new HttpsError('invalid-argument', 'error_amount_reason_required', {
          min: Math.ceil(0.5 * booking.priceEstimate.min),
          max: Math.floor(3 * booking.priceEstimate.max),
        });
      }
      const [presence, live] = await Promise.all([tx.get(presenceRef), tx.get(liveRef)]);

      tx.update(bookingRef, {
        status: 'completed',
        finalAmount: data.finalAmount,
        afterPhotoUrls: data.afterPhotoUrls,
        beforePhotoUrls: data.beforePhotoUrls,
        'timestamps.completed': FieldValue.serverTimestamp(),
        statusHistory: FieldValue.arrayUnion({ status: 'completed', at: Timestamp.fromMillis(nowMs), by: uid }),
        updatedAt: FieldValue.serverTimestamp(),
      });
      tx.update(mechanicRef, { jobsCompleted: FieldValue.increment(1), updatedAt: FieldValue.serverTimestamp() });
      if (presence.get('activeBookingId') === data.bookingId) tx.update(presenceRef, { activeBookingId: null });
      // §12.10: live location is kept for 24 h after the job ends (Firestore TTL on expireAt).
      if (live.exists) tx.update(liveRef, { expireAt: Timestamp.fromMillis(nowMs + LIVE_LOCATION_TTL_MS) });
    });

    // The reason code isn't personal data; the free text stays out of logs.
    logger.info('completeJob', {
      uid,
      bookingId: data.bookingId,
      outOfRange,
      amountReasonCode: outOfRange ? data.amountReason?.code : undefined,
    });
    return { bookingId: data.bookingId, status: 'completed' };
  },
);
