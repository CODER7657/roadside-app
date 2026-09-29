// Shared setup for the rules tests: one emulator project, signed-in contexts per role, fixtures
// written with rules disabled, and payloads shaped like roadside_core's toJson() + stampNew().

const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const { initializeTestEnvironment } = require('@firebase/rules-unit-testing');
const { GeoPoint, Timestamp, serverTimestamp, doc, setDoc } = require('firebase/firestore');

const PROJECT_ID = 'demo-roadside-rules';

const PHONES = {
  cust1: '+919800000001',
  cust2: '+919800000002',
  mech1: '+919800000011',
  mech2: '+919800000012',
  mechP: '+919800000013',
  newMech: '+919800000014',
};

/** Custom claims per test user, as Functions would set them. */
const USERS = {
  cust1: { role: 'customer', phone_number: PHONES.cust1 },
  cust2: { role: 'customer', phone_number: PHONES.cust2 },
  mech1: { role: 'mechanic', mechanicStatus: 'approved', phone_number: PHONES.mech1 },
  mech2: { role: 'mechanic', mechanicStatus: 'approved', phone_number: PHONES.mech2 },
  mechP: { role: 'mechanic', mechanicStatus: 'pending', phone_number: PHONES.mechP },
  mechBlocked: { role: 'mechanic', mechanicStatus: 'blocked', phone_number: '+919800000015' },
  // Just signed up in the mechanic app: still `customer` until onMechanicRegistered runs.
  newMech: { role: 'customer', phone_number: PHONES.newMech },
  admin1: { role: 'admin', email: 'admin@example.com' },
  // A Google account without the admin claim (PLAN §12.11 layer 2).
  googleUser: { email: 'someone@example.com' },
};

let env;

async function setup() {
  env = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules: readFileSync(join(__dirname, '..', '..', 'firestore.rules'), 'utf8') },
  });
  return env;
}

async function teardown() {
  await env?.cleanup();
}

/** Firestore for a test user (`as('cust1')`), or signed out (`as(null)`). */
function as(uid) {
  const ctx = uid ? env.authenticatedContext(uid, USERS[uid]) : env.unauthenticatedContext();
  return ctx.firestore();
}

/** Writes fixtures with rules disabled. `docs` is { 'path/to/doc': data }. */
async function seed(docs) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    for (const [path, data] of Object.entries(docs)) {
      await setDoc(doc(db, path), data);
    }
  });
}

const minutesAgo = (m) => Timestamp.fromMillis(Date.now() - m * 60_000);
const daysAgo = (d) => minutesAgo(d * 24 * 60);
const hoursFromNow = (h) => Timestamp.fromMillis(Date.now() + h * 3_600_000);

/** createdAt / updatedAt / schemaVersion, as roadside_core's stampNew(). */
const stampNew = (data) => ({ ...data, createdAt: serverTimestamp(), updatedAt: serverTimestamp(), schemaVersion: 1 });
/** updatedAt, as roadside_core's stampUpdate(). */
const stampUpdate = (data) => ({ ...data, updatedAt: serverTimestamp() });

// ---------------------------------------------------------------- payloads (roadside_core shapes)

const user = (uid = 'cust1') => ({
  name: 'Riya Shah',
  phone: PHONES[uid],
  language: 'en',
  emergencyContacts: [{ name: 'Amit Shah', phone: '+919800000002' }],
  fcmToken: null,
  consent: { version: '2026-09', acceptedAt: Timestamp.now() },
  deletionRequestedAt: null,
});

const vehicle = () => ({
  type: 'car',
  brand: 'Maruti Suzuki',
  model: 'Swift',
  regNo: 'GJ01AB1234',
  fuel: 'petrol',
  isDefault: true,
});

const workshopMechanic = () => ({
  name: 'Imran Shaikh',
  profilePhotoUrl: 'https://example.invalid/imran.jpg',
  mechanicType: 'workshop',
  shopName: 'Shaikh Auto Works',
  shopAddress: 'Bodakdev, Ahmedabad',
  shopPhotoUrl: 'https://example.invalid/shop.jpg',
  cityId: 'ahmedabad',
  vehicleTypes: ['car', 'bike'],
  services: ['flat_tyre', 'battery'],
  status: 'pending',
  rating: 0,
  ratingCount: 0,
  jobsCompleted: 0,
});

const independentMechanic = () => ({
  name: 'Suresh Vasava',
  profilePhotoUrl: 'https://example.invalid/suresh.jpg',
  mechanicType: 'independent',
  baseArea: { locality: 'GIDC Ankleshwar', geopoint: new GeoPoint(21.6264, 73.0152) },
  experienceYears: 9,
  toolkitPhotoUrls: ['https://example.invalid/t1.jpg', 'https://example.invalid/t2.jpg'],
  travelVehicle: { type: 'scooter', regNo: 'GJ16GH7788' },
  cityId: 'ankleshwar',
  vehicleTypes: ['bike', 'scooter'],
  services: ['flat_tyre'],
  status: 'pending',
  rating: 0,
  ratingCount: 0,
  jobsCompleted: 0,
});

const kyc = (uid, type = 'workshop') => ({
  phone: PHONES[uid],
  idProofPath: `mechanics/${uid}/kyc/id-proof.jpg`,
  upiId: 'suresh.v@ybl',
  upiName: 'SURESH VASAVA',
  ...(type === 'independent'
    ? {
        selfieWithIdPath: `mechanics/${uid}/kyc/selfie.jpg`,
        addressProofPath: `mechanics/${uid}/kyc/address.jpg`,
        referenceContact: { name: 'Patel Motors', phone: '+919800000020' },
      }
    : {}),
});

const location = (lat = 23.0395, lng = 72.5066) => ({ geopoint: new GeoPoint(lat, lng), geohash: 'ts5e4h16jp' });

const booking = ({ customerId = 'cust1', mechanicId = 'mech1', status = 'arriving', updatedAt = minutesAgo(1) } = {}) => ({
  customerId,
  mechanicId,
  cityId: 'ahmedabad',
  status,
  priceEstimate: { min: 350, max: 600 },
  createdAt: minutesAgo(30),
  updatedAt,
  schemaVersion: 1,
});

module.exports = {
  PHONES,
  setup,
  teardown,
  as,
  seed,
  minutesAgo,
  daysAgo,
  hoursFromNow,
  stampNew,
  stampUpdate,
  user,
  vehicle,
  workshopMechanic,
  independentMechanic,
  kyc,
  location,
  booking,
  getEnv: () => env,
};
