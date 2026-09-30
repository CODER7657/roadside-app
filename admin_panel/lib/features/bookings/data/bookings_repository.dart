import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../app/firebase_providers.dart';
import '../../approvals/data/mechanic_admin_api.dart' show AdminActionException, AdminActionFailure;

/// A booking with its id.
typedef BookingEntry = ({String id, Booking booking});

/// India has one time zone and no daylight saving: the console's "day" is an IST day.
const istOffset = Duration(hours: 5, minutes: 30);

DateTime toIst(DateTime utc) => utc.toUtc().add(istOffset);

/// The UTC instant an IST calendar day starts.
DateTime istDayStart(DateTime anyUtc) {
  final ist = toIst(anyUtc);
  return DateTime.utc(ist.year, ist.month, ist.day).subtract(istOffset);
}

/// Reads for A1 / A3. Admins may read bookings, presence, live locations and service areas
/// (firestore.rules). Streams listen on plain refs and convert here (see MechanicsRepository).
class BookingsRepository {
  BookingsRepository(this._db) : _refs = RoadsideRefs(_db);

  final FirebaseFirestore _db;
  final RoadsideRefs _refs;

  /// Bookings created during the IST day starting at [dayStartUtc], newest first.
  Stream<List<BookingEntry>> watchDay(DateTime dayStartUtc) => _db
      .collection(Collections.bookings)
      .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStartUtc))
      .where('createdAt', isLessThan: Timestamp.fromDate(dayStartUtc.add(const Duration(days: 1))))
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(_entries);

  /// Bookings still in progress (PLAN §9 active statuses).
  Stream<List<BookingEntry>> watchActive() => _db
      .collection(Collections.bookings)
      .where('status', whereIn: [for (final s in kActiveStatuses) s.value])
      .snapshots()
      .map(_entries);

  /// Mechanics that say they're online. Callers drop stale ones (PLAN §11: > 2 min = offline).
  Stream<List<Presence>> watchOnline() => _db
      .collection(Collections.presence)
      .where('isOnline', isEqualTo: true)
      .snapshots()
      .map((q) => [for (final d in q.docs) Presence.fromJson(d.data())]);

  Stream<Map<CityId, ServiceArea>> watchServiceAreas() => _db
      .collection(Collections.serviceAreas)
      .snapshots()
      .map(
        (q) => {
          for (final d in q.docs)
            if (CityId.values.any((c) => c.value == d.id))
              CityId.fromValue(d.id): ServiceArea.fromJson(d.data()),
        },
      );

  Stream<LiveLocation?> watchLiveLocation(String bookingId) =>
      _refs.raw(_refs.liveLocation(bookingId)).snapshots().map((s) {
        final data = s.data();
        return data == null ? null : LiveLocation.fromJson(data);
      });

  static List<BookingEntry> _entries(QuerySnapshot<Map<String, dynamic>> q) => [
    for (final d in q.docs) (id: d.id, booking: Booking.fromJson(d.data())),
  ];
}

/// Admin cancel (PLAN §9: `cancelled` by admin, reason required) through `cancelBooking`.
abstract interface class BookingAdminApi {
  Future<void> cancel(String bookingId, {required String reason});
}

class FirebaseBookingAdminApi implements BookingAdminApi {
  FirebaseBookingAdminApi(this._functions);

  final FirebaseFunctions _functions;

  @override
  Future<void> cancel(String bookingId, {required String reason}) async {
    try {
      await _functions.httpsCallable('cancelBooking').call<Object?>({
        'bookingId': bookingId,
        'reason': {'code': 'admin_cancel', 'text': reason},
      });
    } on FirebaseFunctionsException catch (e) {
      throw AdminActionException(switch (e.code) {
        'not-found' || 'unavailable' || 'internal' => AdminActionFailure.unavailable,
        'failed-precondition' => AdminActionFailure.precondition,
        'permission-denied' || 'unauthenticated' => AdminActionFailure.notAllowed,
        _ => AdminActionFailure.unknown,
      });
    }
  }
}

final bookingsRepositoryProvider = Provider<BookingsRepository>(
  (ref) => BookingsRepository(ref.watch(firestoreProvider)),
);

final bookingAdminApiProvider = Provider<BookingAdminApi>(
  (ref) => FirebaseBookingAdminApi(ref.watch(functionsProvider)),
);

final serviceAreasProvider = StreamProvider<Map<CityId, ServiceArea>>(
  (ref) => ref.watch(bookingsRepositoryProvider).watchServiceAreas(),
);

final onlineMechanicsProvider = StreamProvider<List<Presence>>(
  (ref) => ref.watch(bookingsRepositoryProvider).watchOnline(),
);

final activeBookingsProvider = StreamProvider<List<BookingEntry>>(
  (ref) => ref.watch(bookingsRepositoryProvider).watchActive(),
);

final liveLocationProvider = StreamProvider.family<LiveLocation?, String>(
  (ref, bookingId) => ref.watch(bookingsRepositoryProvider).watchLiveLocation(bookingId),
);
