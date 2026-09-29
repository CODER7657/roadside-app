// TypeScript mirror of the enums in packages/roadside_core (PLAN.md §8).
// Change both in the same PR.

export const CITY_IDS = ['ahmedabad', 'ankleshwar', 'bharuch'] as const;
export type CityId = (typeof CITY_IDS)[number];

export const ROLES = ['customer', 'mechanic', 'admin'] as const;
export type Role = (typeof ROLES)[number];

export const MECHANIC_STATUSES = ['pending', 'approved', 'blocked'] as const;
export type MechanicStatus = (typeof MECHANIC_STATUSES)[number];

export const MECHANIC_TYPES = ['workshop', 'independent'] as const;
export type MechanicType = (typeof MECHANIC_TYPES)[number];

export const LANGUAGES = ['en', 'hi', 'gu'] as const;
export type Language = (typeof LANGUAGES)[number];

export const VEHICLE_TYPES = ['car', 'bike', 'scooter', 'ev'] as const;
export type VehicleType = (typeof VEHICLE_TYPES)[number];

export const FUELS = ['petrol', 'diesel', 'cng', 'electric'] as const;
export type Fuel = (typeof FUELS)[number];

export const PROBLEM_TYPES = [
  'flat_tyre',
  'battery',
  'wont_start',
  'overheating',
  'accident',
  'fuel',
  'other',
] as const;
export type ProblemType = (typeof PROBLEM_TYPES)[number];

export const BOOKING_STATUSES = [
  'requested',
  'accepted',
  'arriving',
  'arrived',
  'in_progress',
  'completed',
  'cancelled',
  'no_mechanic_found',
] as const;
export type BookingStatus = (typeof BOOKING_STATUSES)[number];

export const PAYMENT_STATUSES = ['pending', 'customer_marked_paid', 'confirmed', 'disputed'] as const;
export type PaymentStatus = (typeof PAYMENT_STATUSES)[number];

export const OFFER_STATES = ['pending', 'accepted', 'declined', 'expired'] as const;
export type OfferState = (typeof OFFER_STATES)[number];

export const ACTORS = ['customer', 'mechanic', 'admin', 'system'] as const;
export type Actor = (typeof ACTORS)[number];

export const COMPLAINT_STATUSES = ['open', 'resolved'] as const;
export type ComplaintStatus = (typeof COMPLAINT_STATUSES)[number];

export const SCHEMA_VERSION = 1;
