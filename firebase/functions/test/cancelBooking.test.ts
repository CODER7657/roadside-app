import assert from 'node:assert/strict';
import { beforeEach, describe, it } from 'node:test';
import { authEmulatorRunning, emulatorRunning, fakeRequest, rejection } from './helpers.js';
import { cancelBooking } from '../src/callables/cancelBooking.js';
import { respondToOffer } from '../src/callables/respondToOffer.js';
import { advanceDispatch, setDispatchDeps } from '../src/dispatch/advance.js';
import { recomputeRating } from '../src/triggers/onReviewCreated.js';
import { db } from '../src/lib/admin.js';
import {
  AHMEDABAD,
  bookingOf,
  north,
  offerOf,
  resetEmulators,
  seedBooking,
  seedMechanic,
} from './dispatchFixtures.js';

const withdrawn: string[] = [];
setDispatchDeps({
  notifyOffer: async () => {},
  scheduleTimeout: async () => {},
  notifyOfferWithdrawn: async (mechanicId) => void withdrawn.push(mechanicId),
});

const REASON = { code: 'changed_plans' };
const asCustomer = (uid: string, data: unknown) => fakeRequest({ uid, claims: { role: 'customer' }, data });
const asMechanic = (uid: string, data: unknown) =>
  fakeRequest({ uid, claims: { role: 'mechanic', mechanicStatus: 'approved' }, data });
const asAdmin = (data: unknown) => fakeRequest({ uid: 'admin-1', claims: { role: 'admin' }, data });

/** A booking at `status`, already assigned to a seeded mechanic (except `requested`). */
async function assigned(status: 'accepted' | 'arriving' | 'arrived' | 'in_progress') {
  const mechanicId = await seedMechanic({ at: north(AHMEDABAD, 1) });
  const bookingId = await seedBooking(AHMEDABAD, 'ahmedabad', {
    status,
    mechanicId,
    triedMechanicIds: [mechanicId],
    mechanicCard: { name: 'Ramesh' },
    customerCard: { name: 'Priya' },
  });
  await db().doc(`presence/${mechanicId}`).update({ activeBookingId: bookingId });
  await db().doc(`bookings/${bookingId}/private/otp`).set({ code: '1234', attempts: 2, lockedUntil: null });
  const customerId = (await bookingOf(bookingId)).customerId as string;
  return { bookingId, mechanicId, customerId };
}

const activeOf = async (mechanicId: string) =>
  (await db().doc(`presence/${mechanicId}`).get()).get('activeBookingId') as string | null;

describe(
  'cancelBooking (emulator)',
  { skip: !(emulatorRunning && authEmulatorRunning) && 'no Firestore/Auth emulator' },
  () => {
    beforeEach(async () => {
      await resetEmulators();
      withdrawn.length = 0;
    });

    it('customer cancels while searching: the open offer is withdrawn', async () => {
      const m = await seedMechanic({ at: north(AHMEDABAD, 1) });
      const bookingId = await seedBooking(AHMEDABAD);
      const first = await advanceDispatch(bookingId);
      assert.ok(first.result === 'offered');
      const customerId = (await bookingOf(bookingId)).customerId as string;

      const res = await cancelBooking.run(asCustomer(customerId, { bookingId, reason: REASON }));
      assert.deepEqual(res, { bookingId, outcome: 'cancelled' });

      const b = await bookingOf(bookingId);
      assert.equal(b.status, 'cancelled');
      assert.equal(b.cancelledBy, 'customer');
      assert.deepEqual(b.cancelReason, REASON);
      assert.ok(b.timestamps.cancelled);
      assert.equal(b.statusHistory.at(-1).status, 'cancelled');
      assert.equal((await offerOf(first.offerId)).state, 'expired');
      assert.deepEqual(withdrawn, [m]);
      // The sweep leaves it alone from now on.
      assert.deepEqual(await advanceDispatch(bookingId), { result: 'inactive' });
    });

    for (const status of ['accepted', 'arriving', 'arrived'] as const) {
      it(`customer cancels at ${status}: the mechanic is free again`, async () => {
        const { bookingId, mechanicId, customerId } = await assigned(status);
        await cancelBooking.run(
          asCustomer(customerId, { bookingId, reason: { code: 'too_slow', text: 'Found help nearby' } }),
        );
        const b = await bookingOf(bookingId);
        assert.equal(b.status, 'cancelled');
        assert.deepEqual(b.cancelReason, { code: 'too_slow', text: 'Found help nearby' });
        assert.equal(await activeOf(mechanicId), null);
      });
    }

    for (const status of ['accepted', 'arriving'] as const) {
      it(`mechanic cancels at ${status}: back to requested and offered to someone else`, async () => {
        const { bookingId, mechanicId } = await assigned(status);
        const next = await seedMechanic({ at: north(AHMEDABAD, 2) });

        const res = await cancelBooking.run(asMechanic(mechanicId, { bookingId }));
        assert.deepEqual(res, { bookingId, outcome: 'redispatched' });

        const b = await bookingOf(bookingId);
        assert.equal(b.status, 'requested');
        assert.equal(b.mechanicId, null);
        assert.equal(b.mechanicCard, null);
        assert.equal(b.customerCard, null);
        assert.equal(b.cancelledBy ?? null, null);
        assert.ok(b.triedMechanicIds.includes(mechanicId));
        assert.equal(b.statusHistory.at(-1).status, 'requested');
        assert.equal(b.statusHistory.at(-1).by, mechanicId);
        assert.equal(await activeOf(mechanicId), null);

        // New start code, attempts reset (§12.9).
        const otp = (await db().doc(`bookings/${bookingId}/private/otp`).get()).data()!;
        assert.match(otp.code, /^\d{4}$/);
        assert.equal(otp.attempts, 0);

        // Re-dispatched straight away, never back to the mechanic who cancelled.
        assert.ok(b.currentOfferId);
        assert.equal((await offerOf(b.currentOfferId)).mechanicId, next);
      });
    }

    it('mechanic cancels after arrival: cancelled, reason required', async () => {
      const { bookingId, mechanicId } = await assigned('arrived');
      const noReason = await rejection(cancelBooking.run(asMechanic(mechanicId, { bookingId })));
      assert.deepEqual(noReason, { code: 'invalid-argument', message: 'error_reason_required' });

      await cancelBooking.run(asMechanic(mechanicId, { bookingId, reason: { code: 'customer_not_found' } }));
      const b = await bookingOf(bookingId);
      assert.equal(b.status, 'cancelled');
      assert.equal(b.cancelledBy, 'mechanic');
      assert.equal(await activeOf(mechanicId), null);
    });

    it('admin cancels an assigned booking', async () => {
      const { bookingId, mechanicId } = await assigned('arriving');
      await cancelBooking.run(asAdmin({ bookingId, reason: { code: 'fraud_suspected' } }));
      const b = await bookingOf(bookingId);
      assert.equal(b.cancelledBy, 'admin');
      assert.equal(b.statusHistory.at(-1).by, 'admin-1');
      assert.equal(await activeOf(mechanicId), null);
    });

    it('nobody can cancel once work has started', async () => {
      const { bookingId, mechanicId, customerId } = await assigned('in_progress');
      for (const req of [
        asCustomer(customerId, { bookingId, reason: REASON }),
        asMechanic(mechanicId, { bookingId, reason: REASON }),
        asAdmin({ bookingId, reason: REASON }),
      ]) {
        assert.deepEqual(await rejection(cancelBooking.run(req)), {
          code: 'failed-precondition',
          message: 'error_invalid_status',
        });
      }
      assert.equal((await bookingOf(bookingId)).status, 'in_progress');
    });

    it("rejects someone else's booking the same way as a missing one", async () => {
      const { bookingId } = await assigned('accepted');
      const other = await seedMechanic({ at: north(AHMEDABAD, 20) });
      const theirs = await rejection(cancelBooking.run(asCustomer('stranger', { bookingId, reason: REASON })));
      const notAssigned = await rejection(cancelBooking.run(asMechanic(other, { bookingId, reason: REASON })));
      const missing = await rejection(cancelBooking.run(asCustomer('stranger', { bookingId: 'nope', reason: REASON })));
      assert.deepEqual(theirs, { code: 'not-found', message: 'error_booking_not_found' });
      assert.deepEqual(notAssigned, theirs);
      assert.deepEqual(missing, theirs);
    });

    it('rejects a badly formed reason code', async () => {
      const { bookingId, customerId } = await assigned('accepted');
      const err = await rejection(
        cancelBooking.run(asCustomer(customerId, { bookingId, reason: { code: 'Nope; DROP' } })),
      );
      assert.equal(err.code, 'invalid-argument');
    });

    it('a cancel racing an accept always ends cancelled with the mechanic free', async () => {
      const m = await seedMechanic({ at: north(AHMEDABAD, 1) });
      const bookingId = await seedBooking(AHMEDABAD);
      const offer = await advanceDispatch(bookingId);
      assert.ok(offer.result === 'offered');
      const customerId = (await bookingOf(bookingId)).customerId as string;

      const results = await Promise.allSettled([
        cancelBooking.run(asCustomer(customerId, { bookingId, reason: REASON })),
        respondToOffer.run(asMechanic(m, { offerId: offer.offerId, accept: true })),
      ]);
      // Either order is valid: cancel first (the accept is then rejected), or accept first and
      // the customer cancels the accepted booking. The cancel always succeeds, and the mechanic
      // is never left marked busy on a dead booking.
      assert.equal(results[0].status, 'fulfilled', JSON.stringify(results));
      assert.equal((await bookingOf(bookingId)).status, 'cancelled');
      assert.equal(await activeOf(m), null);
    });
  },
);

describe('recomputeRating (emulator)', { skip: !emulatorRunning && 'no Firestore emulator' }, () => {
  beforeEach(resetEmulators);

  it('averages all of the mechanic’s reviews and is safe to repeat', async () => {
    const m = await seedMechanic({ at: north(AHMEDABAD, 1) });
    for (const [i, stars] of [5, 4, 4].entries()) {
      await db().doc(`reviews/b-${i}`).set({ customerId: `c-${i}`, mechanicId: m, stars, tags: [], comment: '' });
    }
    await db().doc('reviews/other').set({ customerId: 'c-9', mechanicId: 'someone-else', stars: 1 });

    assert.deepEqual(await recomputeRating(m), { rating: 4.33, ratingCount: 3 });
    assert.deepEqual(await recomputeRating(m), { rating: 4.33, ratingCount: 3 }); // trigger retry
    const doc = (await db().doc(`mechanics/${m}`).get()).data()!;
    assert.equal(doc.rating, 4.33);
    assert.equal(doc.ratingCount, 3);
  });

  it('does nothing for a mechanic without a profile', async () => {
    assert.equal(await recomputeRating('ghost'), null);
  });
});
