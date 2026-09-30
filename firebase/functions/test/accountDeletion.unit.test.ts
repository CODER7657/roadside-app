import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { GeoPoint } from 'firebase-admin/firestore';
import { anonymisedForCustomer, anonymisedForMechanic, coarse } from '../src/account/purgeAccounts.js';
import { REAUTH_WINDOW_SECONDS, isFreshSignIn, profilePath } from '../src/callables/requestAccountDeletion.js';

describe('requestAccountDeletion helpers', () => {
  const now = Date.UTC(2026, 8, 30, 12);
  const secondsAgo = (s: number) => now / 1000 - s;

  it('a sign-in within 5 minutes is fresh; older, missing or odd auth_time is not', () => {
    assert.equal(isFreshSignIn(secondsAgo(10), now), true);
    assert.equal(isFreshSignIn(secondsAgo(REAUTH_WINDOW_SECONDS), now), true);
    assert.equal(isFreshSignIn(secondsAgo(REAUTH_WINDOW_SECONDS + 1), now), false);
    assert.equal(isFreshSignIn(secondsAgo(-30), now), true, 'small clock skew is fine');
    assert.equal(isFreshSignIn(secondsAgo(-3600), now), false, 'a token from the future is not');
    for (const odd of [undefined, null, '1790000000', Number.NaN]) {
      assert.equal(isFreshSignIn(odd, now), false, String(odd));
    }
  });

  it("each role's profile is where deletionRequestedAt lives", () => {
    assert.equal(profilePath('customer', 'u-1'), 'users/u-1');
    assert.equal(profilePath('mechanic', 'm-1'), 'mechanics/m-1');
  });
});

describe('purge helpers', () => {
  it('rounds a pickup to ~1 km', () => {
    const p = coarse(new GeoPoint(23.022505, 72.571362));
    assert.equal(p.latitude, 23.02);
    assert.equal(p.longitude, 72.57);
  });

  it("blanks everything personal on a customer's booking", () => {
    const update = anonymisedForCustomer({
      pickup: {
        geopoint: new GeoPoint(23.022505, 72.571362),
        geohash: 'tsmxxxxxxx',
        address: '12 Secret Street',
        landmark: 'Near temple',
        plusCode: '7JJQ2HHC+2H',
        accuracyMeters: 10,
      },
    });
    assert.equal(update.customerCard, null);
    assert.equal(update.description, '');
    assert.deepEqual(update.photoUrls, []);
    assert.equal(update['pickup.address'], '');
    assert.equal(update['pickup.landmark'], '');
    assert.equal(update['pickup.plusCode'], '');
    assert.equal(update['vehicle.regNo'], '');
    assert.equal(update['vehicle.brand'], '');
    assert.equal(update['vehicle.model'], '');
    assert.equal(update['vehicle.type'], undefined, 'the type stays');
    assert.deepEqual(update.beforePhotoUrls, []);
    assert.deepEqual(update.afterPhotoUrls, []);
    assert.equal((update['pickup.geohash'] as string).length, 5);
    assert.equal((update['pickup.geopoint'] as GeoPoint).latitude, 23.02);
  });

  it("blanks the mechanic card's personal fields and keeps the rest", () => {
    const update = anonymisedForMechanic();
    for (const f of ['name', 'photoUrl', 'phone', 'upiId', 'upiName']) {
      assert.equal(update[`mechanicCard.${f}`], '', f);
    }
    assert.equal(update['mechanicCard.shopName'], null);
    assert.equal(update['mechanicCard.travelVehicleRegNo'], null);
    assert.equal(update['mechanicCard.rating'], undefined, 'rating stays');
  });
});
