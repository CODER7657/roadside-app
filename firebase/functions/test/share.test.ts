import assert from 'node:assert/strict';
import { beforeEach, describe, it } from 'node:test';
import { GeoPoint, Timestamp } from 'firebase-admin/firestore';
import { emulatorRunning, fakeRequest, rejection } from './helpers.js';
import { createShareLink, getSharedTrip, SHARE_LINK_TTL_MS } from '../src/share/shareLinks.js';
import { handleSharePage, PAGE_RATE_LIMIT, type PageRequest } from '../src/share/sharePage.js';
import { db } from '../src/lib/admin.js';
import { AHMEDABAD, bookingOf, resetEmulators, seedBooking } from './dispatchFixtures.js';

const asCustomer = (uid: string, data: unknown) => fakeRequest({ uid, claims: { role: 'customer' }, data });

/** An `arriving` booking with a mechanic card and live location, plus its customer id. */
async function onTheWay(): Promise<{ bookingId: string; customerId: string }> {
  const bookingId = await seedBooking(AHMEDABAD, 'ahmedabad', {
    status: 'arriving',
    mechanicId: 'm-1',
    mechanicCard: { name: 'Ramesh Patel', phone: '+917000000001', upiId: 'r@okaxis' },
  });
  await db().doc(`liveLocations/${bookingId}`).set({
    mechanicGeopoint: new GeoPoint(23.031234, 72.575678),
    heading: 90,
    speed: 8,
    etaMinutes: 6,
    updatedAt: Timestamp.now(),
    expireAt: Timestamp.fromMillis(Date.now() + 86_400_000),
  });
  return { bookingId, customerId: (await bookingOf(bookingId)).customerId as string };
}

interface Captured {
  status: number;
  headers: Record<string, string>;
  body: string;
}

async function openPage(path: string, extra: Partial<PageRequest> = {}): Promise<Captured> {
  const out: Captured = { status: 200, headers: {}, body: '' };
  const res = {
    status(code: number) {
      out.status = code;
      return res;
    },
    set(k: string, v: string) {
      out.headers[k.toLowerCase()] = v;
      return res;
    },
    send(body: string) {
      out.body = body;
    },
  };
  await handleSharePage(
    { method: 'GET', path, query: {}, headers: { 'x-forwarded-for': `198.51.100.${Math.floor(Math.random() * 250)}` }, ...extra },
    res,
  );
  return out;
}

describe('share links (emulator)', { skip: !emulatorRunning && 'no Firestore emulator' }, () => {
  beforeEach(resetEmulators);

  it('the customer creates a 3-hour link for their active booking', async () => {
    const { bookingId, customerId } = await onTheWay();
    const before = Date.now();
    const res = await createShareLink.run(asCustomer(customerId, { bookingId }));

    assert.match(res.token, /^[A-Za-z0-9_-]{22}$/);
    assert.equal(res.path, `/t/${res.token}`);
    const expires = Date.parse(res.expiresAt);
    assert.ok(expires >= before + SHARE_LINK_TTL_MS - 1000 && expires <= Date.now() + SHARE_LINK_TTL_MS);

    const link = (await db().doc(`shareLinks/${res.token}`).get()).data()!;
    assert.equal(link.bookingId, bookingId);
    assert.equal(link.createdBy, customerId);
  });

  it("rejects someone else's booking and finished bookings", async () => {
    const { bookingId } = await onTheWay();
    const theirs = await rejection(createShareLink.run(asCustomer('stranger', { bookingId })));
    assert.deepEqual(theirs, { code: 'not-found', message: 'error_booking_not_found' });

    const done = await seedBooking(AHMEDABAD, 'ahmedabad', { status: 'completed' });
    const owner = (await bookingOf(done)).customerId as string;
    const err = await rejection(createShareLink.run(asCustomer(owner, { bookingId: done })));
    assert.deepEqual(err, { code: 'failed-precondition', message: 'error_booking_not_active' });
  });

  it('the link works during the job and stops working the moment it ends', async () => {
    const { bookingId, customerId } = await onTheWay();
    const { token } = await createShareLink.run(asCustomer(customerId, { bookingId }));

    assert.deepEqual(await getSharedTrip(token), {
      status: 'arriving',
      mechanicFirstName: 'Ramesh',
      etaMinutes: 6,
      position: { lat: 23.031, lng: 72.576 },
    });

    await db().doc(`bookings/${bookingId}`).update({ status: 'completed' });
    assert.equal(await getSharedTrip(token), null);
  });

  it('stops working after 3 hours even if the job is still going', async () => {
    const { bookingId, customerId } = await onTheWay();
    const { token } = await createShareLink.run(asCustomer(customerId, { bookingId }));
    assert.equal(await getSharedTrip(token, Date.now() + SHARE_LINK_TTL_MS + 1000), null);
  });

  it('unknown and malformed tokens get nothing', async () => {
    assert.equal(await getSharedTrip('AAAAAAAAAAAAAAAAAAAAAA'), null);
    assert.equal(await getSharedTrip('../../bookings/x'), null);
  });

  describe('the page', () => {
    it('shows the trip with safe headers and no private data', async () => {
      const { bookingId, customerId } = await onTheWay();
      const { token } = await createShareLink.run(asCustomer(customerId, { bookingId }));

      const page = await openPage(`/t/${token}`, { query: { lang: 'en' } });
      assert.equal(page.status, 200);
      assert.ok(page.body.includes('Ramesh is on the way'));
      assert.ok(page.body.includes('About 6 min away'));
      for (const secret of ['Patel', '+91', 'okaxis', 'Secret Street', 'temple', '23.0312', token]) {
        assert.ok(!page.body.includes(secret), `page leaks ${secret}`);
      }
      assert.equal(page.headers['cache-control'], 'no-store, private');
      assert.equal(page.headers['x-robots-tag'], 'noindex, nofollow');
      assert.equal(page.headers['referrer-policy'], 'no-referrer');
      assert.ok(page.headers['content-security-policy']!.includes("default-src 'none'"));
    });

    it('unknown, malformed and ended links all get the same 410 page', async () => {
      const { bookingId, customerId } = await onTheWay();
      const { token } = await createShareLink.run(asCustomer(customerId, { bookingId }));
      await db().doc(`bookings/${bookingId}`).update({ status: 'cancelled' });

      const ended = await openPage(`/t/${token}`);
      const unknown = await openPage('/t/AAAAAAAAAAAAAAAAAAAAAA');
      const malformed = await openPage('/t/<script>');
      const noToken = await openPage('/');
      for (const p of [ended, unknown, malformed, noToken]) {
        assert.equal(p.status, 410);
        assert.equal(p.body, ended.body);
      }
    });

    it('only allows GET and HEAD', async () => {
      assert.equal((await openPage('/t/x', { method: 'POST' })).status, 405);
    });

    it('rate-limits one client', async () => {
      const client = { headers: { 'x-forwarded-for': '192.0.2.77' } };
      for (let i = 0; i < PAGE_RATE_LIMIT.max; i++) await openPage('/t/AAAAAAAAAAAAAAAAAAAAAA', client);
      const blocked = await openPage('/t/AAAAAAAAAAAAAAAAAAAAAA', client);
      assert.equal(blocked.status, 429);
      assert.equal(blocked.headers['retry-after'], String(PAGE_RATE_LIMIT.windowSeconds));
      // A different client is unaffected.
      assert.equal((await openPage('/t/AAAAAAAAAAAAAAAAAAAAAA', { headers: { 'x-forwarded-for': '192.0.2.78' } })).status, 410);
    });
  });
});
