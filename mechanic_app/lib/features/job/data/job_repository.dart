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

/// What `verifyStartOtp` (#116) said about a start code (M6).
sealed class StartCodeResult {
  const StartCodeResult();
}

/// The code matched: the job is `in_progress`.
final class StartCodeAccepted extends StartCodeResult {
  const StartCodeAccepted();
}

final class StartCodeWrong extends StartCodeResult {
  const StartCodeWrong(this.attemptsLeft);

  /// Before the 10-minute lock (PLAN §12.9: 5 tries).
  final int attemptsLeft;
}

/// Too many wrong codes: no guesses until [until].
final class StartCodeLocked extends StartCodeResult {
  const StartCodeLocked(this.until);

  final DateTime until;
}

/// The booking moved on (e.g. the customer cancelled): the booking stream shows what happened.
final class StartCodeInvalidStatus extends StartCodeResult {
  const StartCodeInvalidStatus();
}

/// Network or anything unexpected.
final class StartCodeFailed extends StartCodeResult {
  const StartCodeFailed();
}

/// Reads a `verifyStartOtp` error: its message key and `details`.
StartCodeResult startCodeResultForError(String? messageKey, Object? details) {
  final map = details is Map ? details : const <String, Object?>{};
  switch (messageKey) {
    case 'error_code_wrong':
      final left = map['attemptsLeft'];
      return StartCodeWrong(left is int ? left : 0);
    case 'error_code_locked':
      final until = DateTime.tryParse('${map['lockedUntil']}');
      return until == null ? const StartCodeFailed() : StartCodeLocked(until.toLocal());
    case 'error_invalid_status' || 'error_booking_not_found':
      return const StartCodeInvalidStatus();
    default:
      return const StartCodeFailed();
  }
}

/// The mechanic's active job: `bookings/{id}` (readable by the assigned mechanic, #99) and the
/// status steps, which only callables may change.
abstract interface class JobRepository {
  Stream<Booking?> watch(String bookingId);
  Future<TripOutcome> startTrip(String bookingId);
  Future<TripOutcome> markArrived(String bookingId);

  /// M6: the customer's 4-digit start code. The app never reads the code itself (PLAN §12.9).
  Future<StartCodeResult> verifyStartCode(String bookingId, String code);
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

  /// The code the fake accepts (the server keeps the real one in `private/otp`).
  String startCode = '1234';
  int _wrong = 0;
  DateTime? lockedUntil;

  /// The fake's clock for the lock (tests).
  DateTime Function() clock = DateTime.now;

  @override
  Future<StartCodeResult> verifyStartCode(String bookingId, String code) async {
    calls.add('verifyStartCode:$bookingId');
    final until = lockedUntil;
    if (until != null && until.isAfter(clock())) return StartCodeLocked(until);
    if (_bookings[bookingId]?.status != BookingStatus.arrived) return const StartCodeInvalidStatus();
    if (code == startCode) {
      _wrong = 0;
      setStatus(bookingId, BookingStatus.inProgress);
      return const StartCodeAccepted();
    }
    _wrong++;
    // Same rule as the server: the 5th wrong code locks for 10 minutes.
    if (_wrong >= 5) {
      _wrong = 0;
      lockedUntil = clock().add(const Duration(minutes: 10));
      return StartCodeLocked(lockedUntil!);
    }
    return StartCodeWrong(5 - _wrong);
  }
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

  @override
  Future<StartCodeResult> verifyStartCode(String bookingId, String code) async {
    try {
      // verifyStartOtp consumes its App Check token (replay protection), so each call needs a
      // fresh limited-use one; the normal cached token would be refused from the second try on.
      await _functions
          .httpsCallable('verifyStartOtp', options: HttpsCallableOptions(limitedUseAppCheckToken: true))
          .call<Object?>({'bookingId': bookingId, 'code': code});
      return const StartCodeAccepted();
    } on FirebaseFunctionsException catch (e) {
      return startCodeResultForError(e.message, e.details);
    } catch (_) {
      return const StartCodeFailed();
    }
  }
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
