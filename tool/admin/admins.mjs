#!/usr/bin/env node
// Grant, revoke and list console admins (PLAN.md §12.11). The ONLY way to make an admin: no app
// or callable can grant the role. Run by the repo owner or P3 with that project's credentials.
//
//   npm --prefix tool/admin run grant  -- ops@example.com --project roadside-33282
//   npm --prefix tool/admin run revoke -- ops@example.com --project roadside-33282
//   npm --prefix tool/admin run list   -- --project roadside-33282
//
// Credentials: Application Default Credentials (`gcloud auth application-default login`).
// Emulators: run inside `firebase emulators:exec` (no --project needed). roadside-prod also needs
// --allow-prod. Every grant and revoke is written to auditLogs.
//
// grant:  adds adminAllowlist/{email} (the beforeSignIn allow-list). If the Google account has
//         signed in before, also sets the `role: admin` claim and admins/{uid}. Otherwise: ask the
//         person to sign in to the console once (they'll see "Not authorised"), then run grant again.
// revoke: removes the allow-list entry, the claim and admins/{uid}, and revokes refresh tokens,
//         so every session ends within the hour (the console signs out on the next token refresh).

import { userInfo } from 'node:os';
import { parseArgs } from 'node:util';
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';

const { values: args, positionals } = parseArgs({
  allowPositionals: true,
  options: {
    project: { type: 'string' },
    'allow-prod': { type: 'boolean', default: false },
  },
});
const [command, rawEmail] = positionals;
const USAGE = 'Usage: admins.mjs grant|revoke <email> | list  [--project <id>] [--allow-prod]';

const emulator = process.env.FIRESTORE_EMULATOR_HOST;
const projectId = args.project ?? process.env.GCLOUD_PROJECT ?? (emulator ? 'demo-roadside' : undefined);
if (!projectId) fail('No project. Run inside `firebase emulators:exec` or pass --project roadside-33282.');
if (!emulator && projectId.includes('prod') && !args['allow-prod']) fail(`Refusing to touch ${projectId} without --allow-prod.`);

const app = initializeApp({ projectId });
const auth = getAuth(app);
const db = getFirestore(app);
const operator = `script:${userInfo().username}`;

switch (command) {
  case 'grant':
    await grant(normalizeEmail(rawEmail));
    break;
  case 'revoke':
    await revoke(normalizeEmail(rawEmail));
    break;
  case 'list':
    await list();
    break;
  default:
    fail(USAGE);
}

async function grant(email) {
  await db.doc(`adminAllowlist/${email}`).set({ email, addedBy: operator, addedAt: FieldValue.serverTimestamp() });
  const user = await findUser(email);
  if (!user) {
    await audit('admin.allowlist', `adminAllowlist/${email}`, null, { email });
    say(`${email} is allow-listed. Ask them to sign in to the console once, then run grant again to give the role.`);
    return;
  }
  if (user.phoneNumber) fail(`${email} is a phone-OTP account; admins must be Google accounts (PLAN §12.11).`);
  if (!user.providerData.some((p) => p.providerId === 'google.com')) {
    fail(`${email} hasn't signed in with Google; admins must be Google accounts (PLAN §12.11).`);
  }
  const before = user.customClaims ?? {};
  await auth.setCustomUserClaims(user.uid, { role: 'admin' });
  await db.doc(`admins/${user.uid}`).set({ email, grantedBy: operator, grantedAt: FieldValue.serverTimestamp() });
  await audit('admin.grant', `admins/${user.uid}`, before, { role: 'admin' });
  say(`${email} is now an admin in ${projectId}. The role applies on their next sign-in or token refresh.`);
}

async function revoke(email) {
  await db.doc(`adminAllowlist/${email}`).delete();
  const user = await findUser(email);
  if (!user) {
    await audit('admin.revoke', `adminAllowlist/${email}`, { email }, null);
    say(`${email} removed from the allow-list (no account).`);
    return;
  }
  const before = user.customClaims ?? {};
  const { role, ...rest } = before;
  await auth.setCustomUserClaims(user.uid, role === 'admin' ? rest : before);
  await auth.revokeRefreshTokens(user.uid);
  await db.doc(`admins/${user.uid}`).delete();
  await audit('admin.revoke', `admins/${user.uid}`, before, role === 'admin' ? rest : before);
  say(`${email} is no longer an admin in ${projectId}; their sessions end within the hour.`);
}

async function list() {
  const [allow, admins] = await Promise.all([db.collection('adminAllowlist').get(), db.collection('admins').get()]);
  say(`Allow-list (${allow.size}): ${allow.docs.map((d) => d.id).join(', ') || '—'}`);
  say(`Admins with the role (${admins.size}): ${admins.docs.map((d) => d.get('email')).join(', ') || '—'}`);
}

async function findUser(email) {
  try {
    return await auth.getUserByEmail(email);
  } catch (e) {
    if (e.code === 'auth/user-not-found') return null;
    throw e;
  }
}

function audit(action, target, before, after) {
  return db.collection('auditLogs').add({ actorUid: operator, action, target, before, after, at: FieldValue.serverTimestamp() });
}

function normalizeEmail(email) {
  if (!email || !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) fail(USAGE);
  return email.trim().toLowerCase();
}

function say(message) {
  console.log(message);
}

function fail(message) {
  console.error(message);
  process.exit(1);
}
