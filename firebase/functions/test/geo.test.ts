import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { distanceKm, geohash } from '../src/lib/geo.js';

describe('geo', () => {
  it('measures Ankleshwar ↔ Bharuch at about 9 km', () => {
    const d = distanceKm({ lat: 21.6264, lng: 73.0152 }, { lat: 21.7051, lng: 72.9959 });
    assert.ok(d > 8.5 && d < 9.5, `got ${d}`);
  });

  it('is zero for the same point', () => {
    assert.equal(distanceKm({ lat: 23.0225, lng: 72.5714 }, { lat: 23.0225, lng: 72.5714 }), 0);
  });

  it('encodes known geohashes', () => {
    // Reference values from the original geohash.org algorithm.
    assert.equal(geohash({ lat: 57.64911, lng: 10.40744 }, 11), 'u4pruydqqvj');
    assert.equal(geohash({ lat: 0, lng: 0 }, 5), 's0000');
  });

  it('shares a prefix for nearby points', () => {
    const a = geohash({ lat: 23.0225, lng: 72.5714 });
    const b = geohash({ lat: 23.0226, lng: 72.5715 });
    assert.equal(a.slice(0, 6), b.slice(0, 6));
    assert.equal(a.length, 10);
  });
});
