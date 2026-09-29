// users/{uid} and users/{uid}/vehicles (PLAN §8).

const { assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { doc, getDoc, setDoc, updateDoc, deleteDoc, addDoc, collection, serverTimestamp, Timestamp } = require('firebase/firestore');
const h = require('./helpers');

beforeAll(h.setup);
afterAll(h.teardown);
beforeEach(async () => {
  await h.getEnv().clearFirestore();
  await h.seed({
    'users/cust1': { ...h.user('cust1'), createdAt: h.daysAgo(3), updatedAt: h.daysAgo(3), schemaVersion: 1 },
    'users/cust1/vehicles/v1': { ...h.vehicle(), createdAt: h.daysAgo(3), updatedAt: h.daysAgo(3), schemaVersion: 1 },
  });
});

describe('users/{uid}', () => {
  test('a customer creates their own profile with the Auth phone', async () => {
    await assertSucceeds(setDoc(doc(h.as('cust2'), 'users/cust2'), h.stampNew(h.user('cust2'))));
  });

  test('a customer cannot create a profile for someone else', async () => {
    await assertFails(setDoc(doc(h.as('cust2'), 'users/cust1x'), h.stampNew(h.user('cust2'))));
  });

  test('the phone must be the one from Auth (🔒)', async () => {
    await assertFails(setDoc(doc(h.as('cust2'), 'users/cust2'), h.stampNew({ ...h.user('cust2'), phone: '+919999999999' })));
  });

  test('deletionRequestedAt cannot be set by the client (🔒)', async () => {
    await assertFails(
      setDoc(doc(h.as('cust2'), 'users/cust2'), h.stampNew({ ...h.user('cust2'), deletionRequestedAt: Timestamp.now() })),
    );
  });

  test('unknown fields and client-chosen timestamps are rejected', async () => {
    await assertFails(setDoc(doc(h.as('cust2'), 'users/cust2'), h.stampNew({ ...h.user('cust2'), role: 'admin' })));
    await assertFails(
      setDoc(doc(h.as('cust2'), 'users/cust2'), { ...h.user('cust2'), createdAt: Timestamp.now(), updatedAt: Timestamp.now(), schemaVersion: 1 }),
    );
  });

  test('at most 3 emergency contacts, each E.164', async () => {
    const c = { name: 'X', phone: '+919800000009' };
    await assertFails(setDoc(doc(h.as('cust2'), 'users/cust2'), h.stampNew({ ...h.user('cust2'), emergencyContacts: [c, c, c, c] })));
    await assertFails(
      setDoc(doc(h.as('cust2'), 'users/cust2'), h.stampNew({ ...h.user('cust2'), emergencyContacts: [{ name: 'X', phone: '98000' }] })),
    );
  });

  test('owner reads and edits allowed fields', async () => {
    const db = h.as('cust1');
    await assertSucceeds(getDoc(doc(db, 'users/cust1')));
    await assertSucceeds(updateDoc(doc(db, 'users/cust1'), h.stampUpdate({ language: 'gu', fcmToken: 'token' })));
  });

  test('owner cannot change phone or deletionRequestedAt', async () => {
    const db = h.as('cust1');
    await assertFails(updateDoc(doc(db, 'users/cust1'), h.stampUpdate({ phone: '+919999999999' })));
    await assertFails(updateDoc(doc(db, 'users/cust1'), h.stampUpdate({ deletionRequestedAt: serverTimestamp() })));
  });

  test('others cannot read a profile; admins can', async () => {
    await assertFails(getDoc(doc(h.as('cust2'), 'users/cust1')));
    await assertFails(getDoc(doc(h.as('mech1'), 'users/cust1')));
    await assertFails(getDoc(doc(h.as(null), 'users/cust1')));
    await assertSucceeds(getDoc(doc(h.as('admin1'), 'users/cust1')));
  });

  test('nobody deletes a profile directly (requestAccountDeletion)', async () => {
    await assertFails(deleteDoc(doc(h.as('cust1'), 'users/cust1')));
  });
});

describe('users/{uid}/vehicles', () => {
  test('owner adds a vehicle with a valid registration number', async () => {
    await assertSucceeds(addDoc(collection(h.as('cust1'), 'users/cust1/vehicles'), h.stampNew(h.vehicle())));
    await assertSucceeds(
      addDoc(collection(h.as('cust1'), 'users/cust1/vehicles'), h.stampNew({ ...h.vehicle(), type: 'ev', regNo: '22BH1234AA', fuel: 'electric' })),
    );
  });

  test('invalid registration numbers and types are rejected', async () => {
    const col = collection(h.as('cust1'), 'users/cust1/vehicles');
    await assertFails(addDoc(col, h.stampNew({ ...h.vehicle(), regNo: 'gj 01 ab 1234' })));
    await assertFails(addDoc(col, h.stampNew({ ...h.vehicle(), type: 'truck' })));
    await assertFails(addDoc(col, h.stampNew({ ...h.vehicle(), fuel: 'hydrogen' })));
  });

  test('owner updates and deletes; others cannot touch', async () => {
    await assertSucceeds(updateDoc(doc(h.as('cust1'), 'users/cust1/vehicles/v1'), h.stampUpdate({ isDefault: false })));
    await assertFails(updateDoc(doc(h.as('cust2'), 'users/cust1/vehicles/v1'), h.stampUpdate({ isDefault: false })));
    await assertFails(getDoc(doc(h.as('cust2'), 'users/cust1/vehicles/v1')));
    await assertFails(addDoc(collection(h.as('cust2'), 'users/cust1/vehicles'), h.stampNew(h.vehicle())));
    await assertSucceeds(deleteDoc(doc(h.as('cust1'), 'users/cust1/vehicles/v1')));
  });
});
