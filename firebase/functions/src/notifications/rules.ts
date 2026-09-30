// Who hears about which booking change (PLAN §11 Dispatch step 7, §9).
// The person who caused a change isn't notified about it; the other side is.
// Offers are pushed by dispatch (advance.ts), not here.

import type { BookingDoc } from '../models/documents.js';

export type Side = 'customer' | 'mechanic';

export const NOTICE_TYPES = [
  'booking_accepted',
  'booking_arriving',
  'booking_arrived',
  'booking_started',
  'booking_completed',
  'booking_redispatched',
  'booking_no_mechanic',
  'booking_cancelled_by_customer',
  'booking_cancelled_by_mechanic',
  'booking_cancelled',
  'payment_marked_paid',
  'payment_confirmed',
  'payment_disputed',
  'start_code_locked',
] as const;
export type NoticeType = (typeof NOTICE_TYPES)[number];

export interface Notice {
  uid: string;
  side: Side;
  type: NoticeType;
  /** ARB keys, filled in by the app in the reader's language (C8 Notifications list). */
  titleKey: string;
  bodyKey: string;
  /** Placeholder values for the ARB strings. Never phone numbers, addresses or codes. */
  args: Record<string, string>;
}

export type BookingState = Pick<
  BookingDoc,
  'status' | 'customerId' | 'mechanicId' | 'paymentStatus' | 'finalAmount' | 'cancelledBy'
>;

export function notice(
  uid: string | null | undefined,
  side: Side,
  type: NoticeType,
  args: Record<string, string> = {},
): Notice[] {
  if (!uid) return [];
  return [{ uid, side, type, titleKey: `notif_${type}_title`, bodyKey: `notif_${type}_body`, args }];
}

function amountArgs(b: BookingState): Record<string, string> {
  return b.finalAmount != null ? { amount: String(b.finalAmount) } : {};
}

function forStatusChange(before: BookingState, after: BookingState): Notice[] {
  const customer = after.customerId;
  // After a mechanic cancels, mechanicId may already be cleared; fall back to the old value.
  const mechanic = after.mechanicId ?? before.mechanicId;

  switch (after.status) {
    case 'accepted':
      return notice(customer, 'customer', 'booking_accepted');
    case 'arriving':
      return notice(customer, 'customer', 'booking_arriving');
    case 'arrived':
      return notice(customer, 'customer', 'booking_arrived');
    case 'in_progress':
      return notice(customer, 'customer', 'booking_started');
    case 'completed':
      return notice(customer, 'customer', 'booking_completed', amountArgs(after));
    case 'requested':
      // Back to requested = the mechanic cancelled before arrival and we're re-dispatching.
      return before.status === 'accepted' || before.status === 'arriving'
        ? notice(customer, 'customer', 'booking_redispatched')
        : [];
    case 'no_mechanic_found':
      return notice(customer, 'customer', 'booking_no_mechanic');
    case 'cancelled':
      switch (after.cancelledBy) {
        case 'customer':
          return notice(mechanic, 'mechanic', 'booking_cancelled_by_customer');
        case 'mechanic':
          return notice(customer, 'customer', 'booking_cancelled_by_mechanic');
        default: // admin or system: tell everyone involved
          return [
            ...notice(customer, 'customer', 'booking_cancelled'),
            ...notice(mechanic, 'mechanic', 'booking_cancelled'),
          ];
      }
    default:
      return [];
  }
}

function forPaymentChange(after: BookingState): Notice[] {
  switch (after.paymentStatus) {
    case 'customer_marked_paid':
      return notice(after.mechanicId, 'mechanic', 'payment_marked_paid', amountArgs(after));
    case 'confirmed':
      return notice(after.customerId, 'customer', 'payment_confirmed', amountArgs(after));
    case 'disputed':
      // Either side can dispute and we don't record who; both need to know a complaint is open.
      return [
        ...notice(after.customerId, 'customer', 'payment_disputed'),
        ...notice(after.mechanicId, 'mechanic', 'payment_disputed'),
      ];
    default:
      return [];
  }
}

/** Every notice a booking update should produce. Empty when nothing user-visible changed. */
export function noticesFor(before: BookingState, after: BookingState): Notice[] {
  return [
    ...(before.status !== after.status ? forStatusChange(before, after) : []),
    ...(before.paymentStatus !== after.paymentStatus ? forPaymentChange(after) : []),
  ];
}
