import { getApps, initializeApp } from 'firebase-admin/app';
import { getFirestore, type Firestore } from 'firebase-admin/firestore';

/** Region for every function (PLAN §3). Can't be changed after launch. */
export const REGION = 'asia-south1';

export function db(): Firestore {
  if (getApps().length === 0) initializeApp();
  return getFirestore();
}
