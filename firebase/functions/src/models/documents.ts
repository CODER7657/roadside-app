// Firestore document shapes (PLAN.md §8). Mirror of the models in packages/roadside_core.
// No field may exist here that isn't in §8. Change both in the same PR.

import type { GeoPoint, Timestamp } from 'firebase-admin/firestore';
import type {
  Actor,
  BookingStatus,
  CityId,
  ComplaintStatus,
  Fuel,
  Language,
  MechanicStatus,
  MechanicType,
  OfferState,
  PaymentStatus,
  ProblemType,
  Role,
  VehicleType,
} from './enums.js';

/** Fields every document carries. */
export interface BaseDoc {
  createdAt: Timestamp;
  updatedAt: Timestamp;
  schemaVersion: 1;
}

export interface Contact {
  name: string;
  /** E.164 */
  phone: string;
}

export interface GeoLocation {
  geopoint: GeoPoint;
  geohash: string;
}

/** users/{uid} */
export interface UserDoc extends BaseDoc {
  name: string;
  phone: string;
  language: Language;
  emergencyContacts: Contact[]; // max 3
  fcmToken: string | null;
  consent: { version: string; acceptedAt: Timestamp } | null;
  deletionRequestedAt: Timestamp | null;
}

/** users/{uid}/vehicles/{vehicleId} */
export interface VehicleDoc extends BaseDoc {
  type: VehicleType;
  brand: string;
  model: string;
  regNo: string;
  fuel: Fuel;
  isDefault: boolean;
}

/** mechanics/{uid} */
export interface MechanicDoc extends BaseDoc {
  name: string;
  profilePhotoUrl: string;
  mechanicType: MechanicType;
  // workshop only
  shopName?: string;
  shopAddress?: string;
  shopPhotoUrl?: string;
  // independent only
  baseArea?: { locality: string; geopoint: GeoPoint };
  experienceYears?: number;
  toolkitPhotoUrls?: string[];
  travelVehicle?: { type: VehicleType; regNo: string };
  cityId: CityId;
  vehicleTypes: VehicleType[];
  services: ProblemType[];
  status: MechanicStatus;
  rating: number;
  ratingCount: number;
  jobsCompleted: number;
  fcmToken: string | null;
  /** 🔒 Set by requestAccountDeletion (#167; proposed for PLAN §8 alongside users/{uid}). */
  deletionRequestedAt?: Timestamp | null;
}

/** mechanics/{uid}/private/kyc */
export interface MechanicKycDoc extends BaseDoc {
  phone: string;
  idProofPath: string;
  upiId: string;
  upiName: string;
  kycCheckedBy: string | null;
  kycCheckedAt: Timestamp | null;
  // independent only
  selfieWithIdPath?: string;
  addressProofPath?: string;
  referenceContact?: Contact;
  verificationCall?: { doneBy: string; at: Timestamp; notes: string };
}

/** presence/{uid} */
export interface PresenceDoc {
  isOnline: boolean;
  location: GeoLocation;
  updatedAt: Timestamp;
  cityId: CityId;
  activeBookingId: string | null;
}

/** offers/{offerId} */
export interface OfferDoc extends BaseDoc {
  bookingId: string;
  mechanicId: string;
  vehicleType: VehicleType;
  problemType: ProblemType;
  regNo: string;
  distanceKm: number;
  areaName: string;
  priceEstimate: PriceRange;
  expiresAt: Timestamp;
  state: OfferState;
}

export interface PriceRange {
  min: number;
  max: number;
}

export interface MechanicCard {
  name: string;
  photoUrl: string;
  mechanicType: MechanicType;
  shopName: string | null;
  experienceYears: number | null;
  travelVehicleRegNo: string | null;
  rating: number;
  jobsCompleted: number;
  phone: string;
  upiId: string;
  upiName: string;
}

export interface StatusHistoryEntry {
  status: BookingStatus;
  at: Timestamp;
  by: string;
}

/** bookings/{bookingId} */
export interface BookingDoc extends BaseDoc {
  customerId: string;
  mechanicId: string | null;
  cityId: CityId;
  vehicle: { type: VehicleType; brand: string; model: string; regNo: string };
  problemType: ProblemType;
  description: string;
  photoUrls: string[];
  pickup: GeoLocation & {
    address: string;
    landmark: string;
    plusCode: string;
    accuracyMeters: number;
  };
  status: BookingStatus;
  statusHistory: StatusHistoryEntry[];
  currentOfferId: string | null;
  triedMechanicIds: string[];
  searchRadiusKm: 3 | 5 | 10;
  priceEstimate: PriceRange;
  finalAmount: number | null;
  mechanicCard: MechanicCard | null;
  customerCard: Contact | null;
  paymentStatus: PaymentStatus;
  beforePhotoUrls: string[];
  afterPhotoUrls: string[];
  timestamps: Partial<
    Record<
      'requested' | 'accepted' | 'arriving' | 'arrived' | 'started' | 'completed' | 'cancelled',
      Timestamp
    >
  >;
  cancelledBy: Actor | null;
  cancelReason: { code: string; text?: string } | null;
  idempotencyKey: string;
}

/** bookings/{bookingId}/private/otp */
export interface BookingOtpDoc {
  code: string;
  attempts: number;
  lockedUntil: Timestamp | null;
}

/** bookings/{bookingId}/messages/{messageId} */
export interface MessageDoc {
  senderId: string;
  text: string; // ≤ 500 chars
  imagePath: string | null;
  createdAt: Timestamp;
}

/** liveLocations/{bookingId} */
export interface LiveLocationDoc {
  mechanicGeopoint: GeoPoint;
  heading: number;
  speed: number;
  etaMinutes: number;
  updatedAt: Timestamp;
  expireAt: Timestamp;
}

/** shareLinks/{token} */
export interface ShareLinkDoc {
  bookingId: string;
  createdBy: string;
  expiresAt: Timestamp;
}

/** prices/{vehicleType_problemType} */
export interface PriceDoc extends BaseDoc {
  vehicleType: VehicleType;
  problemType: ProblemType;
  min: number;
  max: number;
  includes: string;
  cityOverrides?: Partial<Record<CityId, PriceRange>>;
}

/** serviceAreas/{cityId} */
export interface ServiceAreaDoc extends BaseDoc {
  name: Record<Language, string>;
  center: GeoPoint;
  radiusKm: number;
  active: boolean;
  supportPhone: string;
  launchedAt: Timestamp | null;
}

/** reviews/{bookingId} */
export interface ReviewDoc {
  customerId: string;
  mechanicId: string;
  stars: 1 | 2 | 3 | 4 | 5;
  tags: string[];
  comment: string; // ≤ 500 chars
  createdAt: Timestamp;
}

/** complaints/{complaintId} */
export interface ComplaintDoc {
  bookingId: string;
  raisedBy: string;
  category: string;
  text: string;
  status: ComplaintStatus;
  resolution: string | null;
  createdAt: Timestamp;
}

/** inbox/{uid}/items/{itemId} */
export interface InboxItemDoc {
  type: string;
  titleKey: string;
  bodyKey: string;
  args: Record<string, string>;
  bookingId: string | null;
  read: boolean;
}

/** appConfig/public */
export interface AppConfigDoc {
  minSupportedBuild: number;
  maintenanceMessage: string | null;
  supportPhone: string;
  dispatchEnabled: boolean;
}

/** auditLogs/{id} */
export interface AuditLogDoc {
  actorUid: string;
  action: string;
  target: string;
  before: unknown;
  after: unknown;
  at: Timestamp;
}

/** Custom claims set only by Functions (PLAN §8 Roles, §12.2). */
export interface RoleClaims {
  role?: Role;
  mechanicStatus?: MechanicStatus;
}
