// mechanics/{uid}, its private KYC, and presence/{uid} (PLAN §8, §10.0).

const { assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { doc, getDoc, setDoc, updateDoc, writeBatch, serverTimestamp, Timestamp } = require('firebase/firestore');
const h = require('./helpers');

beforeAll(h.setup);
afterAll(h.teardown);
beforeEach(async () => {
  await h.getEnv().clearFirestore();
  const stamps = { createdAt: h.daysAgo(1), updatedAt: h.daysAgo(1), schemaVersion: 1 };
  await h.seed({
    'mechanics/mech1': { ...h.workshopMechanic(), status: 'approved', rating: 4.8, ratingCount: 10, jobsCompleted: 12, ...stamps },
    'mechanics/mechP': { ...h.independentMechanic(), ...stamps },
    'mechanics/mechBlocked': { ...h.workshopMechanic(), status: 'blocked', ...stamps },
    'mechanics/mech1/private/kyc': { ...h.kyc('mech1'), ...stamps },
    'presence/mech1': { isOnline: false, location: h.location(), updatedAt: h.minutesAgo(5), cityId: 'ahmedabad', activeBookingId: null },
  });
});

describe('mechanics/{uid} registration (M1)', () => {
  test('a new phone user registers as a workshop mechanic', async () => {
    await assertSucceeds(setDoc(doc(h.as('newMech'), 'mechanics/newMech'), h.stampNew(h.workshopMechanic())));
  });

  test('a new phone user registers as an independent mechanic', async () => {
    await assertSucceeds(setDoc(doc(h.as('newMech'), 'mechanics/newMech'), h.stampNew(h.independentMechanic())));
  });

  test('the 🔒 fields may be left out entirely', async () => {
    const { status, rating, ratingCount, jobsCompleted, ...rest } = h.workshopMechanic();
    await assertSucceeds(setDoc(doc(h.as('newMech'), 'mechanics/newMech'), h.stampNew(rest)));
  });

  test('cannot register as approved or with a rating (🔒)', async () => {
    const ref = doc(h.as('newMech'), 'mechanics/newMech');
    await assertFails(setDoc(ref, h.stampNew({ ...h.workshopMechanic(), status: 'approved' })));
    await assertFails(setDoc(ref, h.stampNew({ ...h.workshopMechanic(), rating: 5, ratingCount: 100 })));
    await assertFails(setDoc(ref, h.stampNew({ ...h.workshopMechanic(), jobsCompleted: 50 })));
  });

  test("each type writes only its own fields", async () => {
    const ref = doc(h.as('newMech'), 'mechanics/newMech');
    await assertFails(setDoc(ref, h.stampNew({ ...h.workshopMechanic(), experienceYears: 3 })));
    await assertFails(setDoc(ref, h.stampNew({ ...h.independentMechanic(), shopName: 'Fake shop' })));
  });

  test('type-specific fields are required', async () => {
    const ref = doc(h.as('newMech'), 'mechanics/newMech');
    const { shopPhotoUrl, ...noShopPhoto } = h.workshopMechanic();
    await assertFails(setDoc(ref, h.stampNew(noShopPhoto)));
    await assertFails(setDoc(ref, h.stampNew({ ...h.independentMechanic(), toolkitPhotoUrls: ['https://example.invalid/t1.jpg'] })));
    await assertFails(setDoc(ref, h.stampNew({ ...h.independentMechanic(), travelVehicle: { type: 'bike', regNo: 'NOPE' } })));
  });

  test('only for yourself, and only with a phone-verified account', async () => {
    await assertFails(setDoc(doc(h.as('newMech'), 'mechanics/someoneElse'), h.stampNew(h.workshopMechanic())));
    await assertFails(setDoc(doc(h.as('googleUser'), 'mechanics/googleUser'), h.stampNew(h.workshopMechanic())));
    await assertFails(setDoc(doc(h.as(null), 'mechanics/anon'), h.stampNew(h.workshopMechanic())));
  });

  test('unknown cities are rejected', async () => {
    await assertFails(setDoc(doc(h.as('newMech'), 'mechanics/newMech'), h.stampNew({ ...h.workshopMechanic(), cityId: 'surat' })));
  });
});

describe('mechanics/{uid} after registration', () => {
  test('pending: can fix own profile fields', async () => {
    await assertSucceeds(updateDoc(doc(h.as('mechP'), 'mechanics/mechP'), h.stampUpdate({ experienceYears: 10, services: ['flat_tyre', 'battery'] })));
  });

  test('pending: cannot change type, city or 🔒 fields', async () => {
    const ref = doc(h.as('mechP'), 'mechanics/mechP');
    await assertFails(updateDoc(ref, h.stampUpdate({ status: 'approved' })));
    await assertFails(updateDoc(ref, h.stampUpdate({ cityId: 'bharuch' })));
    await assertFails(updateDoc(ref, h.stampUpdate({ rating: 5 })));
    await assertFails(updateDoc(ref, h.stampUpdate({ mechanicType: 'workshop' })));
  });

  test('approved: only fcmToken', async () => {
    const ref = doc(h.as('mech1'), 'mechanics/mech1');
    await assertSucceeds(updateDoc(ref, h.stampUpdate({ fcmToken: 'new-token' })));
    await assertFails(updateDoc(ref, h.stampUpdate({ name: 'Someone else' })));
    await assertFails(updateDoc(ref, h.stampUpdate({ rating: 5 })));
    await assertFails(updateDoc(ref, h.stampUpdate({ status: 'approved', jobsCompleted: 999 })));
  });

  test('blocked: cannot unblock themself', async () => {
    await assertFails(updateDoc(doc(h.as('mechBlocked'), 'mechanics/mechBlocked'), h.stampUpdate({ status: 'approved' })));
  });

  test('readable by self and admins only (customers see the mechanicCard snapshot)', async () => {
    await assertSucceeds(getDoc(doc(h.as('mech1'), 'mechanics/mech1')));
    await assertSucceeds(getDoc(doc(h.as('admin1'), 'mechanics/mech1')));
    await assertFails(getDoc(doc(h.as('cust1'), 'mechanics/mech1')));
    await assertFails(getDoc(doc(h.as('mech2'), 'mechanics/mech1')));
  });

  test('admins do not write profiles directly (approve/block go through callables)', async () => {
    await assertFails(updateDoc(doc(h.as('admin1'), 'mechanics/mechP'), { status: 'approved' }));
  });
});

describe('mechanics/{uid}/private/kyc', () => {
  test('profile + KYC in one batch at registration (independent)', async () => {
    const db = h.as('newMech');
    const batch = writeBatch(db);
    batch.set(doc(db, 'mechanics/newMech'), h.stampNew(h.independentMechanic()));
    batch.set(doc(db, 'mechanics/newMech/private/kyc'), h.stampNew(h.kyc('newMech', 'independent')));
    await assertSucceeds(batch.commit());
  });

  test('workshop KYC without selfie / address proof', async () => {
    const db = h.as('newMech');
    await setDoc(doc(db, 'mechanics/newMech'), h.stampNew(h.workshopMechanic()));
    await assertSucceeds(setDoc(doc(db, 'mechanics/newMech/private/kyc'), h.stampNew(h.kyc('newMech'))));
  });

  test('independent KYC needs selfie with ID and address proof', async () => {
    const db = h.as('mechP');
    const { selfieWithIdPath, ...noSelfie } = h.kyc('mechP', 'independent');
    await assertFails(setDoc(doc(db, 'mechanics/mechP/private/kyc'), h.stampNew(noSelfie)));
    await assertSucceeds(setDoc(doc(db, 'mechanics/mechP/private/kyc'), h.stampNew(h.kyc('mechP', 'independent'))));
  });

  test('cannot set 🔒 fields: kycCheckedBy, verificationCall', async () => {
    const ref = doc(h.as('mechP'), 'mechanics/mechP/private/kyc');
    await assertFails(setDoc(ref, h.stampNew({ ...h.kyc('mechP', 'independent'), kycCheckedBy: 'mechP' })));
    await assertFails(
      setDoc(ref, h.stampNew({ ...h.kyc('mechP', 'independent'), verificationCall: { doneBy: 'mechP', at: Timestamp.now(), notes: 'ok' } })),
    );
  });

  test('ID proof must be a Storage path under the own KYC folder, UPI must be valid', async () => {
    const ref = doc(h.as('mechP'), 'mechanics/mechP/private/kyc');
    await assertFails(setDoc(ref, h.stampNew({ ...h.kyc('mechP', 'independent'), idProofPath: 'https://evil.example/id.jpg' })));
    await assertFails(setDoc(ref, h.stampNew({ ...h.kyc('mechP', 'independent'), idProofPath: 'mechanics/mech1/kyc/id.jpg' })));
    await assertFails(setDoc(ref, h.stampNew({ ...h.kyc('mechP', 'independent'), upiId: 'not-a-upi' })));
  });

  test('write once, and only while pending', async () => {
    await assertFails(updateDoc(doc(h.as('mech1'), 'mechanics/mech1/private/kyc'), h.stampUpdate({ upiId: 'other@ybl' })));
  });

  test('self and admin read; customers and other mechanics cannot', async () => {
    await assertSucceeds(getDoc(doc(h.as('mech1'), 'mechanics/mech1/private/kyc')));
    await assertSucceeds(getDoc(doc(h.as('admin1'), 'mechanics/mech1/private/kyc')));
    await assertFails(getDoc(doc(h.as('mech2'), 'mechanics/mech1/private/kyc')));
    await assertFails(getDoc(doc(h.as('cust1'), 'mechanics/mech1/private/kyc')));
  });
});

describe('presence/{uid}', () => {
  test('an approved mechanic goes online and moves', async () => {
    await assertSucceeds(
      updateDoc(doc(h.as('mech1'), 'presence/mech1'), { isOnline: true, location: h.location(23.04, 72.51), updatedAt: serverTimestamp() }),
    );
  });

  test('first go-online creates presence with the profile city', async () => {
    await h.seed({ 'mechanics/mech2': { ...h.workshopMechanic(), status: 'approved', createdAt: h.daysAgo(1), updatedAt: h.daysAgo(1), schemaVersion: 1 } });
    const ref = doc(h.as('mech2'), 'presence/mech2');
    const p = { isOnline: true, location: h.location(), updatedAt: serverTimestamp(), activeBookingId: null };
    await assertFails(setDoc(ref, { ...p, cityId: 'bharuch' }));
    await assertFails(setDoc(ref, { ...p, cityId: 'ahmedabad', activeBookingId: 'b1' }));
    await assertSucceeds(setDoc(ref, { ...p, cityId: 'ahmedabad' }));
  });

  test('cannot change cityId or activeBookingId (🔒)', async () => {
    const ref = doc(h.as('mech1'), 'presence/mech1');
    await assertFails(updateDoc(ref, { cityId: 'bharuch', updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(ref, { activeBookingId: 'b9', updatedAt: serverTimestamp() }));
  });

  test('pending or blocked mechanics cannot go online', async () => {
    const p = { isOnline: true, location: h.location(), updatedAt: serverTimestamp(), cityId: 'ankleshwar', activeBookingId: null };
    await assertFails(setDoc(doc(h.as('mechP'), 'presence/mechP'), p));
    await assertFails(setDoc(doc(h.as('mechBlocked'), 'presence/mechBlocked'), { ...p, cityId: 'ahmedabad' }));
  });

  test('customers can never read presence (stalking control)', async () => {
    await assertFails(getDoc(doc(h.as('cust1'), 'presence/mech1')));
    await assertFails(getDoc(doc(h.as('mech2'), 'presence/mech1')));
    await assertSucceeds(getDoc(doc(h.as('mech1'), 'presence/mech1')));
    await assertSucceeds(getDoc(doc(h.as('admin1'), 'presence/mech1')));
  });
});
