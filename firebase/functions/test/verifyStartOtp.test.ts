import assert from 'node:assert/strict';
import { beforeEach, describe, it } from 'node:test';
import { Timestamp } from 'firebase-admin/firestore';
import { HttpsError } from 'firebase-functions/v2/https';
import { emulatorRunning, fakeRequest, rejection } from './helpers.js';
import { verifyStartOtp } from '../src/callables/verifyStartOtp.js';
import { setNotifyDeps } from '../src/notifications/onBookingStatusChange.js';
import type { Notice } from '../src/notifications/rules.js';
import { db } from '../src/lib/admin.js';
import { AHMEDABAD, bookingOf, resetEmulators, seedBooking } from './dispatchFixtures.js';

const pushes: Array<{ token: string; type: string }> = [];
setNotifyDeps({ push: async (token: string, n: Notice) => void pushes.push({ token, type: n.type }) });

const asMechanic = (uid: string, data: unknown) =>
  fakeRequest({ uid, claims: { role: 'mechanic', mechanicStatus: 'approved' }, data });

/** An `arrived` booking for m-1 with start code 0427. Returns its id and customer. */
async function arrived(status = 'arrived'): Promise<{ bookingId: string; customerId: string }> {
  const bookingId = await seedBooking(AHMEDABAD, 'ahmedabad', { status, mechanicId: 'm-1' });
  await db().doc(`bookings/${bookingId}/private/otp`).set({ code: '0427', attempts: 0, lockedUntil: null });
  const customerId = (await bookingOf(bookingId)).customerId as string;
  await db().doc(`users/${customerId}`).set({ name: 'Priya', fcmToken: 'cust-token' }, { merge: true });
  return { bookingId, customerId };
}

const otpOf = async (bookingId: string) => (await db().doc(`bookings/${bookingId}/private/otp`).get()).data()!;

async function details(p: Promise<unknown>): Promise<{ code: string; message: string; details: unknown }> {
  try {
    await p;
  } catch (err) {
    assert.ok(err instanceof HttpsError);
    return { code: err.code, message: err.message, details: err.details };
  }
  throw new Error('expected rejection');
}

describe('verifyStartOtp (emulator)', { skip: !emulatorRunning && 'no Firestore emulator' }, () => {
  beforeEach(async () => {
    await resetEmulators();
    pushes.length = 0;
  });

  it('the right code: arrived → in_progress', async () => {
    const { bookingId } = await arrived();
    assert.deepEqual(await verifyStartOtp.run(asMechanic('m-1', { bookingId, code: '0427' })), {
      bookingId,
      status: 'in_progress',
    });
    const b = await bookingOf(bookingId);
    assert.equal(b.status, 'in_progress');
    assert.ok(b.timestamps.started);
    assert.equal(b.statusHistory.at(-1).status, 'in_progress');
  });

  it('a wrong code is rejected, counted, and changes nothing else', async () => {
    const { bookingId } = await arrived();
    const err = await details(verifyStartOtp.run(asMechanic('m-1', { bookingId, code: '1111' })));
    assert.deepEqual(err, { code: 'invalid-argument', message: 'error_code_wrong', details: { attemptsLeft: 4 } });
    assert.equal((await otpOf(bookingId)).attempts, 1);
    assert.equal((await bookingOf(bookingId)).status, 'arrived');
  });

  it('5 wrong codes lock it, the 6th try is locked even with the right code, and the customer is told', async () => {
    const { bookingId, customerId } = await arrived();
    for (let i = 1; i <= 4; i++) {
      assert.equal((await details(verifyStartOtp.run(asMechanic('m-1', { bookingId, code: '1111' })))).message, 'error_code_wrong');
    }
    const fifth = await details(verifyStartOtp.run(asMechanic('m-1', { bookingId, code: '1111' })));
    assert.equal(fifth.code, 'resource-exhausted');
    assert.equal(fifth.message, 'error_code_locked');
    const lockedUntil = Date.parse((fifth.details as { lockedUntil: string }).lockedUntil);
    assert.ok(lockedUntil > Date.now() + 9 * 60_000 && lockedUntil <= Date.now() + 10 * 60_000);

    const sixth = await details(verifyStartOtp.run(asMechanic('m-1', { bookingId, code: '0427' })));
    assert.equal(sixth.message, 'error_code_locked');
    assert.equal((await bookingOf(bookingId)).status, 'arrived');

    const inbox = (await db().collection(`inbox/${customerId}/items`).get()).docs.map((d) => d.data());
    assert.equal(inbox.length, 1);
    assert.equal(inbox[0]!.type, 'start_code_locked');
    assert.equal(inbox[0]!.bookingId, bookingId);
    assert.deepEqual(pushes, [{ token: 'cust-token', type: 'start_code_locked' }]);
  });

  it('once the lock runs out, the right code works', async () => {
    const { bookingId } = await arrived();
    await db()
      .doc(`bookings/${bookingId}/private/otp`)
      .update({ attempts: 0, lockedUntil: Timestamp.fromMillis(Date.now() - 1000) });
    const res = await verifyStartOtp.run(asMechanic('m-1', { bookingId, code: '0427' }));
    assert.equal(res.status, 'in_progress');
    assert.equal((await otpOf(bookingId)).lockedUntil, null);
  });

  it('locks again after the first lock has run out (regression, #124 review)', async () => {
    const { bookingId } = await arrived();
    const guess = () => details(verifyStartOtp.run(asMechanic('m-1', { bookingId, code: '1111' })));
    for (let i = 1; i <= 5; i++) await guess();
    assert.ok((await otpOf(bookingId)).lockedUntil, 'first lock');

    // Wait out the lock. Ten real minutes would also empty the 1-minute rate-limit window, so
    // clear it too; otherwise the 11th call in a second is (correctly) rate limited instead.
    await db().doc(`bookings/${bookingId}/private/otp`).update({ lockedUntil: Timestamp.fromMillis(Date.now() - 1000) });
    await db().doc('rateLimits/m-1').delete();
    for (let i = 1; i <= 4; i++) assert.equal((await guess()).message, 'error_code_wrong');
    assert.equal((await otpOf(bookingId)).lockedUntil, null, 'the expired lock is cleared');
    assert.equal((await otpOf(bookingId)).attempts, 4);
    assert.equal((await guess()).message, 'error_code_locked');
    assert.equal((await guess()).message, 'error_code_locked');
  });

  it('only from arrived, only by the assigned mechanic', async () => {
    const { bookingId: onTheWay } = await arrived('arriving');
    assert.equal(
      (await rejection(verifyStartOtp.run(asMechanic('m-1', { bookingId: onTheWay, code: '0427' })))).message,
      'error_invalid_status',
    );
    const { bookingId } = await arrived();
    const theirs = await rejection(verifyStartOtp.run(asMechanic('m-2', { bookingId, code: '0427' })));
    assert.deepEqual(theirs, { code: 'not-found', message: 'error_booking_not_found' });
    assert.equal((await otpOf(bookingId)).attempts, 0); // another mechanic can't burn attempts
  });

  it('rejects anything that is not 4 digits before touching the booking', async () => {
    const { bookingId } = await arrived();
    for (const code of ['123', '12345', 'abcd', ' 042']) {
      assert.equal((await rejection(verifyStartOtp.run(asMechanic('m-1', { bookingId, code })))).code, 'invalid-argument');
    }
    assert.equal((await otpOf(bookingId)).attempts, 0);
  });
});
