import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../_local_ui/stat_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../bookings/data/bookings_repository.dart';
import '../../console/presentation/labels.dart';
import '../application/dashboard.dart';

/// A1 Dashboard (PLAN §10 admin 1, wireframe A1): stat cards for one IST day and the
/// console's city, then that day's bookings.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final day = ref.watch(dashboardDayProvider);
    final dayNotifier = ref.read(dashboardDayProvider.notifier);
    final stats = ref.watch(dashboardStatsProvider);
    final bookings = ref.watch(dashboardBookingsProvider);

    String dash(Object? v, String Function() format) => v == null ? '—' : format();

    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                dayNotifier.isToday
                    ? l10n.dashboard_today(DateFormat.yMMMd(locale).format(toIst(day)))
                    : DateFormat.yMMMEd(locale).format(toIst(day)),
                style: lane.text.title,
              ),
            ),
            LaneButton.ghost(label: l10n.dashboard_previous_day, onPressed: dayNotifier.previous),
            LaneButton.ghost(
              label: l10n.dashboard_next_day,
              onPressed: dayNotifier.isToday ? null : dayNotifier.next,
            ),
          ],
        ),
        Gap(lane.space.s16),
        if (stats.hasError)
          ErrorState(
            message: l10n.dashboard_load_failed,
            onRetry: () => ref
              ..invalidate(dayBookingsProvider(day))
              ..invalidate(onlineMechanicsProvider),
          )
        else
          Wrap(
            spacing: lane.space.s16,
            runSpacing: lane.space.s16,
            children: [
              for (final (label, value, caption) in <(String, String, String?)>[
                (l10n.dashboard_stat_bookings, dash(stats.value, () => '${stats.value!.bookings}'), null),
                (
                  l10n.dashboard_stat_active_mechanics,
                  dash(stats.value, () => '${stats.value!.activeMechanics}'),
                  l10n.dashboard_stat_active_mechanics_note,
                ),
                (
                  l10n.dashboard_stat_completion,
                  dash(
                    stats.value?.completionRate,
                    () => NumberFormat.percentPattern(locale).format(stats.value!.completionRate),
                  ),
                  null,
                ),
                (
                  l10n.dashboard_stat_median_arrival,
                  dash(
                    stats.value?.medianArrival,
                    () => l10n.dashboard_minutes(stats.value!.medianArrival!.inMinutes),
                  ),
                  l10n.dashboard_stat_median_arrival_note,
                ),
                (l10n.dashboard_stat_sms, '—', l10n.dashboard_stat_sms_note),
              ])
                StatCard(label: label, value: stats.isLoading ? '…' : value, caption: caption),
            ],
          ),
        Gap(lane.space.s32),
        Text(l10n.dashboard_bookings_title, style: lane.text.title),
        Gap(lane.space.s12),
        if (bookings.hasValue)
          bookings.requireValue.isEmpty
              ? Text(
                  l10n.dashboard_bookings_empty,
                  style: lane.text.body.copyWith(color: lane.color.inkMuted),
                )
              : _BookingsTable(bookings: bookings.requireValue)
        else if (!bookings.hasError)
          SkeletonGroup(child: SkeletonBlock(height: lane.touch.critical * 3)),
      ],
    );
  }
}

class _BookingsTable extends StatelessWidget {
  const _BookingsTable({required this.bookings});

  /// Narrower than this, the table scrolls sideways instead of squashing the badges.
  static const minWidth = 760.0;

  final List<BookingEntry> bookings;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final head = lane.text.caps.copyWith(color: lane.color.inkMuted);
    final cellGap = lane.space.s12;
    final cell = EdgeInsets.symmetric(vertical: cellGap, horizontal: cellGap);
    final rupees = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());

    TableRow row(List<Widget> cells, {bool header = false}) => TableRow(
      decoration: header
          ? null
          : BoxDecoration(
              border: Border(
                top: BorderSide(color: lane.color.line, width: lane.stroke.hairline),
              ),
            ),
      children: [for (final c in cells) Padding(padding: cell, child: c)],
    );

    final table = Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {0: FlexColumnWidth(1.2), 4: FlexColumnWidth(0.8)},
      children: [
        row([
          for (final h in [
            l10n.dashboard_column_booking,
            l10n.dashboard_column_customer,
            l10n.dashboard_column_mechanic,
            l10n.dashboard_column_status,
            l10n.dashboard_column_amount,
          ])
            Text(h, style: head),
        ], header: true),
        for (final e in bookings)
          row([
            Text(bookingTitle(l10n, e.id, e.booking.problemType), style: lane.text.body),
            Text(e.booking.customerCard?.name ?? '—', style: lane.text.body),
            Text(e.booking.mechanicCard?.name ?? '—', style: lane.text.body),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SignalBadge(
                signal: bookingSignal(e.booking.status),
                label: bookingStatusLabel(l10n, e.booking.status),
              ),
            ),
            Text(
              e.booking.finalAmount == null ? '—' : '₹${rupees.format(e.booking.finalAmount)}',
              style: lane.text.body,
            ),
          ]),
      ],
    );
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: box.maxWidth < minWidth ? minWidth : box.maxWidth, child: table),
      ),
    );
  }
}
