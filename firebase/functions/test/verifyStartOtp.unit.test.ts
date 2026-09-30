import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { Timestamp } from 'firebase-admin/firestore';
import { codesMatch, judge, MAX_OTP_ATTEMPTS, OTP_LOCK_MS } from '../src/callables/verifyStartOtp.js';

const now = 1_790_000_000_000;
const otp = (attempts = 0, lockedUntilMs: number | null = null) => ({
  code: '0427',
  attempts,
  lockedUntil: lockedUntilMs === null ? null : Timestamp.fromMillis(lockedUntilMs),
});

describe('codesMatch', () => {
  it('matches only the exact code', () => {
    assert.ok(codesMatch('0427', '0427'));
    assert.ok(!codesMatch('0427', '427'));
    assert.ok(!codesMatch('0427', '0428'));
    assert.ok(!codesMatch('0427', '04270'));
  });
});

describe('judge', () => {
  it('the right code starts the job and clears attempts', () => {
    assert.deepEqual(judge(otp(3), '0427', now), { result: 'started', attempts: 3, lockedUntilMs: null });
  });

  it('counts wrong codes', () => {
    assert.deepEqual(judge(otp(0), '1111', now), { result: 'wrong', attempts: 1, lockedUntilMs: null });
    assert.deepEqual(judge(otp(3), '1111', now), { result: 'wrong', attempts: 4, lockedUntilMs: null });
  });

  it(`the ${MAX_OTP_ATTEMPTS}th wrong code locks for 10 minutes`, () => {
    assert.deepEqual(judge(otp(MAX_OTP_ATTEMPTS - 1), '1111', now), {
      result: 'locked_now',
      attempts: 0,
      lockedUntilMs: now + OTP_LOCK_MS,
    });
  });

  it('while locked, even the right code is refused', () => {
    assert.equal(judge(otp(0, now + 60_000), '0427', now).result, 'locked');
  });

  it('after the lock runs out there are 5 fresh attempts', () => {
    assert.deepEqual(judge(otp(0, now - 1), '1111', now), { result: 'wrong', attempts: 1, lockedUntilMs: null });
    assert.equal(judge(otp(0, now - 1), '0427', now).result, 'started');
  });
});
