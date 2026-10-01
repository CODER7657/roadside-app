import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart' show LaneSignal;
import 'package:roadside_core/roadside_core.dart';

import '../../../l10n/app_localizations.dart';
import '../../booking/application/estimate.dart';
import '../../booking/data/booking_repository.dart';

/// U15: the signed-in customer's bookings, newest first.
final historyProvider = StreamProvider.autoDispose<List<BookingEntry>>(
  (ref) => ref.watch(bookingRepositoryProvider).watchHistory(ref.watch(customerIdProvider)),
);

/// U15's filter chips.
enum HistoryFilter {
  all,
  active,
  past;

  bool matches(BookingStatus s) => switch (this) {
    HistoryFilter.all => true,
    HistoryFilter.active => s.isActive,
    HistoryFilter.past => !s.isActive,
  };
}

/// A booking's status as one word and its signal colour (PLAN §6.7): colour + word, never
/// colour alone. Cancelled and no-mechanic are neutral grey, not red (§6.5 ②).
(String, LaneSignal) statusBadge(AppLocalizations l10n, BookingStatus s) => switch (s) {
  BookingStatus.requested => (l10n.history_status_searching, LaneSignal.wait),
  BookingStatus.accepted || BookingStatus.arriving => (l10n.stop_on_the_way, LaneSignal.route),
  BookingStatus.arrived => (l10n.stop_arrived, LaneSignal.go),
  BookingStatus.inProgress => (l10n.stop_working, LaneSignal.work),
  BookingStatus.completed => (l10n.stop_done, LaneSignal.go),
  BookingStatus.cancelled => (l10n.history_status_cancelled, LaneSignal.neutral),
  BookingStatus.noMechanicFound => (l10n.history_status_no_mechanic, LaneSignal.neutral),
};
