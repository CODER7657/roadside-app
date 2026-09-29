import assert from 'node:assert/strict';
import { setTimeout as sleep } from 'node:timers/promises';
import { beforeEach, describe, it } from 'node:test';
import { initializeApp } from 'firebase-admin/app';
import { getAuth, type Auth } from 'firebase-admin/auth';
import { getFirestore, type Firestore } from 'firebase-admin/firestore';
import { authEmulatorRunning, emulatorRunning, TRIGGER_PROJECT } from './helpers.js';
import { registerMechanic } from '../src/triggers/onMechanicRegistered.js';
import { db } from '../src/lib/admin.js';
import { resetEmulators } from './dispatchFixtures.js';
import { INDEPENDENT, WORKSHOP } from './fixtures.js';

const ready = emulatorRunning && authEmulatorRunning;

let seq = 0;
const newUid = () => `mech-${process.pid}-${Date.now()}-${++seq}`;

async function waitFor<T>(read: () => Promise<T>, ok: (v: T) => boolean, ms = 20_000): Promise<T> {
  const until = Date.now() + ms;
  for (;;) {
    const v = await read();
    if (ok(v) || Date.now() > until) return v;
    await sleep(250);
  }
}

// Direct calls, in the test project (no trigger reacts to this data).
describe('registerMechanic (emulator)', { skip: !ready && 'no Firestore/Auth emulator' }, () => {
  beforeEach(resetEmulators);

  async function user(claims: Record<string, unknown>): Promise<string> {
    const uid = newUid();
    await getAuth().createUser({ uid });
    await getAuth().setCustomUserClaims(uid, claims);
    return uid;
  }

  it('grants the claims and fills the 🔒 fields the app left out', async () => {
    const uid = await user({ role: 'customer' });
    await db().doc(`mechanics/${uid}`).set(WORKSHOP);

    assert.equal(await registerMechanic(uid), 'granted');
    assert.deepEqual((await getAuth().getUser(uid)).customClaims, { role: 'mechanic', mechanicStatus: 'pending' });
    const doc = (await db().doc(`mechanics/${uid}`).get()).data()!;
    assert.equal(doc.status, 'pending');
    assert.equal(doc.rating, 0);
    assert.equal(doc.ratingCount, 0);
    assert.equal(doc.jobsCompleted, 0);
    assert.equal(doc.shopName, 'Shree Auto');
  });

  it('a retry after approval resets nothing', async () => {
    const uid = await user({ role: 'customer' });
    await db().doc(`mechanics/${uid}`).set(WORKSHOP);
    await registerMechanic(uid);

    // Admin approves; then the trigger is delivered again.
    await getAuth().setCustomUserClaims(uid, { role: 'mechanic', mechanicStatus: 'approved' });
    await db().doc(`mechanics/${uid}`).update({ status: 'approved', rating: 4.8, ratingCount: 3 });

    assert.equal(await registerMechanic(uid), 'already_mechanic');
    assert.deepEqual((await getAuth().getUser(uid)).customClaims, { role: 'mechanic', mechanicStatus: 'approved' });
    const doc = (await db().doc(`mechanics/${uid}`).get()).data()!;
    assert.equal(doc.status, 'approved');
    assert.equal(doc.rating, 4.8);
    assert.equal(doc.ratingCount, 3);
  });

  it('does not touch an admin', async () => {
    const uid = await user({ role: 'admin' });
    await db().doc(`mechanics/${uid}`).set(WORKSHOP);
    assert.equal(await registerMechanic(uid), 'admin_skipped');
    assert.deepEqual((await getAuth().getUser(uid)).customClaims, { role: 'admin' });
  });
});

// End to end: write the doc in the project the Functions emulator watches and let the
// real trigger do its work.
describe('onMechanicRegistered trigger (emulator)', { skip: !ready && 'no Firestore/Auth emulator' }, () => {
  let fs: Firestore;
  let auth: Auth;
  if (ready) {
    const app = initializeApp({ projectId: TRIGGER_PROJECT }, 'trigger-project');
    fs = getFirestore(app);
    auth = getAuth(app);
  }

  for (const [label, profile] of [['workshop', WORKSHOP], ['independent', INDEPENDENT]] as const) {
    it(`a new ${label} profile gets the mechanic claims and 🔒 defaults`, async () => {
      const uid = newUid();
      await auth.createUser({ uid });
      await auth.setCustomUserClaims(uid, { role: 'customer' });
      await fs.doc(`mechanics/${uid}`).set(profile);

      const claims = await waitFor(
        async () => (await auth.getUser(uid)).customClaims ?? {},
        (c) => c.role === 'mechanic',
      );
      assert.deepEqual(claims, { role: 'mechanic', mechanicStatus: 'pending' });

      const doc = await waitFor(
        async () => (await fs.doc(`mechanics/${uid}`).get()).data() ?? {},
        (d) => 'jobsCompleted' in d,
      );
      assert.equal(doc.status, 'pending');
      assert.equal(doc.rating, 0);
      assert.equal(doc.ratingCount, 0);
      assert.equal(doc.jobsCompleted, 0);
    });
  }
});
