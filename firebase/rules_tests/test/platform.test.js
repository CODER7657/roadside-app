// prices, serviceAreas, appConfig, inbox, auditLogs, admins (PLAN §8, §12.11).

const { assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { doc, getDoc, getDocs, setDoc, updateDoc, deleteDoc, addDoc, collection, writeBatch, serverTimestamp, GeoPoint } = require('firebase/firestore');
const h = require('./helpers');

const price = (extra = {}) => ({
  vehicleType: 'car',
  problemType: 'flat_tyre',
  min: 350,
  max: 600,
  includes: 'Puncture repair or spare fitting',
  cityOverrides: { ankleshwar: { min: 400, max: 700 } },
  createdAt: h.daysAgo(1),
  updatedAt: serverTimestamp(),
  schemaVersion: 1,
  ...extra,
});

const area = (extra = {}) => ({
  name: { en: 'Bharuch', hi: 'भरूच', gu: 'ભરૂચ' },
  center: new GeoPoint(21.7051, 72.9959),
  radiusKm: 12,
  active: true,
  supportPhone: '+919800000000',
  launchedAt: null,
  createdAt: h.daysAgo(1),
  updatedAt: serverTimestamp(),
  schemaVersion: 1,
  ...extra,
});

const config = { minSupportedBuild: 1, maintenanceMessage: null, supportPhone: '+919800000000', dispatchEnabled: true };

beforeAll(h.setup);
afterAll(h.teardown);
beforeEach(async () => {
  await h.getEnv().clearFirestore();
  await h.seed({
    'prices/car_flat_tyre': { ...price(), updatedAt: h.daysAgo(1) },
    'serviceAreas/bharuch': { ...area(), updatedAt: h.daysAgo(1) },
    'appConfig/public': config,
    'appConfig/secret': { internal: true },
    'inbox/cust1/items/i1': { type: 'booking_status', titleKey: 't', bodyKey: 'b', args: {}, bookingId: 'b1', read: false },
    'auditLogs/a1': { actorUid: 'admin1', action: 'price.update', target: 'prices/car_flat_tyre', before: null, after: null, at: h.daysAgo(1) },
    'admins/admin1': { email: 'admin@example.com' },
  });
});

describe('prices', () => {
  test('signed-in users read; signed-out cannot', async () => {
    await assertSucceeds(getDoc(doc(h.as('cust1'), 'prices/car_flat_tyre')));
    await assertSucceeds(getDoc(doc(h.as('mech1'), 'prices/car_flat_tyre')));
    await assertFails(getDoc(doc(h.as(null), 'prices/car_flat_tyre')));
  });

  test('admins edit with validation (A4)', async () => {
    const db = h.as('admin1');
    await assertSucceeds(setDoc(doc(db, 'prices/car_flat_tyre'), price({ min: 400 })));
    await assertFails(setDoc(doc(db, 'prices/car_flat_tyre'), price({ min: 700, max: 600 })));
    await assertFails(setDoc(doc(db, 'prices/car_battery'), price())); // id must match the fields
    await assertFails(setDoc(doc(db, 'prices/car_flat_tyre'), price({ cityOverrides: { surat: { min: 1, max: 2 } } })));
  });

  test('customers and mechanics cannot change prices', async () => {
    await assertFails(setDoc(doc(h.as('cust1'), 'prices/car_flat_tyre'), price({ min: 1, max: 2 })));
    await assertFails(setDoc(doc(h.as('mech1'), 'prices/car_flat_tyre'), price({ max: 5000 })));
    await assertFails(setDoc(doc(h.as('googleUser'), 'prices/car_flat_tyre'), price()));
  });
});

describe('serviceAreas', () => {
  test('everyone reads, even signed out (the "not in your area" screen)', async () => {
    await assertSucceeds(getDoc(doc(h.as(null), 'serviceAreas/bharuch')));
    await assertSucceeds(getDocs(collection(h.as('cust1'), 'serviceAreas')));
  });

  test('admins switch a city off and tune the radius (A6)', async () => {
    await assertSucceeds(setDoc(doc(h.as('admin1'), 'serviceAreas/bharuch'), area({ active: false, radiusKm: 10 })));
    await assertFails(setDoc(doc(h.as('admin1'), 'serviceAreas/bharuch'), area({ radiusKm: 500 })));
    await assertFails(setDoc(doc(h.as('admin1'), 'serviceAreas/bharuch'), area({ supportPhone: '12345' })));
    await assertFails(deleteDoc(doc(h.as('admin1'), 'serviceAreas/bharuch')));
  });

  test('nobody else writes', async () => {
    await assertFails(setDoc(doc(h.as('cust1'), 'serviceAreas/bharuch'), area({ active: false })));
    await assertFails(setDoc(doc(h.as('mech1'), 'serviceAreas/surat'), area()));
  });
});

describe('appConfig', () => {
  test('everyone reads public (force update, maintenance)', async () => {
    await assertSucceeds(getDoc(doc(h.as(null), 'appConfig/public')));
    await assertFails(getDoc(doc(h.as('cust1'), 'appConfig/secret')));
  });

  test('admins flip the kill switch; others cannot', async () => {
    await assertSucceeds(setDoc(doc(h.as('admin1'), 'appConfig/public'), { ...config, dispatchEnabled: false, maintenanceMessage: 'Back soon' }));
    await assertFails(setDoc(doc(h.as('admin1'), 'appConfig/public'), { ...config, debug: true }));
    await assertFails(updateDoc(doc(h.as('cust1'), 'appConfig/public'), { dispatchEnabled: false }));
    await assertFails(updateDoc(doc(h.as('mech1'), 'appConfig/public'), { minSupportedBuild: 0 }));
  });
});

describe('inbox', () => {
  test('owner reads and marks read, nothing else', async () => {
    const db = h.as('cust1');
    await assertSucceeds(getDocs(collection(db, 'inbox/cust1/items')));
    await assertSucceeds(updateDoc(doc(db, 'inbox/cust1/items/i1'), { read: true }));
    await assertFails(updateDoc(doc(db, 'inbox/cust1/items/i1'), { titleKey: 'spoofed' }));
    await assertFails(addDoc(collection(db, 'inbox/cust1/items'), { type: 'x', read: false }));
    await assertFails(deleteDoc(doc(db, 'inbox/cust1/items/i1')));
  });

  test('others cannot read it', async () => {
    await assertFails(getDocs(collection(h.as('cust2'), 'inbox/cust1/items')));
    await assertFails(getDoc(doc(h.as('admin1'), 'inbox/cust1/items/i1')));
  });
});

describe('auditLogs and admins (admin only)', () => {
  test('admins read and append; history is never edited', async () => {
    const db = h.as('admin1');
    await assertSucceeds(getDocs(collection(db, 'auditLogs')));
    const entry = { actorUid: 'admin1', action: 'price.update', target: 'prices/car_flat_tyre', before: { min: 350 }, after: { min: 400 }, at: serverTimestamp() };
    await assertSucceeds(addDoc(collection(db, 'auditLogs'), entry));
    await assertFails(addDoc(collection(db, 'auditLogs'), { ...entry, actorUid: 'someoneElse' }));
    await assertFails(updateDoc(doc(db, 'auditLogs/a1'), { action: 'nothing' }));
    await assertFails(deleteDoc(doc(db, 'auditLogs/a1')));
  });

  test('a price change and its audit entry in one batch', async () => {
    const db = h.as('admin1');
    const batch = writeBatch(db);
    batch.set(doc(db, 'prices/car_flat_tyre'), price({ max: 650 }));
    batch.set(doc(collection(db, 'auditLogs')), {
      actorUid: 'admin1',
      action: 'price.update',
      target: 'prices/car_flat_tyre',
      before: { max: 600 },
      after: { max: 650 },
      at: serverTimestamp(),
    });
    await assertSucceeds(batch.commit());
  });

  test('non-admins, incl. Google accounts without the claim, see nothing', async () => {
    for (const uid of ['cust1', 'mech1', 'googleUser']) {
      await assertFails(getDocs(collection(h.as(uid), 'auditLogs')));
      await assertFails(getDoc(doc(h.as(uid), 'admins/admin1')));
    }
    await assertFails(addDoc(collection(h.as('cust1'), 'auditLogs'), { actorUid: 'cust1', action: 'x', target: 'y', at: serverTimestamp() }));
  });

  test('the admins list and allow-list are never client-writable', async () => {
    await assertSucceeds(getDoc(doc(h.as('admin1'), 'admins/admin1')));
    await assertFails(setDoc(doc(h.as('admin1'), 'admins/newAdmin'), { email: 'x@example.com' }));
    await assertFails(setDoc(doc(h.as('cust1'), 'admins/cust1'), { email: 'x@example.com' }));
    await assertFails(getDoc(doc(h.as('admin1'), 'adminAllowlist/admin@example.com')));
  });

  test('anything not listed is denied', async () => {
    await assertFails(getDoc(doc(h.as('admin1'), 'somethingNew/x')));
    await assertFails(setDoc(doc(h.as('admin1'), 'somethingNew/x'), { a: 1 }));
  });
});
