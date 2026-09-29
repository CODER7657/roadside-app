// Booking status machine (PLAN.md §9). Mirror of the table in packages/roadside_core.
// Every status change runs in a transaction and calls assertTransition() first.

import { HttpsError } from 'firebase-functions/v2/https';
import type { Actor, BookingStatus } from './enums.js';

export interface Transition {
  from: BookingStatus;
  to: BookingStatus;
  by: readonly Actor[];
}

export const TRANSITIONS: readonly Transition[] = [
  { from: 'requested', to: 'accepted', by: ['mechanic'] }, // respondToOffer
  { from: 'requested', to: 'no_mechanic_found', by: ['system'] }, // dispatch sweep
  { from: 'requested', to: 'cancelled', by: ['customer', 'admin'] },

  { from: 'accepted', to: 'arriving', by: ['mechanic'] }, // startTrip
  { from: 'accepted', to: 'requested', by: ['mechanic'] }, // cancelBooking → re-dispatch
  { from: 'accepted', to: 'cancelled', by: ['customer', 'admin'] },

  { from: 'arriving', to: 'arrived', by: ['mechanic'] }, // markArrived
  { from: 'arriving', to: 'requested', by: ['mechanic'] }, // cancelBooking → re-dispatch
  { from: 'arriving', to: 'cancelled', by: ['customer', 'admin'] },

  { from: 'arrived', to: 'in_progress', by: ['mechanic'] }, // verifyStartOtp
  { from: 'arrived', to: 'cancelled', by: ['customer', 'mechanic', 'admin'] },

  { from: 'in_progress', to: 'completed', by: ['mechanic'] }, // completeJob
];

/** Statuses that count as "the customer has an active booking". */
export const ACTIVE_STATUSES: readonly BookingStatus[] = [
  'requested',
  'accepted',
  'arriving',
  'arrived',
  'in_progress',
];

export function canTransition(from: BookingStatus, to: BookingStatus, by: Actor): boolean {
  return TRANSITIONS.some((t) => t.from === from && t.to === to && t.by.includes(by));
}

/** Throws `failed-precondition` for any transition not in the table (PLAN §9). */
export function assertTransition(from: BookingStatus, to: BookingStatus, by: Actor): void {
  if (!canTransition(from, to, by)) {
    throw new HttpsError('failed-precondition', 'error_invalid_status');
  }
}
