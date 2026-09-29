// Live-trip share links (PLAN §8 shareLinks, §10 customer "Share live trip link", U1·SOS).
//
// createShareLink: the booking's customer makes a link for family. The token is 128 bits of
// randomness and is the only secret; it expires after 3 h.
// getSharedTrip: what the public page may show. A link works only while its booking is active
// and before expiresAt, so it stops working the moment the job ends, with nothing to clean up.
// It never returns phone numbers, addresses, the pickup point or the customer's name.

import { randomBytes } from 'node:crypto';
import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { HttpsError } from 'firebase-functions/v2/https';
import { z } from 'zod';
import { db } from '../lib/admin.js';
import { secureCall } from '../lib/secureCall.js';
import { ACTIVE_STATUSES } from '../models/status.js';
import { SCHEMA_VERSION, type BookingStatus } from '../models/enums.js';
import type { BookingDoc, LiveLocationDoc, ShareLinkDoc } from '../models/documents.js';

export const SHARE_LINK_TTL_MS = 3 * 60 * 60 * 1000;
/** 16 random bytes, base64url: 22 characters. */
export const TOKEN_PATTERN = /^[A-Za-z0-9_-]{22}$/;
/** Decimal places kept for the mechanic's position: 3 ≈ 110 m. */
const COARSE_DECIMALS = 3;
/** Statuses where the mechanic is still travelling, so their position and ETA mean something. */
const ON_THE_WAY: readonly BookingStatus[] = ['accepted', 'arriving'];

export function newShareToken(): string {
  return randomBytes(16).toString('base64url');
}

export interface SharedTrip {
  status: BookingStatus;
  /** Null until a mechanic has accepted. */
  mechanicFirstName: string | null;
  /** Only while the mechanic is on the way. */
  etaMinutes: number | null;
  /** Rounded to ~110 m, only while the mechanic is on the way. */
  position: { lat: number; lng: number } | null;
}

export function firstName(name: string | null | undefined): string | null {
  const first = name?.trim().split(/\s+/)[0];
  return first ? first.slice(0, 40) : null;
}

export function coarse(value: number): number {
  const f = 10 ** COARSE_DECIMALS;
  return Math.round(value * f) / f;
}

/** Pure: the public view of a booking and its live location. */
export function buildSharedTrip(
  booking: Pick<BookingDoc, 'status' | 'mechanicCard'>,
  live: Pick<LiveLocationDoc, 'mechanicGeopoint' | 'etaMinutes'> | undefined,
): SharedTrip {
  const onTheWay = ON_THE_WAY.includes(booking.status);
  return {
    status: booking.status,
    mechanicFirstName: firstName(booking.mechanicCard?.name),
    etaMinutes: onTheWay && typeof live?.etaMinutes === 'number' ? Math.max(0, Math.round(live.etaMinutes)) : null,
    position:
      onTheWay && live?.mechanicGeopoint
        ? { lat: coarse(live.mechanicGeopoint.latitude), lng: coarse(live.mechanicGeopoint.longitude) }
        : null,
  };
}

/** The trip for a token, or null if the token is unknown, expired, or its job has ended. */
export async function getSharedTrip(token: string, nowMs: number = Date.now()): Promise<SharedTrip | null> {
  if (!TOKEN_PATTERN.test(token)) return null;
  const fs = db();
  const link = (await fs.doc(`shareLinks/${token}`).get()).data() as ShareLinkDoc | undefined;
  if (!link || link.expiresAt.toMillis() <= nowMs) return null;

  const [bookingSnap, liveSnap] = await fs.getAll(
    fs.doc(`bookings/${link.bookingId}`),
    fs.doc(`liveLocations/${link.bookingId}`),
  );
  const booking = bookingSnap!.data() as BookingDoc | undefined;
  if (!booking || !ACTIVE_STATUSES.includes(booking.status)) return null;
  return buildSharedTrip(booking, liveSnap!.data() as LiveLocationDoc | undefined);
}

const input = z.object({ bookingId: z.string().min(1).max(128) });

export interface CreateShareLinkResult {
  token: string;
  /** Path on the Hosting site; the app puts its own origin in front. */
  path: string;
  /** ISO 8601. The link also stops working as soon as the job ends. */
  expiresAt: string;
}

export const createShareLink = secureCall(
  {
    name: 'createShareLink',
    roles: ['customer'],
    input,
    rateLimit: { max: 10, windowSeconds: 3600 },
  },
  async ({ uid, data }): Promise<CreateShareLinkResult> => {
    const fs = db();
    const booking = (await fs.doc(`bookings/${data.bookingId}`).get()).data() as BookingDoc | undefined;
    // Someone else's booking looks the same as a missing one.
    if (!booking || booking.customerId !== uid) throw new HttpsError('not-found', 'error_booking_not_found');
    if (!ACTIVE_STATUSES.includes(booking.status)) {
      throw new HttpsError('failed-precondition', 'error_booking_not_active');
    }

    const token = newShareToken();
    const expiresAt = Timestamp.fromMillis(Date.now() + SHARE_LINK_TTL_MS);
    await fs.doc(`shareLinks/${token}`).create({
      bookingId: data.bookingId,
      createdBy: uid,
      expiresAt,
      schemaVersion: SCHEMA_VERSION,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Never log the token: it's the only secret the link has.
    logger.info('createShareLink', { uid, bookingId: data.bookingId });
    return { token, path: `/t/${token}`, expiresAt: expiresAt.toDate().toISOString() };
  },
);
