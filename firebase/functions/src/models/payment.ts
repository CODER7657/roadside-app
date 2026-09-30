// Payment status flow (PLAN §9 "Payment" paragraph; issue #117). Only after `completed`.
// roadside_core has no table for this yet; mirror it there when the apps need it.
//
//   pending ──markPaid (customer)──► customer_marked_paid ──confirmPayment (mechanic)──► confirmed
//      │                                   │
//      └──────── disputePayment (either) ──┴──► disputed

import { HttpsError } from 'firebase-functions/v2/https';
import type { PaymentStatus } from './enums.js';

export type PaymentAction = 'markPaid' | 'confirmPayment' | 'disputePayment';
export type PaymentActor = 'customer' | 'mechanic';

interface PaymentTransition {
  action: PaymentAction;
  from: readonly PaymentStatus[];
  to: PaymentStatus;
  by: readonly PaymentActor[];
}

export const PAYMENT_TRANSITIONS: readonly PaymentTransition[] = [
  { action: 'markPaid', from: ['pending'], to: 'customer_marked_paid', by: ['customer'] },
  { action: 'confirmPayment', from: ['customer_marked_paid'], to: 'confirmed', by: ['mechanic'] },
  { action: 'disputePayment', from: ['pending', 'customer_marked_paid'], to: 'disputed', by: ['customer', 'mechanic'] },
];

/** The new payment status, or `failed-precondition` if §9 doesn't allow it. */
export function nextPaymentStatus(action: PaymentAction, from: PaymentStatus, by: PaymentActor): PaymentStatus {
  const t = PAYMENT_TRANSITIONS.find((x) => x.action === action);
  if (!t || !t.from.includes(from) || !t.by.includes(by)) {
    throw new HttpsError('failed-precondition', 'error_invalid_payment_status');
  }
  return t.to;
}
