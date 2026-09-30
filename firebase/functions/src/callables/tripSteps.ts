// startTrip and markArrived (PLAN §9 `arriving` and `arrived` rows). Assigned mechanic only.
//
//   startTrip:   accepted → arriving
//   markArrived: arriving → arrived, only when the mechanic's last reported position
//                (liveLocations/{bookingId}, written by the app every 5 s / 10 m) is within
//                100 m of the pickup, or 200 m when the pickup itself was vague (issue #115).
// Both run in a transaction against the §9 table.

import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { HttpsError } from 'firebase-functions/v2/https';
import { z } from 'zod';
import { db } from '../lib/admin.js';
import { distanceKm } from '../lib/geo.js';
import { secureCall } from '../lib/secureCall.js';
import { assertTransition } from '../models/status.js';
import type { BookingStatus } from '../models/enums.js';
import type { BookingDoc, LiveLocationDoc } from '../models/documents.js';

/** PLAN §9: arrival radius. */
export const ARRIVAL_RADIUS_M = 100;
export const ARRIVAL_RADIUS_POOR_ACCURACY_M = 200;
/** A pickup fix worse than this counts as "poor accuracy" (issue #115). */
export const POOR_PICKUP_ACCURACY_M = 100;
/**
 * The mechanic's reported position must be at least this fresh (issue #115; the app sends every
 * 5 s). It's read from liveLocations, never from the call, so it can't be faked by sending coordinates.
 */
export const LIVE_LOCATION_MAX_AGE_MS = 30 * 1000;

export function arrivalRadiusM(pickupAccuracyM: number): number {
  return pickupAccuracyM > POOR_PICKUP_ACCURACY_M ? ARRIVAL_RADIUS_POOR_ACCURACY_M : ARRIVAL_RADIUS_M;
}

const input = z.object({ bookingId: z.string().min(1).max(128) });

export interface TripStepResult {
  bookingId: string;
  status: BookingStatus;
}

type Step = 'arriving' | 'arrived';

/**
 * Moves the caller's booking to `to`. `check` runs inside the transaction after the §9 check
 * and can reject the step (e.g. too far from the pickup).
 */
async function step(
  uid: string,
  bookingId: string,
  to: Step,
  check?: (booking: BookingDoc, live: LiveLocationDoc | undefined, nowMs: number) => void,
): Promise<TripStepResult> {
  const fs = db();
  const ref = fs.doc(`bookings/${bookingId}`);
  const liveRef = fs.doc(`liveLocations/${bookingId}`);

  await fs.runTransaction(async (tx) => {
    const nowMs = Date.now();
    const booking = (await tx.get(ref)).data() as BookingDoc | undefined;
    // Someone else's booking looks the same as a missing one.
    if (!booking || booking.mechanicId !== uid) throw new HttpsError('not-found', 'error_booking_not_found');
    assertTransition(booking.status, to, 'mechanic');
    const live = check ? ((await tx.get(liveRef)).data() as LiveLocationDoc | undefined) : undefined;
    check?.(booking, live, nowMs);

    tx.update(ref, {
      status: to,
      [`timestamps.${to}`]: FieldValue.serverTimestamp(),
      statusHistory: FieldValue.arrayUnion({ status: to, at: Timestamp.fromMillis(nowMs), by: uid }),
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  logger.info(`trip step ${to}`, { uid, bookingId });
  return { bookingId, status: to };
}

/** Throws unless the mechanic's fresh reported position is within the arrival radius. */
export function assertNearPickup(booking: BookingDoc, live: LiveLocationDoc | undefined, nowMs: number): void {
  if (!live?.mechanicGeopoint || !live.updatedAt || nowMs - live.updatedAt.toMillis() > LIVE_LOCATION_MAX_AGE_MS) {
    throw new HttpsError('failed-precondition', 'error_location_unavailable');
  }
  const metres =
    distanceKm(
      { lat: live.mechanicGeopoint.latitude, lng: live.mechanicGeopoint.longitude },
      { lat: booking.pickup.geopoint.latitude, lng: booking.pickup.geopoint.longitude },
    ) * 1000;
  if (metres > arrivalRadiusM(booking.pickup.accuracyMeters)) {
    // No distance in the error: it would reveal how far the pickup is.
    throw new HttpsError('failed-precondition', 'error_not_at_pickup');
  }
}

export const startTrip = secureCall(
  { name: 'startTrip', roles: ['mechanic'], mechanicStatuses: ['approved'], input, rateLimit: { max: 20, windowSeconds: 60 } },
  async ({ uid, data }) => step(uid, data.bookingId, 'arriving'),
);

export const markArrived = secureCall(
  { name: 'markArrived', roles: ['mechanic'], mechanicStatuses: ['approved'], input, rateLimit: { max: 20, windowSeconds: 60 } },
  async ({ uid, data }) => step(uid, data.bookingId, 'arrived', assertNearPickup),
);
