import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:roadside_core/roadside_core.dart';

import '../application/booking_draft.dart';

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
  FakeBookingService(this.catalog, this.vehicleType);

  final PriceCatalog catalog;
  final Future<VehicleType?> Function(String vehicleId) vehicleType;
  final _byKey = <String, CreatedBooking>{};

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
    final type = await vehicleType(draft.vehicleId!);
    if (type == null) throw const BookingException(BookingException.vehicleNotFound);
    final pickup = draft.pickup!;
    final city = resolveCity(pickup.lat, pickup.lng, await catalog.serviceAreas());
    if (city == null) throw const BookingException(BookingException.outOfArea);
    final price = await catalog.price(type, draft.problem!);
    if (price == null) throw const BookingException(BookingException.priceUnavailable);
    final range = price.rangeFor(city);
    return _byKey[draft.idempotencyKey] = CreatedBooking(
      bookingId: 'booking-${_byKey.length + 1}',
      cityId: city,
      min: range.min,
      max: range.max,
    );
  }
}
