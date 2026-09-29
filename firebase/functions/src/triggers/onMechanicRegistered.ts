// onMechanicRegistered (PLAN §8 mechanics, §8 Roles, §12.2; issue #101).
//
// When the mechanic app creates mechanics/{uid} (M1 registration), this:
//   1. sets the claims `role: mechanic, mechanicStatus: pending`, keeping any other claims;
//   2. fills in any 🔒 fields the app left out (status, rating, ratingCount, jobsCompleted),
//      never overwriting one that's already there.
// The Firestore rules already check the profile for each mechanic type and only let the
// app send the starting 🔒 values, so this doesn't re-validate the profile.
//
// Safe on retries: a user who already has the mechanic role keeps their claims (a retry
// after approval can't reset them to pending), and the 🔒 fields are read from the current
// doc in a transaction, not from the event snapshot.
// The app calls getIdToken(true) after registering to pick up the new claims.

import { getAuth } from 'firebase-admin/auth';
import { type DocumentData } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { db, ensureAdminApp } from '../lib/admin.js';
import type { MechanicStatus } from '../models/enums.js';
import type { RoleClaims } from '../models/documents.js';

export type RegistrationOutcome = 'granted' | 'already_mechanic' | 'admin_skipped';

export interface ClaimsDecision {
  outcome: RegistrationOutcome;
  /** Claims to set, or null to leave them as they are. */
  claims: RoleClaims | null;
  /** Status to fill in if the doc has none. */
  defaultStatus: MechanicStatus;
}

/** Pure decision on the caller's current claims, so every branch is testable without Auth. */
export function decideClaims(current: Readonly<Record<string, unknown>>): ClaimsDecision {
  const claims = current as RoleClaims;
  if (claims.role === 'admin') {
    // Never turn an admin into a mechanic; their doc still gets the 🔒 defaults.
    return { outcome: 'admin_skipped', claims: null, defaultStatus: 'pending' };
  }
  if (claims.role === 'mechanic') {
    // Retry, or a doc re-created by an admin: keep whatever status was already decided.
    return { outcome: 'already_mechanic', claims: null, defaultStatus: claims.mechanicStatus ?? 'pending' };
  }
  return {
    outcome: 'granted',
    claims: { ...current, role: 'mechanic', mechanicStatus: 'pending' } as RoleClaims,
    defaultStatus: 'pending',
  };
}

/** The 🔒 fields missing from `doc`, with their starting values. Present fields are left alone. */
export function missingLockedFields(doc: DocumentData, defaultStatus: MechanicStatus): Record<string, unknown> {
  const defaults: Record<string, unknown> = { status: defaultStatus, rating: 0, ratingCount: 0, jobsCompleted: 0 };
  return Object.fromEntries(Object.entries(defaults).filter(([key]) => !(key in doc)));
}

export async function registerMechanic(uid: string): Promise<RegistrationOutcome> {
  ensureAdminApp();
  const auth = getAuth();
  const user = await auth.getUser(uid);
  const decision = decideClaims(user.customClaims ?? {});

  if (decision.claims) await auth.setCustomUserClaims(uid, decision.claims);

  const ref = db().doc(`mechanics/${uid}`);
  await db().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) return;
    const missing = missingLockedFields(snap.data()!, decision.defaultStatus);
    if (Object.keys(missing).length > 0) tx.update(ref, missing);
  });

  logger.info(`onMechanicRegistered ${decision.outcome}`, { uid });
  return decision.outcome;
}

export const onMechanicRegistered = onDocumentCreated('mechanics/{uid}', async (event) => {
  await registerMechanic(event.params.uid);
});
