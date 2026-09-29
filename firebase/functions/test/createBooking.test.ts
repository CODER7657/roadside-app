import assert from 'node:assert/strict';
import { before, describe, it } from 'node:test';
import { GeoPoint } from 'firebase-admin/firestore';
import { createBooking, type CreateBookingInput } from '../src/callables/createBooking.js';
import { db } from '../src/lib/admin.js';
import { emulatorRunning, fakeRequest, rejection } from './helpers.js';

type Input = Omit<CreateBookingInput, 'description' | 'photoUrls' | 'pinConfirmed' | 'pickup'> &
  Partial<Pick<CreateBookingInput, 'description' | 'photoUrls' | 'pinConfirmed'>> & {
    pickup: { lat: number; lng: number; address: string; accuracyMeters: number };
  };

const CENTRES = {
  ahmedabad: { lat: 23.0225, lng: 72.5714, radiusKm: 25 },
  ankleshwar: { lat: 21.6264, lng: 73.0152, radiusKm: 12 },
  bharuch: { lat: 21.7051, lng: 72.9959, radiusKm: 12 },
} as const;

let seq = 0;
/** A fresh customer with one car, so tests never share an active booking. */
async function newCustomer(): Promise<{ uid: string; claims: { role: string } }> {
  const uid = `cust-${Date.now()}-${++seq}`;
  await db().doc(`users/${uid}/vehicles/v1`).set({
    type: 'car',
    brand: 'Maruti',
    model: 'Swift',
    regNo: 'GJ01AB1234',
    fuel: 'petrol',
    isDefault: true,
  });
  return { uid, claims: { role: 'customer' } };
}

function bookingInput(at: { lat: number; lng: number }, overrides: Partial<Input> = {}): Input {
  return {
    idempotencyKey: `idem-${Date.now()}-${++seq}-xxxxxxxx`,
    vehicleId: 'v1',
    problemType: 'flat_tyre',
    pickup: { lat: at.lat, lng: at.lng, address: 'Test road', accuracyMeters: 15 },
    ...overrides,
  };
}

describe('createBooking (emulator)', { skip: !emulatorRunning && 'no Firestore emulator' }, () => {
  before(async () => {
    const fs = db();
    for (const [id, c] of Object.entries(CENTRES)) {
      await fs.doc(`serviceAreas/${id}`).set({
        name: { en: id, hi: id, gu: id },
        center: new GeoPoint(c.lat, c.lng),
        radiusKm: c.radiusKm,
        active: true,
        supportPhone: '+910000000000',
        launchedAt: null,
      });
    }
    await fs.doc('prices/car_flat_tyre').set({
      vehicleType: 'car',
      problemType: 'flat_tyre',
      min: 300,
      max: 600,
      includes: 'Puncture repair',
      cityOverrides: { bharuch: { min: 400, max: 800 } },
    });
    await fs.doc('appConfig/public').set({ dispatchEnabled: true }, { merge: true });
  });

  it('creates a booking in each of the 3 cities with its OTP', async () => {
    for (const [cityId, c] of Object.entries(CENTRES)) {
      const who = await newCustomer();
      const res = await createBooking.run(fakeRequest({ ...who, data: bookingInput(c) }));
      assert.equal(res.cityId, cityId);

      const booking = (await db().doc(`bookings/${res.bookingId}`).get()).data()!;
      assert.equal(booking.customerId, who.uid);
      assert.equal(booking.status, 'requested');
      assert.equal(booking.cityId, cityId);
      assert.equal(booking.mechanicId, null);
      assert.equal(booking.searchRadiusKm, 3);
      assert.equal(booking.paymentStatus, 'pending');
      assert.equal(booking.pickup.geohash.length, 10);
      assert.deepEqual(booking.vehicle, {
        type: 'car',
        brand: 'Maruti',
        model: 'Swift',
        regNo: 'GJ01AB1234',
      });

      const otp = (await db().doc(`bookings/${res.bookingId}/private/otp`).get()).data()!;
      assert.match(otp.code, /^\d{4}$/);
      assert.equal(otp.attempts, 0);
    }
  });

  it('applies the city price override', async () => {
    const who = await newCustomer();
    const bharuch = await createBooking.run(fakeRequest({ ...who, data: bookingInput(CENTRES.bharuch) }));
    assert.deepEqual(bharuch.priceEstimate, { min: 400, max: 800 });

    const who2 = await newCustomer();
    const ahd = await createBooking.run(fakeRequest({ ...who2, data: bookingInput(CENTRES.ahmedabad) }));
    assert.deepEqual(ahd.priceEstimate, { min: 300, max: 600 });
  });

  it('returns the same booking for a repeated idempotency key', async () => {
    const who = await newCustomer();
    const data = bookingInput(CENTRES.ahmedabad);
    const first = await createBooking.run(fakeRequest({ ...who, data }));
    const again = await createBooking.run(fakeRequest({ ...who, data }));
    assert.equal(again.bookingId, first.bookingId);
  });

  it('rejects a second active booking', async () => {
    const who = await newCustomer();
    const first = await createBooking.run(fakeRequest({ ...who, data: bookingInput(CENTRES.ahmedabad) }));
    try {
      await createBooking.run(fakeRequest({ ...who, data: bookingInput(CENTRES.ahmedabad) }));
      assert.fail('expected rejection');
    } catch (err) {
      const e = err as { code: string; message: string; details: unknown };
      assert.equal(e.code, 'failed-precondition');
      assert.equal(e.message, 'error_active_booking_exists');
      assert.deepEqual(e.details, { bookingId: first.bookingId });
    }
  });

  it('rejects a pickup outside every service area', async () => {
    const who = await newCustomer();
    const surat = { lat: 21.1702, lng: 72.8311 };
    const err = await rejection(createBooking.run(fakeRequest({ ...who, data: bookingInput(surat) })));
    assert.deepEqual(err, { code: 'failed-precondition', message: 'error_out_of_area' });
  });

  it('rejects a pickup in a city that is switched off', async () => {
    await db().doc('serviceAreas/bharuch').update({ active: false });
    try {
      const who = await newCustomer();
      const err = await rejection(
        createBooking.run(fakeRequest({ ...who, data: bookingInput(CENTRES.bharuch) })),
      );
      assert.equal(err.message, 'error_out_of_area');
    } finally {
      await db().doc('serviceAreas/bharuch').update({ active: true });
    }
  });

  it('rejects a vague pickup unless the pin was confirmed', async () => {
    const who = await newCustomer();
    const vague = bookingInput(CENTRES.ahmedabad);
    vague.pickup.accuracyMeters = 250;
    const err = await rejection(createBooking.run(fakeRequest({ ...who, data: vague })));
    assert.equal(err.message, 'error_pickup_not_confirmed');

    const res = await createBooking.run(fakeRequest({ ...who, data: { ...vague, pinConfirmed: true } }));
    assert.equal(res.cityId, 'ahmedabad');
  });

  it("rejects another customer's vehicle", async () => {
    const who = await newCustomer();
    const err = await rejection(
      createBooking.run(
        fakeRequest({ ...who, data: bookingInput(CENTRES.ahmedabad, { vehicleId: 'someone-elses' }) }),
      ),
    );
    assert.deepEqual(err, { code: 'not-found', message: 'error_vehicle_not_found' });
  });

  it('returns "service paused" when dispatch is switched off', async () => {
    await db().doc('appConfig/public').update({ dispatchEnabled: false });
    try {
      const who = await newCustomer();
      const err = await rejection(
        createBooking.run(fakeRequest({ ...who, data: bookingInput(CENTRES.ahmedabad) })),
      );
      assert.deepEqual(err, { code: 'unavailable', message: 'error_service_paused' });
    } finally {
      await db().doc('appConfig/public').update({ dispatchEnabled: true });
    }
  });

  it('rejects client-sent price, status or unknown pickup fields', async () => {
    const who = await newCustomer();
    for (const extra of [
      { priceEstimate: { min: 1, max: 2 } },
      { status: 'completed' },
      { cityId: 'ahmedabad' },
    ]) {
      const err = await rejection(
        createBooking.run(fakeRequest({ ...who, data: { ...bookingInput(CENTRES.ahmedabad), ...extra } })),
      );
      assert.equal(err.code, 'invalid-argument');
    }
    const data = bookingInput(CENTRES.ahmedabad);
    const err = await rejection(
      createBooking.run(fakeRequest({ ...who, data: { ...data, pickup: { ...data.pickup, geohash: 'x' } } })),
    );
    assert.equal(err.code, 'invalid-argument');
  });

  it('only accepts Firebase Storage photo URLs', async () => {
    const who = await newCustomer();
    const err = await rejection(
      createBooking.run(
        fakeRequest({
          ...who,
          data: bookingInput(CENTRES.ahmedabad, { photoUrls: ['https://evil.example.com/a.jpg'] }),
        }),
      ),
    );
    assert.equal(err.code, 'invalid-argument');

    const ok = await createBooking.run(
      fakeRequest({
        ...who,
        data: bookingInput(CENTRES.ahmedabad, {
          photoUrls: ['https://firebasestorage.googleapis.com/v0/b/x/o/a.jpg'],
        }),
      }),
    );
    assert.equal(ok.cityId, 'ahmedabad');
  });

  it('rejects mechanics', async () => {
    const err = await rejection(
      createBooking.run(
        fakeRequest({ uid: 'm-1', claims: { role: 'mechanic' }, data: bookingInput(CENTRES.ahmedabad) }),
      ),
    );
    assert.equal(err.code, 'permission-denied');
  });
});
