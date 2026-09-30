import assert from 'node:assert/strict';
import { beforeEach, describe, it } from 'node:test';
import { GeoPoint, Timestamp } from 'firebase-admin/firestore';
import { emulatorRunning, fakeRequest, rejection } from './helpers.js';
import { markArrived, startTrip } from '../src/callables/tripSteps.js';
import { db } from '../src/lib/admin.js';
import { AHMEDABAD, bookingOf, north, resetEmulators, seedBooking } from './dispatchFixtures.js';

const asMechanic = (uid: string, data: unknown) =>
  fakeRequest({ uid, claims: { role: 'mechanic', mechanicStatus: 'approved' }, data });

async function assigned(status: string, mechanicId = 'm-1'): Promise<string> {
  return seedBooking(AHMEDABAD, 'ahmedabad', { status, mechanicId });
}

async function reportPosition(bookingId: string, at: { lat: number; lng: number }, ageMs = 3_000) {
  await db().doc(`liveLocations/${bookingId}`).set({
    mechanicGeopoint: new GeoPoint(at.lat, at.lng),
    heading: 0,
    speed: 0,
    etaMinutes: 1,
    updatedAt: Timestamp.fromMillis(Date.now() - ageMs),
    expireAt: Timestamp.fromMillis(Date.now() + 86_400_000),
  });
}

describe('startTrip / markArrived (emulator)', { skip: !emulatorRunning && 'no Firestore emulator' }, () => {
  beforeEach(resetEmulators);

  it('startTrip: accepted → arriving', async () => {
    const bookingId = await assigned('accepted');
    assert.deepEqual(await startTrip.run(asMechanic('m-1', { bookingId })), { bookingId, status: 'arriving' });
    const b = await bookingOf(bookingId);
    assert.equal(b.status, 'arriving');
    assert.ok(b.timestamps.arriving);
    assert.deepEqual(
      { status: b.statusHistory.at(-1).status, by: b.statusHistory.at(-1).by },
      { status: 'arriving', by: 'm-1' },
    );
  });

  it('markArrived near the pickup: arriving → arrived', async () => {
    const bookingId = await assigned('arriving');
    await reportPosition(bookingId, north(AHMEDABAD, 0.05));
    assert.deepEqual(await markArrived.run(asMechanic('m-1', { bookingId })), { bookingId, status: 'arrived' });
    const b = await bookingOf(bookingId);
    assert.equal(b.status, 'arrived');
    assert.ok(b.timestamps.arrived);
  });

  it('markArrived too far away, or without a fresh position, changes nothing', async () => {
    const bookingId = await assigned('arriving');
    await reportPosition(bookingId, north(AHMEDABAD, 0.5));
    assert.equal((await rejection(markArrived.run(asMechanic('m-1', { bookingId })))).message, 'error_not_at_pickup');

    await reportPosition(bookingId, north(AHMEDABAD, 0.02), 45_000); // older than 30 s
    assert.equal(
      (await rejection(markArrived.run(asMechanic('m-1', { bookingId })))).message,
      'error_location_unavailable',
    );
    assert.equal((await bookingOf(bookingId)).status, 'arriving');
  });

  it('follows the §9 table: no skipping ahead, no going back', async () => {
    const accepted = await assigned('accepted');
    await reportPosition(accepted, AHMEDABAD);
    assert.deepEqual(await rejection(markArrived.run(asMechanic('m-1', { bookingId: accepted }))), {
      code: 'failed-precondition',
      message: 'error_invalid_status',
    });
    const arrived = await assigned('arrived');
    assert.equal((await rejection(startTrip.run(asMechanic('m-1', { bookingId: arrived })))).message, 'error_invalid_status');
  });

  it("another mechanic's booking looks like a missing one", async () => {
    const bookingId = await assigned('accepted', 'm-1');
    const theirs = await rejection(startTrip.run(asMechanic('m-2', { bookingId })));
    const missing = await rejection(startTrip.run(asMechanic('m-2', { bookingId: 'nope' })));
    assert.deepEqual(theirs, { code: 'not-found', message: 'error_booking_not_found' });
    assert.deepEqual(missing, theirs);
  });

  it('customers cannot call them', async () => {
    const bookingId = await assigned('accepted');
    const err = await rejection(startTrip.run(fakeRequest({ uid: 'c', claims: { role: 'customer' }, data: { bookingId } })));
    assert.equal(err.code, 'permission-denied');
  });
});
