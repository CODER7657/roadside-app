import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { GeoPoint } from 'firebase-admin/firestore';
import {
  buildSharedTrip,
  coarse,
  firstName,
  newShareToken,
  TOKEN_PATTERN,
} from '../src/share/shareLinks.js';
import { clientKey, escapeHtml, pickLang, renderGone, renderTrip } from '../src/share/sharePage.js';

const card = { name: 'Ramesh Kumar Patel', phone: '+919999999999', upiId: 'r@okaxis' } as never;
const live = { mechanicGeopoint: new GeoPoint(23.022512, 72.571398), etaMinutes: 7.4 };

describe('share tokens', () => {
  it('are 128-bit, url-safe and unique', () => {
    const tokens = new Set(Array.from({ length: 1000 }, newShareToken));
    assert.equal(tokens.size, 1000);
    for (const t of tokens) assert.match(t, TOKEN_PATTERN);
    assert.equal(Buffer.from([...tokens][0]!, 'base64url').length, 16);
  });
});

describe('buildSharedTrip', () => {
  it('shows first name, ETA and a coarse position while on the way', () => {
    assert.deepEqual(buildSharedTrip({ status: 'arriving', mechanicCard: card }, live), {
      status: 'arriving',
      mechanicFirstName: 'Ramesh',
      etaMinutes: 7,
      position: { lat: 23.023, lng: 72.571 },
    });
  });

  it('hides position and ETA once the mechanic has arrived', () => {
    const trip = buildSharedTrip({ status: 'arrived', mechanicCard: card }, live);
    assert.equal(trip.position, null);
    assert.equal(trip.etaMinutes, null);
    assert.equal(trip.mechanicFirstName, 'Ramesh');
  });

  it('has no mechanic while still searching', () => {
    assert.deepEqual(buildSharedTrip({ status: 'requested', mechanicCard: null }, undefined), {
      status: 'requested',
      mechanicFirstName: null,
      etaMinutes: null,
      position: null,
    });
  });

  it('never carries phone, UPI, surname or exact coordinates', () => {
    const json = JSON.stringify(buildSharedTrip({ status: 'arriving', mechanicCard: card }, live));
    for (const secret of ['+91', 'okaxis', 'Kumar', 'Patel', '23.0225', '72.5713']) {
      assert.ok(!json.includes(secret), `leaks ${secret}`);
    }
  });
});

describe('helpers', () => {
  it('firstName', () => {
    assert.equal(firstName('  Ramesh  Patel '), 'Ramesh');
    assert.equal(firstName(''), null);
    assert.equal(firstName(undefined), null);
  });

  it('coarse keeps 3 decimals', () => {
    assert.equal(coarse(21.705149), 21.705);
    assert.equal(coarse(-0.0004), -0);
  });

  it('escapeHtml', () => {
    assert.equal(escapeHtml(`<script>"x"&'y'</script>`), '&lt;script&gt;&quot;x&quot;&amp;&#39;y&#39;&lt;/script&gt;');
  });

  it('pickLang: query first, then Accept-Language, then English', () => {
    assert.equal(pickLang('gu', 'hi-IN'), 'gu');
    assert.equal(pickLang(undefined, 'hi-IN,hi;q=0.9,en;q=0.8'), 'hi');
    assert.equal(pickLang('fr', 'fr-FR,de'), 'en');
  });

  it('clientKey hashes the first forwarded address', () => {
    const a = clientKey('203.0.113.9, 10.0.0.1', undefined);
    assert.equal(a, clientKey('203.0.113.9', '10.0.0.2'));
    assert.notEqual(a, clientKey('203.0.113.10', undefined));
    assert.ok(!a.includes('203.0.113.9'));
    assert.match(a, /^share_ip_[0-9a-f]{32}$/);
  });
});

describe('page rendering', () => {
  it('renders the trip in the chosen language, escaped, with auto-refresh', () => {
    const html = renderTrip(
      { status: 'arriving', mechanicFirstName: '<b>Ra</b>', etaMinutes: 7, position: { lat: 23.023, lng: 72.571 } },
      'hi',
    );
    assert.ok(html.includes('<html lang="hi">'));
    assert.ok(html.includes('रास्ते में हैं'));
    assert.ok(html.includes('&lt;b&gt;Ra&lt;/b&gt;'));
    assert.ok(!html.includes('<b>Ra</b>'));
    assert.ok(html.includes('http-equiv="refresh"'));
    assert.ok(html.includes('query=23.023,72.571'));
    assert.ok(!html.includes('<script'));
  });

  it('the expired page has no refresh and no trip data', () => {
    const html = renderGone('gu');
    assert.ok(html.includes('આ લિંક હવે સક્રિય નથી'));
    assert.ok(!html.includes('http-equiv="refresh"'));
  });
});
