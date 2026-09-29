import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { HttpsError } from 'firebase-functions/v2/https';
import { z } from 'zod';
import { secureCall } from '../src/lib/secureCall.js';
import { emulatorRunning, fakeRequest, rejection } from './helpers.js';

// A sample callable that only customers may call.
const sample = secureCall(
  {
    name: 'sample',
    roles: ['customer'],
    input: z.object({ note: z.string().max(10) }),
  },
  async ({ uid, data }) => ({ uid, note: data.note }),
);

const approvedOnly = secureCall(
  {
    name: 'approvedOnly',
    roles: ['mechanic'],
    mechanicStatuses: ['approved'],
    input: z.object({}),
  },
  async () => 'ok',
);

const crashes = secureCall(
  { name: 'crashes', roles: ['customer'], input: z.object({}) },
  async () => {
    throw new Error('boom: +919999999999');
  },
);

const customer = { uid: 'cust-1', claims: { role: 'customer' } };

describe('secureCall', () => {
  it('accepts a valid call from the right role', async () => {
    const res = await sample.run(fakeRequest({ ...customer, data: { note: 'hi' } }));
    assert.deepEqual(res, { uid: 'cust-1', note: 'hi' });
  });

  it('rejects a call without auth', async () => {
    const err = await rejection(sample.run(fakeRequest({ data: { note: 'hi' } })));
    assert.deepEqual(err, { code: 'unauthenticated', message: 'error_unauthenticated' });
  });

  it('rejects a call without App Check outside the emulator', async () => {
    const err = await rejection(
      sample.run(fakeRequest({ ...customer, data: { note: 'hi' }, withAppCheck: false })),
    );
    assert.deepEqual(err, { code: 'unauthenticated', message: 'error_app_check' });
  });

  it('rejects the wrong role', async () => {
    const err = await rejection(
      sample.run(fakeRequest({ uid: 'm-1', claims: { role: 'mechanic' }, data: { note: 'hi' } })),
    );
    assert.deepEqual(err, { code: 'permission-denied', message: 'error_permission_denied' });
  });

  it('rejects a caller with no role claim', async () => {
    const err = await rejection(sample.run(fakeRequest({ uid: 'x', data: { note: 'hi' } })));
    assert.equal(err.code, 'permission-denied');
  });

  it('rejects extra fields', async () => {
    const err = await rejection(
      sample.run(fakeRequest({ ...customer, data: { note: 'hi', status: 'completed' } })),
    );
    assert.deepEqual(err, { code: 'invalid-argument', message: 'error_invalid_input' });
  });

  it('rejects invalid values without echoing them back', async () => {
    try {
      await sample.run(fakeRequest({ ...customer, data: { note: 'far too long a note' } }));
      assert.fail('expected rejection');
    } catch (err) {
      assert.ok(err instanceof HttpsError);
      assert.equal(err.code, 'invalid-argument');
      assert.deepEqual(err.details, { fields: ['note'] });
      assert.ok(!JSON.stringify(err.toJSON()).includes('far too long'));
    }
  });

  it('rejects a mechanic who is not approved', async () => {
    const pending = { uid: 'm-2', claims: { role: 'mechanic', mechanicStatus: 'pending' } };
    const err = await rejection(approvedOnly.run(fakeRequest(pending)));
    assert.deepEqual(err, { code: 'permission-denied', message: 'error_mechanic_not_approved' });

    const approved = { uid: 'm-3', claims: { role: 'mechanic', mechanicStatus: 'approved' } };
    assert.equal(await approvedOnly.run(fakeRequest(approved)), 'ok');
  });

  it('turns unexpected errors into a safe internal error', async () => {
    try {
      await crashes.run(fakeRequest(customer));
      assert.fail('expected rejection');
    } catch (err) {
      assert.ok(err instanceof HttpsError);
      assert.equal(err.code, 'internal');
      assert.equal(err.message, 'error_internal');
      assert.ok(!JSON.stringify(err.toJSON()).includes('+91'));
    }
  });
});

describe('secureCall rate limit (emulator)', { skip: !emulatorRunning && 'no Firestore emulator' }, () => {
  const limited = secureCall(
    {
      name: 'limited',
      roles: ['customer'],
      input: z.object({}),
      rateLimit: { max: 2, windowSeconds: 60 },
    },
    async () => 'ok',
  );

  it('allows calls up to the limit, then rejects', async () => {
    const who = { uid: `rl-${Date.now()}`, claims: { role: 'customer' } };
    assert.equal(await limited.run(fakeRequest(who)), 'ok');
    assert.equal(await limited.run(fakeRequest(who)), 'ok');
    const err = await rejection(limited.run(fakeRequest(who)));
    assert.deepEqual(err, { code: 'resource-exhausted', message: 'error_rate_limited' });
  });
});
