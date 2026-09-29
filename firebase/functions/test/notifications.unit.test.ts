import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { noticesFor, type BookingState } from '../src/notifications/rules.js';
import { TRANSITIONS } from '../src/models/status.js';

const base: BookingState = {
  status: 'requested',
  customerId: 'cust',
  mechanicId: null,
  paymentStatus: 'pending',
  finalAmount: null,
  cancelledBy: null,
};

const at = (patch: Partial<BookingState>): BookingState => ({ ...base, ...patch });
const who = (before: BookingState, after: BookingState) =>
  noticesFor(before, after).map((n) => `${n.side}:${n.uid}:${n.type}`);

describe('noticesFor', () => {
  it('tells the customer about each step the mechanic takes', () => {
    const steps = [
      ['requested', 'accepted', 'booking_accepted'],
      ['accepted', 'arriving', 'booking_arriving'],
      ['arriving', 'arrived', 'booking_arrived'],
      ['arrived', 'in_progress', 'booking_started'],
      ['in_progress', 'completed', 'booking_completed'],
    ] as const;
    for (const [from, to, type] of steps) {
      assert.deepEqual(
        who(at({ status: from, mechanicId: 'mech' }), at({ status: to, mechanicId: 'mech' })),
        [`customer:cust:${type}`],
        `${from} → ${to}`,
      );
    }
  });

  it('never notifies the mechanic about their own steps', () => {
    const n = noticesFor(at({ status: 'accepted', mechanicId: 'mech' }), at({ status: 'arriving', mechanicId: 'mech' }));
    assert.ok(n.every((x) => x.uid !== 'mech'));
  });

  it('passes the final amount on completion, and nothing sensitive', () => {
    const [n] = noticesFor(
      at({ status: 'in_progress', mechanicId: 'mech' }),
      at({ status: 'completed', mechanicId: 'mech', finalAmount: 450 }),
    );
    assert.deepEqual(n!.args, { amount: '450' });
    assert.equal(n!.titleKey, 'notif_booking_completed_title');
    assert.equal(n!.bodyKey, 'notif_booking_completed_body');
  });

  it('tells the customer when their mechanic cancels and we re-dispatch', () => {
    for (const from of ['accepted', 'arriving'] as const) {
      assert.deepEqual(who(at({ status: from, mechanicId: 'mech' }), at({ status: 'requested' })), [
        'customer:cust:booking_redispatched',
      ]);
    }
  });

  it('tells the customer when nobody was found', () => {
    assert.deepEqual(who(base, at({ status: 'no_mechanic_found' })), ['customer:cust:booking_no_mechanic']);
  });

  it('routes cancellations to the other side', () => {
    const before = at({ status: 'arriving', mechanicId: 'mech' });
    assert.deepEqual(who(before, at({ status: 'cancelled', mechanicId: 'mech', cancelledBy: 'customer' })), [
      'mechanic:mech:booking_cancelled_by_customer',
    ]);
    assert.deepEqual(
      who(at({ status: 'arrived', mechanicId: 'mech' }), at({ status: 'cancelled', mechanicId: 'mech', cancelledBy: 'mechanic' })),
      ['customer:cust:booking_cancelled_by_mechanic'],
    );
    assert.deepEqual(who(before, at({ status: 'cancelled', mechanicId: 'mech', cancelledBy: 'admin' })), [
      'customer:cust:booking_cancelled',
      'mechanic:mech:booking_cancelled',
    ]);
  });

  it('a customer cancelling before anyone accepted notifies nobody', () => {
    assert.deepEqual(who(base, at({ status: 'cancelled', cancelledBy: 'customer' })), []);
  });

  it('handles the payment steps', () => {
    const done = at({ status: 'completed', mechanicId: 'mech', finalAmount: 450 });
    assert.deepEqual(who(done, { ...done, paymentStatus: 'customer_marked_paid' }), [
      'mechanic:mech:payment_marked_paid',
    ]);
    assert.deepEqual(who({ ...done, paymentStatus: 'customer_marked_paid' }, { ...done, paymentStatus: 'confirmed' }), [
      'customer:cust:payment_confirmed',
    ]);
    assert.deepEqual(who({ ...done, paymentStatus: 'customer_marked_paid' }, { ...done, paymentStatus: 'disputed' }), [
      'customer:cust:payment_disputed',
      'mechanic:mech:payment_disputed',
    ]);
  });

  it('stays quiet when nothing user-visible changed', () => {
    assert.deepEqual(who(base, { ...base }), []);
  });

  it('covers every transition in the §9 table', () => {
    for (const t of TRANSITIONS) {
      const before = at({ status: t.from, mechanicId: 'mech' });
      const after = at({
        status: t.to,
        mechanicId: t.to === 'requested' ? null : 'mech',
        cancelledBy: t.to === 'cancelled' ? t.by[0]! : null,
      });
      assert.ok(noticesFor(before, after).length > 0, `${t.from} → ${t.to} sends nothing`);
    }
  });
});
