#!/usr/bin/env node
// Self-test for admins.mjs on the emulators. From firebase/:
//   firebase emulators:exec --project demo-roadside --only auth,firestore "node ../tool/admin/selftest.mjs"

import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

if (!process.env.FIREBASE_AUTH_EMULATOR_HOST || !process.env.FIRESTORE_EMULATOR_HOST) {
  console.error('Run inside firebase emulators:exec with auth + firestore.');
  process.exit(1);
}

const script = join(dirname(fileURLToPath(import.meta.url)), 'admins.mjs');
const app = initializeApp({ projectId: process.env.GCLOUD_PROJECT ?? 'demo-roadside' });
const auth = getAuth(app);
const db = getFirestore(app);

/** Runs admins.mjs; returns { ok, out }. */
function run(...args) {
  try {
    return { ok: true, out: execFileSync(process.execPath, [script, ...args], { encoding: 'utf8', stdio: 'pipe' }) };
  } catch (e) {
    return { ok: false, out: `${e.stdout}${e.stderr}` };
  }
}

// 1. Allow-list before the first sign-in: no account yet, so no role.
let r = run('grant', 'Ops@Example.com');
assert.ok(r.ok, r.out);
assert.match(r.out, /allow-listed/);
assert.ok((await db.doc('adminAllowlist/ops@example.com').get()).exists);

// 2. They sign in with Google once; grant again gives the role.
await auth.importUsers([
  { uid: 'google-ops', email: 'ops@example.com', emailVerified: true,
    providerData: [{ uid: 'g-1', providerId: 'google.com', email: 'ops@example.com' }] },
  { uid: 'phone-user', email: 'rider@example.com', phoneNumber: '+919800000001',
    providerData: [{ uid: '+919800000001', providerId: 'phone', phoneNumber: '+919800000001' }] },
]);
r = run('grant', 'ops@example.com');
assert.ok(r.ok, r.out);
assert.deepEqual((await auth.getUser('google-ops')).customClaims, { role: 'admin' });
assert.ok((await db.doc('admins/google-ops').get()).exists);

// 3. Phone-OTP accounts are refused.
r = run('grant', 'rider@example.com');
assert.equal(r.ok, false);
assert.match(r.out, /phone-OTP account/);
assert.equal((await auth.getUser('phone-user')).customClaims?.role, undefined);

// 4. Revoke removes everything and ends sessions.
r = run('revoke', 'ops@example.com');
assert.ok(r.ok, r.out);
const revoked = await auth.getUser('google-ops');
assert.equal(revoked.customClaims?.role, undefined);
assert.ok(revoked.tokensValidAfterTime, 'refresh tokens revoked');
assert.equal((await db.doc('admins/google-ops').get()).exists, false);
assert.equal((await db.doc('adminAllowlist/ops@example.com').get()).exists, false);

// 5. Every grant and revoke is audited.
const actions = (await db.collection('auditLogs').get()).docs.map((d) => d.get('action')).sort();
assert.deepEqual(actions, ['admin.allowlist', 'admin.grant', 'admin.revoke']);

// 6. Bad input.
assert.equal(run('grant', 'not-an-email').ok, false);
assert.equal(run('promote', 'ops@example.com').ok, false);

console.log('✓ admin tools self-test passed');
