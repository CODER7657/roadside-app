import assert from 'node:assert/strict';
import { beforeEach, describe, it } from 'node:test';
import { advanceDispatch, setDispatchDeps } from '../src/dispatch/advance.js';
import { respondToOffer } from '../src/callables/respondToOffer.js';
import { db } from '../src/lib/admin.js';
import { authEmulatorRunning, emulatorRunning, fakeRequest, rejection } from './helpers.js';
import {
  AHMEDABAD,
  bookingOf,
  north,
  offerOf,
  resetEmulators,
  seedBooking,
  seedMechanic,
} from './dispatchFixtures.js';

setDispatchDeps({ notifyOffer: async () => {}, scheduleTimeout: async () => {}, notifyOfferWithdrawn: async () => {} });

const asMechanic = (uid: string, data: unknown) =>
  fakeRequest({ uid, claims: { role: 'mechanic', mechanicStatus: 'approved' }, data });

/** Books near Ahmedabad and offers it to the nearest seeded mechanic. */
async function offered(): Promise<{ bookingId: string; offerId: string; mechanicId: string }> {
  const bookingId = await seedBooking(AHMEDABAD);
  const res = await advanceDispatch(bookingId);
  assert.ok(res.result === 'offered');
  return { bookingId, offerId: res.offerId, mechanicId: res.mechanicId };
}

describe(
  'respondToOffer (emulator)',
  { skip: !(emulatorRunning && authEmulatorRunning) && 'no Firestore/Auth emulator' },
  () => {
    beforeEach(resetEmulators);

    it('accepts: booking accepted with snapshots, mechanic marked busy', async () => {
      const m = await seedMechanic({ at: north(AHMEDABAD, 1), mechanicType: 'independent' });
      const { bookingId, offerId } = await offered();

      const res = await respondToOffer.run(asMechanic(m, { offerId, accept: true }));
      assert.deepEqual(res, { bookingId, state: 'accepted' });

      const b = await bookingOf(bookingId);
      assert.equal(b.status, 'accepted');
      assert.equal(b.mechanicId, m);
      assert.ok(b.timestamps.accepted);
      assert.equal(b.statusHistory.at(-1).status, 'accepted');
      assert.equal(b.mechanicCard.mechanicType, 'independent');
      assert.equal(b.mechanicCard.experienceYears, 6);
      assert.equal(b.mechanicCard.travelVehicleRegNo, 'GJ16AB1234');
      assert.equal(b.mechanicCard.shopName, null);
      assert.equal(b.mechanicCard.upiId, `${m}@okaxis`);
      assert.match(b.mechanicCard.phone, /^\+917/);
      assert.equal(b.customerCard.name, 'Priya');
      assert.match(b.customerCard.phone, /^\+918/);

      assert.equal((await offerOf(offerId)).state, 'accepted');
      assert.equal((await db().doc(`presence/${m}`).get()).get('activeBookingId'), bookingId);
    });

    it('two mechanics racing to accept: exactly one wins', async () => {
      const a = await seedMechanic({ at: north(AHMEDABAD, 1) });
      const b = await seedMechanic({ at: north(AHMEDABAD, 2) });
      const bookingId = await seedBooking(AHMEDABAD);

      // A's offer times out and B gets one, but A's app still shows a (stale) live offer.
      const first = await advanceDispatch(bookingId);
      assert.ok(first.result === 'offered' && first.mechanicId === a);
      const second = await advanceDispatch(bookingId, Date.now() + 31_000);
      assert.ok(second.result === 'offered' && second.mechanicId === b);
      await db().doc(`offers/${first.offerId}`).update({ state: 'pending' });

      const results = await Promise.allSettled([
        respondToOffer.run(asMechanic(a, { offerId: first.offerId, accept: true })),
        respondToOffer.run(asMechanic(b, { offerId: second.offerId, accept: true })),
      ]);
      const wins = results.filter((r) => r.status === 'fulfilled');
      assert.equal(wins.length, 1, JSON.stringify(results));

      const booking = await bookingOf(bookingId);
      assert.equal(booking.status, 'accepted');
      assert.equal(booking.mechanicId, b);
      const busy = await Promise.all([a, b].map(async (u) => (await db().doc(`presence/${u}`).get()).get('activeBookingId')));
      assert.deepEqual(busy, [null, bookingId]);
    });

    it('one mechanic accepting two bookings at once gets only one', async () => {
      const m = await seedMechanic({ at: north(AHMEDABAD, 1) });
      const b1 = await seedBooking(AHMEDABAD);
      const b2 = await seedBooking(AHMEDABAD);
      const o1 = await advanceDispatch(b1);
      assert.ok(o1.result === 'offered');
      // Force a second live offer for the same mechanic (the live-offer check normally prevents it).
      const o2 = db().collection('offers').doc();
      const offer1 = await offerOf(o1.offerId);
      await o2.set({ ...offer1, bookingId: b2 });
      await db().doc(`bookings/${b2}`).update({ currentOfferId: o2.id, triedMechanicIds: [m] });

      const results = await Promise.allSettled([
        respondToOffer.run(asMechanic(m, { offerId: o1.offerId, accept: true })),
        respondToOffer.run(asMechanic(m, { offerId: o2.id, accept: true })),
      ]);
      assert.equal(results.filter((r) => r.status === 'fulfilled').length, 1);
      const statuses = [(await bookingOf(b1)).status, (await bookingOf(b2)).status].sort();
      assert.deepEqual(statuses, ['accepted', 'requested']);
    });

    it("rejects someone else's offer the same way as a missing one", async () => {
      await seedMechanic({ at: north(AHMEDABAD, 1) });
      const other = await seedMechanic({ at: north(AHMEDABAD, 20) });
      const { offerId } = await offered();

      const theirs = await rejection(respondToOffer.run(asMechanic(other, { offerId, accept: true })));
      const missing = await rejection(respondToOffer.run(asMechanic(other, { offerId: 'nope', accept: true })));
      assert.deepEqual(theirs, { code: 'failed-precondition', message: 'error_offer_unavailable' });
      assert.deepEqual(missing, theirs);
    });

    it('rejects an expired offer', async () => {
      await seedMechanic({ at: north(AHMEDABAD, 1) });
      const { offerId, mechanicId } = await offered();
      await db().doc(`offers/${offerId}`).update({ expiresAt: new Date(Date.now() - 1000) });
      const err = await rejection(respondToOffer.run(asMechanic(mechanicId, { offerId, accept: true })));
      assert.equal(err.message, 'error_offer_expired');
    });

    it('rejects a mechanic who went offline', async () => {
      await seedMechanic({ at: north(AHMEDABAD, 1) });
      const { offerId, mechanicId } = await offered();
      await db().doc(`presence/${mechanicId}`).update({ isOnline: false });
      const err = await rejection(respondToOffer.run(asMechanic(mechanicId, { offerId, accept: true })));
      assert.equal(err.message, 'error_not_available');
    });

    it('decline moves the booking on to the next mechanic', async () => {
      const a = await seedMechanic({ at: north(AHMEDABAD, 1) });
      const b = await seedMechanic({ at: north(AHMEDABAD, 2) });
      const { bookingId, offerId } = await offered();

      const res = await respondToOffer.run(asMechanic(a, { offerId, accept: false }));
      assert.deepEqual(res, { bookingId, state: 'declined' });
      assert.equal((await offerOf(offerId)).state, 'declined');

      const booking = await bookingOf(bookingId);
      assert.notEqual(booking.currentOfferId, offerId);
      assert.equal((await offerOf(booking.currentOfferId)).mechanicId, b);
    });

    it('rejects mechanics who are not approved', async () => {
      const err = await rejection(
        respondToOffer.run(
          fakeRequest({ uid: 'x', claims: { role: 'mechanic', mechanicStatus: 'pending' }, data: { offerId: 'o', accept: true } }),
        ),
      );
      assert.equal(err.message, 'error_mechanic_not_approved');
    });
  },
);
