import assert from 'node:assert/strict';
import { beforeEach, describe, it } from 'node:test';
import { Timestamp } from 'firebase-admin/firestore';
import { emulatorRunning } from './helpers.js';
import { advanceDispatch, setDispatchDeps } from '../src/dispatch/advance.js';
import { db } from '../src/lib/admin.js';
import {
  AHMEDABAD,
  ANKLESHWAR,
  BHARUCH,
  bookingOf,
  north,
  offerOf,
  resetEmulators,
  seedBooking,
  seedMechanic,
} from './dispatchFixtures.js';

const pushes: string[] = [];
const timers: string[] = [];
setDispatchDeps({
  notifyOffer: async (mechanicId) => void pushes.push(mechanicId),
  scheduleTimeout: async (bookingId) => void timers.push(bookingId),
  notifyOfferWithdrawn: async () => {},
});

describe('advanceDispatch (emulator)', { skip: !emulatorRunning && 'no Firestore emulator' }, () => {
  beforeEach(async () => {
    await resetEmulators();
    pushes.length = 0;
    timers.length = 0;
  });

  it('offers the nearest eligible mechanic within 3 km, then pushes and starts the timer', async () => {
    const far = await seedMechanic({ at: north(AHMEDABAD, 2.5) });
    const near = await seedMechanic({ at: north(AHMEDABAD, 1) });
    const bookingId = await seedBooking(AHMEDABAD);

    const res = await advanceDispatch(bookingId);
    assert.equal(res.result, 'offered');
    assert.ok(res.result === 'offered' && res.mechanicId === near && res.radiusKm === 3);
    assert.notEqual(far, near);
    assert.deepEqual(pushes, [near]);
    assert.deepEqual(timers, [bookingId]);

    const booking = await bookingOf(bookingId);
    assert.equal(booking.currentOfferId, res.offerId);
    assert.deepEqual(booking.triedMechanicIds, [near]);

    const offer = await offerOf(res.offerId);
    assert.equal(offer.state, 'pending');
    assert.equal(offer.mechanicId, near);
    assert.equal(offer.distanceKm, 1);
    assert.equal(offer.areaName, 'Ahmedabad');
    assert.equal(offer.regNo, 'GJ01AB1234');
    assert.deepEqual(offer.priceEstimate, { min: 300, max: 600 });
    const expiresIn = (offer.expiresAt as Timestamp).toMillis() - Date.now();
    assert.ok(expiresIn > 25_000 && expiresIn <= 30_000);
    // Nothing before accept may reveal the exact place or the customer.
    const json = JSON.stringify(offer);
    for (const secret of ['Secret Street', 'temple', 'customerId', 'geopoint', '23.02']) {
      assert.ok(!json.includes(secret), `offer leaks ${secret}`);
    }
  });

  it('skips ineligible mechanics and ignores mechanicType', async () => {
    await seedMechanic({ at: north(AHMEDABAD, 0.2), status: 'pending' });
    await seedMechanic({ at: north(AHMEDABAD, 0.3), online: false });
    await seedMechanic({ at: north(AHMEDABAD, 0.4), activeBookingId: 'busy' });
    await seedMechanic({ at: north(AHMEDABAD, 0.5), presenceAgeMs: 5 * 60_000 });
    await seedMechanic({ at: north(AHMEDABAD, 0.6), vehicleTypes: ['bike'] });
    await seedMechanic({ at: north(AHMEDABAD, 0.7), services: ['battery'] });
    const ok = await seedMechanic({ at: north(AHMEDABAD, 0.9), mechanicType: 'independent' });

    const res = await advanceDispatch(await seedBooking(AHMEDABAD));
    assert.ok(res.result === 'offered' && res.mechanicId === ok);
  });

  it('is a no-op while the current offer is live', async () => {
    await seedMechanic({ at: north(AHMEDABAD, 1) });
    await seedMechanic({ at: north(AHMEDABAD, 2) });
    const bookingId = await seedBooking(AHMEDABAD);
    const first = await advanceDispatch(bookingId);
    const again = await advanceDispatch(bookingId);
    assert.ok(first.result === 'offered');
    assert.deepEqual(again, { result: 'waiting', offerId: first.offerId });
  });

  it('expires an unanswered offer after 30 s and moves to the next mechanic', async () => {
    const a = await seedMechanic({ at: north(AHMEDABAD, 1) });
    const b = await seedMechanic({ at: north(AHMEDABAD, 2) });
    const bookingId = await seedBooking(AHMEDABAD);
    const first = await advanceDispatch(bookingId);
    assert.ok(first.result === 'offered' && first.mechanicId === a);

    const second = await advanceDispatch(bookingId, Date.now() + 31_000);
    assert.ok(second.result === 'offered' && second.mechanicId === b);
    assert.equal((await offerOf(first.offerId)).state, 'expired');
    assert.deepEqual((await bookingOf(bookingId)).triedMechanicIds, [a, b]);
  });

  it('widens 3 → 5 → 10 km', async () => {
    const at4 = await seedMechanic({ at: north(AHMEDABAD, 4) });
    const at8 = await seedMechanic({ at: north(AHMEDABAD, 8) });
    const bookingId = await seedBooking(AHMEDABAD);

    const r1 = await advanceDispatch(bookingId);
    assert.ok(r1.result === 'offered' && r1.mechanicId === at4 && r1.radiusKm === 5);
    const r2 = await advanceDispatch(bookingId, Date.now() + 31_000);
    assert.ok(r2.result === 'offered' && r2.mechanicId === at8 && r2.radiusKm === 10);
    assert.equal((await bookingOf(bookingId)).searchRadiusKm, 10);
  });

  it('marks no_mechanic_found when nobody is left at 10 km', async () => {
    await seedMechanic({ at: north(AHMEDABAD, 12) }); // too far
    const bookingId = await seedBooking(AHMEDABAD);
    assert.deepEqual(await advanceDispatch(bookingId), { result: 'no_mechanic_found' });

    const booking = await bookingOf(bookingId);
    assert.equal(booking.status, 'no_mechanic_found');
    assert.equal(booking.currentOfferId, null);
    assert.equal(booking.statusHistory.at(-1).by, 'system');
    assert.deepEqual(await advanceDispatch(bookingId), { result: 'inactive' });
  });

  it('cross-matches Ankleshwar ↔ Bharuch only once the radius reaches 10 km', async () => {
    // A Bharuch mechanic 4 km from an Ankleshwar pickup: not offered at 3 or 5 km.
    const bharuchMech = await seedMechanic({ at: north(ANKLESHWAR, 4), cityId: 'bharuch' });
    const bookingId = await seedBooking(ANKLESHWAR, 'ankleshwar');
    const res = await advanceDispatch(bookingId);
    assert.ok(res.result === 'offered' && res.mechanicId === bharuchMech && res.radiusKm === 10);
  });

  it('never cross-matches Ahmedabad', async () => {
    await seedMechanic({ at: north(AHMEDABAD, 1), cityId: 'bharuch' });
    assert.deepEqual(await advanceDispatch(await seedBooking(AHMEDABAD)), { result: 'no_mechanic_found' });
  });

  it("doesn't offer a mechanic who is already looking at another offer", async () => {
    const busy = await seedMechanic({ at: north(BHARUCH, 1), cityId: 'bharuch' });
    const free = await seedMechanic({ at: north(BHARUCH, 2), cityId: 'bharuch' });
    const b1 = await advanceDispatch(await seedBooking(BHARUCH, 'bharuch'));
    const b2 = await advanceDispatch(await seedBooking(BHARUCH, 'bharuch'));
    assert.ok(b1.result === 'offered' && b1.mechanicId === busy);
    assert.ok(b2.result === 'offered' && b2.mechanicId === free);
  });

  it('never creates two offers when the timer and the sweep run at once', async () => {
    await seedMechanic({ at: north(AHMEDABAD, 1) });
    await seedMechanic({ at: north(AHMEDABAD, 2) });
    await seedMechanic({ at: north(AHMEDABAD, 3) });
    const bookingId = await seedBooking(AHMEDABAD);
    await advanceDispatch(bookingId);

    const later = Date.now() + 31_000;
    const results = await Promise.all([advanceDispatch(bookingId, later), advanceDispatch(bookingId, later)]);
    const offered = results.filter((r) => r.result === 'offered');
    assert.equal(offered.length, 1, JSON.stringify(results));

    const pending = await db()
      .collection('offers')
      .where('bookingId', '==', bookingId)
      .where('state', '==', 'pending')
      .get();
    assert.equal(pending.size, 1);
  });

  it('leaves bookings that are no longer requested alone', async () => {
    await seedMechanic({ at: north(AHMEDABAD, 1) });
    const bookingId = await seedBooking(AHMEDABAD, 'ahmedabad', { status: 'cancelled' });
    assert.deepEqual(await advanceDispatch(bookingId), { result: 'inactive' });
  });
});
