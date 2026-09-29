import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { enforceRateLimit } from '../src/lib/rateLimit.js';
import { emulatorRunning, rejection } from './helpers.js';

describe('enforceRateLimit (emulator)', { skip: !emulatorRunning && 'no Firestore emulator' }, () => {
  const limit = { max: 3, windowSeconds: 60 };

  it('lets old calls slide out of the window', async () => {
    const uid = `slide-${Date.now()}`;
    const t0 = 1_000_000_000_000;
    await enforceRateLimit(uid, 'k', limit, t0);
    await enforceRateLimit(uid, 'k', limit, t0 + 1_000);
    await enforceRateLimit(uid, 'k', limit, t0 + 2_000);

    const err = await rejection(enforceRateLimit(uid, 'k', limit, t0 + 3_000));
    assert.equal(err.code, 'resource-exhausted');

    // 61 s after the first call, one slot is free again.
    await enforceRateLimit(uid, 'k', limit, t0 + 61_000);
  });

  it('counts each function separately', async () => {
    const uid = `keys-${Date.now()}`;
    const one = { max: 1, windowSeconds: 60 };
    await enforceRateLimit(uid, 'a', one);
    await enforceRateLimit(uid, 'b', one);
    const err = await rejection(enforceRateLimit(uid, 'a', one));
    assert.equal(err.code, 'resource-exhausted');
  });
});
