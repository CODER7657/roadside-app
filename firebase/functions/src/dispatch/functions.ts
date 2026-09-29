// The three ways dispatch gets moved on (PLAN §11 steps 1, 2 and 4).

import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { onTaskDispatched } from 'firebase-functions/v2/tasks';
import * as logger from 'firebase-functions/logger';
import { db } from '../lib/admin.js';
import { advanceDispatch } from './advance.js';

/** A new booking (from createBooking) gets its first offer straight away. */
export const dispatchOnBookingCreated = onDocumentCreated('bookings/{bookingId}', async (event) => {
  await advanceDispatch(event.params.bookingId);
});

/** Cloud Task queued for each offer, fired just after it expires. */
export const offerTimeout = onTaskDispatched<{ bookingId: string }>(
  {
    retryConfig: { maxAttempts: 3, minBackoffSeconds: 5 },
    rateLimits: { maxConcurrentDispatches: 50 },
  },
  async (req) => {
    const bookingId = req.data?.bookingId;
    if (typeof bookingId !== 'string' || bookingId.length === 0) return;
    await advanceDispatch(bookingId);
  },
);

/** Backstop for lost timers, failed pushes and missed triggers. */
export const dispatchSweep = onSchedule({ schedule: 'every 1 minutes', timeZone: 'Asia/Kolkata' }, async () => {
  const requested = await db().collection('bookings').where('status', '==', 'requested').limit(200).get();
  const results = await Promise.allSettled(requested.docs.map((d) => advanceDispatch(d.id)));
  const failed = results.filter((r) => r.status === 'rejected').length;
  logger.info('dispatchSweep', { checked: requested.size, failed });
});
