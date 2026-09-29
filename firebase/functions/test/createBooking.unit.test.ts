import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { claimsForNewUser } from '../src/auth/beforeUserCreated.js';
import {
  bookingIdFor,
  newStartCode,
  priceFor,
  resolveCity,
  type ServiceArea,
} from '../src/callables/createBooking.js';

export const AREAS: ServiceArea[] = [
  { cityId: 'ahmedabad', center: { lat: 23.0225, lng: 72.5714 }, radiusKm: 25, active: true },
  { cityId: 'ankleshwar', center: { lat: 21.6264, lng: 73.0152 }, radiusKm: 12, active: true },
  { cityId: 'bharuch', center: { lat: 21.7051, lng: 72.9959 }, radiusKm: 12, active: true },
];

describe('resolveCity', () => {
  it('finds each city from its centre', () => {
    for (const a of AREAS) assert.equal(resolveCity(a.center, AREAS), a.cityId);
  });

  it('gives an overlap point to the nearer centre', () => {
    // Inside both circles, 2 km from Bharuch and ~7 km from Ankleshwar.
    const nearBharuch = { lat: 21.688, lng: 73.0 };
    assert.equal(resolveCity(nearBharuch, AREAS), 'bharuch');
    const nearAnkleshwar = { lat: 21.64, lng: 73.01 };
    assert.equal(resolveCity(nearAnkleshwar, AREAS), 'ankleshwar');
  });

  it('rejects a pickup outside every circle (Surat)', () => {
    assert.equal(resolveCity({ lat: 21.1702, lng: 72.8311 }, AREAS), null);
  });

  it('rejects a pickup whose city is not active yet', () => {
    const areas = AREAS.map((a) => (a.cityId === 'bharuch' ? { ...a, active: false } : a));
    assert.equal(resolveCity({ lat: 21.7051, lng: 72.9959 }, areas), null);
  });
});

describe('priceFor', () => {
  const price = { min: 300, max: 600, cityOverrides: { bharuch: { min: 400, max: 800 } } };

  it('uses the base price by default', () => {
    assert.deepEqual(priceFor(price, 'ahmedabad'), { min: 300, max: 600 });
  });

  it('uses the city override when there is one', () => {
    assert.deepEqual(priceFor(price, 'bharuch'), { min: 400, max: 800 });
  });
});

describe('bookingIdFor', () => {
  it('is stable for the same caller and key, different otherwise', () => {
    const a = bookingIdFor('u1', 'key-aaaaaaaaaaaaaaaa');
    assert.equal(a, bookingIdFor('u1', 'key-aaaaaaaaaaaaaaaa'));
    assert.notEqual(a, bookingIdFor('u2', 'key-aaaaaaaaaaaaaaaa'));
    assert.notEqual(a, bookingIdFor('u1', 'key-bbbbbbbbbbbbbbbb'));
    assert.match(a, /^[A-Za-z0-9_-]{20}$/);
  });
});

describe('newStartCode', () => {
  it('is always 4 digits', () => {
    for (let i = 0; i < 500; i++) assert.match(newStartCode(), /^\d{4}$/);
  });
});

describe('claimsForNewUser', () => {
  it('makes phone sign-ups customers', () => {
    assert.deepEqual(claimsForNewUser({ phoneNumber: '+910000000000' }), { role: 'customer' });
  });

  it('gives no role to Google (admin) sign-ups', () => {
    assert.deepEqual(claimsForNewUser({ phoneNumber: null }), {});
    assert.deepEqual(claimsForNewUser(undefined), {});
  });
});
