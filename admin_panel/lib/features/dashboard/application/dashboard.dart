import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart' show laneClockProvider;
import 'package:roadside_core/roadside_core.dart';

import '../../bookings/data/bookings_repository.dart';
import '../../console/application/city_filter.dart';

/// Presence older than this is offline (PLAN §11, mechanic app #27).
const presenceStaleAfter = Duration(minutes: 2);

/// A1's numbers for one IST day and city (PLAN §10 admin 1).
class DashboardStats {
  const DashboardStats({
    required this.bookings,
    required this.activeMechanics,
    required this.completionRate,
    required this.medianArrival,
  });

  /// [day] = bookings created that day; [online] = mechanics' presence documents.
  factory DashboardStats.from({
    required List<BookingEntry> day,
    required List<Presence> online,
    required DateTime now,
  }) {
    final ended = day.where((e) => e.booking.status.isTerminal).toList();
    final completed = ended.where((e) => e.booking.status == BookingStatus.completed).length;
    final arrivals = [
      for (final e in day)
        if (e.booking.timestamps case BookingTimestamps(:final accepted?, :final arrived?))
          arrived.difference(accepted),
    ]..sort();
    return DashboardStats(
      bookings: day.length,
      activeMechanics: online
          .where(
            (p) => p.isOnline && p.updatedAt != null && now.difference(p.updatedAt!) <= presenceStaleAfter,
          )
          .length,
      completionRate: ended.isEmpty ? null : completed / ended.length,
      medianArrival: arrivals.isEmpty ? null : _median(arrivals),
    );
  }

  final int bookings;
  final int activeMechanics;

  /// Completed ÷ ended (completed, cancelled, no mechanic). Null when nothing ended yet.
  final double? completionRate;

  /// Median accept → arrive. Null when nobody arrived yet.
  final Duration? medianArrival;

  static Duration _median(List<Duration> sorted) {
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) ~/ 2;
  }
}

/// The IST day A1 shows, as the UTC instant it starts. Defaults to today.
final dashboardDayProvider = NotifierProvider<DashboardDay, DateTime>(DashboardDay.new);

class DashboardDay extends Notifier<DateTime> {
  @override
  DateTime build() => istDayStart(ref.watch(laneClockProvider)());

  void previous() => state = state.subtract(const Duration(days: 1));

  void next() {
    final today = istDayStart(ref.read(laneClockProvider)());
    if (state.isBefore(today)) state = state.add(const Duration(days: 1));
  }

  bool get isToday => !state.isBefore(istDayStart(ref.read(laneClockProvider)()));
}

final dayBookingsProvider = StreamProvider.family<List<BookingEntry>, DateTime>(
  (ref, dayStartUtc) => ref.watch(bookingsRepositoryProvider).watchDay(dayStartUtc),
);

/// The day's bookings in the console's city.
final dashboardBookingsProvider = Provider<AsyncValue<List<BookingEntry>>>((ref) {
  final city = ref.watch(cityFilterProvider);
  return ref
      .watch(dayBookingsProvider(ref.watch(dashboardDayProvider)))
      .whenData(
        (list) => [
          for (final e in list)
            if (city == null || e.booking.cityId == city) e,
        ],
      );
});

final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  final city = ref.watch(cityFilterProvider);
  final day = ref.watch(dashboardBookingsProvider);
  final online = ref.watch(onlineMechanicsProvider);
  if (day.hasError) return AsyncError(day.error!, day.stackTrace ?? StackTrace.empty);
  if (online.hasError) return AsyncError(online.error!, online.stackTrace ?? StackTrace.empty);
  if (!day.hasValue || !online.hasValue) return const AsyncLoading();
  return AsyncData(
    DashboardStats.from(
      day: day.requireValue,
      online: [
        for (final p in online.requireValue)
          if (city == null || p.cityId == city) p,
      ],
      now: ref.watch(laneClockProvider)(),
    ),
  );
});
