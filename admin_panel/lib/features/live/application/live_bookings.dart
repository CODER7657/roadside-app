import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../bookings/data/bookings_repository.dart';
import '../../console/application/city_filter.dart';

/// A3 filters on top of the console's city filter (wireframe A3: status, vehicle).
class LiveFilters {
  const LiveFilters({this.status, this.vehicle});

  /// Null = every active status.
  final BookingStatus? status;
  final VehicleType? vehicle;
}

final liveFiltersProvider = NotifierProvider<LiveFiltersController, LiveFilters>(LiveFiltersController.new);

class LiveFiltersController extends Notifier<LiveFilters> {
  @override
  LiveFilters build() => const LiveFilters();

  void status(BookingStatus? s) => state = LiveFilters(status: s, vehicle: state.vehicle);

  void vehicle(VehicleType? v) => state = LiveFilters(status: state.status, vehicle: v);
}

/// Active bookings after the city / status / vehicle filters, oldest request first (they've
/// waited longest).
final liveBookingsProvider = Provider<AsyncValue<List<BookingEntry>>>((ref) {
  final city = ref.watch(cityFilterProvider);
  final f = ref.watch(liveFiltersProvider);
  return ref.watch(activeBookingsProvider).whenData((list) {
    final shown = [
      for (final e in list)
        if ((city == null || e.booking.cityId == city) &&
            (f.status == null || e.booking.status == f.status) &&
            (f.vehicle == null || e.booking.vehicle.type == f.vehicle))
          e,
    ];
    DateTime at(BookingEntry e) => e.booking.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    return shown..sort((a, b) => at(a).compareTo(at(b)));
  });
});

final selectedBookingProvider = NotifierProvider<SelectedBooking, String?>(SelectedBooking.new);

class SelectedBooking extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

/// Admin cancel in flight.
final cancellingProvider = NotifierProvider<Cancelling, bool>(Cancelling.new);

class Cancelling extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> cancel(String bookingId, String reason) async {
    state = true;
    try {
      await ref.read(bookingAdminApiProvider).cancel(bookingId, reason: reason.trim());
      LaneLog.i('admin cancelled booking', {'bookingId': bookingId});
    } finally {
      state = false;
    }
  }
}
