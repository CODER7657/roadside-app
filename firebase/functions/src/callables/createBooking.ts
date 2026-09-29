// createBooking (PLAN §9 `requested`, §11 Dispatch). Customer only.
//
// Server checks, in order:
//   dispatch kill switch → pickup accuracy → vehicle belongs to caller → pickup inside an
//   active service area (nearest centre wins) → price from `prices` (+ city override) →
//   in a transaction: idempotent replay, no other active booking, then create the booking
//   and its private OTP.
// Dispatch itself (offers, radius widening) is not started here; see #28.

import { createHash, randomInt } from 'node:crypto';
import * as logger from 'firebase-functions/logger';
import { HttpsError } from 'firebase-functions/v2/https';
import { FieldValue, GeoPoint, Timestamp } from 'firebase-admin/firestore';
import { z } from 'zod';
import { db } from '../lib/admin.js';
import { distanceKm, geohash, type LatLng } from '../lib/geo.js';
import { secureCall } from '../lib/secureCall.js';
import {
  ACTIVE_STATUSES,
  CITY_IDS,
  PROBLEM_TYPES,
  SCHEMA_VERSION,
  type CityId,
} from '../models/index.js';
import type {
  AppConfigDoc,
  BookingDoc,
  BookingOtpDoc,
  PriceDoc,
  PriceRange,
  ServiceAreaDoc,
  VehicleDoc,
} from '../models/documents.js';

/** Pickups less accurate than this need the customer to confirm the pin on the map (PLAN §9). */
export const MAX_UNCONFIRMED_ACCURACY_M = 100;
const MAX_PHOTOS = 4;
const STORAGE_HOST = 'firebasestorage.googleapis.com';

const input = z.object({
  idempotencyKey: z.string().regex(/^[A-Za-z0-9_-]{16,64}$/),
  vehicleId: z.string().min(1).max(128),
  problemType: z.enum(PROBLEM_TYPES),
  description: z.string().trim().max(500).default(''),
  photoUrls: z
    .array(z.url({ protocol: /^https$/, hostname: new RegExp(`^${STORAGE_HOST.replace(/\./g, '\\.')}$`) }))
    .max(MAX_PHOTOS)
    .default([]),
  pickup: z.strictObject({
    lat: z.number().min(-90).max(90),
    lng: z.number().min(-180).max(180),
    address: z.string().trim().min(1).max(300),
    landmark: z.string().trim().max(120).default(''),
    plusCode: z.string().trim().max(20).default(''),
    accuracyMeters: z.number().min(0).max(10_000),
  }),
  /** The customer dragged / confirmed the pin on U6 Confirm location. */
  pinConfirmed: z.boolean().default(false),
});

export type CreateBookingInput = z.infer<typeof input>;

export interface CreateBookingResult {
  bookingId: string;
  cityId: CityId;
  priceEstimate: PriceRange;
}

export interface ServiceArea {
  cityId: CityId;
  center: LatLng;
  radiusKm: number;
  active: boolean;
}

/**
 * The city a pickup belongs to: the nearest centre whose circle contains it
 * (Ankleshwar and Bharuch overlap). Null when the pickup is in no circle, or when the
 * city it belongs to isn't active yet.
 */
export function resolveCity(pickup: LatLng, areas: readonly ServiceArea[]): CityId | null {
  const containing = areas
    .map((a) => ({ a, d: distanceKm(pickup, a.center) }))
    .filter(({ a, d }) => d <= a.radiusKm)
    .sort((x, y) => x.d - y.d);
  const nearest = containing[0];
  return nearest && nearest.a.active ? nearest.a.cityId : null;
}

export function priceFor(price: Pick<PriceDoc, 'min' | 'max' | 'cityOverrides'>, cityId: CityId): PriceRange {
  const o = price.cityOverrides?.[cityId];
  return o ? { min: o.min, max: o.max } : { min: price.min, max: price.max };
}

/** Deterministic id so a retried call with the same key finds the same booking. */
export function bookingIdFor(uid: string, idempotencyKey: string): string {
  return createHash('sha256').update(`${uid}:${idempotencyKey}`).digest('base64url').slice(0, 20);
}

export function newStartCode(): string {
  return randomInt(0, 10_000).toString().padStart(4, '0');
}

async function loadServiceAreas(): Promise<ServiceArea[]> {
  const snaps = await db().getAll(...CITY_IDS.map((id) => db().collection('serviceAreas').doc(id)));
  return snaps
    .filter((s) => s.exists)
    .map((s) => {
      const d = s.data() as ServiceAreaDoc;
      return {
        cityId: s.id as CityId,
        center: { lat: d.center.latitude, lng: d.center.longitude },
        radiusKm: d.radiusKm,
        active: d.active === true,
      };
    });
}

export const createBooking = secureCall(
  {
    name: 'createBooking',
    roles: ['customer'],
    input,
    rateLimit: { max: 5, windowSeconds: 600 },
  },
  async ({ uid, data }): Promise<CreateBookingResult> => {
    const fs = db();

    const config = (await fs.doc('appConfig/public').get()).data() as AppConfigDoc | undefined;
    if (config?.dispatchEnabled === false) {
      throw new HttpsError('unavailable', 'error_service_paused');
    }

    if (data.pickup.accuracyMeters > MAX_UNCONFIRMED_ACCURACY_M && !data.pinConfirmed) {
      throw new HttpsError('failed-precondition', 'error_pickup_not_confirmed');
    }

    const vehicleSnap = await fs.doc(`users/${uid}/vehicles/${data.vehicleId}`).get();
    if (!vehicleSnap.exists) throw new HttpsError('not-found', 'error_vehicle_not_found');
    const vehicle = vehicleSnap.data() as VehicleDoc;

    const pickupLatLng = { lat: data.pickup.lat, lng: data.pickup.lng };
    const cityId = resolveCity(pickupLatLng, await loadServiceAreas());
    if (!cityId) throw new HttpsError('failed-precondition', 'error_out_of_area');

    const priceSnap = await fs.doc(`prices/${vehicle.type}_${data.problemType}`).get();
    if (!priceSnap.exists) throw new HttpsError('failed-precondition', 'error_price_unavailable');
    const priceEstimate = priceFor(priceSnap.data() as PriceDoc, cityId);

    const bookingId = bookingIdFor(uid, data.idempotencyKey);
    const bookingRef = fs.collection('bookings').doc(bookingId);
    const activeQuery = fs
      .collection('bookings')
      .where('customerId', '==', uid)
      .where('status', 'in', [...ACTIVE_STATUSES])
      .limit(1);

    const result = await fs.runTransaction(async (tx): Promise<CreateBookingResult> => {
      const existing = await tx.get(bookingRef);
      if (existing.exists) {
        // Double tap / retry: hand back the booking the first call made.
        const b = existing.data() as BookingDoc;
        return { bookingId, cityId: b.cityId, priceEstimate: b.priceEstimate };
      }

      const active = await tx.get(activeQuery);
      if (!active.empty) {
        throw new HttpsError('failed-precondition', 'error_active_booking_exists', {
          bookingId: active.docs[0]!.id,
        });
      }

      const now = Timestamp.now();
      const booking: Omit<BookingDoc, 'createdAt' | 'updatedAt' | 'timestamps'> & {
        createdAt: FieldValue;
        updatedAt: FieldValue;
        timestamps: { requested: FieldValue };
      } = {
        customerId: uid,
        mechanicId: null,
        cityId,
        vehicle: { type: vehicle.type, brand: vehicle.brand, model: vehicle.model, regNo: vehicle.regNo },
        problemType: data.problemType,
        description: data.description,
        photoUrls: data.photoUrls,
        pickup: {
          geopoint: new GeoPoint(data.pickup.lat, data.pickup.lng),
          geohash: geohash(pickupLatLng),
          address: data.pickup.address,
          landmark: data.pickup.landmark,
          plusCode: data.pickup.plusCode,
          accuracyMeters: data.pickup.accuracyMeters,
        },
        status: 'requested',
        statusHistory: [{ status: 'requested', at: now, by: uid }],
        currentOfferId: null,
        triedMechanicIds: [],
        searchRadiusKm: 3,
        priceEstimate,
        finalAmount: null,
        mechanicCard: null,
        customerCard: null,
        paymentStatus: 'pending',
        beforePhotoUrls: [],
        afterPhotoUrls: [],
        timestamps: { requested: FieldValue.serverTimestamp() },
        cancelledBy: null,
        cancelReason: null,
        idempotencyKey: data.idempotencyKey,
        schemaVersion: SCHEMA_VERSION,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      };
      const otp: BookingOtpDoc = { code: newStartCode(), attempts: 0, lockedUntil: null };

      tx.create(bookingRef, booking);
      tx.create(bookingRef.collection('private').doc('otp'), otp);
      return { bookingId, cityId, priceEstimate };
    });

    logger.info('createBooking ok', { uid, bookingId: result.bookingId });
    return result;
  },
);
