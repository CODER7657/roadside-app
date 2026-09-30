// verifyStartOtp (PLAN §9 `in_progress` row, §12.6, §12.9; issue #116). Assigned mechanic only.
//
// The mechanic types the 4-digit start code the customer reads out. The code lives in
// bookings/{id}/private/otp, which the mechanic can never read.
//   - right code:            arrived → in_progress, timestamps.started
//   - wrong code:            attempts + 1; the 5th wrong one locks the code for 10 minutes
//                            and the customer gets an inbox item + push
//   - while locked:          rejected without looking at the code
// Replay protection: consumeAppCheckToken. The comparison is constant-time.
// A wrong code must still save the attempt, so the transaction returns an outcome and the
// error is thrown only after it commits.

import { timingSafeEqual } from 'node:crypto';
import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { HttpsError } from 'firebase-functions/v2/https';
import { z } from 'zod';
import { db } from '../lib/admin.js';
import { secureCall } from '../lib/secureCall.js';
import { assertTransition } from '../models/status.js';
import type { BookingDoc, BookingOtpDoc } from '../models/documents.js';
import { deliverNotice } from '../notifications/onBookingStatusChange.js';
import { notice } from '../notifications/rules.js';

export const MAX_OTP_ATTEMPTS = 5;
export const OTP_LOCK_MS = 10 * 60 * 1000;

const input = z.object({
  bookingId: z.string().min(1).max(128),
  code: z.string().regex(/^\d{4}$/),
});

export function codesMatch(expected: string, given: string): boolean {
  const a = Buffer.from(expected, 'utf8');
  const b = Buffer.from(given, 'utf8');
  return a.length === b.length && timingSafeEqual(a, b);
}

type Outcome =
  | { kind: 'started' }
  | { kind: 'wrong'; attemptsLeft: number }
  | { kind: 'locked_now'; lockedUntilMs: number; customerId: string }
  | { kind: 'locked'; lockedUntilMs: number };

/** Pure: what a guess does to the OTP state. */
export function judge(
  otp: Pick<BookingOtpDoc, 'code' | 'attempts' | 'lockedUntil'>,
  given: string,
  nowMs: number,
): { result: 'locked' | 'started' | 'wrong' | 'locked_now'; attempts: number; lockedUntilMs: number | null } {
  const lockedUntilMs = otp.lockedUntil?.toMillis() ?? null;
  if (lockedUntilMs !== null && lockedUntilMs > nowMs) {
    return { result: 'locked', attempts: otp.attempts, lockedUntilMs };
  }
  // A lock that has run out starts a fresh set of attempts.
  const attempts = lockedUntilMs !== null ? 0 : otp.attempts;
  if (codesMatch(otp.code, given)) return { result: 'started', attempts, lockedUntilMs: null };
  if (attempts + 1 >= MAX_OTP_ATTEMPTS) {
    return { result: 'locked_now', attempts: 0, lockedUntilMs: nowMs + OTP_LOCK_MS };
  }
  return { result: 'wrong', attempts: attempts + 1, lockedUntilMs: null };
}

export interface VerifyStartOtpResult {
  bookingId: string;
  status: 'in_progress';
}

export const verifyStartOtp = secureCall(
  {
    name: 'verifyStartOtp',
    roles: ['mechanic'],
    mechanicStatuses: ['approved'],
    input,
    // Well above 5 honest tries; the lock does the real limiting.
    rateLimit: { max: 10, windowSeconds: 60 },
    consumeAppCheckToken: true,
  },
  async ({ uid, data }): Promise<VerifyStartOtpResult> => {
    const fs = db();
    const bookingRef = fs.doc(`bookings/${data.bookingId}`);
    const otpRef = bookingRef.collection('private').doc('otp');

    const outcome = await fs.runTransaction(async (tx): Promise<Outcome> => {
      const nowMs = Date.now();
      const booking = (await tx.get(bookingRef)).data() as BookingDoc | undefined;
      // Someone else's booking looks the same as a missing one.
      if (!booking || booking.mechanicId !== uid) throw new HttpsError('not-found', 'error_booking_not_found');
      assertTransition(booking.status, 'in_progress', 'mechanic');
      const otp = (await tx.get(otpRef)).data() as BookingOtpDoc | undefined;
      if (!otp) throw new HttpsError('failed-precondition', 'error_code_unavailable');

      const verdict = judge(otp, data.code, nowMs);
      switch (verdict.result) {
        case 'locked':
          return { kind: 'locked', lockedUntilMs: verdict.lockedUntilMs! };
        case 'started':
          tx.update(otpRef, { attempts: 0, lockedUntil: null });
          tx.update(bookingRef, {
            status: 'in_progress',
            'timestamps.started': FieldValue.serverTimestamp(),
            statusHistory: FieldValue.arrayUnion({ status: 'in_progress', at: Timestamp.fromMillis(nowMs), by: uid }),
            updatedAt: FieldValue.serverTimestamp(),
          });
          return { kind: 'started' };
        case 'locked_now':
          tx.update(otpRef, { attempts: 0, lockedUntil: Timestamp.fromMillis(verdict.lockedUntilMs!) });
          return { kind: 'locked_now', lockedUntilMs: verdict.lockedUntilMs!, customerId: booking.customerId };
        case 'wrong':
          tx.update(otpRef, { attempts: verdict.attempts });
          return { kind: 'wrong', attemptsLeft: MAX_OTP_ATTEMPTS - verdict.attempts };
      }
    });

    // Never log the code or attempts detail beyond the outcome.
    logger.info('verifyStartOtp', { uid, bookingId: data.bookingId, outcome: outcome.kind });

    switch (outcome.kind) {
      case 'started':
        return { bookingId: data.bookingId, status: 'in_progress' };
      case 'wrong':
        throw new HttpsError('invalid-argument', 'error_code_wrong', { attemptsLeft: outcome.attemptsLeft });
      case 'locked_now':
        // The customer should know someone is guessing their start code.
        await deliverNotice(
          `otp_lock_${outcome.lockedUntilMs}`,
          data.bookingId,
          notice(outcome.customerId, 'customer', 'start_code_locked')[0]!,
        ).catch((err: unknown) =>
          logger.warn('start code lock alert failed', { bookingId: data.bookingId, errorName: (err as Error)?.name }),
        );
        throw new HttpsError('resource-exhausted', 'error_code_locked', {
          lockedUntil: new Date(outcome.lockedUntilMs).toISOString(),
        });
      case 'locked':
        throw new HttpsError('resource-exhausted', 'error_code_locked', {
          lockedUntil: new Date(outcome.lockedUntilMs).toISOString(),
        });
    }
  },
);
