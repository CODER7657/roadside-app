// bookings (+ OTP, chat), offers, liveLocations, shareLinks, reviews, complaints (PLAN §8, §9).

const { assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const {
  doc,
  getDoc,
  getDocs,
  setDoc,
  updateDoc,
  addDoc,
  deleteDoc,
  collection,
  query,
  where,
  serverTimestamp,
  GeoPoint,
} = require('firebase/firestore');
const h = require('./helpers');

beforeAll(h.setup);
afterAll(h.teardown);
beforeEach(async () => {
  await h.getEnv().clearFirestore();
  await h.seed({
    'bookings/b1': h.booking({ status: 'arriving' }),
    'bookings/b1/private/otp': { code: '4821', attempts: 0, lockedUntil: null },
    'bookings/b1/messages/m1': { senderId: 'cust1', text: 'Near the petrol pump', imagePath: null, createdAt: h.minutesAgo(2) },
    'bookings/bOther': h.booking({ customerId: 'cust2', mechanicId: 'mech2' }),
    'bookings/bDone': h.booking({ status: 'completed' }),
    'bookings/bDone/messages/m1': { senderId: 'mech1', text: 'Done', imagePath: null, createdAt: h.minutesAgo(1) },
    'bookings/bOld': h.booking({ status: 'completed', updatedAt: h.daysAgo(40) }),
    'bookings/bOld/messages/m1': { senderId: 'mech1', text: 'Done', imagePath: null, createdAt: h.daysAgo(40) },
    'bookings/bRequested': h.booking({ status: 'requested', mechanicId: null }),
    'offers/o1': { bookingId: 'bRequested', mechanicId: 'mech1', state: 'pending', areaName: 'Thaltej' },
    'liveLocations/b1': {
      mechanicGeopoint: new GeoPoint(23.0395, 72.5066),
      heading: 20,
      speed: 7.5,
      etaMinutes: 6,
      updatedAt: h.minutesAgo(0),
      expireAt: h.hoursFromNow(24),
    },
    'liveLocations/bDone': {
      mechanicGeopoint: new GeoPoint(23.0395, 72.5066),
      heading: 0,
      speed: 0,
      etaMinutes: 0,
      updatedAt: h.minutesAgo(10),
      expireAt: h.hoursFromNow(20),
    },
    'shareLinks/tok': { bookingId: 'b1', createdBy: 'cust1', expiresAt: h.hoursFromNow(3) },
    'reviews/bOld': { customerId: 'cust1', mechanicId: 'mech1', stars: 5, tags: [], comment: '', createdAt: h.daysAgo(40) },
    'complaints/c1': { bookingId: 'bDone', raisedBy: 'cust1', category: 'payment', text: 'x', status: 'open', resolution: null, createdAt: h.minutesAgo(1) },
    'rateLimits/cust1': { createBooking: [] },
  });
});

describe('bookings (🔒 Functions write)', () => {
  test('customer, assigned mechanic and admin read', async () => {
    await assertSucceeds(getDoc(doc(h.as('cust1'), 'bookings/b1')));
    await assertSucceeds(getDoc(doc(h.as('mech1'), 'bookings/b1')));
    await assertSucceeds(getDoc(doc(h.as('admin1'), 'bookings/b1')));
  });

  test("a customer can't read another customer's booking", async () => {
    await assertFails(getDoc(doc(h.as('cust1'), 'bookings/bOther')));
    await assertFails(getDoc(doc(h.as('mech1'), 'bookings/bOther')));
    await assertFails(getDoc(doc(h.as(null), 'bookings/b1')));
  });

  test('history query by customerId is allowed; an unscoped query is not', async () => {
    const db = h.as('cust1');
    await assertSucceeds(getDocs(query(collection(db, 'bookings'), where('customerId', '==', 'cust1'))));
    await assertFails(getDocs(collection(db, 'bookings')));
  });

  test("mechanic can't write status; nobody writes bookings from a client", async () => {
    await assertFails(updateDoc(doc(h.as('mech1'), 'bookings/b1'), { status: 'arrived' }));
    await assertFails(updateDoc(doc(h.as('cust1'), 'bookings/b1'), { priceEstimate: { min: 1, max: 2 } }));
    await assertFails(setDoc(doc(h.as('cust1'), 'bookings/new'), h.booking()));
    await assertFails(updateDoc(doc(h.as('admin1'), 'bookings/b1'), { status: 'cancelled' }));
    await assertFails(deleteDoc(doc(h.as('cust1'), 'bookings/b1')));
  });
});

describe('bookings/{id}/private/otp', () => {
  test('only the customer reads the start code', async () => {
    await assertSucceeds(getDoc(doc(h.as('cust1'), 'bookings/b1/private/otp')));
    await assertFails(getDoc(doc(h.as('mech1'), 'bookings/b1/private/otp')));
    await assertFails(getDoc(doc(h.as('cust2'), 'bookings/b1/private/otp')));
  });

  test('nobody writes it from a client', async () => {
    await assertFails(updateDoc(doc(h.as('cust1'), 'bookings/b1/private/otp'), { attempts: 0 }));
    await assertFails(updateDoc(doc(h.as('mech1'), 'bookings/b1/private/otp'), { attempts: 0 }));
  });
});

describe('bookings/{id}/messages', () => {
  const msg = (senderId, extra = {}) => ({ senderId, text: 'On my way', imagePath: null, createdAt: serverTimestamp(), ...extra });

  test('participants chat while the booking is active', async () => {
    await assertSucceeds(addDoc(collection(h.as('cust1'), 'bookings/b1/messages'), msg('cust1')));
    await assertSucceeds(addDoc(collection(h.as('mech1'), 'bookings/b1/messages'), msg('mech1')));
    await assertSucceeds(
      addDoc(collection(h.as('mech1'), 'bookings/b1/messages'), msg('mech1', { text: '', imagePath: 'bookings/b1/chat/photo.jpg' })),
    );
  });

  test('no chat after the booking ends, no spoofed sender, max 500 chars', async () => {
    await assertFails(addDoc(collection(h.as('cust1'), 'bookings/bDone/messages'), msg('cust1')));
    await assertFails(addDoc(collection(h.as('cust1'), 'bookings/b1/messages'), msg('mech1')));
    await assertFails(addDoc(collection(h.as('cust1'), 'bookings/b1/messages'), msg('cust1', { text: 'x'.repeat(501) })));
    await assertFails(addDoc(collection(h.as('cust1'), 'bookings/b1/messages'), msg('cust1', { text: '' })));
    await assertFails(
      addDoc(collection(h.as('cust1'), 'bookings/b1/messages'), msg('cust1', { imagePath: 'bookings/bOther/chat/x.jpg' })),
    );
  });

  test('outsiders cannot read or write', async () => {
    await assertFails(getDocs(collection(h.as('cust2'), 'bookings/b1/messages')));
    await assertFails(addDoc(collection(h.as('cust2'), 'bookings/b1/messages'), msg('cust2')));
  });

  test('readable for 30 days after the job, then not', async () => {
    await assertSucceeds(getDocs(collection(h.as('cust1'), 'bookings/bDone/messages')));
    await assertFails(getDocs(collection(h.as('cust1'), 'bookings/bOld/messages')));
  });

  test('messages are never edited', async () => {
    await assertFails(updateDoc(doc(h.as('cust1'), 'bookings/b1/messages/m1'), { text: 'edited' }));
  });
});

describe('offers (🔒)', () => {
  test('only the offered mechanic reads it', async () => {
    await assertSucceeds(getDoc(doc(h.as('mech1'), 'offers/o1')));
    await assertSucceeds(getDocs(query(collection(h.as('mech1'), 'offers'), where('mechanicId', '==', 'mech1'))));
    await assertFails(getDoc(doc(h.as('mech2'), 'offers/o1')));
    await assertFails(getDoc(doc(h.as('cust1'), 'offers/o1')));
  });

  test('mechanics cannot accept by writing the offer (respondToOffer)', async () => {
    await assertFails(updateDoc(doc(h.as('mech1'), 'offers/o1'), { state: 'accepted' }));
  });
});

describe('liveLocations', () => {
  const live = (extra = {}) => ({
    mechanicGeopoint: new GeoPoint(23.045, 72.509),
    heading: 20,
    speed: 7.5,
    etaMinutes: 4,
    updatedAt: serverTimestamp(),
    expireAt: h.hoursFromNow(24),
    ...extra,
  });

  test('the assigned mechanic writes during the job', async () => {
    await assertSucceeds(setDoc(doc(h.as('mech1'), 'liveLocations/b1'), live()));
    await assertSucceeds(setDoc(doc(h.as('mech1'), 'liveLocations/b1'), live({ heading: -1, speed: -1 })));
  });

  test('others cannot, and not after the job', async () => {
    await assertFails(setDoc(doc(h.as('mech2'), 'liveLocations/b1'), live()));
    await assertFails(setDoc(doc(h.as('cust1'), 'liveLocations/b1'), live()));
    await assertFails(setDoc(doc(h.as('mech1'), 'liveLocations/bDone'), live()));
    await assertFails(setDoc(doc(h.as('mech1'), 'liveLocations/bRequested'), live()));
  });

  test('expireAt must be a near-future TTL, fields are fixed', async () => {
    await assertFails(setDoc(doc(h.as('mech1'), 'liveLocations/b1'), live({ expireAt: h.hoursFromNow(24 * 365) })));
    await assertFails(setDoc(doc(h.as('mech1'), 'liveLocations/b1'), live({ expireAt: h.minutesAgo(1) })));
    await assertFails(setDoc(doc(h.as('mech1'), 'liveLocations/b1'), live({ customerPhone: '+919800000001' })));
  });

  test('the customer reads only while the booking is active', async () => {
    await assertSucceeds(getDoc(doc(h.as('cust1'), 'liveLocations/b1')));
    await assertFails(getDoc(doc(h.as('cust1'), 'liveLocations/bDone')));
    await assertFails(getDoc(doc(h.as('cust2'), 'liveLocations/b1')));
    await assertSucceeds(getDoc(doc(h.as('admin1'), 'liveLocations/b1')));
  });
});

describe('shareLinks and rateLimits (🔒 server only)', () => {
  test('nobody reads or writes them from a client', async () => {
    await assertFails(getDoc(doc(h.as('cust1'), 'shareLinks/tok')));
    await assertFails(getDoc(doc(h.as(null), 'shareLinks/tok')));
    await assertFails(setDoc(doc(h.as('cust1'), 'shareLinks/mine'), { bookingId: 'b1' }));
    await assertFails(getDoc(doc(h.as('cust1'), 'rateLimits/cust1')));
    await assertFails(setDoc(doc(h.as('cust1'), 'rateLimits/cust1'), {}));
    await assertFails(getDoc(doc(h.as('admin1'), 'rateLimits/cust1')));
  });
});

describe('reviews', () => {
  const review = (extra = {}) => ({
    customerId: 'cust1',
    mechanicId: 'mech1',
    stars: 5,
    tags: ['on_time'],
    comment: 'Quick fix',
    createdAt: serverTimestamp(),
    ...extra,
  });

  test("the booking's customer reviews a completed booking once", async () => {
    await assertSucceeds(setDoc(doc(h.as('cust1'), 'reviews/bDone'), review()));
    await assertFails(setDoc(doc(h.as('cust1'), 'reviews/bOld'), review())); // already reviewed
  });

  test('no reviews for active bookings, by others, or with a wrong mechanic / stars', async () => {
    await assertFails(setDoc(doc(h.as('cust1'), 'reviews/b1'), review()));
    await assertFails(setDoc(doc(h.as('cust2'), 'reviews/bDone'), review({ customerId: 'cust2' })));
    await assertFails(setDoc(doc(h.as('mech1'), 'reviews/bDone'), review()));
    await assertFails(setDoc(doc(h.as('cust1'), 'reviews/bDone'), review({ mechanicId: 'mech2' })));
    await assertFails(setDoc(doc(h.as('cust1'), 'reviews/bDone'), review({ stars: 6 })));
    await assertFails(setDoc(doc(h.as('cust1'), 'reviews/bDone'), review({ comment: 'x'.repeat(501) })));
  });

  test('tags come from the U14 list only (#57)', async () => {
    await assertSucceeds(setDoc(doc(h.as('cust1'), 'reviews/bDone'), review({ stars: 2, tags: ['late', 'overcharged'] })));
  });

  test('unknown, oversized or too many tags are rejected (#57)', async () => {
    await assertFails(setDoc(doc(h.as('cust1'), 'reviews/bDone'), review({ tags: ['great'] })));
    await assertFails(setDoc(doc(h.as('cust1'), 'reviews/bDone'), review({ tags: ['x'.repeat(5000)] })));
    await assertFails(setDoc(doc(h.as('cust1'), 'reviews/bDone'), review({ tags: [42] })));
    await assertFails(setDoc(doc(h.as('cust1'), 'reviews/bDone'), review({ tags: Array(9).fill('late') })));
  });

  test('customer and reviewed mechanic read; others cannot; nobody edits', async () => {
    await assertSucceeds(getDoc(doc(h.as('cust1'), 'reviews/bOld')));
    await assertSucceeds(getDoc(doc(h.as('mech1'), 'reviews/bOld')));
    await assertFails(getDoc(doc(h.as('cust2'), 'reviews/bOld')));
    await assertFails(updateDoc(doc(h.as('cust1'), 'reviews/bOld'), { stars: 1 }));
  });
});

describe('complaints', () => {
  const complaint = (extra = {}) => ({
    bookingId: 'bDone',
    raisedBy: 'mech1',
    category: 'payment',
    text: 'Customer marked paid, not received.',
    status: 'open',
    resolution: null,
    createdAt: serverTimestamp(),
    ...extra,
  });

  test('a participant raises one', async () => {
    await assertSucceeds(addDoc(collection(h.as('mech1'), 'complaints'), complaint()));
  });

  test('outsiders cannot, and nobody opens one pre-resolved', async () => {
    await assertFails(addDoc(collection(h.as('cust2'), 'complaints'), complaint({ raisedBy: 'cust2' })));
    await assertFails(addDoc(collection(h.as('mech1'), 'complaints'), complaint({ status: 'resolved' })));
    await assertFails(addDoc(collection(h.as('mech1'), 'complaints'), complaint({ raisedBy: 'cust1' })));
    await assertFails(addDoc(collection(h.as('mech1'), 'complaints'), complaint({ category: 'refund please' }))); // #57
    await assertSucceeds(addDoc(collection(h.as('mech1'), 'complaints'), complaint({ category: 'safety' })));
  });

  test('raiser and admins read; admins resolve', async () => {
    await assertSucceeds(getDoc(doc(h.as('cust1'), 'complaints/c1')));
    await assertFails(getDoc(doc(h.as('mech2'), 'complaints/c1')));
    await assertFails(updateDoc(doc(h.as('cust1'), 'complaints/c1'), { status: 'resolved' }));
    await assertSucceeds(updateDoc(doc(h.as('admin1'), 'complaints/c1'), { status: 'resolved', resolution: 'Refund note sent' }));
    await assertFails(updateDoc(doc(h.as('admin1'), 'complaints/c1'), { text: 'rewritten' }));
  });
});
