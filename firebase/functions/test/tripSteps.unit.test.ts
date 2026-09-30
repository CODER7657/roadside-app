import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { GeoPoint, Timestamp } from 'firebase-admin/firestore';
import { arrivalRadiusM, assertNearPickup, LIVE_LOCATION_MAX_AGE_MS } from '../src/callables/tripSteps.js';
import type { BookingDoc, LiveLocationDoc } from '../src/models/documents.js';

const PICKUP = { lat: 23.0225, lng: 72.5714 };
const now = 1_790_000_000_000;

function booking(accuracyMeters = 10): BookingDoc {
  return { pickup: { geopoint: new GeoPoint(PICKUP.lat, PICKUP.lng), accuracyMeters } } as BookingDoc;
}

/** Mechanic `metres` north of the pickup, reported `ageMs` ago. */
function live(metres: number, ageMs = 5_000): LiveLocationDoc {
  return {
    mechanicGeopoint: new GeoPoint(PICKUP.lat + metres / 111_195, PICKUP.lng),
    updatedAt: Timestamp.fromMillis(now - ageMs),
  } as LiveLocationDoc;
}

const code = (fn: () => void): string | null => {
  try {
    fn();
    return null;
  } catch (err) {
    return (err as { message: string }).message;
  }
};

describe('arrival radius (PLAN §9)', () => {
  it('is 100 m, or 200 m when the pickup fix was poor', () => {
    assert.equal(arrivalRadiusM(10), 100);
    assert.equal(arrivalRadiusM(100), 100);
    assert.equal(arrivalRadiusM(101), 200);
  });

  it('accepts a mechanic within 100 m', () => {
    assert.equal(code(() => assertNearPickup(booking(), live(95), now)), null);
  });

  it('rejects a mechanic 150 m away from a precise pickup', () => {
    assert.equal(code(() => assertNearPickup(booking(), live(150), now)), 'error_not_at_pickup');
  });

  it('accepts 150 m when the pickup accuracy was poor, but not 250 m', () => {
    assert.equal(code(() => assertNearPickup(booking(150), live(150), now)), null);
    assert.equal(code(() => assertNearPickup(booking(150), live(250), now)), 'error_not_at_pickup');
  });

  it('needs a fresh reported position', () => {
    assert.equal(code(() => assertNearPickup(booking(), undefined, now)), 'error_location_unavailable');
    assert.equal(
      code(() => assertNearPickup(booking(), live(10, LIVE_LOCATION_MAX_AGE_MS + 1000), now)),
      'error_location_unavailable',
    );
  });
});
