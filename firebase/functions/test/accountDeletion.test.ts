import assert from 'node:assert/strict';
import { afterEach, beforeEach, describe, it } from 'node:test';
import { getAuth } from 'firebase-admin/auth';
import { GeoPoint, Timestamp } from 'firebase-admin/firestore';
import { authEmulatorRunning, emulatorRunning, fakeRequest, rejection } from './helpers.js';
import { purgePending, setPurgeDeps } from '../src/account/purgeAccounts.js';
import { requestAccountDeletion } from '../src/callables/requestAccountDeletion.js';
import { db } from '../src/lib/admin.js';
import { AHMEDABAD, bookingOf, north, resetEmulators, seedBooking, seedMechanic } from './dispatchFixtures.js';

const REASON = { reason: { code: 'privacy', text: 'no longer needed' } };
const freshAuthTime = () => Math.floor(Date.now() / 1000) - 30;

const call = (uid: string, role: 'customer' | 'mechanic', opts: { authTime?: number; data?: unknown } = {}) =>
  requestAccountDeletion.run(
    fakeRequest({
      uid,
      claims: {
        role,
        ...(role === 'mechanic' ? { mechanicStatus: 'approved' } : {}),
        auth_time: opts.authTime ?? freshAuthTime(),
      },
      data: opts.data ?? REASON,
    }),
  );

const deletedPrefixes: string[] = [];

/** A customer with a profile, a vehicle and a finished booking (with chat, review, share link). */
async function customerWithHistory() {
  const bookingId = await seedBooking(AHMEDABAD, 'ahmedabad', {
    status: 'completed',
    description: 'Front left tyre, near my house',
    photoUrls: ['https://example.test/draft.jpg'],
    customerCard: { name: 'Priya', phone: '+919000000002' },
  });
  const customerId = (await bookingOf(bookingId)).customerId as string;
  const fs = db();
  await fs.doc(`users/${customerId}`).set({ name: 'Priya', phone: '+919000000002', emergencyContacts: [] });
  await fs.doc(`users/${customerId}/vehicles/v-1`).set({ type: 'car', regNo: 'GJ01AB1234' });
  await fs.doc(`bookings/${bookingId}/private/otp`).set({ code: '1234', attempts: 0, lockedUntil: null });
  await fs.doc(`bookings/${bookingId}/messages/msg-1`).set({ senderId: customerId, text: 'Blue gate' });
  await fs.doc(`liveLocations/${bookingId}`).set({ etaMinutes: 3 });
  await fs.doc(`reviews/${bookingId}`).set({ customerId, stars: 5, tags: ['on_time'], comment: 'Ask for Priya' });
  await fs.doc('shareLinks/tok-1').set({ bookingId, createdBy: customerId });
  return { customerId, bookingId };
}

describe(
  'requestAccountDeletion (emulator)',
  { skip: !(emulatorRunning && authEmulatorRunning) && 'no Firestore/Auth emulator' },
  () => {
    beforeEach(async () => {
      await resetEmulators();
      deletedPrefixes.length = 0;
      setPurgeDeps({ deleteFiles: async (prefix) => void deletedPrefixes.push(prefix) });
    });
    afterEach(() => setPurgeDeps(null));

    it('customer: marks the profile, disables sign-in and revokes sessions', async () => {
      const { customerId } = await customerWithHistory();
      const result = await call(customerId, 'customer');
      assert.ok(Date.parse(result.requestedAt) > 0);

      const profile = await db().doc(`users/${customerId}`).get();
      assert.ok(profile.get('deletionRequestedAt') instanceof Timestamp);
      const user = await getAuth().getUser(customerId);
      assert.equal(user.disabled, true, "can't sign in again");
      assert.ok(user.tokensValidAfterTime, 'refresh tokens revoked');
    });

    it('mechanic: marks the profile and goes offline', async () => {
      const mechanicId = await seedMechanic({ at: north(AHMEDABAD, 1), online: true });
      await call(mechanicId, 'mechanic');
      assert.ok((await db().doc(`mechanics/${mechanicId}`).get()).get('deletionRequestedAt') instanceof Timestamp);
      assert.equal((await db().doc(`presence/${mechanicId}`).get()).get('isOnline'), false);
      assert.equal((await getAuth().getUser(mechanicId)).disabled, true);
    });

    it('a second request keeps the first time', async () => {
      const { customerId } = await customerWithHistory();
      const first = await call(customerId, 'customer');
      const second = await call(customerId, 'customer');
      assert.equal(second.requestedAt, first.requestedAt);
    });

    it('a stale sign-in must sign in again first', async () => {
      const { customerId } = await customerWithHistory();
      const err = await rejection(call(customerId, 'customer', { authTime: freshAuthTime() - 10 * 60 }));
      assert.deepEqual(err, { code: 'failed-precondition', message: 'error_reauth_required' });
      assert.equal((await db().doc(`users/${customerId}`).get()).get('deletionRequestedAt'), undefined);
      assert.equal((await getAuth().getUser(customerId)).disabled, false);
    });

    it('refused while a booking is active, for either side', async () => {
      const mechanicId = await seedMechanic({ at: north(AHMEDABAD, 1) });
      const bookingId = await seedBooking(AHMEDABAD, 'ahmedabad', { status: 'arriving', mechanicId });
      const customerId = (await bookingOf(bookingId)).customerId as string;
      for (const [uid, role] of [
        [customerId, 'customer'],
        [mechanicId, 'mechanic'],
      ] as const) {
        const err = await rejection(call(uid, role));
        assert.deepEqual(err, { code: 'failed-precondition', message: 'error_active_booking' }, role);
      }
    });

    it('rejects unauthenticated calls, admins and unknown input', async () => {
      const unauth = await rejection(requestAccountDeletion.run(fakeRequest({ data: REASON })));
      assert.equal(unauth.code, 'unauthenticated');
      const admin = await rejection(
        requestAccountDeletion.run(
          fakeRequest({ uid: 'a-1', claims: { role: 'admin', auth_time: freshAuthTime() }, data: REASON }),
        ),
      );
      assert.equal(admin.code, 'permission-denied');
      const { customerId } = await customerWithHistory();
      for (const bad of [{}, { reason: { code: 'Privacy!' } }, { reason: { code: 'other', text: 'x'.repeat(301) } }]) {
        assert.equal((await rejection(call(customerId, 'customer', { data: bad }))).code, 'invalid-argument');
      }
    });

    it('purge: a customer is erased; their booking stays, anonymised', async () => {
      const { customerId, bookingId } = await customerWithHistory();
      await call(customerId, 'customer');
      assert.deepEqual(await purgePending(), { purged: 1, failed: 0 });

      const fs = db();
      assert.equal((await fs.doc(`users/${customerId}`).get()).exists, false);
      assert.equal((await fs.doc(`users/${customerId}/vehicles/v-1`).get()).exists, false);
      assert.deepEqual(deletedPrefixes, [`users/${customerId}/`]);
      await assert.rejects(getAuth().getUser(customerId), /user-not-found|no user record/i);

      const b = await bookingOf(bookingId);
      assert.equal(b.customerCard, null);
      assert.equal(b.description, '');
      assert.deepEqual(b.photoUrls, []);
      assert.equal(b.pickup.address, '');
      assert.equal(b.pickup.landmark, '');
      assert.equal((b.pickup.geopoint as GeoPoint).latitude, Math.round(AHMEDABAD.lat * 100) / 100);
      assert.equal(b.status, 'completed', 'the record itself is kept (tax, disputes)');
      assert.equal((await fs.doc(`bookings/${bookingId}/private/otp`).get()).exists, false);
      assert.equal((await fs.doc(`bookings/${bookingId}/messages/msg-1`).get()).exists, false);
      assert.equal((await fs.doc(`liveLocations/${bookingId}`).get()).exists, false);
      assert.equal((await fs.doc('shareLinks/tok-1').get()).exists, false);
      const review = (await fs.doc(`reviews/${bookingId}`).get()).data()!;
      assert.equal(review.comment, '');
      assert.equal(review.stars, 5, "the mechanic's rating stays");

      assert.deepEqual(await purgePending(), { purged: 0, failed: 0 }, 'nothing left to do');
    });

    it('purge: a mechanic becomes a tombstone; KYC stays for its 180-day job', async () => {
      const mechanicId = await seedMechanic({ at: north(AHMEDABAD, 1) });
      const bookingId = await seedBooking(AHMEDABAD, 'ahmedabad', {
        status: 'completed',
        mechanicId,
        mechanicCard: { name: 'Ramesh', phone: '+919000000003', upiId: 'r@okaxis', upiName: 'Ramesh', rating: 4.6 },
      });
      await db().doc('offers/o-1').set({ mechanicId, bookingId, state: 'expired' });
      await call(mechanicId, 'mechanic');
      assert.deepEqual(await purgePending(), { purged: 1, failed: 0 });

      const fs = db();
      const tomb = (await fs.doc(`mechanics/${mechanicId}`).get()).data()!;
      assert.equal(tomb.name, undefined);
      assert.equal(tomb.status, 'blocked');
      assert.ok(tomb.deletionRequestedAt instanceof Timestamp);
      assert.equal((await fs.doc(`mechanics/${mechanicId}/private/kyc`).get()).exists, true, 'PLAN §12.10: 180 days');
      assert.equal((await fs.doc(`presence/${mechanicId}`).get()).exists, false);
      assert.equal((await fs.doc('offers/o-1').get()).exists, false);
      assert.deepEqual(deletedPrefixes, [`mechanics/${mechanicId}/shop/`]);

      const card = (await bookingOf(bookingId)).mechanicCard;
      assert.equal(card.name, '');
      assert.equal(card.phone, '');
      assert.equal(card.upiId, '');
      assert.equal(card.rating, 4.6);

      assert.deepEqual(await purgePending(), { purged: 0, failed: 0 }, 'the tombstone is skipped');
    });
  },
);
