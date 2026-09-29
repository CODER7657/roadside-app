// Storage rules (PLAN §12.5): paths, images only, < 5 MB, KYC write-once and private.

const { assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { ref, uploadBytes, getMetadata, deleteObject } = require('firebase/storage');
const h = require('./helpers');

const jpeg = new Uint8Array([0xff, 0xd8, 0xff, 0xe0, 1, 2, 3]);
const JPEG = { contentType: 'image/jpeg' };

const put = (uid, path, { bytes = jpeg, meta = JPEG } = {}) => uploadBytes(ref(h.storageAs(uid), path), bytes, meta);
const read = (uid, path) => getMetadata(ref(h.storageAs(uid), path));

beforeAll(h.setup);
afterAll(h.teardown);
beforeEach(async () => {
  const env = h.getEnv();
  await env.clearFirestore();
  await env.clearStorage();
  await h.seed({
    'bookings/b1': h.booking({ status: 'arrived' }),
    'bookings/bArriving': h.booking({ status: 'arriving' }),
    'bookings/bDone': h.booking({ status: 'completed' }),
  });
  // Existing files, written with rules disabled.
  await env.withSecurityRulesDisabled(async (ctx) => {
    const s = ctx.storage();
    for (const path of [
      'users/cust1/bookings/draft1/p1.jpg',
      'mechanics/mech1/shop/shop.jpg',
      'mechanics/mech1/kyc/id-proof.jpg',
      'bookings/b1/work/before-1.jpg',
      'bookings/b1/chat/c1.jpg',
    ]) {
      await uploadBytes(ref(s, path), jpeg, JPEG);
    }
  });
});

describe('every write', () => {
  test('must be a jpeg / png / webp image', async () => {
    await assertSucceeds(put('cust1', 'users/cust1/bookings/draft2/a.png', { meta: { contentType: 'image/png' } }));
    await assertSucceeds(put('cust1', 'users/cust1/bookings/draft2/b.webp', { meta: { contentType: 'image/webp' } }));
    await assertFails(put('cust1', 'users/cust1/bookings/draft2/c.pdf', { meta: { contentType: 'application/pdf' } }));
    await assertFails(put('cust1', 'users/cust1/bookings/draft2/d.svg', { meta: { contentType: 'image/svg+xml' } }));
    await assertFails(put('cust1', 'users/cust1/bookings/draft2/e.html', { meta: { contentType: 'text/html' } }));
  });

  test('must be under 5 MB', async () => {
    const big = new Uint8Array(5 * 1024 * 1024);
    await assertFails(put('cust1', 'users/cust1/bookings/draft2/big.jpg', { bytes: big }));
    await assertSucceeds(put('cust1', 'users/cust1/bookings/draft2/ok.jpg', { bytes: new Uint8Array(5 * 1024 * 1024 - 1) }));
  });

  test('only known paths exist', async () => {
    await assertFails(put('admin1', 'public/anything.jpg'));
    await assertFails(put('cust1', 'users/cust1/avatar.jpg'));
    await assertFails(read('admin1', 'somewhere/else.jpg'));
  });

  test('nobody deletes from a client', async () => {
    await assertFails(deleteObject(ref(h.storageAs('cust1'), 'users/cust1/bookings/draft1/p1.jpg')));
    await assertFails(deleteObject(ref(h.storageAs('mech1'), 'mechanics/mech1/kyc/id-proof.jpg')));
    await assertFails(deleteObject(ref(h.storageAs('admin1'), 'bookings/b1/work/before-1.jpg')));
  });
});

describe('users/{uid}/bookings (problem photos)', () => {
  test('owner uploads and reads; admin reads', async () => {
    await assertSucceeds(put('cust1', 'users/cust1/bookings/draft2/p1.jpg'));
    await assertSucceeds(read('cust1', 'users/cust1/bookings/draft1/p1.jpg'));
    await assertSucceeds(read('admin1', 'users/cust1/bookings/draft1/p1.jpg'));
  });

  test('others cannot upload into or read your folder', async () => {
    await assertFails(put('cust2', 'users/cust1/bookings/draft2/p1.jpg'));
    await assertFails(read('cust2', 'users/cust1/bookings/draft1/p1.jpg'));
    await assertFails(read('mech1', 'users/cust1/bookings/draft1/p1.jpg'));
    await assertFails(read(null, 'users/cust1/bookings/draft1/p1.jpg'));
  });
});

describe('mechanics/{uid}/shop', () => {
  test('owner uploads (also before approval) and reads', async () => {
    await assertSucceeds(put('newMech', 'mechanics/newMech/shop/profile.jpg'));
    await assertSucceeds(put('mech1', 'mechanics/mech1/shop/shop.jpg')); // replace
    await assertSucceeds(read('mech1', 'mechanics/mech1/shop/shop.jpg'));
  });

  test('others cannot', async () => {
    await assertFails(put('mech2', 'mechanics/mech1/shop/fake.jpg'));
    await assertFails(read('cust1', 'mechanics/mech1/shop/shop.jpg'));
  });
});

describe('mechanics/{uid}/kyc', () => {
  test('owner uploads once; owner and admin read', async () => {
    await assertSucceeds(put('newMech', 'mechanics/newMech/kyc/id-proof.jpg'));
    await assertSucceeds(read('mech1', 'mechanics/mech1/kyc/id-proof.jpg'));
    await assertSucceeds(read('admin1', 'mechanics/mech1/kyc/id-proof.jpg'));
  });

  test('cannot be overwritten', async () => {
    await assertFails(put('mech1', 'mechanics/mech1/kyc/id-proof.jpg'));
  });

  test('leaked ID documents: nobody else reads them', async () => {
    await assertFails(read('mech2', 'mechanics/mech1/kyc/id-proof.jpg'));
    await assertFails(read('cust1', 'mechanics/mech1/kyc/id-proof.jpg'));
    await assertFails(read('googleUser', 'mechanics/mech1/kyc/id-proof.jpg'));
    await assertFails(read(null, 'mechanics/mech1/kyc/id-proof.jpg'));
    await assertFails(put('cust1', 'mechanics/mech1/kyc/other.jpg'));
  });
});

describe('bookings/{id}/work (before / after)', () => {
  test('the assigned mechanic uploads once arrived', async () => {
    await assertSucceeds(put('mech1', 'bookings/b1/work/after-1.jpg'));
  });

  test('not before arrival, not after the job, not by others', async () => {
    await assertFails(put('mech1', 'bookings/bArriving/work/before-1.jpg'));
    await assertFails(put('mech1', 'bookings/bDone/work/after-2.jpg'));
    await assertFails(put('mech2', 'bookings/b1/work/after-1.jpg'));
    await assertFails(put('cust1', 'bookings/b1/work/after-1.jpg'));
    await assertFails(put('mech1', 'bookings/b1/work/before-1.jpg')); // no overwrite
  });

  test('participants and admins read', async () => {
    await assertSucceeds(read('cust1', 'bookings/b1/work/before-1.jpg'));
    await assertSucceeds(read('mech1', 'bookings/b1/work/before-1.jpg'));
    await assertSucceeds(read('admin1', 'bookings/b1/work/before-1.jpg'));
    await assertFails(read('cust2', 'bookings/b1/work/before-1.jpg'));
  });
});

describe('bookings/{id}/chat', () => {
  test('participants upload while active', async () => {
    await assertSucceeds(put('cust1', 'bookings/b1/chat/c2.jpg'));
    await assertSucceeds(put('mech1', 'bookings/b1/chat/c3.jpg'));
  });

  test('not after the job, not by outsiders', async () => {
    await assertFails(put('cust1', 'bookings/bDone/chat/c2.jpg'));
    await assertFails(put('cust2', 'bookings/b1/chat/c2.jpg'));
    await assertFails(put('mech1', 'bookings/b1/chat/c1.jpg')); // no overwriting the other side's photo
    await assertFails(read('cust2', 'bookings/b1/chat/c1.jpg'));
    await assertSucceeds(read('cust1', 'bookings/b1/chat/c1.jpg'));
  });
});
