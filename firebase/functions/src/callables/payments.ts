// markPaid, confirmPayment, disputePayment (PLAN §9 Payment; issue #117).
//
//   markPaid        customer   pending → customer_marked_paid   ("I have paid", U13)
//   confirmPayment  mechanic   customer_marked_paid → confirmed (M8; consumeAppCheckToken)
//   disputePayment  either     pending | customer_marked_paid → disputed, and opens a
//                              `payment` complaint for the admins (A5)
// Only on a `completed` booking, only by its own customer / assigned mechanic, in a transaction.
// The app never moves money; the customer pays the mechanic's UPI directly.

import { FieldValue } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { HttpsError } from 'firebase-functions/v2/https';
import { z } from 'zod';
import { db } from '../lib/admin.js';
import { secureCall } from '../lib/secureCall.js';
import { nextPaymentStatus, type PaymentAction, type PaymentActor } from '../models/payment.js';
import type { Role } from '../models/enums.js';
import type { BookingDoc, ComplaintDoc } from '../models/documents.js';

const bookingOnly = z.object({ bookingId: z.string().min(1).max(128) });
const disputeInput = z.object({
  bookingId: z.string().min(1).max(128),
  /** What went wrong, for the admin reviewing the complaint. */
  text: z.string().trim().min(1).max(1000),
});

export interface PaymentResult {
  bookingId: string;
  paymentStatus: string;
  complaintId?: string;
}

function actorFor(role: Role, uid: string, b: BookingDoc): PaymentActor | null {
  if (role === 'customer' && b.customerId === uid) return 'customer';
  if (role === 'mechanic' && b.mechanicId === uid) return 'mechanic';
  return null;
}

async function changePayment(
  action: PaymentAction,
  uid: string,
  role: Role,
  bookingId: string,
  disputeText?: string,
): Promise<PaymentResult> {
  const fs = db();
  const bookingRef = fs.doc(`bookings/${bookingId}`);
  const complaintRef = disputeText ? fs.collection('complaints').doc() : null;

  const result = await fs.runTransaction(async (tx): Promise<PaymentResult> => {
    const booking = (await tx.get(bookingRef)).data() as BookingDoc | undefined;
    const actor = booking ? actorFor(role, uid, booking) : null;
    // Someone else's booking looks the same as a missing one.
    if (!booking || !actor) throw new HttpsError('not-found', 'error_booking_not_found');
    if (booking.status !== 'completed') throw new HttpsError('failed-precondition', 'error_invalid_status');
    const to = nextPaymentStatus(action, booking.paymentStatus, actor);

    tx.update(bookingRef, { paymentStatus: to, updatedAt: FieldValue.serverTimestamp() });
    if (complaintRef) {
      const complaint: Omit<ComplaintDoc, 'createdAt'> & { createdAt: FieldValue } = {
        bookingId,
        raisedBy: uid,
        category: 'payment',
        text: disputeText!,
        status: 'open',
        resolution: null,
        createdAt: FieldValue.serverTimestamp(),
      };
      tx.create(complaintRef, complaint);
    }
    return { bookingId, paymentStatus: to, ...(complaintRef ? { complaintId: complaintRef.id } : {}) };
  });

  logger.info(action, { uid, bookingId, paymentStatus: result.paymentStatus });
  return result;
}

export const markPaid = secureCall(
  { name: 'markPaid', roles: ['customer'], input: bookingOnly, rateLimit: { max: 10, windowSeconds: 60 } },
  async ({ uid, role, data }) => changePayment('markPaid', uid, role, data.bookingId),
);

export const confirmPayment = secureCall(
  {
    name: 'confirmPayment',
    roles: ['mechanic'],
    mechanicStatuses: ['approved'],
    input: bookingOnly,
    rateLimit: { max: 10, windowSeconds: 60 },
    consumeAppCheckToken: true,
  },
  async ({ uid, role, data }) => changePayment('confirmPayment', uid, role, data.bookingId),
);

export const disputePayment = secureCall(
  {
    name: 'disputePayment',
    roles: ['customer', 'mechanic'],
    mechanicStatuses: ['approved'],
    input: disputeInput,
    rateLimit: { max: 5, windowSeconds: 600 },
  },
  async ({ uid, role, data }) => changePayment('disputePayment', uid, role, data.bookingId, data.text),
);
