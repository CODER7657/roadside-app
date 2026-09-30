import 'dart:async';

import 'package:roadside_core/roadside_core.dart';

/// The customer's view of one booking (PLAN §8: customers read their own bookings, the
/// start code in `private/otp` and the trip's `liveLocations`; they never write them).
abstract interface class BookingRepository {
  /// The booking as it changes; null if it doesn't exist (or isn't the caller's).
  Stream<Booking?> watch(String bookingId);

  /// The 4-digit start code; null until it exists.
  Stream<BookingOtp?> watchOtp(String bookingId);

  /// The mechanic's position during the trip (`liveLocations/{id}`, every 5 s / 10 m).
  Stream<LiveLocation?> watchLive(String bookingId);
}

class FirestoreBookingRepository implements BookingRepository {
  FirestoreBookingRepository(this._refs);

  final RoadsideRefs _refs;

  @override
  Stream<Booking?> watch(String bookingId) => _refs.booking(bookingId).snapshots().map((s) => s.data());

  @override
  Stream<BookingOtp?> watchOtp(String bookingId) =>
      _refs.bookingOtp(bookingId).snapshots().map((s) => s.data());

  @override
  Stream<LiveLocation?> watchLive(String bookingId) =>
      _refs.liveLocation(bookingId).snapshots().map((s) => s.data());
}

/// Bookings kept in memory until #92 wires Firebase. The fake `createBooking` /
/// `cancelBooking` write here; tests can [put] any booking in any status and [putLive]
/// the mechanic's readings.
class InMemoryBookingStore implements BookingRepository {
  final _bookings = <String, Booking>{};
  final _otps = <String, BookingOtp>{};
  final _lives = <String, LiveLocation>{};

  /// Each change carries its own snapshot, so fast successive changes arrive in order
  /// instead of all showing the latest state.
  final _bookingChanges = StreamController<(String, Booking?)>.broadcast();
  final _otpChanges = StreamController<(String, BookingOtp?)>.broadcast();
  final _liveChanges = StreamController<(String, LiveLocation?)>.broadcast();

  Booking? operator [](String bookingId) => _bookings[bookingId];

  void put(String bookingId, Booking booking, {BookingOtp? otp}) {
    if (otp != null) {
      _otps[bookingId] = otp;
      _otpChanges.add((bookingId, otp));
    }
    _bookings[bookingId] = booking;
    _bookingChanges.add((bookingId, booking));
  }

  void putLive(String bookingId, LiveLocation live) {
    _lives[bookingId] = live;
    _liveChanges.add((bookingId, live));
  }

  void remove(String bookingId) {
    _bookings.remove(bookingId);
    _otps.remove(bookingId);
    _lives.remove(bookingId);
    _otpChanges.add((bookingId, null));
    _liveChanges.add((bookingId, null));
    _bookingChanges.add((bookingId, null));
  }

  /// The value when listening starts, then every change. Reading it and subscribing happen
  /// in the same synchronous step, so no change can slip in between.
  static Stream<T?> _watch<T>(String bookingId, T? Function() current, Stream<(String, T?)> changes) {
    StreamSubscription<(String, T?)>? sub;
    late final StreamController<T?> out;
    out = StreamController<T?>(
      onListen: () {
        out.add(current());
        sub = changes.where((c) => c.$1 == bookingId).listen((c) => out.add(c.$2));
      },
      onCancel: () => sub?.cancel(),
    );
    return out.stream;
  }

  @override
  Stream<Booking?> watch(String bookingId) =>
      _watch(bookingId, () => _bookings[bookingId], _bookingChanges.stream);

  @override
  Stream<BookingOtp?> watchOtp(String bookingId) =>
      _watch(bookingId, () => _otps[bookingId], _otpChanges.stream);

  @override
  Stream<LiveLocation?> watchLive(String bookingId) =>
      _watch(bookingId, () => _lives[bookingId], _liveChanges.stream);
}
