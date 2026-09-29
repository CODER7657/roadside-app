import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { decideCancel } from '../src/callables/cancelBooking.js';
import { summarise } from '../src/triggers/onReviewCreated.js';
import { BOOKING_STATUSES, type Actor, type BookingStatus } from '../src/models/enums.js';

type Expected = 'cancelled' | 'redispatched' | 'rejected';

// PLAN §9, every status from every side.
const EXPECTED: Record<BookingStatus, Record<'customer' | 'mechanic' | 'admin', Expected>> = {
  requested: { customer: 'cancelled', mechanic: 'rejected', admin: 'cancelled' },
  accepted: { customer: 'cancelled', mechanic: 'redispatched', admin: 'cancelled' },
  arriving: { customer: 'cancelled', mechanic: 'redispatched', admin: 'cancelled' },
  arrived: { customer: 'cancelled', mechanic: 'cancelled', admin: 'cancelled' },
  in_progress: { customer: 'rejected', mechanic: 'rejected', admin: 'rejected' },
  completed: { customer: 'rejected', mechanic: 'rejected', admin: 'rejected' },
  cancelled: { customer: 'rejected', mechanic: 'rejected', admin: 'rejected' },
  no_mechanic_found: { customer: 'rejected', mechanic: 'rejected', admin: 'rejected' },
};

function attempt(status: BookingStatus, actor: Actor): Expected {
  try {
    return decideCancel(status, actor);
  } catch (err) {
    assert.equal((err as { code: string }).code, 'failed-precondition');
    assert.equal((err as { message: string }).message, 'error_invalid_status');
    return 'rejected';
  }
}

describe('decideCancel', () => {
  for (const status of BOOKING_STATUSES) {
    for (const actor of ['customer', 'mechanic', 'admin'] as const) {
      const expected = EXPECTED[status][actor];
      it(`${actor} at ${status} → ${expected}`, () => {
        assert.equal(attempt(status, actor), expected);
      });
    }
  }
});

describe('summarise', () => {
  it('averages to 2 decimals', () => {
    assert.deepEqual(summarise([5, 4, 4]), { rating: 4.33, ratingCount: 3 });
    assert.deepEqual(summarise([5]), { rating: 5, ratingCount: 1 });
  });

  it('is 0 with no reviews', () => {
    assert.deepEqual(summarise([]), { rating: 0, ratingCount: 0 });
  });

  it('ignores anything that is not 1–5 whole stars', () => {
    assert.deepEqual(summarise([5, 0, 6, 3.5, '4', null, 3]), { rating: 4, ratingCount: 2 });
  });
});
