import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:lane_ui/lane_ui.dart' as ui show PriceRange;
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../booking/data/booking_repository.dart';
import '../../booking/presentation/booking_labels.dart';
import '../application/history.dart';

/// The clock "Today" and "Yesterday" are judged by. Tests override it.
final historyClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// "Flat tyre · Swift": what went wrong, on which vehicle.
String bookingTitle(AppLocalizations l10n, Booking b) =>
    '${l10n.problemType(b.problemType)} · ${b.vehicle.model}';

/// "Today", "Yesterday" or "12 Sep", in the app's language.
String bookingDay(BuildContext context, DateTime at, DateTime now) {
  final l10n = AppLocalizations.of(context);
  final local = at.toLocal();
  final today = DateUtils.dateOnly(now.toLocal());
  final days = today.difference(DateUtils.dateOnly(local)).inDays;
  if (days == 0) return l10n.history_today;
  if (days == 1) return l10n.history_yesterday;
  // Day before month, as on the wireframe ("12 Sep"), with the language's month names.
  return DateFormat('d MMM', Localizations.localeOf(context).toLanguageTag()).format(local);
}

/// U15 Booking history (PLAN §10 Customer 15, wireframe U15, `LaneListScaffold`): newest first,
/// filtered All / Active / Past; each row shows its status as a SignalBadge (colour + word).
/// An active booking opens its live screen; a finished one opens U16.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  var _filter = HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(historyProvider);
    final all = history.value ?? const <BookingEntry>[];
    final shown = [
      for (final e in all)
        if (_filter.matches(e.booking.status)) e,
    ];

    final filters = [
      for (final f in HistoryFilter.values)
        LaneChip(
          label: switch (f) {
            HistoryFilter.all => l10n.history_filter_all,
            HistoryFilter.active => l10n.history_filter_active,
            HistoryFilter.past => l10n.history_filter_past,
          },
          selected: f == _filter,
          onSelected: (_) => setState(() => _filter = f),
        ),
    ];

    final Widget empty;
    if (history.hasError && !history.hasValue) {
      empty = ErrorState(message: l10n.history_error, onRetry: () => ref.invalidate(historyProvider));
    } else if (all.isEmpty) {
      empty = EmptyState(
        title: l10n.history_empty_title,
        message: l10n.history_empty_body,
        illustration: LaneIcon(LaneIcons.road, size: lane.space.s64),
        actionLabel: l10n.history_empty_action,
        onAction: () => context.go(AppRoutes.home),
      );
    } else {
      empty = EmptyState(
        title: _filter == HistoryFilter.active ? l10n.history_none_active : l10n.history_none_past,
        actionLabel: l10n.history_show_all,
        onAction: () => setState(() => _filter = HistoryFilter.all),
      );
    }

    final loading = history.isLoading && !history.hasValue && !history.hasError;
    return LaneListScaffold(
      title: l10n.history_title,
      showBack: true,
      filters: loading || all.isEmpty ? null : filters,
      itemCount: loading ? 3 : shown.length,
      itemBuilder: (context, i) => loading ? SkeletonGroup.lines(lines: 2) : _HistoryRow(entry: shown[i]),
      empty: empty,
    );
  }
}

class _HistoryRow extends ConsumerWidget {
  const _HistoryRow({required this.entry});

  final BookingEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final b = entry.booking;
    final (label, signal) = statusBadge(l10n, b.status);
    final at = b.createdAt ?? b.timestamps.requested;
    final day = at == null ? null : bookingDay(context, at, ref.watch(historyClockProvider)());
    final amount = b.status == BookingStatus.completed && b.finalAmount != null
        ? ui.PriceRange.rupees(b.finalAmount!)
        : null;
    final details = [?day, ?amount];
    final lane = context.lane;
    // Not a LaneListTile: the badge sits under the title (wrapping with the day), so a long
    // status in Hindi at 200% text never squeezes the title off the row.
    return InkWell(
      onTap: () =>
          context.push(b.status.isActive ? AppRoutes.booking(entry.id) : AppRoutes.bookingDetail(entry.id)),
      borderRadius: lane.radius.r12,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: lane.touch.primary),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: lane.space.s4, vertical: lane.space.s12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LaneIcon(LaneIcons.forProblem(b.problemType.value), size: lane.space.s32),
              SizedBox(width: lane.space.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookingTitle(l10n, b),
                      style: lane.text.body.copyWith(color: lane.color.ink),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: lane.space.s8),
                    Wrap(
                      spacing: lane.space.s8,
                      runSpacing: lane.space.s4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SignalBadge(signal: signal, label: label),
                        if (details.isNotEmpty)
                          Text(
                            details.join(' · '),
                            style: lane.text.caption.copyWith(color: lane.color.inkMuted),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
