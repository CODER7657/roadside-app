import assert from 'node:assert/strict';
import { beforeEach, describe, it } from 'node:test';
import { emulatorRunning } from './helpers.js';
import { handleBookingChange, setNotifyDeps } from '../src/notifications/onBookingStatusChange.js';
import type { BookingState, Notice } from '../src/notifications/rules.js';
import { db } from '../src/lib/admin.js';
import { resetEmulators } from './dispatchFixtures.js';

const sent: Array<{ token: string; type: string; bookingId: string }> = [];
let failPush = false;
setNotifyDeps({
  push: async (token: string, n: Notice, bookingId: string) => {
    if (failPush) throw Object.assign(new Error('push failed'), { code: 'messaging/internal-error' });
    sent.push({ token, type: n.type, bookingId });
  },
});

const base: BookingState = {
  status: 'arriving',
  customerId: 'cust-1',
  mechanicId: 'mech-1',
  paymentStatus: 'pending',
  finalAmount: null,
  cancelledBy: null,
};

async function inbox(uid: string) {
  return (await db().collection(`inbox/${uid}/items`).get()).docs.map((d) => d.data());
}

describe('onBookingStatusChange (emulator)', { skip: !emulatorRunning && 'no Firestore emulator' }, () => {
  beforeEach(async () => {
    await resetEmulators();
    sent.length = 0;
    failPush = false;
    await db().doc('users/cust-1').set({ name: 'Priya', fcmToken: 'cust-token' });
    await db().doc('mechanics/mech-1').set({ name: 'Ramesh', fcmToken: 'mech-token' });
  });

  it('writes an inbox item for the other side and pushes to them', async () => {
    const n = await handleBookingChange('evt-1', 'b-1', base, { ...base, status: 'arrived' });
    assert.equal(n, 1);

    const [item] = await inbox('cust-1');
    assert.equal(item!.type, 'booking_arrived');
    assert.equal(item!.titleKey, 'notif_booking_arrived_title');
    assert.equal(item!.bodyKey, 'notif_booking_arrived_body');
    assert.equal(item!.bookingId, 'b-1');
    assert.equal(item!.read, false);
    assert.equal(item!.schemaVersion, 1);
    assert.ok(item!.createdAt);
    assert.deepEqual(await inbox('mech-1'), []);

    assert.deepEqual(sent, [{ token: 'cust-token', type: 'booking_arrived', bookingId: 'b-1' }]);
  });

  it('never notifies twice when the trigger is retried', async () => {
    const after = { ...base, status: 'arrived' as const };
    await handleBookingChange('evt-2', 'b-1', base, after);
    const again = await handleBookingChange('evt-2', 'b-1', base, after);
    assert.equal(again, 0);
    assert.equal((await inbox('cust-1')).length, 1);
    assert.equal(sent.length, 1);
  });

  it('notifies both sides when an admin cancels', async () => {
    await handleBookingChange('evt-3', 'b-1', base, { ...base, status: 'cancelled', cancelledBy: 'admin' });
    assert.equal((await inbox('cust-1')).length, 1);
    assert.equal((await inbox('mech-1')).length, 1);
    assert.deepEqual(sent.map((s) => s.token).sort(), ['cust-token', 'mech-token']);
  });

  it('keeps the inbox item when there is no token or the push fails', async () => {
    await db().doc('users/cust-1').update({ fcmToken: null });
    await handleBookingChange('evt-4', 'b-1', base, { ...base, status: 'arrived' });
    assert.equal((await inbox('cust-1')).length, 1);
    assert.equal(sent.length, 0);

    failPush = true;
    await handleBookingChange('evt-5', 'b-2', { ...base, status: 'accepted' }, base);
    assert.equal((await inbox('cust-1')).length, 2);
  });

  it('does nothing for updates that change no status', async () => {
    assert.equal(await handleBookingChange('evt-6', 'b-1', base, { ...base }), 0);
    assert.deepEqual(await inbox('cust-1'), []);
  });
});
