// Who can get an offer for a booking (PLAN §11 Dispatch step 1).
// Approved, online, free mechanics in the booking's city who handle its vehicle type
// and problem, within the radius, nearest first. mechanicType is ignored on purpose.

import { Timestamp } from 'firebase-admin/firestore';
import { db } from '../lib/admin.js';
import { distanceKm, geohashQueryBounds, type LatLng } from '../lib/geo.js';
import type { CityId } from '../models/enums.js';
import type { BookingDoc, MechanicDoc, PresenceDoc } from '../models/documents.js';

/** Search radii in order (PLAN §8 searchRadiusKm, §11 step 5). */
export const RADII_KM = [3, 5, 10] as const;
export type RadiusKm = (typeof RADII_KM)[number];

/** Presence older than this counts as offline (PLAN §11 Mechanic live location). */
export const PRESENCE_STALE_MS = 2 * 60 * 1000;

/** Highway pickups between these two may match the other city once the radius reaches 10 km. */
const CROSS_MATCH: Partial<Record<CityId, CityId>> = { ankleshwar: 'bharuch', bharuch: 'ankleshwar' };

export function citiesFor(cityId: CityId, radiusKm: number): CityId[] {
  const other = CROSS_MATCH[cityId];
  return radiusKm >= 10 && other ? [cityId, other] : [cityId];
}

export interface Candidate {
  uid: string;
  distanceKm: number;
}

export type BookingForDispatch = Pick<
  BookingDoc,
  'cityId' | 'vehicle' | 'problemType' | 'pickup' | 'triedMechanicIds'
>;

/** Presence filter: online, free, fresh, in an allowed city, not tried before. */
export function presenceOk(
  p: PresenceDoc,
  uid: string,
  cities: readonly CityId[],
  tried: readonly string[],
  nowMs: number,
): boolean {
  return (
    p.isOnline === true &&
    !p.activeBookingId &&
    cities.includes(p.cityId) &&
    !tried.includes(uid) &&
    p.updatedAt instanceof Timestamp &&
    nowMs - p.updatedAt.toMillis() <= PRESENCE_STALE_MS
  );
}

/** Profile filter: approved and handles this vehicle type and problem. */
export function mechanicOk(m: MechanicDoc | undefined, b: BookingForDispatch): boolean {
  return (
    !!m &&
    m.status === 'approved' &&
    m.vehicleTypes?.includes(b.vehicle.type) === true &&
    m.services?.includes(b.problemType) === true
  );
}

export async function findCandidates(
  booking: BookingForDispatch,
  radiusKm: number,
  nowMs: number,
): Promise<Candidate[]> {
  const fs = db();
  const pickup: LatLng = { lat: booking.pickup.geopoint.latitude, lng: booking.pickup.geopoint.longitude };
  const cities = citiesFor(booking.cityId, radiusKm);

  // Range queries on the geohash only (single-field index); everything else is filtered here.
  const snaps = await Promise.all(
    geohashQueryBounds(pickup, radiusKm).map(([start, end]) =>
      fs.collection('presence').where('location.geohash', '>=', start).where('location.geohash', '<=', end).get(),
    ),
  );

  const nearby = new Map<string, number>();
  for (const snap of snaps) {
    for (const doc of snap.docs) {
      const p = doc.data() as PresenceDoc;
      if (!presenceOk(p, doc.id, cities, booking.triedMechanicIds, nowMs)) continue;
      const d = distanceKm(pickup, { lat: p.location.geopoint.latitude, lng: p.location.geopoint.longitude });
      if (d <= radiusKm) nearby.set(doc.id, d);
    }
  }
  if (nearby.size === 0) return [];

  const profiles = await fs.getAll(...[...nearby.keys()].map((uid) => fs.doc(`mechanics/${uid}`)));
  return profiles
    .filter((s) => mechanicOk(s.data() as MechanicDoc | undefined, booking))
    .map((s) => ({ uid: s.id, distanceKm: nearby.get(s.id)! }))
    .sort((a, b) => a.distanceKm - b.distanceKm || a.uid.localeCompare(b.uid));
}

/** True if the mechanic is already looking at another live offer. */
export async function hasLiveOffer(uid: string, nowMs: number): Promise<boolean> {
  const snap = await db()
    .collection('offers')
    .where('mechanicId', '==', uid)
    .where('state', '==', 'pending')
    .get();
  return snap.docs.some((d) => (d.get('expiresAt') as Timestamp).toMillis() > nowMs);
}
