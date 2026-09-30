// requestAccountDeletion (#167; PLAN §12.2, §12.6, §12.12). C10 in both apps calls it.
//
//   - Needs a fresh sign-in: the ID token's `auth_time` within the last 5 minutes (§12.2).
//   - Refused while the caller has an active booking (they cancel or finish it first).
//   - Marks the profile with `deletionRequestedAt` (users/{uid} for customers, mechanics/{uid}
//     for mechanics), takes a mechanic offline, then disables the Auth user and revokes their
//     refresh tokens, so the account stops working at once: they can't sign in again, and
//     their current ID token expires within the hour.
//   - The data itself goes in the daily purge (src/account/purgeAccounts.ts), well within the
//     30 days the privacy policy promises (§12.12).
//
// The reason is logged as a code only; the optional text is never stored or logged (it may
// hold personal details) until the team decides where feedback should go.

import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';
import * as logger from 'firebase-functions/logger';
import { HttpsError } from 'firebase-functions/v2/https';
import { z } from 'zod';
import { db } from '../lib/admin.js';
import { secureCall } from '../lib/secureCall.js';
import { ACTIVE_STATUSES } from '../models/status.js';
import type { Role } from '../models/enums.js';

const input = z.object({
  reason: z.strictObject({
    // Codes come from the C10 reason chips (e.g. not_needed, privacy, other).
    code: z.string().regex(/^[a-z][a-z0-9_]{1,39}$/),
    text: z.string().trim().max(300).optional(),
  }),
});

/** §12.2: deletion needs a sign-in within the last 5 minutes. */
export const REAUTH_WINDOW_SECONDS = 5 * 60;

/** True if the token's `auth_time` (seconds) is within [REAUTH_WINDOW_SECONDS] of [nowMs]. */
export function isFreshSignIn(authTime: unknown, nowMs: number): boolean {
  if (typeof authTime !== 'number' || !Number.isFinite(authTime)) return false;
  const age = nowMs / 1000 - authTime;
  // A small negative age is clock skew between Auth and this server.
  return age >= -60 && age <= REAUTH_WINDOW_SECONDS;
}

/** Where each role's profile (and so `deletionRequestedAt`) lives. */
export function profilePath(role: Role, uid: string): string {
  return role === 'mechanic' ? `mechanics/${uid}` : `users/${uid}`;
}

export interface RequestAccountDeletionResult {
  /** When the request was recorded (the first time, for a repeated call). */
  requestedAt: string;
}

export const requestAccountDeletion = secureCall(
  {
    name: 'requestAccountDeletion',
    roles: ['customer', 'mechanic'],
    // Any mechanic may leave: pending, approved or blocked.
    input,
    // §12.6: replay protection on this one.
    consumeAppCheckToken: true,
    rateLimit: { max: 5, windowSeconds: 3600 },
  },
  async ({ uid, role, claims, data }): Promise<RequestAccountDeletionResult> => {
    if (!isFreshSignIn((claims as { auth_time?: unknown }).auth_time, Date.now())) {
      throw new HttpsError('failed-precondition', 'error_reauth_required');
    }

    const fs = db();
    const profileRef = fs.doc(profilePath(role, uid));
    const activeQuery = fs
      .collection('bookings')
      .where(role === 'mechanic' ? 'mechanicId' : 'customerId', '==', uid)
      .where('status', 'in', [...ACTIVE_STATUSES])
      .limit(1);

    const requestedAt = await fs.runTransaction(async (tx) => {
      const active = await tx.get(activeQuery);
      if (!active.empty) throw new HttpsError('failed-precondition', 'error_active_booking');

      const profile = await tx.get(profileRef);
      const presenceRef = fs.doc(`presence/${uid}`);
      const presence = role === 'mechanic' ? await tx.get(presenceRef) : null;

      const already = profile.get('deletionRequestedAt') as Timestamp | null | undefined;
      if (already) return already;

      const now = Timestamp.now();
      if (profile.exists) {
        tx.update(profileRef, { deletionRequestedAt: now, updatedAt: FieldValue.serverTimestamp() });
      } else {
        // Signed up but never finished the profile: a stub marks the request for the purge.
        tx.set(profileRef, {
          deletionRequestedAt: now,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
          schemaVersion: 1,
        });
      }
      if (presence?.exists) {
        tx.update(presenceRef, { isOnline: false, updatedAt: FieldValue.serverTimestamp() });
      }
      return now;
    });

    // Outside the transaction: Auth isn't transactional, and repeating these is harmless.
    const auth = getAuth();
    await auth.updateUser(uid, { disabled: true });
    await auth.revokeRefreshTokens(uid);

    logger.info('account deletion requested', { uid, role, reason: data.reason.code });
    return { requestedAt: requestedAt.toDate().toISOString() };
  },
);
