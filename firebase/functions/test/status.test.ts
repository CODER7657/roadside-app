import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { assertTransition, canTransition } from '../src/models/status.js';

describe('status machine (PLAN §9)', () => {
  it('allows the happy path for the mechanic', () => {
    assert.ok(canTransition('requested', 'accepted', 'mechanic'));
    assert.ok(canTransition('accepted', 'arriving', 'mechanic'));
    assert.ok(canTransition('arriving', 'arrived', 'mechanic'));
    assert.ok(canTransition('arrived', 'in_progress', 'mechanic'));
    assert.ok(canTransition('in_progress', 'completed', 'mechanic'));
  });

  it('re-dispatches when a mechanic cancels before arrival only', () => {
    assert.ok(canTransition('accepted', 'requested', 'mechanic'));
    assert.ok(canTransition('arriving', 'requested', 'mechanic'));
    assert.ok(!canTransition('arrived', 'requested', 'mechanic'));
  });

  it('lets the customer cancel only before in_progress', () => {
    assert.ok(canTransition('arrived', 'cancelled', 'customer'));
    assert.ok(!canTransition('in_progress', 'cancelled', 'customer'));
  });

  it('lets the mechanic cancel outright only after arrival', () => {
    assert.ok(!canTransition('accepted', 'cancelled', 'mechanic'));
    assert.ok(canTransition('arrived', 'cancelled', 'mechanic'));
  });

  it('only the system marks no_mechanic_found', () => {
    assert.ok(canTransition('requested', 'no_mechanic_found', 'system'));
    assert.ok(!canTransition('requested', 'no_mechanic_found', 'admin'));
  });

  it('rejects a customer completing their own booking', () => {
    assert.throws(() => assertTransition('in_progress', 'completed', 'customer'), {
      code: 'failed-precondition',
      message: 'error_invalid_status',
    });
  });

  it('never leaves a terminal status', () => {
    for (const to of ['requested', 'accepted', 'cancelled'] as const) {
      assert.ok(!canTransition('completed', to, 'admin'));
      assert.ok(!canTransition('cancelled', to, 'admin'));
    }
  });
});
