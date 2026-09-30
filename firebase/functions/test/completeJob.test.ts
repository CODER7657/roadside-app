import assert from 'node:assert/strict';
import { beforeEach, describe, it } from 'node:test';
import { GeoPoint, Timestamp } from 'firebase-admin/firestore';
import { emulatorRunning, fakeRequest, rejection } from './helpers.js';
import { completeJob, LIVE_LOCATION_TTL_MS } from '../src/callables/completeJob.js';
import { confirmPayment, disputePayment, markPaid } from '../src/callables/payments.js';
import { db } from '../src/lib/admin.js';
import { AHMEDABAD, bookingOf, north, resetEmulators, seedBooking, seedMechanic } from './dispatchFixtures.js';

const asMechanic = (uid: string, data: unknown) =>
  fakeRequest({ uid, claims: { role: 'mechanic', mechanicStatus: 'approved' }, data });
const asCustomer = (uid: string, data: unknown) => fakeRequest({ uid, claims: { role: 'customer' }, data });

const photo = (bookingId: string, name = 'after-1.jpg') =>
  `https://firebasestorage.googleapis.com/v0/b/roadside-dev.appspot.com/o/${encodeURIComponent(`bookings/${bookingId}/work/${name}`)}?alt=media&token=t`;

/** A booking at `status` for a seeded mechanic who is busy with it; estimate ₹300–600. */
async function job(status = 'in_progress', extra: Record<string, unknown> = {}) {
  const mechanicId = await seedMechanic({ at: north(AHMEDABAD, 1) });
  const bookingId = await seedBooking(AHMEDABAD, 'ahmedabad', { status, mechanicId, paymentStatus: 'pending', ...extra });
  await db().doc(`presence/${mechanicId}`).update({ activeBookingId: bookingId });
  await db().doc(`liveLocations/${bookingId}`).set({
    mechanicGeopoint: new GeoPoint(AHMEDABAD.lat, AHMEDABAD.lng),
    heading: 0,
    speed: 0,
    etaMinutes: 0,
    updatedAt: Timestamp.now(),
    expireAt: Timestamp.fromMillis(Date.now() + 7 * 86_400_000),
  });
  const customerId = (await bookingOf(bookingId)).customerId as string;
  return { bookingId, mechanicId, customerId };
}

describe('completeJob (emulator)', { skip: !emulatorRunning && 'no Firestore emulator' }, () => {
  beforeEach(resetEmulators);

  it('in_progress → completed: amount, photos, jobsCompleted, mechanic free, live location expiring', async () => {
    const { bookingId, mechanicId } = await job();
    const before = Date.now();
    const res = await completeJob.run(
      asMechanic(mechanicId, {
        bookingId,
        finalAmount: 450,
        afterPhotoUrls: [photo(bookingId)],
        beforePhotoUrls: [photo(bookingId, 'before-1.jpg')],
      }),
    );
    assert.deepEqual(res, { bookingId, status: 'completed' });

    const b = await bookingOf(bookingId);
    assert.equal(b.status, 'completed');
    assert.equal(b.finalAmount, 450);
    assert.equal(b.paymentStatus, 'pending');
    assert.deepEqual(b.afterPhotoUrls, [photo(bookingId)]);
    assert.ok(b.timestamps.completed);
    assert.equal((await db().doc(`mechanics/${mechanicId}`).get()).get('jobsCompleted'), 26); // seeded at 25
    assert.equal((await db().doc(`presence/${mechanicId}`).get()).get('activeBookingId'), null);
    const expireAt = ((await db().doc(`liveLocations/${bookingId}`).get()).get('expireAt') as Timestamp).toMillis();
    assert.ok(expireAt >= before + LIVE_LOCATION_TTL_MS - 1000 && expireAt <= Date.now() + LIVE_LOCATION_TTL_MS);
  });

  it('an amount outside 0.5×–3× the estimate needs a reason', async () => {
    const { bookingId, mechanicId } = await job();
    const base = { bookingId, afterPhotoUrls: [photo(bookingId)] };
    const err = await rejection(completeJob.run(asMechanic(mechanicId, { ...base, finalAmount: 2500 })));
    assert.deepEqual(err, { code: 'invalid-argument', message: 'error_amount_reason_required' });
    assert.equal((await bookingOf(bookingId)).status, 'in_progress');

    await completeJob.run(
      asMechanic(mechanicId, { ...base, finalAmount: 2500, amountReason: { code: 'extra_parts', text: 'New tyre' } }),
    );
    assert.equal((await bookingOf(bookingId)).finalAmount, 2500);
  });

  it('needs an after photo from this booking’s work folder', async () => {
    const { bookingId, mechanicId } = await job();
    const other = await seedBooking(AHMEDABAD);
    const none = await rejection(completeJob.run(asMechanic(mechanicId, { bookingId, finalAmount: 450, afterPhotoUrls: [] })));
    assert.equal(none.code, 'invalid-argument');
    const foreign = await rejection(
      completeJob.run(asMechanic(mechanicId, { bookingId, finalAmount: 450, afterPhotoUrls: [photo(other)] })),
    );
    assert.deepEqual(foreign, { code: 'invalid-argument', message: 'error_photo_invalid' });
  });

  it('only from in_progress, only by the assigned mechanic', async () => {
    const { bookingId, mechanicId } = await job('arrived');
    const data = { bookingId, finalAmount: 450, afterPhotoUrls: [photo(bookingId)] };
    assert.equal((await rejection(completeJob.run(asMechanic(mechanicId, data)))).message, 'error_invalid_status');
    assert.deepEqual(await rejection(completeJob.run(asMechanic('someone-else', data))), {
      code: 'not-found',
      message: 'error_booking_not_found',
    });
  });
});

describe('payments (emulator)', { skip: !emulatorRunning && 'no Firestore emulator' }, () => {
  beforeEach(resetEmulators);

  it('ends in confirmed: customer marks paid, mechanic confirms', async () => {
    const { bookingId, mechanicId, customerId } = await job('completed', { finalAmount: 450 });
    assert.deepEqual(await markPaid.run(asCustomer(customerId, { bookingId })), {
      bookingId,
      paymentStatus: 'customer_marked_paid',
    });
    assert.deepEqual(await confirmPayment.run(asMechanic(mechanicId, { bookingId })), {
      bookingId,
      paymentStatus: 'confirmed',
    });
    assert.equal((await bookingOf(bookingId)).paymentStatus, 'confirmed');
    // Nothing further once confirmed.
    const late = await rejection(disputePayment.run(asCustomer(customerId, { bookingId, text: 'changed my mind' })));
    assert.equal(late.message, 'error_invalid_payment_status');
  });

  it('ends in disputed: "not received" opens a payment complaint', async () => {
    const { bookingId, mechanicId, customerId } = await job('completed', { finalAmount: 450 });
    await markPaid.run(asCustomer(customerId, { bookingId }));
    const res = await disputePayment.run(asMechanic(mechanicId, { bookingId, text: 'No UPI credit received' }));
    assert.equal(res.paymentStatus, 'disputed');
    assert.ok(res.complaintId);

    assert.equal((await bookingOf(bookingId)).paymentStatus, 'disputed');
    const complaint = (await db().doc(`complaints/${res.complaintId}`).get()).data()!;
    assert.equal(complaint.bookingId, bookingId);
    assert.equal(complaint.raisedBy, mechanicId);
    assert.equal(complaint.category, 'payment');
    assert.equal(complaint.status, 'open');
    assert.equal(complaint.resolution, null);
    assert.ok(complaint.createdAt);
  });

  it('the mechanic cannot confirm before the customer marks paid', async () => {
    const { bookingId, mechanicId } = await job('completed', { finalAmount: 450 });
    assert.equal(
      (await rejection(confirmPayment.run(asMechanic(mechanicId, { bookingId })))).message,
      'error_invalid_payment_status',
    );
  });

  it('only on a completed booking, only by its own customer or mechanic', async () => {
    const { bookingId, customerId } = await job('in_progress');
    assert.equal((await rejection(markPaid.run(asCustomer(customerId, { bookingId })))).message, 'error_invalid_status');

    const done = await job('completed', { finalAmount: 450 });
    const stranger = await rejection(markPaid.run(asCustomer('stranger', { bookingId: done.bookingId })));
    assert.deepEqual(stranger, { code: 'not-found', message: 'error_booking_not_found' });
    const otherMechanic = await rejection(
      disputePayment.run(asMechanic('m-other', { bookingId: done.bookingId, text: 'x' })),
    );
    assert.deepEqual(otherMechanic, stranger);
  });
});
