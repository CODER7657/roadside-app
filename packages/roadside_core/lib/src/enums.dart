// Enums of the Firestore contract (PLAN.md §8). Mirror of firebase/functions/src/models/enums.ts.
// Change both in the same PR. Each value carries the exact string stored in Firestore.

import 'package:json_annotation/json_annotation.dart';

/// Version written to every document's `schemaVersion`.
const int kSchemaVersion = 1;

/// Looks up an enum by its Firestore string. Throws [ArgumentError] for unknown values.
T _byValue<T extends Enum>(List<T> values, String value, String Function(T) valueOf) {
  for (final v in values) {
    if (valueOf(v) == value) return v;
  }
  throw ArgumentError.value(value, 'value', 'Unknown ${T.toString()}');
}

/// Launch cities (`serviceAreas/{cityId}`).
@JsonEnum(valueField: 'value')
enum CityId {
  ahmedabad('ahmedabad'),
  ankleshwar('ankleshwar'),
  bharuch('bharuch');

  const CityId(this.value);
  final String value;
  static CityId fromValue(String value) => _byValue(values, value, (v) => v.value);
}

/// Firebase Auth custom claim `role` (PLAN §8 Roles). Set only by Functions.
@JsonEnum(valueField: 'value')
enum Role {
  customer('customer'),
  mechanic('mechanic'),
  admin('admin');

  const Role(this.value);
  final String value;
  static Role fromValue(String value) => _byValue(values, value, (v) => v.value);
}

/// `mechanics/{uid}.status` and the `mechanicStatus` custom claim.
@JsonEnum(valueField: 'value')
enum MechanicStatus {
  pending('pending'),
  approved('approved'),
  blocked('blocked');

  const MechanicStatus(this.value);
  final String value;
  static MechanicStatus fromValue(String value) => _byValue(values, value, (v) => v.value);
}

/// Workshop (has a shop) or independent (no shop) mechanic (PLAN §10.0).
@JsonEnum(valueField: 'value')
enum MechanicType {
  workshop('workshop'),
  independent('independent');

  const MechanicType(this.value);
  final String value;
  static MechanicType fromValue(String value) => _byValue(values, value, (v) => v.value);
}

@JsonEnum(valueField: 'value')
enum Language {
  en('en'),
  hi('hi'),
  gu('gu');

  const Language(this.value);
  final String value;
  static Language fromValue(String value) => _byValue(values, value, (v) => v.value);
}

@JsonEnum(valueField: 'value')
enum VehicleType {
  car('car'),
  bike('bike'),
  scooter('scooter'),
  ev('ev');

  const VehicleType(this.value);
  final String value;
  static VehicleType fromValue(String value) => _byValue(values, value, (v) => v.value);
}

@JsonEnum(valueField: 'value')
enum Fuel {
  petrol('petrol'),
  diesel('diesel'),
  cng('cng'),
  electric('electric');

  const Fuel(this.value);
  final String value;
  static Fuel fromValue(String value) => _byValue(values, value, (v) => v.value);
}

@JsonEnum(valueField: 'value')
enum ProblemType {
  flatTyre('flat_tyre'),
  battery('battery'),
  wontStart('wont_start'),
  overheating('overheating'),
  accident('accident'),
  fuel('fuel'),
  other('other');

  const ProblemType(this.value);
  final String value;
  static ProblemType fromValue(String value) => _byValue(values, value, (v) => v.value);
}

/// Booking status (PLAN §9). Transitions live in `status_machine.dart`.
@JsonEnum(valueField: 'value')
enum BookingStatus {
  requested('requested'),
  accepted('accepted'),
  arriving('arriving'),
  arrived('arrived'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled'),
  noMechanicFound('no_mechanic_found');

  const BookingStatus(this.value);
  final String value;
  static BookingStatus fromValue(String value) => _byValue(values, value, (v) => v.value);
}

@JsonEnum(valueField: 'value')
enum PaymentStatus {
  pending('pending'),
  customerMarkedPaid('customer_marked_paid'),
  confirmed('confirmed'),
  disputed('disputed');

  const PaymentStatus(this.value);
  final String value;
  static PaymentStatus fromValue(String value) => _byValue(values, value, (v) => v.value);
}

@JsonEnum(valueField: 'value')
enum OfferState {
  pending('pending'),
  accepted('accepted'),
  declined('declined'),
  expired('expired');

  const OfferState(this.value);
  final String value;
  static OfferState fromValue(String value) => _byValue(values, value, (v) => v.value);
}

/// Who made a status change (`statusHistory[].by` role, `cancelledBy`).
@JsonEnum(valueField: 'value')
enum Actor {
  customer('customer'),
  mechanic('mechanic'),
  admin('admin'),
  system('system');

  const Actor(this.value);
  final String value;
  static Actor fromValue(String value) => _byValue(values, value, (v) => v.value);
}

@JsonEnum(valueField: 'value')
enum ComplaintStatus {
  open('open'),
  resolved('resolved');

  const ComplaintStatus(this.value);
  final String value;
  static ComplaintStatus fromValue(String value) => _byValue(values, value, (v) => v.value);
}
