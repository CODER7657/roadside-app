import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
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

/// The amount rule of `completeJob` (#117): the final amount must be within 0.5x the estimate's
/// minimum and 3x its maximum, or come with a reason.
({int min, int max}) amountBounds(PriceRange estimate) =>
    (min: (0.5 * estimate.min).ceil(), max: 3 * estimate.max);

bool amountNeedsReason(int amount, PriceRange estimate) {
  final b = amountBounds(estimate);
  return amount < b.min || amount > b.max;
}

/// Why the amount on M7 is outside the usual range (codes for `completeJob.amountReason`).
enum AmountReason {
  extraWork('extra_work'),
  parts('parts'),
  discount('discount'),
  other('other');

  const AmountReason(this.code);
  final String code;
}

/// What `completeJob` said (M7).
sealed class CompleteResult {
  const CompleteResult();
}

final class JobCompleted extends CompleteResult {
  const JobCompleted();
}

/// The amount is outside [min]..[max] and needs a reason.
final class AmountNeedsReason extends CompleteResult {
  const AmountNeedsReason({required this.min, required this.max});

  final int min;
  final int max;
}

enum CompleteProblem {
  /// A photo isn't one of this booking's `work/` uploads.
  photoInvalid,

  /// The booking moved on (e.g. cancelled).
  invalidStatus,

  failed,
}

final class CompleteRejected extends CompleteResult {
  const CompleteRejected(this.problem);

  final CompleteProblem problem;
}

CompleteResult completeResultForError(String? messageKey, Object? details) {
  final map = details is Map ? details : const <String, Object?>{};
  return switch (messageKey) {
    'error_amount_reason_required' when map['min'] is int && map['max'] is int => AmountNeedsReason(
      min: map['min'] as int,
      max: map['max'] as int,
    ),
    'error_photo_invalid' => const CompleteRejected(CompleteProblem.photoInvalid),
    'error_invalid_status' ||
    'error_booking_not_found' => const CompleteRejected(CompleteProblem.invalidStatus),
    _ => const CompleteRejected(CompleteProblem.failed),
  };
}

/// What `confirmPayment` / `disputePayment` said (M8).
enum PaymentOutcome { ok, invalidStatus, failed }

PaymentOutcome paymentOutcomeForError(String? messageKey) => switch (messageKey) {
  'error_invalid_status' ||
  'error_booking_not_found' ||
  'error_invalid_transition' => PaymentOutcome.invalidStatus,
  _ => PaymentOutcome.failed,
};

/// M7 photos, uploaded to `bookings/{id}/work/{fileName}` (the only place the storage rules let
/// the assigned mechanic upload them, while arrived or in progress). Returns the download URL
/// that `completeJob` checks.
abstract interface class WorkPhotoUploader {
  Future<String> upload({required String bookingId, required String fileName, required Uint8List bytes});
}

class FirebaseWorkPhotoUploader implements WorkPhotoUploader {
  FirebaseWorkPhotoUploader(this._storage);

  final FirebaseStorage _storage;

  @override
  Future<String> upload({
    required String bookingId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref('bookings/$bookingId/work/$fileName');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}

/// Until Firebase is wired: keeps nothing and returns Storage-shaped URLs.
class FakeWorkPhotoUploader implements WorkPhotoUploader {
  final uploaded = <String>[];

  /// How many of the next uploads fail (tests).
  int failNext = 0;

  @override
  Future<String> upload({
    required String bookingId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (failNext > 0) {
      failNext--;
      throw Exception('upload failed');
    }
    final path = 'bookings/$bookingId/work/$fileName';
    uploaded.add(path);
    return 'https://firebasestorage.googleapis.com/v0/b/demo-roadside/o/${Uri.encodeComponent(path)}?alt=media';
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

  /// M7: in progress -> completed. [afterPhotoUrls] needs at least one.
  Future<CompleteResult> completeJob(
    String bookingId, {
    required int finalAmount,
    required List<String> beforePhotoUrls,
    required List<String> afterPhotoUrls,
    AmountReason? amountReason,
  });

  /// M8 "Yes, received": customer_marked_paid -> confirmed.
  Future<PaymentOutcome> confirmPayment(String bookingId);

  /// M8 "Not received": -> disputed, and a complaint for the admins (A5).
  Future<PaymentOutcome> disputePayment(String bookingId, String text);
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

  final disputes = <String>[];

  /// What the next `completeJob` returns instead of the normal answer (tests).
  CompleteResult? nextComplete;

  /// What the customer's app does (U13 "I have paid"); tests.
  void setPayment(String bookingId, PaymentStatus status) {
    _bookings[bookingId] = _bookings[bookingId]!.copyWith(paymentStatus: status);
    _changes.add(bookingId);
  }

  @override
  Future<CompleteResult> completeJob(
    String bookingId, {
    required int finalAmount,
    required List<String> beforePhotoUrls,
    required List<String> afterPhotoUrls,
    AmountReason? amountReason,
  }) async {
    calls.add('completeJob:$bookingId');
    final forced = nextComplete;
    nextComplete = null;
    if (forced != null) return forced;
    final b = _bookings[bookingId];
    if (b == null || b.status != BookingStatus.inProgress) {
      return const CompleteRejected(CompleteProblem.invalidStatus);
    }
    if (afterPhotoUrls.isEmpty) return const CompleteRejected(CompleteProblem.photoInvalid);
    if (amountReason == null && amountNeedsReason(finalAmount, b.priceEstimate)) {
      final bounds = amountBounds(b.priceEstimate);
      return AmountNeedsReason(min: bounds.min, max: bounds.max);
    }
    _bookings[bookingId] = b.copyWith(
      status: BookingStatus.completed,
      finalAmount: finalAmount,
      beforePhotoUrls: beforePhotoUrls,
      afterPhotoUrls: afterPhotoUrls,
      paymentStatus: PaymentStatus.pending,
    );
    _changes.add(bookingId);
    return const JobCompleted();
  }

  @override
  Future<PaymentOutcome> confirmPayment(String bookingId) async {
    calls.add('confirmPayment:$bookingId');
    final b = _bookings[bookingId];
    if (b == null || b.paymentStatus != PaymentStatus.customerMarkedPaid) return PaymentOutcome.invalidStatus;
    setPayment(bookingId, PaymentStatus.confirmed);
    return PaymentOutcome.ok;
  }

  @override
  Future<PaymentOutcome> disputePayment(String bookingId, String text) async {
    calls.add('disputePayment:$bookingId');
    final b = _bookings[bookingId];
    if (b == null ||
        !(b.paymentStatus == PaymentStatus.pending || b.paymentStatus == PaymentStatus.customerMarkedPaid)) {
      return PaymentOutcome.invalidStatus;
    }
    disputes.add(text);
    setPayment(bookingId, PaymentStatus.disputed);
    return PaymentOutcome.ok;
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

  /// `verifyStartOtp` and `confirmPayment` consume their App Check token (replay protection,
  /// PLAN §12.6), so they need a limited-use token.
  static final _limitedUse = HttpsCallableOptions(limitedUseAppCheckToken: true);

  @override
  Future<TripOutcome> markArrived(String bookingId) => _call('markArrived', bookingId);

  @override
  Future<StartCodeResult> verifyStartCode(String bookingId, String code) async {
    try {
      await _functions.httpsCallable('verifyStartOtp', options: _limitedUse).call<Object?>({
        'bookingId': bookingId,
        'code': code,
      });
      return const StartCodeAccepted();
    } on FirebaseFunctionsException catch (e) {
      return startCodeResultForError(e.message, e.details);
    } catch (_) {
      return const StartCodeFailed();
    }
  }

  @override
  Future<CompleteResult> completeJob(
    String bookingId, {
    required int finalAmount,
    required List<String> beforePhotoUrls,
    required List<String> afterPhotoUrls,
    AmountReason? amountReason,
  }) async {
    try {
      await _functions.httpsCallable('completeJob').call<Object?>({
        'bookingId': bookingId,
        'finalAmount': finalAmount,
        'beforePhotoUrls': beforePhotoUrls,
        'afterPhotoUrls': afterPhotoUrls,
        if (amountReason != null) 'amountReason': {'code': amountReason.code},
      });
      return const JobCompleted();
    } on FirebaseFunctionsException catch (e) {
      return completeResultForError(e.message, e.details);
    } catch (_) {
      return const CompleteRejected(CompleteProblem.failed);
    }
  }

  Future<PaymentOutcome> _payment(
    String name,
    Map<String, Object?> data, {
    HttpsCallableOptions? options,
  }) async {
    try {
      await _functions.httpsCallable(name, options: options).call<Object?>(data);
      return PaymentOutcome.ok;
    } on FirebaseFunctionsException catch (e) {
      return paymentOutcomeForError(e.message);
    } catch (_) {
      return PaymentOutcome.failed;
    }
  }

  @override
  Future<PaymentOutcome> confirmPayment(String bookingId) =>
      _payment('confirmPayment', {'bookingId': bookingId}, options: _limitedUse);

  @override
  Future<PaymentOutcome> disputePayment(String bookingId, String text) =>
      _payment('disputePayment', {'bookingId': bookingId, 'text': text});
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
