import { getApps, initializeApp } from 'firebase-admin/app';
import { getFirestore, type Firestore } from 'firebase-admin/firestore';

/** Region for every function (PLAN §3). Can't be changed after launch. */
export const REGION = 'asia-south1';

/**
 * Makes sure the default Admin app exists. Checks for the default app by name:
 * firebase-functions creates its own named app, so `getApps().length` isn't enough.
 */
export function ensureAdminApp(): void {
  if (!getApps().some((a) => a.name === '[DEFAULT]')) initializeApp();
}

export function db(): Firestore {
  ensureAdminApp();
  return getFirestore();
}
