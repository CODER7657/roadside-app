import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../dashboard/data/location_service.dart';

/// What `startTrip` / `markArrived` (#115) said.
enum TripOutcome {
  ok,

  /// `markArrived`: more than 100 m (200 m for a vague pickup) from the pickup.
  notAtPickup,

  /// `markArrived`: no fresh position in liveLocations (≤ 30 s).
  locationUnavailable,

  /// The booking moved on (e.g. the customer cancelled).
  invalidStatus,

  /// Network or anything unexpected.
  failed,
}

TripOutcome tripOutcomeForError(String? messageKey) => switch (messageKey) {
  'error_not_at_pickup' => TripOutcome.notAtPickup,
  'error_location_unavailable' => TripOutcome.locationUnavailable,
  'error_invalid_status' || 'error_booking_not_found' => TripOutcome.invalidStatus,
  _ => TripOutcome.failed,
};

/// The mechanic's active job: `bookings/{id}` (readable by the assigned mechanic, #99) and the
/// status steps, which only callables may change.
abstract interface class JobRepository {
  Stream<Booking?> watch(String bookingId);
  Future<TripOutcome> startTrip(String bookingId);
  Future<TripOutcome> markArrived(String bookingId);
}

/// Writes `liveLocations/{bookingId}` (PLAN §8, §11): the customer's map follows it.
abstract interface class LiveLocationRepository {
  Future<void> write(String bookingId, LocationFix fix, {required int etaMinutes});
}

/// Until Firebase is wired (#120, #123).
class InMemoryJobRepository implements JobRepository {
  InMemoryJobRepository([Map<String, Booking> bookings = const {}]) : _bookings = {...bookings};

  final Map<String, Booking> _bookings;
  final _changes = StreamController<String>.broadcast();

  /// What the next step returns instead of the normal answer (tests).
  TripOutcome? nextOutcome;
  final calls = <String>[];

  void setStatus(String bookingId, BookingStatus status) {
    _bookings[bookingId] = _bookings[bookingId]!.copyWith(status: status);
    _changes.add(bookingId);
  }

  @override
  Stream<Booking?> watch(String bookingId) async* {
    yield _bookings[bookingId];
    await for (final id in _changes.stream) {
      if (id == bookingId) yield _bookings[bookingId];
    }
  }

  Future<TripOutcome> _step(String name, String bookingId, BookingStatus from, BookingStatus to) async {
    calls.add('$name:$bookingId');
    final forced = nextOutcome;
    nextOutcome = null;
    if (forced != null) return forced;
    if (_bookings[bookingId]?.status != from) return TripOutcome.invalidStatus;
    setStatus(bookingId, to);
    return TripOutcome.ok;
  }

  @override
  Future<TripOutcome> startTrip(String bookingId) =>
      _step('startTrip', bookingId, BookingStatus.accepted, BookingStatus.arriving);

  @override
  Future<TripOutcome> markArrived(String bookingId) =>
      _step('markArrived', bookingId, BookingStatus.arriving, BookingStatus.arrived);
}

class InMemoryLiveLocationRepository implements LiveLocationRepository {
  final writes = <(String, LocationFix, int)>[];

  @override
  Future<void> write(String bookingId, LocationFix fix, {required int etaMinutes}) async =>
      writes.add((bookingId, fix, etaMinutes));
}

class FirebaseJobRepository implements JobRepository {
  FirebaseJobRepository(this._db, this._functions);

  final FirebaseFirestore _db;

  /// `FirebaseFunctions.instanceFor(region: 'asia-south1')`.
  final FirebaseFunctions _functions;

  @override
  Stream<Booking?> watch(String bookingId) =>
      RoadsideRefs(_db).bookings.doc(bookingId).snapshots().map((s) => s.data());

  Future<TripOutcome> _call(String name, String bookingId) async {
    try {
      await _functions.httpsCallable(name).call<Object?>({'bookingId': bookingId});
      return TripOutcome.ok;
    } on FirebaseFunctionsException catch (e) {
      return tripOutcomeForError(e.message);
    } catch (_) {
      return TripOutcome.failed;
    }
  }

  @override
  Future<TripOutcome> startTrip(String bookingId) => _call('startTrip', bookingId);

  @override
  Future<TripOutcome> markArrived(String bookingId) => _call('markArrived', bookingId);
}

class FirestoreLiveLocationRepository implements LiveLocationRepository {
  FirestoreLiveLocationRepository(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final FirebaseFirestore _db;
  final DateTime Function() _clock;

  /// `expireAt` is ~24 h out; Firestore TTL deletes the doc a day after the job (PLAN §12.10).
  static const keepFor = Duration(hours: 24);

  @override
  Future<void> write(String bookingId, LocationFix fix, {required int etaMinutes}) =>
      // The whole doc each time: the rules want every field on create and update (#99).
      _db
          .doc('${Collections.liveLocations}/$bookingId')
          .set(
            stampUpdate({
              'mechanicGeopoint': GeoPoint(fix.lat, fix.lng),
              // Kept inside the ranges the rules accept (heading 0–360°, speed ≤ 100 m/s).
              'heading': fix.heading.clamp(0, 360),
              'speed': fix.speed.clamp(0, 100),
              'etaMinutes': etaMinutes,
              'expireAt': Timestamp.fromDate(_clock().add(keepFor)),
            }),
          );
}
