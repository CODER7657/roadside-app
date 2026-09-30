import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { amountInRange, isWorkPhotoUrl } from '../src/callables/completeJob.js';
import { nextPaymentStatus } from '../src/models/payment.js';

const url = (path: string) =>
  `https://firebasestorage.googleapis.com/v0/b/roadside-dev.appspot.com/o/${encodeURIComponent(path)}?alt=media&token=t`;

describe('isWorkPhotoUrl', () => {
  it("accepts this booking's work photos", () => {
    assert.ok(isWorkPhotoUrl(url('bookings/b1/work/after-1.jpg'), 'b1'));
  });

  it("rejects other bookings, other folders, nesting, traversal and other hosts", () => {
    assert.ok(!isWorkPhotoUrl(url('bookings/b2/work/after-1.jpg'), 'b1'));
    assert.ok(!isWorkPhotoUrl(url('bookings/b1/chat/a.jpg'), 'b1'));
    assert.ok(!isWorkPhotoUrl(url('bookings/b1/work/'), 'b1'));
    assert.ok(!isWorkPhotoUrl(url('bookings/b1/work/x/../../b2/work/a.jpg'), 'b1'));
    assert.ok(!isWorkPhotoUrl(url('mechanics/m1/kyc/id.jpg'), 'b1'));
    assert.ok(!isWorkPhotoUrl('https://evil.example.com/v0/b/x/o/bookings%2Fb1%2Fwork%2Fa.jpg', 'b1'));
    assert.ok(!isWorkPhotoUrl('http://firebasestorage.googleapis.com/v0/b/x/o/bookings%2Fb1%2Fwork%2Fa.jpg', 'b1'));
    assert.ok(!isWorkPhotoUrl('not a url', 'b1'));
  });
});

describe('amountInRange (PLAN §9: 0.5× min to 3× max)', () => {
  const estimate = { min: 300, max: 600 };
  it('accepts the edges', () => {
    assert.ok(amountInRange(150, estimate));
    assert.ok(amountInRange(1800, estimate));
  });
  it('rejects outside them', () => {
    assert.ok(!amountInRange(149, estimate));
    assert.ok(!amountInRange(1801, estimate));
  });
});

describe('payment transitions', () => {
  const ok = (a: Parameters<typeof nextPaymentStatus>[0], from: Parameters<typeof nextPaymentStatus>[1], by: Parameters<typeof nextPaymentStatus>[2]) => {
    try {
      return nextPaymentStatus(a, from, by);
    } catch (err) {
      assert.equal((err as { message: string }).message, 'error_invalid_payment_status');
      return 'rejected';
    }
  };

  it('pending → customer_marked_paid → confirmed', () => {
    assert.equal(ok('markPaid', 'pending', 'customer'), 'customer_marked_paid');
    assert.equal(ok('confirmPayment', 'customer_marked_paid', 'mechanic'), 'confirmed');
  });

  it('either side can dispute before confirmation', () => {
    for (const by of ['customer', 'mechanic'] as const) {
      assert.equal(ok('disputePayment', 'pending', by), 'disputed');
      assert.equal(ok('disputePayment', 'customer_marked_paid', by), 'disputed');
    }
  });

  it('rejects everything else', () => {
    assert.equal(ok('markPaid', 'pending', 'mechanic'), 'rejected');
    assert.equal(ok('confirmPayment', 'pending', 'mechanic'), 'rejected');
    assert.equal(ok('confirmPayment', 'customer_marked_paid', 'customer'), 'rejected');
    assert.equal(ok('markPaid', 'confirmed', 'customer'), 'rejected');
    assert.equal(ok('disputePayment', 'confirmed', 'customer'), 'rejected');
    assert.equal(ok('disputePayment', 'disputed', 'mechanic'), 'rejected');
  });
});
