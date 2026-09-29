// Collection paths and typed references (PLAN.md §8). Use these instead of string paths.
//
//   final refs = RoadsideRefs(FirebaseFirestore.instance);
//   refs.booking(id).snapshots().map((s) => s.data());                    // read: Stream<Booking?>
//   refs.raw(refs.vehicles(uid).doc()).set(stampNew(vehicle.toJson()));  // create
//   refs.raw(refs.user(uid)).update(stampUpdate({'language': 'gu'}));     // update
//
// Read through the typed refs; write raw maps. The rules check `createdAt`/`updatedAt` against
// `request.time`, so every client write goes through [stampNew], [stampUpdate] or [stampCreated]
// (firebase/README.md lists which one each path takes).

import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/booking.dart';
import 'models/mechanic.dart';
import 'models/platform.dart';
import 'models/user.dart';

abstract final class Collections {
  static const users = 'users';
  static const vehicles = 'vehicles';
  static const mechanics = 'mechanics';
  static const private = 'private';
  static const kycDoc = 'kyc';
  static const presence = 'presence';
  static const offers = 'offers';
  static const bookings = 'bookings';
  static const otpDoc = 'otp';
  static const messages = 'messages';
  static const liveLocations = 'liveLocations';
  static const shareLinks = 'shareLinks';
  static const prices = 'prices';
  static const serviceAreas = 'serviceAreas';
  static const reviews = 'reviews';
  static const complaints = 'complaints';
  static const inbox = 'inbox';
  static const inboxItems = 'items';
  static const appConfig = 'appConfig';
  static const appConfigPublic = 'public';
  static const auditLogs = 'auditLogs';
  static const admins = 'admins';
}

/// Sets `createdAt`, `updatedAt` (server time) and `schemaVersion` on a new document's map.
Map<String, Object?> stampNew(Map<String, Object?> data) => {
  ...data,
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
  'schemaVersion': 1,
};

/// Sets `createdAt` (server time) on documents without `updatedAt`: chat messages, reviews,
/// complaints.
Map<String, Object?> stampCreated(Map<String, Object?> data) => {
  ...data,
  'createdAt': FieldValue.serverTimestamp(),
};

/// Sets `updatedAt` (server time) on an update's map. Also for every write to `presence` and
/// `liveLocations`, which have no `createdAt`.
Map<String, Object?> stampUpdate(Map<String, Object?> data) => {
  ...data,
  'updatedAt': FieldValue.serverTimestamp(),
};

class RoadsideRefs {
  const RoadsideRefs(this.db);

  final FirebaseFirestore db;

  /// The untyped reference, for writes with [stampNew] / [stampUpdate].
  DocumentReference<Map<String, dynamic>> raw(DocumentReference<Object?> ref) => db.doc(ref.path);

  CollectionReference<T> _col<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
    Map<String, Object?> Function(T) toJson,
  ) => db
      .collection(path)
      .withConverter<T>(fromFirestore: (s, _) => fromJson(s.data()!), toFirestore: (v, _) => toJson(v));

  DocumentReference<T> _doc<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
    Map<String, Object?> Function(T) toJson,
  ) => db
      .doc(path)
      .withConverter<T>(fromFirestore: (s, _) => fromJson(s.data()!), toFirestore: (v, _) => toJson(v));

  CollectionReference<AppUser> get users => _col(Collections.users, AppUser.fromJson, (v) => v.toJson());
  DocumentReference<AppUser> user(String uid) => users.doc(uid);

  CollectionReference<Vehicle> vehicles(String uid) =>
      _col('${Collections.users}/$uid/${Collections.vehicles}', Vehicle.fromJson, (v) => v.toJson());

  CollectionReference<Mechanic> get mechanics =>
      _col(Collections.mechanics, Mechanic.fromJson, (v) => v.toJson());
  DocumentReference<Mechanic> mechanic(String uid) => mechanics.doc(uid);

  DocumentReference<MechanicKyc> mechanicKyc(String uid) => _doc(
    '${Collections.mechanics}/$uid/${Collections.private}/${Collections.kycDoc}',
    MechanicKyc.fromJson,
    (v) => v.toJson(),
  );

  DocumentReference<Presence> presence(String uid) =>
      _doc('${Collections.presence}/$uid', Presence.fromJson, (v) => v.toJson());

  CollectionReference<Offer> get offers => _col(Collections.offers, Offer.fromJson, (v) => v.toJson());

  CollectionReference<Booking> get bookings =>
      _col(Collections.bookings, Booking.fromJson, (v) => v.toJson());
  DocumentReference<Booking> booking(String id) => bookings.doc(id);

  DocumentReference<BookingOtp> bookingOtp(String bookingId) => _doc(
    '${Collections.bookings}/$bookingId/${Collections.private}/${Collections.otpDoc}',
    BookingOtp.fromJson,
    (v) => v.toJson(),
  );

  CollectionReference<ChatMessage> messages(String bookingId) => _col(
    '${Collections.bookings}/$bookingId/${Collections.messages}',
    ChatMessage.fromJson,
    (v) => v.toJson(),
  );

  DocumentReference<LiveLocation> liveLocation(String bookingId) =>
      _doc('${Collections.liveLocations}/$bookingId', LiveLocation.fromJson, (v) => v.toJson());

  CollectionReference<Price> get prices => _col(Collections.prices, Price.fromJson, (v) => v.toJson());

  CollectionReference<ServiceArea> get serviceAreas =>
      _col(Collections.serviceAreas, ServiceArea.fromJson, (v) => v.toJson());

  CollectionReference<Review> get reviews => _col(Collections.reviews, Review.fromJson, (v) => v.toJson());

  CollectionReference<Complaint> get complaints =>
      _col(Collections.complaints, Complaint.fromJson, (v) => v.toJson());

  CollectionReference<InboxItem> inbox(String uid) =>
      _col('${Collections.inbox}/$uid/${Collections.inboxItems}', InboxItem.fromJson, (v) => v.toJson());

  DocumentReference<AppConfig> get appConfig =>
      _doc('${Collections.appConfig}/${Collections.appConfigPublic}', AppConfig.fromJson, (v) => v.toJson());

  CollectionReference<AuditLog> get auditLogs =>
      _col(Collections.auditLogs, AuditLog.fromJson, (v) => v.toJson());
}
