import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:roadside_core/roadside_core.dart';

import '../application/booking_draft.dart';
import 'booking_repository.dart';

/// `prices` and `serviceAreas` (PLAN §8): what U7 needs for the estimate.
abstract interface class PriceCatalog {
  Future<Map<CityId, ServiceArea>> serviceAreas();

  /// `prices/{vehicleType_problemType}`, or null if there's no price for it.
  Future<Price?> price(VehicleType vehicle, ProblemType problem);
}

class FirestorePriceCatalog implements PriceCatalog {
  FirestorePriceCatalog(this._refs);

  final RoadsideRefs _refs;

  @override
  Future<Map<CityId, ServiceArea>> serviceAreas() async {
    final snap = await _refs.serviceAreas.get();
    return {
      for (final d in snap.docs)
        if (CityId.values.any((c) => c.value == d.id)) CityId.fromValue(d.id): d.data(),
    };
  }

  @override
  Future<Price?> price(VehicleType vehicle, ProblemType problem) async =>
      (await _refs.prices.doc(Price.idFor(vehicle, problem)).get()).data();
}

/// Until #92 wires Firebase: the three launch cities and whatever prices a test adds.
class InMemoryPriceCatalog implements PriceCatalog {
  InMemoryPriceCatalog({Map<CityId, ServiceArea>? areas, this.prices = const {}})
    : areas = areas ?? launchAreas;

  final Map<CityId, ServiceArea> areas;
  final Map<String, Price> prices;

  /// Mirrors `firebase/seed/data/serviceAreas.json` (PLAN §8).
  static final launchAreas = <CityId, ServiceArea>{
    CityId.ahmedabad: _area('Ahmedabad', 'अहमदाबाद', 'અમદાવાદ', 23.0225, 72.5714, 25),
    CityId.ankleshwar: _area('Ankleshwar', 'अंकलेश्वर', 'અંકલેશ્વર', 21.6264, 73.0152, 12),
    CityId.bharuch: _area('Bharuch', 'भरूच', 'ભરૂચ', 21.7051, 72.9959, 12),
  };

  static ServiceArea _area(String en, String hi, String gu, double lat, double lng, double radiusKm) =>
      ServiceArea(
        name: LocalizedText(en: en, hi: hi, gu: gu),
        center: GeoPoint(lat, lng),
        radiusKm: radiusKm,
        active: true,
        supportPhone: '',
      );

  @override
  Future<Map<CityId, ServiceArea>> serviceAreas() async => areas;

  @override
  Future<Price?> price(VehicleType vehicle, ProblemType problem) async =>
      prices[Price.idFor(vehicle, problem)];
}

/// What `createBooking` returned.
@immutable
class CreatedBooking {
  const CreatedBooking({required this.bookingId, required this.cityId, required this.min, required this.max});

  final String bookingId;
  final CityId cityId;
  final int min;
  final int max;
}

/// A `createBooking` failure, by the server's safe message key (`error_out_of_area`, …).
class BookingException implements Exception {
  const BookingException(this.code, {this.activeBookingId});

  /// The HttpsError message key, or [network] / [unknown].
  final String code;

  /// With `error_active_booking_exists`: the booking that's already open.
  final String? activeBookingId;

  static const outOfArea = 'error_out_of_area';
  static const activeBookingExists = 'error_active_booking_exists';
  static const servicePaused = 'error_service_paused';
  static const priceUnavailable = 'error_price_unavailable';
  static const vehicleNotFound = 'error_vehicle_not_found';
  static const rateLimited = 'error_rate_limited';

  /// `cancelBooking`: the booking can't be cancelled any more (work has started, or it ended).
  static const invalidStatus = 'error_invalid_status';
  static const bookingNotFound = 'error_booking_not_found';

  /// `markPaid` / `disputePayment`: the payment has already moved on (PLAN §9 Payment).
  static const invalidPaymentStatus = 'error_invalid_payment_status';
  static const network = 'network';
  static const unknown = 'unknown';

  @override
  String toString() => 'BookingException($code)';
}

/// The exact input `createBooking` validates (zod schema in Functions).
Map<String, Object?> createBookingPayload(BookingDraft draft) {
  final pickup = draft.pickup!;
  return {
    'idempotencyKey': draft.idempotencyKey,
    'vehicleId': draft.vehicleId,
    'problemType': draft.problem!.value,
    'description': draft.description.trim(),
    'photoUrls': draft.photoUrls,
    'pickup': {
      'lat': pickup.lat,
      'lng': pickup.lng,
      'address': pickup.address,
      'landmark': pickup.landmark,
      'plusCode': pickup.plusCode,
      'accuracyMeters': pickup.accuracyMeters,
    },
    // The customer confirmed the pin on U6.
    'pinConfirmed': true,
  };
}

abstract interface class BookingService {
  /// Books a mechanic for [draft]. Retrying with the same draft returns the same booking.
  /// Throws [BookingException].
  Future<CreatedBooking> createBooking(BookingDraft draft);

  /// `cancelBooking` as the customer, with a required reason (PLAN §9). Throws [BookingException].
  Future<void> cancelBooking(String bookingId, CancelReason reason);

  /// "I have paid": `pending → customer_marked_paid` (#128). Throws [BookingException].
  Future<void> markPaid(String bookingId);

  /// "Something's wrong": `→ disputed` and a payment complaint for the admins (#128).
  Future<void> disputePayment(String bookingId, String text);
}

/// The reasons the customer cancel sheet offers (`cancelBooking` takes any snake_case code;
/// #35 suggests moving the list into roadside_core so the mechanic app agrees).
abstract final class CustomerCancelReasons {
  static const foundHelp = 'found_help';
  static const fixedMyself = 'fixed_myself';
  static const tooSlow = 'too_slow';
  static const wrongDetails = 'wrong_details';
  static const other = 'other';
  static const all = [foundHelp, fixedMyself, tooSlow, wrongDetails, other];
}

/// `createBooking` in `asia-south1` (PLAN §9).
class CallableBookingService implements BookingService {
  CallableBookingService(this._functions);

  final FirebaseFunctions _functions;

  @override
  Future<CreatedBooking> createBooking(BookingDraft draft) async {
    try {
      final result = await _functions
          .httpsCallable('createBooking')
          .call<Map<String, Object?>>(createBookingPayload(draft));
      final data = result.data;
      final estimate = (data['priceEstimate']! as Map).cast<String, Object?>();
      return CreatedBooking(
        bookingId: data['bookingId']! as String,
        cityId: CityId.fromValue(data['cityId']! as String),
        min: (estimate['min']! as num).toInt(),
        max: (estimate['max']! as num).toInt(),
      );
    } on FirebaseFunctionsException catch (e) {
      throw bookingExceptionFrom(e.code, e.message, e.details);
    }
  }

  @override
  Future<void> markPaid(String bookingId) => _call('markPaid', {'bookingId': bookingId});

  @override
  Future<void> disputePayment(String bookingId, String text) =>
      _call('disputePayment', {'bookingId': bookingId, 'text': text.trim()});

  Future<void> _call(String name, Map<String, Object?> data) async {
    try {
      await _functions.httpsCallable(name).call<Object?>(data);
    } on FirebaseFunctionsException catch (e) {
      throw bookingExceptionFrom(e.code, e.message, e.details);
    }
  }

  @override
  Future<void> cancelBooking(String bookingId, CancelReason reason) async {
    try {
      await _functions.httpsCallable('cancelBooking').call<Object?>({
        'bookingId': bookingId,
        'reason': {'code': reason.code, if (reason.text != null) 'text': reason.text},
      });
    } on FirebaseFunctionsException catch (e) {
      throw bookingExceptionFrom(e.code, e.message, e.details);
    }
  }
}

/// Maps an HttpsError to a [BookingException]: the message is the server's key.
BookingException bookingExceptionFrom(String code, String? message, Object? details) {
  if (code == 'unavailable' && message != BookingException.servicePaused) {
    return const BookingException(BookingException.network);
  }
  if (code == 'deadline-exceeded') return const BookingException(BookingException.network);
  final key = message != null && message.startsWith('error_') ? message : BookingException.unknown;
  final active = details is Map ? details['bookingId'] as String? : null;
  return BookingException(key, activeBookingId: active);
}

/// Until #92 wires Firebase: books against the in-memory catalog, idempotently.
class FakeBookingService implements BookingService {
  FakeBookingService(this.catalog, this.vehicleOf, {InMemoryBookingStore? store, Random? random})
    : store = store ?? InMemoryBookingStore(),
      _random = random ?? Random();

  final PriceCatalog catalog;
  final Future<Vehicle?> Function(String vehicleId) vehicleOf;

  /// Where the created bookings live, so U8/U9 can watch them.
  final InMemoryBookingStore store;
  final Random _random;
  final _byKey = <String, CreatedBooking>{};

  /// The signed-in customer until #96.
  static const customerId = 'me';

  /// Set to make the next call fail.
  BookingException? failNext;
  int calls = 0;

  @override
  Future<CreatedBooking> createBooking(BookingDraft draft) async {
    calls++;
    final fail = failNext;
    if (fail != null) {
      failNext = null;
      throw fail;
    }
    final existing = _byKey[draft.idempotencyKey];
    if (existing != null) return existing;
    final vehicle = await vehicleOf(draft.vehicleId!);
    if (vehicle == null) throw const BookingException(BookingException.vehicleNotFound);
    final pickup = draft.pickup!;
    final city = resolveCity(pickup.lat, pickup.lng, await catalog.serviceAreas());
    if (city == null) throw const BookingException(BookingException.outOfArea);
    final price = await catalog.price(vehicle.type, draft.problem!);
    if (price == null) throw const BookingException(BookingException.priceUnavailable);
    final range = price.rangeFor(city);
    final bookingId = 'booking-${_byKey.length + 1}';
    store.put(
      bookingId,
      Booking(
        customerId: customerId,
        cityId: city,
        vehicle: BookingVehicle(
          type: vehicle.type,
          brand: vehicle.brand,
          model: vehicle.model,
          regNo: vehicle.regNo,
        ),
        problemType: draft.problem!,
        description: draft.description.trim(),
        photoUrls: draft.photoUrls,
        pickup: Pickup(
          geopoint: GeoPoint(pickup.lat, pickup.lng),
          geohash: encodeGeohash(pickup.lat, pickup.lng),
          address: pickup.address,
          landmark: pickup.landmark,
          plusCode: pickup.plusCode,
          accuracyMeters: pickup.accuracyMeters,
        ),
        status: BookingStatus.requested,
        searchRadiusKm: 3,
        priceEstimate: range,
        idempotencyKey: draft.idempotencyKey,
      ),
      otp: BookingOtp(code: _random.nextInt(10000).toString().padLeft(4, '0')),
    );
    return _byKey[draft.idempotencyKey] = CreatedBooking(
      bookingId: bookingId,
      cityId: city,
      min: range.min,
      max: range.max,
    );
  }

  /// Follows the §9 table for the customer: anything before `in_progress` can be cancelled.
  @override
  Future<void> cancelBooking(String bookingId, CancelReason reason) async {
    calls++;
    final fail = failNext;
    if (fail != null) {
      failNext = null;
      throw fail;
    }
    final booking = store[bookingId];
    if (booking == null || booking.customerId != customerId) {
      throw const BookingException(BookingException.bookingNotFound);
    }
    if (!canTransition(booking.status, BookingStatus.cancelled, Actor.customer)) {
      throw const BookingException(BookingException.invalidStatus);
    }
    store.put(
      bookingId,
      booking.copyWith(status: BookingStatus.cancelled, cancelledBy: Actor.customer, cancelReason: reason),
    );
  }

  @override
  Future<void> markPaid(String bookingId) =>
      _pay(bookingId, from: const [PaymentStatus.pending], to: PaymentStatus.customerMarkedPaid);

  @override
  Future<void> disputePayment(String bookingId, String text) => _pay(
    bookingId,
    from: const [PaymentStatus.pending, PaymentStatus.customerMarkedPaid],
    to: PaymentStatus.disputed,
  );

  /// The #128 payment table for the customer: only on a completed booking of theirs.
  Future<void> _pay(String bookingId, {required List<PaymentStatus> from, required PaymentStatus to}) async {
    calls++;
    final fail = failNext;
    if (fail != null) {
      failNext = null;
      throw fail;
    }
    final booking = store[bookingId];
    if (booking == null || booking.customerId != customerId) {
      throw const BookingException(BookingException.bookingNotFound);
    }
    if (booking.status != BookingStatus.completed) {
      throw const BookingException(BookingException.invalidStatus);
    }
    if (!from.contains(booking.paymentStatus)) {
      throw const BookingException(BookingException.invalidPaymentStatus);
    }
    store.put(bookingId, booking.copyWith(paymentStatus: to));
  }
}
