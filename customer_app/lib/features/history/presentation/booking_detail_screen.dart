import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:lane_ui/lane_ui.dart' as ui show PriceRange;
import 'package:roadside_core/roadside_core.dart' as core show JourneyStop;
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../booking/application/live_booking.dart';
import '../../booking/presentation/booking_rail.dart';
import '../application/history.dart';
import 'history_screen.dart';

/// When the booking reached each PLAN §9 stop, from `timestamps`.
DateTime? reachedAt(Booking b, core.JourneyStop stop) => switch (stop) {
  core.JourneyStop.requested => b.timestamps.requested ?? b.createdAt,
  core.JourneyStop.accepted => b.timestamps.accepted,
  core.JourneyStop.onTheWay => b.timestamps.arriving,
  core.JourneyStop.arrived => b.timestamps.arrived,
  core.JourneyStop.working => b.timestamps.started,
  core.JourneyStop.done => b.timestamps.completed,
};

/// The stop the rail stops at: where the booking is, or for a cancelled one (and no mechanic
/// found) the last stop it reached.
int railStop(Booking b) {
  if (b.status.journeyStop case final stop?) return stop.index;
  var last = 0;
  for (final stop in core.JourneyStop.values) {
    if (reachedAt(b, stop) != null) last = stop.index;
  }
  return last;
}

/// U16 Booking detail (PLAN §10 Customer 16, wireframe U16, `LaneListScaffold`): the vertical
/// JourneyRail with the time of each stop, and the receipt (amount, paid by UPI to whom, and
/// whether the mechanic confirmed it).
class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final booking = ref.watch(liveBookingProvider(bookingId));
    final b = booking.value;

    if (b == null) {
      final loading = booking.isLoading && !booking.hasError;
      return LaneListScaffold(
        title: l10n.detail_title,
        showBack: true,
        itemCount: loading ? 3 : 0,
        itemBuilder: (context, _) => SkeletonGroup.lines(lines: 2),
        empty: booking.hasError
            ? ErrorState(
                message: l10n.history_error,
                onRetry: () => ref.invalidate(liveBookingProvider(bookingId)),
              )
            : EmptyState(
                title: l10n.detail_missing,
                actionLabel: l10n.detail_back_to_history,
                onAction: () => context.canPop() ? context.pop() : context.go(AppRoutes.history),
              ),
      );
    }

    final sections = <Widget>[_Summary(booking: b), _Rail(booking: b), _Receipt(booking: b)];
    return LaneListScaffold(
      title: bookingTitle(l10n, b),
      showBack: true,
      itemCount: sections.length,
      itemBuilder: (context, i) => Padding(
        padding: EdgeInsets.only(bottom: context.lane.space.s16),
        child: sections[i],
      ),
      empty: const SizedBox.shrink(),
      // Help & FAQ has the support line and the grievance officer (C9).
      primary: LaneButton.secondary(label: l10n.detail_report, onPressed: () => context.push(AppRoutes.help)),
    );
  }
}

/// Plate, status and day.
class _Summary extends ConsumerWidget {
  const _Summary({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final (label, signal) = statusBadge(l10n, booking.status);
    final at = booking.createdAt ?? booking.timestamps.requested;
    return Wrap(
      spacing: lane.space.s8,
      runSpacing: lane.space.s8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PlateChip(regNo: booking.vehicle.regNo),
        SignalBadge(signal: signal, label: label),
        if (at != null)
          Text(
            bookingDay(context, at, ref.watch(historyClockProvider)()),
            style: lane.text.body.copyWith(color: lane.color.inkMuted),
          ),
      ],
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final time = DateFormat.Hm(Localizations.localeOf(context).toLanguageTag());
    final ended =
        booking.status == BookingStatus.cancelled || booking.status == BookingStatus.noMechanicFound;
    final endedAt = booking.timestamps.cancelled ?? booking.updatedAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JourneyRail(
          direction: Axis.vertical,
          ended: ended,
          current: railStop(booking),
          stops: journeyStops(
            l10n,
            time: (stop) => switch (reachedAt(booking, stop)) {
              final at? => time.format(at.toLocal()),
              null => null,
            },
          ),
        ),
        if (ended) ...[
          SizedBox(height: lane.space.s16),
          Text(switch ((booking.status, booking.cancelledBy, endedAt)) {
            (BookingStatus.noMechanicFound, _, _) => l10n.detail_no_mechanic,
            (_, Actor.customer, final at?) => l10n.detail_cancelled_by_you(time.format(at.toLocal())),
            (_, _, final at?) => l10n.detail_cancelled_at(time.format(at.toLocal())),
            _ => l10n.history_status_cancelled,
          }, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
        ],
      ],
    );
  }
}

/// Amount, how it was paid (UPI straight to the mechanic, PLAN §12.9) and its state.
class _Receipt extends StatelessWidget {
  const _Receipt({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final b = booking;
    final mechanic = b.mechanicCard;
    final done = b.status == BookingStatus.completed;
    final rows = <(String, String)>[
      if (mechanic != null) (l10n.detail_mechanic, mechanic.name),
      if (done && b.finalAmount != null) ...[
        (l10n.detail_amount, ui.PriceRange.rupees(b.finalAmount!)),
        (l10n.detail_paid_by, mechanic == null ? l10n.detail_upi : l10n.detail_upi_to(mechanic.upiName)),
        (
          l10n.detail_payment,
          switch (b.paymentStatus) {
            PaymentStatus.pending => l10n.detail_payment_pending,
            PaymentStatus.customerMarkedPaid => l10n.detail_payment_marked,
            PaymentStatus.confirmed => l10n.detail_payment_confirmed,
            PaymentStatus.disputed => l10n.detail_payment_disputed,
          },
        ),
      ] else if (!b.status.isActive && !done)
        (l10n.detail_amount, l10n.detail_nothing_to_pay),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final (k, v) in rows) _KeyValue(label: k, value: v)],
    );
  }
}

/// "Amount   ₹450": the label on the left, the value on the right; they stack when the text
/// is large.
class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return Semantics(
      container: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: lane.space.s8),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: lane.space.s16,
          children: [
            Text(label, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
            Text(value, style: lane.text.label.copyWith(color: lane.color.ink)),
          ],
        ),
      ),
    );
  }
}
