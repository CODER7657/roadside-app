import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { Timestamp } from 'firebase-admin/firestore';
import { buildMechanicCard } from '../src/callables/respondToOffer.js';
import { citiesFor, mechanicOk, presenceOk } from '../src/dispatch/candidates.js';
import { distanceKm, geohash, geohashQueryBounds } from '../src/lib/geo.js';
import type { MechanicDoc, MechanicKycDoc, PresenceDoc } from '../src/models/documents.js';

/** Deterministic pseudo-random numbers so a failure is reproducible. */
function rng(seed: number): () => number {
  return () => ((seed = (seed * 1664525 + 1013904223) % 2 ** 32) / 2 ** 32);
}

describe('geohashQueryBounds', () => {
  const centres = [
    { lat: 23.0225, lng: 72.5714 }, // Ahmedabad
    { lat: 21.6264, lng: 73.0152 }, // Ankleshwar
    { lat: 21.7051, lng: 72.9959 }, // Bharuch
  ];

  for (const radiusKm of [3, 5, 10]) {
    it(`covers every point within ${radiusKm} km`, () => {
      const rand = rng(radiusKm);
      for (const c of centres) {
        const bounds = geohashQueryBounds(c, radiusKm);
        for (let i = 0; i < 2000; i++) {
          // Random point in the bounding square, kept only if inside the circle.
          const p = {
            lat: c.lat + (rand() * 2 - 1) * (radiusKm / 111),
            lng: c.lng + (rand() * 2 - 1) * (radiusKm / 100),
          };
          if (distanceKm(c, p) > radiusKm) continue;
          const h = geohash(p);
          assert.ok(
            bounds.some(([s, e]) => h >= s && h <= e),
            `${radiusKm} km: point ${p.lat},${p.lng} not covered`,
          );
        }
      }
    });
  }

  it('uses at most 9 ranges', () => {
    assert.ok(geohashQueryBounds({ lat: 23.0225, lng: 72.5714 }, 10).length <= 9);
  });
});

describe('citiesFor', () => {
  it('only cross-matches Ankleshwar and Bharuch, and only at 10 km', () => {
    assert.deepEqual(citiesFor('ankleshwar', 5), ['ankleshwar']);
    assert.deepEqual(citiesFor('ankleshwar', 10), ['ankleshwar', 'bharuch']);
    assert.deepEqual(citiesFor('bharuch', 10), ['bharuch', 'ankleshwar']);
    assert.deepEqual(citiesFor('ahmedabad', 10), ['ahmedabad']);
  });
});

describe('presenceOk', () => {
  const now = 1_700_000_000_000;
  const base = {
    isOnline: true,
    activeBookingId: null,
    cityId: 'ahmedabad',
    updatedAt: Timestamp.fromMillis(now - 30_000),
  } as unknown as PresenceDoc;

  it('accepts an online, free, fresh mechanic in the city', () => {
    assert.ok(presenceOk(base, 'm1', ['ahmedabad'], [], now));
  });

  it('rejects offline, busy, stale, other-city and already-tried mechanics', () => {
    assert.ok(!presenceOk({ ...base, isOnline: false }, 'm1', ['ahmedabad'], [], now));
    assert.ok(!presenceOk({ ...base, activeBookingId: 'b9' }, 'm1', ['ahmedabad'], [], now));
    assert.ok(!presenceOk({ ...base, updatedAt: Timestamp.fromMillis(now - 3 * 60_000) }, 'm1', ['ahmedabad'], [], now));
    assert.ok(!presenceOk(base, 'm1', ['bharuch'], [], now));
    assert.ok(!presenceOk(base, 'm1', ['ahmedabad'], ['m1'], now));
  });
});

describe('mechanicOk', () => {
  const booking = { vehicle: { type: 'car' }, problemType: 'battery' } as never;
  const m = { status: 'approved', vehicleTypes: ['car'], services: ['battery'] } as unknown as MechanicDoc;

  it('needs approved + vehicle type + service, and ignores mechanicType', () => {
    assert.ok(mechanicOk({ ...m, mechanicType: 'workshop' }, booking));
    assert.ok(mechanicOk({ ...m, mechanicType: 'independent' }, booking));
    assert.ok(!mechanicOk({ ...m, status: 'pending' }, booking));
    assert.ok(!mechanicOk({ ...m, vehicleTypes: ['bike'] }, booking));
    assert.ok(!mechanicOk({ ...m, services: ['flat_tyre'] }, booking));
    assert.ok(!mechanicOk(undefined, booking));
  });
});

describe('buildMechanicCard', () => {
  const kyc = { upiId: 'ramesh@okaxis', upiName: 'Ramesh' } as MechanicKycDoc;
  const base = { name: 'Ramesh', profilePhotoUrl: 'p', rating: 4.5, jobsCompleted: 12 };

  it('snapshots the shop name for a workshop mechanic', () => {
    const card = buildMechanicCard(
      { ...base, mechanicType: 'workshop', shopName: 'Shree Auto' } as MechanicDoc,
      kyc,
      '+910000000001',
    );
    assert.equal(card.shopName, 'Shree Auto');
    assert.equal(card.experienceYears, null);
    assert.equal(card.travelVehicleRegNo, null);
    assert.equal(card.upiId, 'ramesh@okaxis');
  });

  it('snapshots experience and travel vehicle for an independent mechanic', () => {
    const card = buildMechanicCard(
      {
        ...base,
        mechanicType: 'independent',
        experienceYears: 8,
        travelVehicle: { type: 'bike', regNo: 'GJ16AB1234' },
      } as MechanicDoc,
      kyc,
      '+910000000001',
    );
    assert.equal(card.shopName, null);
    assert.equal(card.experienceYears, 8);
    assert.equal(card.travelVehicleRegNo, 'GJ16AB1234');
  });
});
