// onBookingStatusChange (PLAN §11 Dispatch step 7): on every booking status or payment
// change, write an inbox item for the other side (C8 Notifications list) and push to them.
//
// Triggers can fire more than once. Inbox item ids come from the event id, and the push is
// only sent by the run that created the item, so a retry never notifies twice.

import { createHash } from 'node:crypto';
import { FieldValue } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import * as logger from 'firebase-functions/logger';
import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { db, ensureAdminApp } from '../lib/admin.js';
import { SCHEMA_VERSION } from '../models/enums.js';
import { noticesFor, type BookingState, type Notice } from './rules.js';

/** Push sender. Tests replace it. */
export interface NotifyDeps {
  push(token: string, notice: Notice, bookingId: string): Promise<void>;
}

export const defaultNotifyDeps: NotifyDeps = {
  async push(token, notice, bookingId) {
    ensureAdminApp();
    // Data-only so the app renders the ARB strings in the user's language. High priority:
    // every notice here is shown to the user straight away.
    await getMessaging().send({
      token,
      data: {
        type: notice.type,
        bookingId,
        titleKey: notice.titleKey,
        bodyKey: notice.bodyKey,
        args: JSON.stringify(notice.args),
      },
      android: { priority: 'high', collapseKey: bookingId },
    });
  },
};

let deps: NotifyDeps = defaultNotifyDeps;
/** Test hook. */
export function setNotifyDeps(d: NotifyDeps): void {
  deps = d;
}

export function inboxItemId(eventId: string, notice: Notice): string {
  return createHash('sha256').update(`${eventId}:${notice.uid}:${notice.type}`).digest('base64url').slice(0, 24);
}

async function tokenOf(notice: Notice): Promise<string | null> {
  const path = notice.side === 'customer' ? `users/${notice.uid}` : `mechanics/${notice.uid}`;
  return ((await db().doc(path).get()).get('fcmToken') as string | null | undefined) ?? null;
}

/**
 * Writes one inbox item and pushes it. `eventKey` makes the item id stable, so a retry with the
 * same key does nothing. Returns false when the item already existed.
 */
export async function deliverNotice(eventKey: string, bookingId: string, notice: Notice): Promise<boolean> {
  const ref = db().doc(`inbox/${notice.uid}/items/${inboxItemId(eventKey, notice)}`);
  try {
    await ref.create({
      type: notice.type,
      titleKey: notice.titleKey,
      bodyKey: notice.bodyKey,
      args: notice.args,
      bookingId,
      read: false,
      schemaVersion: SCHEMA_VERSION,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
  } catch (err) {
    if ((err as { code?: number }).code === 6 /* ALREADY_EXISTS */) return false; // retry
    throw err;
  }

  const token = await tokenOf(notice);
  if (!token) return true; // inbox only; the app shows it next time it opens
  await deps.push(token, notice, bookingId).catch((err: unknown) =>
    // The inbox item is already saved, so a failed push isn't retried.
    logger.warn('status push failed', {
      uid: notice.uid,
      bookingId,
      type: notice.type,
      errorCode: (err as { code?: unknown })?.code ?? null,
    }),
  );
  return true;
}

/** Returns how many notices were newly delivered (retries count 0). */
export async function handleBookingChange(
  eventId: string,
  bookingId: string,
  before: BookingState,
  after: BookingState,
): Promise<number> {
  const notices = noticesFor(before, after);
  let delivered = 0;
  for (const notice of notices) {
    if (await deliverNotice(eventId, bookingId, notice)) delivered++;
  }
  if (notices.length > 0) logger.info('onBookingStatusChange', { bookingId, notices: notices.length, delivered });
  return delivered;
}

export const onBookingStatusChange = onDocumentUpdated('bookings/{bookingId}', async (event) => {
  const before = event.data?.before.data() as BookingState | undefined;
  const after = event.data?.after.data() as BookingState | undefined;
  if (!before || !after) return;
  await handleBookingChange(event.id, event.params.bookingId, before, after);
});
