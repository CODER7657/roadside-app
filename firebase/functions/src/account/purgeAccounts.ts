// The second half of account deletion (#167; PLAN §12.10, §12.12): a daily job erases every
// account whose `deletionRequestedAt` is set, well inside the 30 days the privacy policy
// promises. Each account is handled on its own, so one failure doesn't hold up the rest, and a
// failed account is simply tried again the next day.
//
// Customer (users/{uid}):
//   - the profile with its vehicles (recursive), draft photos in Storage (users/{uid}/…)
//   - their bookings are kept for 3 years (tax, disputes) but anonymised: no name, phone,
//     address, landmark, plus code, description, number plate, brand or model; the pickup point
//     is rounded to ~1 km; problem, chat and before/after photos are deleted (from Storage
//     too: the work photos can show the plate); the start-code doc, chat, live location and
//     share links are deleted
//   - their review comments are cleared (stars and tags stay: they're the mechanic's rating)
// Mechanic (mechanics/{uid}):
//   - the profile is reduced to a tombstone (`deletionRequestedAt`, `status: blocked`), so the
//     KYC retention job can delete `private/kyc` and the KYC files 180 days after they left
//     (PLAN §12.10); shop, profile and toolkit photos go now
//   - presence and offers are deleted; the mechanic card on their bookings is anonymised
// Both: rateLimits/{uid} and the Firebase Auth user are deleted.

import { getAuth } from 'firebase-admin/auth';
import { FieldValue, GeoPoint, type DocumentReference, type Timestamp } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import * as logger from 'firebase-functions/logger';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { db } from '../lib/admin.js';
import { geohash } from '../lib/geo.js';
import type { BookingDoc } from '../models/documents.js';

export type AccountKind = 'customer' | 'mechanic';

/** Storage is behind a seam so the emulator tests (no Storage emulator) can check the calls. */
export interface PurgeDeps {
  deleteFiles(prefix: string): Promise<void>;
}

const liveDeps: PurgeDeps = {
  async deleteFiles(prefix) {
    await getStorage().bucket().deleteFiles({ prefix, force: true });
  },
};

let deps: PurgeDeps = liveDeps;

/** Tests only. */
export function setPurgeDeps(next: PurgeDeps | null): void {
  deps = next ?? liveDeps;
}

/** ~1 km: enough for city statistics, not enough to find a home. */
export function coarse(p: GeoPoint): GeoPoint {
  const round = (x: number) => Math.round(x * 100) / 100;
  return new GeoPoint(round(p.latitude), round(p.longitude));
}

/** The personal parts of a customer's booking, blanked (PLAN §12.12). */
export function anonymisedForCustomer(b: Pick<BookingDoc, 'pickup'>): Record<string, unknown> {
  const point = coarse(b.pickup.geopoint);
  return {
    customerCard: null,
    description: '',
    photoUrls: [],
    beforePhotoUrls: [],
    afterPhotoUrls: [],
    // A number plate identifies the owner; the vehicle type stays for statistics.
    'vehicle.regNo': '',
    'vehicle.brand': '',
    'vehicle.model': '',
    'pickup.geopoint': point,
    'pickup.geohash': geohash({ lat: point.latitude, lng: point.longitude }, 5),
    'pickup.address': '',
    'pickup.landmark': '',
    'pickup.plusCode': '',
    updatedAt: FieldValue.serverTimestamp(),
  };
}

/** The personal parts of the mechanic card on a mechanic's booking. */
export function anonymisedForMechanic(): Record<string, unknown> {
  return {
    'mechanicCard.name': '',
    'mechanicCard.photoUrl': '',
    'mechanicCard.phone': '',
    'mechanicCard.upiId': '',
    'mechanicCard.upiName': '',
    'mechanicCard.shopName': null,
    'mechanicCard.travelVehicleRegNo': null,
    updatedAt: FieldValue.serverTimestamp(),
  };
}

async function deleteAuthUser(uid: string): Promise<void> {
  try {
    await getAuth().deleteUser(uid);
  } catch (err) {
    if ((err as { code?: string }).code !== 'auth/user-not-found') throw err;
  }
}

/** Deletes each document from [refs] in batches of 400. */
async function deleteAll(refs: DocumentReference[]): Promise<void> {
  for (let i = 0; i < refs.length; i += 400) {
    const batch = db().batch();
    for (const ref of refs.slice(i, i + 400)) batch.delete(ref);
    await batch.commit();
  }
}

async function purgeCustomer(uid: string): Promise<void> {
  const fs = db();
  const bookings = await fs.collection('bookings').where('customerId', '==', uid).get();
  for (const doc of bookings.docs) {
    const id = doc.id;
    await doc.ref.update(anonymisedForCustomer(doc.data() as BookingDoc));
    await fs.recursiveDelete(fs.doc(`bookings/${id}/private/otp`));
    await fs.recursiveDelete(fs.collection(`bookings/${id}/messages`));
    await deps.deleteFiles(`bookings/${id}/chat/`);
    await deps.deleteFiles(`bookings/${id}/work/`);
    await fs.doc(`liveLocations/${id}`).delete();
    const review = fs.doc(`reviews/${id}`);
    if ((await review.get()).exists) await review.update({ comment: '' });
  }
  const links = await fs.collection('shareLinks').where('createdBy', '==', uid).get();
  await deleteAll(links.docs.map((d) => d.ref));

  await deps.deleteFiles(`users/${uid}/`);
  await fs.recursiveDelete(fs.doc(`users/${uid}`));
}

async function purgeMechanic(uid: string, requestedAt: Timestamp): Promise<void> {
  const fs = db();
  const bookings = await fs.collection('bookings').where('mechanicId', '==', uid).get();
  for (const doc of bookings.docs) {
    if (doc.get('mechanicCard')) await doc.ref.update(anonymisedForMechanic());
  }
  const offers = await fs.collection('offers').where('mechanicId', '==', uid).get();
  await deleteAll(offers.docs.map((d) => d.ref));
  await fs.doc(`presence/${uid}`).delete();

  await deps.deleteFiles(`mechanics/${uid}/shop/`);
  // Tombstone: `set` without merge drops every other field; private/kyc stays for its job.
  await fs.doc(`mechanics/${uid}`).set({
    deletionRequestedAt: requestedAt,
    status: 'blocked',
    schemaVersion: 1,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });
}

/** Erases one account (see the top of this file). Safe to run again after a partial failure. */
export async function purgeAccount(kind: AccountKind, uid: string, requestedAt: Timestamp): Promise<void> {
  if (kind === 'customer') await purgeCustomer(uid);
  else await purgeMechanic(uid, requestedAt);
  await db().doc(`rateLimits/${uid}`).delete();
  await deleteAuthUser(uid);
}

/** Purges up to [limit] pending accounts of each kind. Returns how many succeeded / failed. */
export async function purgePending(limit = 50): Promise<{ purged: number; failed: number }> {
  const fs = db();
  // A mechanic tombstone keeps `deletionRequestedAt` (for the KYC job), so skip the ones already
  // reduced: their `status` is blocked and they have no name.
  const [customers, mechanics] = await Promise.all([
    fs.collection('users').where('deletionRequestedAt', '!=', null).limit(limit).get(),
    fs.collection('mechanics').where('deletionRequestedAt', '!=', null).limit(limit * 4).get(),
  ]);
  const jobs: Array<[AccountKind, string, Timestamp]> = [
    ...customers.docs.map((d): [AccountKind, string, Timestamp] => [
      'customer',
      d.id,
      d.get('deletionRequestedAt') as Timestamp,
    ]),
    ...mechanics.docs
      .filter((d) => d.get('name') !== undefined || d.get('status') !== 'blocked')
      .slice(0, limit)
      .map((d): [AccountKind, string, Timestamp] => ['mechanic', d.id, d.get('deletionRequestedAt') as Timestamp]),
  ];

  let purged = 0;
  let failed = 0;
  for (const [kind, uid, requestedAt] of jobs) {
    try {
      await purgeAccount(kind, uid, requestedAt);
      purged++;
    } catch (err) {
      failed++;
      // uid only: the error may carry personal data.
      logger.error('account purge failed', { uid, kind, errorName: err instanceof Error ? err.name : typeof err });
    }
  }
  return { purged, failed };
}

/** Daily at 03:00 IST. Needs Blaze to deploy (firebase/CLAUDE.md); tested on the emulators. */
export const purgeDeletedAccounts = onSchedule(
  { schedule: 'every day 03:00', timeZone: 'Asia/Kolkata', timeoutSeconds: 540 },
  async () => {
    const result = await purgePending();
    logger.info('purgeDeletedAccounts', result);
  },
);
