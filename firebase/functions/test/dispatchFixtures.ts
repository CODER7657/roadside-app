// Seed data for dispatch tests. Not a test file.

import { getAuth } from 'firebase-admin/auth';
import { GeoPoint, Timestamp } from 'firebase-admin/firestore';
import { db } from '../src/lib/admin.js';
import { TEST_PROJECT } from './helpers.js';
import { geohash } from '../src/lib/geo.js';
import type { CityId } from '../src/models/enums.js';

export const AHMEDABAD = { lat: 23.0225, lng: 72.5714 };
export const ANKLESHWAR = { lat: 21.6264, lng: 73.0152 };
export const BHARUCH = { lat: 21.7051, lng: 72.9959 };

/** A point `km` north of `from` (1° latitude ≈ 111.2 km). */
export function north(from: { lat: number; lng: number }, km: number) {
  return { lat: from.lat + km / 111.2, lng: from.lng };
}

/** Wipes the test project's Firestore and Auth emulator data. */
export async function resetEmulators(): Promise<void> {
  const project = TEST_PROJECT;
  await fetch(
    `http://${process.env.FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/${project}/databases/(default)/documents`,
    { method: 'DELETE' },
  );
  if (process.env.FIREBASE_AUTH_EMULATOR_HOST) {
    await fetch(`http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/emulator/v1/projects/${project}/accounts`, {
      method: 'DELETE',
    });
  }
  await db()
    .doc('serviceAreas/ahmedabad')
    .set({ name: { en: 'Ahmedabad', hi: 'अहमदाबाद', gu: 'અમદાવાદ' }, active: true });
}

let seq = 0;

/** Unique E.164 test number: prefix digit + 3 digits of pid + 6-digit sequence. */
function testPhone(prefix: 7 | 8): string {
  return `+91${prefix}${String(process.pid % 1000).padStart(3, '0')}${String(seq).padStart(6, '0')}`;
}

export interface MechanicOpts {
  at: { lat: number; lng: number };
  cityId?: CityId;
  status?: 'pending' | 'approved' | 'blocked';
  online?: boolean;
  activeBookingId?: string | null;
  presenceAgeMs?: number;
  vehicleTypes?: string[];
  services?: string[];
  mechanicType?: 'workshop' | 'independent';
}

export async function seedMechanic(opts: MechanicOpts): Promise<string> {
  const uid = `m-${++seq}-${Date.now()}`;
  const fs = db();
  const independent = opts.mechanicType === 'independent';
  await fs.doc(`mechanics/${uid}`).set({
    name: `Mechanic ${seq}`,
    profilePhotoUrl: 'https://example.test/p.jpg',
    mechanicType: opts.mechanicType ?? 'workshop',
    ...(independent
      ? { experienceYears: 6, travelVehicle: { type: 'bike', regNo: 'GJ16AB1234' } }
      : { shopName: 'Shree Auto' }),
    cityId: opts.cityId ?? 'ahmedabad',
    vehicleTypes: opts.vehicleTypes ?? ['car'],
    services: opts.services ?? ['flat_tyre'],
    status: opts.status ?? 'approved',
    rating: 4.6,
    ratingCount: 10,
    jobsCompleted: 25,
    fcmToken: null,
  });
  await fs.doc(`mechanics/${uid}/private/kyc`).set({ upiId: `${uid}@okaxis`, upiName: 'Test Mechanic' });
  await fs.doc(`presence/${uid}`).set({
    isOnline: opts.online ?? true,
    activeBookingId: opts.activeBookingId ?? null,
    cityId: opts.cityId ?? 'ahmedabad',
    location: { geopoint: new GeoPoint(opts.at.lat, opts.at.lng), geohash: geohash(opts.at) },
    updatedAt: Timestamp.fromMillis(Date.now() - (opts.presenceAgeMs ?? 0)),
  });
  if (process.env.FIREBASE_AUTH_EMULATOR_HOST) {
    await getAuth().createUser({ uid, phoneNumber: testPhone(7) });
  }
  return uid;
}

export async function seedBooking(
  at: { lat: number; lng: number },
  cityId: CityId = 'ahmedabad',
  extra: Record<string, unknown> = {},
): Promise<string> {
  const id = `b-${++seq}-${Date.now()}`;
  const customerId = `c-${seq}`;
  await db().doc(`users/${customerId}`).set({ name: 'Priya' });
  if (process.env.FIREBASE_AUTH_EMULATOR_HOST) {
    await getAuth().createUser({ uid: customerId, phoneNumber: testPhone(8) });
  }
  await db()
    .doc(`bookings/${id}`)
    .set({
      customerId,
      mechanicId: null,
      cityId,
      vehicle: { type: 'car', brand: 'Maruti', model: 'Swift', regNo: 'GJ01AB1234' },
      problemType: 'flat_tyre',
      pickup: {
        geopoint: new GeoPoint(at.lat, at.lng),
        geohash: geohash(at),
        address: '12 Secret Street',
        landmark: 'Near temple',
        plusCode: '',
        accuracyMeters: 10,
      },
      status: 'requested',
      statusHistory: [],
      currentOfferId: null,
      triedMechanicIds: [],
      searchRadiusKm: 3,
      priceEstimate: { min: 300, max: 600 },
      timestamps: {},
      ...extra,
    });
  return id;
}

export async function bookingOf(id: string) {
  return (await db().doc(`bookings/${id}`).get()).data()!;
}

export async function offerOf(id: string) {
  return (await db().doc(`offers/${id}`).get()).data()!;
}
