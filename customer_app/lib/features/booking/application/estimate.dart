import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../vehicles/application/vehicles.dart';
import '../data/booking_repository.dart';
import '../data/booking_service.dart';
import 'booking_draft.dart';

/// In memory until #92 wires Firebase: then `FirestorePriceCatalog(RoadsideRefs(FirebaseFirestore.instance))`.
final priceCatalogProvider = Provider<PriceCatalog>((ref) => InMemoryPriceCatalog());

/// Fake until #92 wires Firebase: then `CallableBookingService(FirebaseFunctions.instanceFor(region: 'asia-south1'))`.
final bookingServiceProvider = Provider<BookingService>(
  (ref) => FakeBookingService(ref.watch(priceCatalogProvider), (vehicleId) async {
    final list = await ref.read(vehiclesProvider.future);
    return list.where((v) => v.id == vehicleId).firstOrNull?.vehicle;
  }, store: ref.watch(bookingStoreProvider)),
);

/// In memory until #92: the fake `createBooking` writes here and U8/U9 watch it.
final bookingStoreProvider = Provider<InMemoryBookingStore>((ref) => InMemoryBookingStore());

/// Then `FirestoreBookingRepository(RoadsideRefs(FirebaseFirestore.instance))`.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) => ref.watch(bookingStoreProvider));

/// What U7 shows before booking: the range for this vehicle and problem in the pickup's city.
@immutable
class Estimate {
  const Estimate({required this.cityId, required this.min, required this.max, required this.includes});

  final CityId cityId;
  final int min;
  final int max;
  final String includes;
}

/// The estimate for the current draft. Fails with a [BookingException]
/// (`error_out_of_area`, `error_price_unavailable`, `error_vehicle_not_found`) the same way
/// `createBooking` would, so U7 shows the problem before the customer taps Book.
final estimateProvider = FutureProvider.autoDispose<Estimate>((ref) async {
  final (vehicleId, problem, pickup) = ref.watch(
    bookingDraftProvider.select((d) => (d.vehicleId, d.problem, d.pickup)),
  );
  if (vehicleId == null || problem == null || pickup == null) {
    throw const BookingException(BookingException.unknown);
  }
  final vehicles = await ref.watch(vehiclesProvider.future);
  final vehicle = vehicles.where((v) => v.id == vehicleId).firstOrNull;
  if (vehicle == null) throw const BookingException(BookingException.vehicleNotFound);

  final catalog = ref.watch(priceCatalogProvider);
  final city = resolveCity(pickup.lat, pickup.lng, await catalog.serviceAreas());
  if (city == null) throw const BookingException(BookingException.outOfArea);
  final price = await catalog.price(vehicle.vehicle.type, problem);
  if (price == null) throw const BookingException(BookingException.priceUnavailable);
  final range = price.rangeFor(city);
  return Estimate(cityId: city, min: range.min, max: range.max, includes: price.includes);
});

/// The booking `createBooking` made, for U8 Searching (#16).
class ActiveBookingNotifier extends Notifier<CreatedBooking?> {
  @override
  CreatedBooking? build() => null;

  void set(CreatedBooking booking) => state = booking;
}

final activeBookingProvider = NotifierProvider<ActiveBookingNotifier, CreatedBooking?>(
  ActiveBookingNotifier.new,
);
