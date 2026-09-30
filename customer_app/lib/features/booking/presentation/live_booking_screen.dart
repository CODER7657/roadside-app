import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:roadside_core/roadside_core.dart' as core show JourneyStop;
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../application/booking_draft.dart';
import '../application/estimate.dart';
import '../application/live_booking.dart';
import '../data/booking_service.dart';
import 'tracking_view.dart';

/// The customer's live booking, one screen that follows `bookings/{id}`:
/// U8 Searching (`requested`), U9 Assigned (`accepted` … `arrived`, until U10 #126 takes
/// over the trip), and the endings (`no_mechanic_found`, `cancelled`).
class LiveBookingScreen extends ConsumerStatefulWidget {
  const LiveBookingScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<LiveBookingScreen> createState() => _LiveBookingScreenState();
}

class _LiveBookingScreenState extends ConsumerState<LiveBookingScreen> {
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    // The success haptic when a mechanic accepts while the customer is watching (PLAN §6.5 ⑧).
    ref.listenManual(liveBookingProvider(widget.bookingId), (before, now) {
      final was = before?.value?.status;
      final is_ = now.value?.status;
      if (was == BookingStatus.requested && is_ == BookingStatus.accepted) {
        unawaited(LaneHaptics.statusAdvance());
      }
    });
  }

  Future<void> _cancel(Booking booking) async {
    if (_cancelling) return;
    final l10n = AppLocalizations.of(context);
    final picked = await LaneConfirmSheet.show<String>(
      context,
      title: l10n.cancel_title,
      message: booking.mechanicId == null ? l10n.cancel_body_searching : l10n.cancel_body_assigned,
      reasons: [
        for (final code in CustomerCancelReasons.all)
          LaneReason(code, _reasonLabel(l10n, code), asksForText: code == CustomerCancelReasons.other),
      ],
      confirmLabel: l10n.cancel_confirm,
      keepLabel: l10n.cancel_keep,
      textLabel: l10n.cancel_reason_text,
    );
    if (picked == null || !mounted) return;
    setState(() => _cancelling = true);
    try {
      await ref
          .read(bookingServiceProvider)
          .cancelBooking(widget.bookingId, CancelReason(code: picked.reason, text: picked.text));
      // The stream shows the cancelled state; nothing else to do.
    } on BookingException catch (e) {
      if (!mounted) return;
      LaneHaptics.error().ignore();
      LaneToast.show(
        context,
        e.code == BookingException.invalidStatus ? l10n.cancel_error_too_late : l10n.cancel_error_network,
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  static String _reasonLabel(AppLocalizations l10n, String code) => switch (code) {
    CustomerCancelReasons.foundHelp => l10n.cancel_reason_found_help,
    CustomerCancelReasons.fixedMyself => l10n.cancel_reason_fixed_myself,
    CustomerCancelReasons.tooSlow => l10n.cancel_reason_too_slow,
    CustomerCancelReasons.wrongDetails => l10n.cancel_reason_wrong_details,
    _ => l10n.cancel_reason_other,
  };

  /// No mechanic found: book the same thing again (a new idempotency key, so it's a new
  /// booking) from U7, or start over if the draft is gone (app restarted).
  void _tryAgain(Booking booking) {
    final draft = ref.read(bookingDraftProvider);
    final notifier = ref.read(bookingDraftProvider.notifier);
    context.go(AppRoutes.home);
    if (draft.idempotencyKey == booking.idempotencyKey && draft.pickup != null) {
      notifier.renewKey();
      context.push(AppRoutes.bookPrice);
    } else {
      notifier.start(vehicleId: draft.vehicleId);
      context.push(AppRoutes.bookProblem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final booking = ref.watch(liveBookingProvider(widget.bookingId));
    final home = LaneButton.primary(
      label: l10n.booking_back_home,
      onPressed: () => context.go(AppRoutes.home),
    );

    return switch (booking) {
      AsyncData(value: null) => LaneStatusScaffold(
        visual: LaneIcon(LaneIcons.tray, size: lane.space.s64),
        title: l10n.live_not_found,
        primary: home,
      ),
      AsyncData(:final value?) => _forStatus(context, value, l10n, home),
      AsyncError() => Scaffold(
        body: SafeArea(
          child: ErrorState(onRetry: () => ref.invalidate(liveBookingProvider(widget.bookingId))),
        ),
      ),
      _ => Scaffold(body: SafeArea(child: SkeletonGroup.lines())),
    };
  }

  Widget _forStatus(BuildContext context, Booking b, AppLocalizations l10n, Widget home) {
    final lane = context.lane;
    final cancel = b.status.customerCanCancel
        ? LaneButton.ghost(label: l10n.cancel_booking, loading: _cancelling, onPressed: () => _cancel(b))
        : null;
    return switch (b.status) {
      BookingStatus.requested => LaneStatusScaffold(
        visual: BreathingPulse(child: LaneIcon(LaneIcons.mechanic, size: lane.space.s48)),
        title: l10n.searching_title,
        // The real radius from the booking: dispatch widens in one step (#80), so nothing
        // is animated that isn't happening.
        message: l10n.searching_radius(b.searchRadiusKm),
        primary: cancel,
      ),
      BookingStatus.accepted => _Assigned(booking: b, bookingId: widget.bookingId, cancel: cancel),
      // U10 (#126): the trip on the map.
      BookingStatus.arriving || BookingStatus.arrived => TrackingView(
        bookingId: widget.bookingId,
        booking: b,
        rail: bookingRail(l10n, b),
        cancel: cancel,
      ),
      BookingStatus.noMechanicFound => LaneStatusScaffold(
        visual: LaneIcon(LaneIcons.road, size: lane.space.s64 + lane.space.s32),
        title: l10n.no_mechanic_title,
        message: l10n.no_mechanic_body,
        primary: LaneButton.primary(label: l10n.no_mechanic_try_again, onPressed: () => _tryAgain(b)),
        secondary: LaneButton.secondary(
          label: l10n.price_get_support,
          onPressed: () => context.push(AppRoutes.help),
        ),
      ),
      BookingStatus.cancelled => LaneStatusScaffold(
        visual: LaneIcon(LaneIcons.minusCircle, size: lane.space.s64),
        title: l10n.cancelled_title,
        message: switch (b.cancelledBy) {
          Actor.customer => l10n.cancelled_by_you,
          Actor.mechanic => l10n.cancelled_by_mechanic,
          _ => l10n.cancelled_by_support,
        },
        primary: home,
      ),
      // U12 Job in progress and after (#17).
      _ => LaneStatusScaffold(
        visual: LaneIcon(LaneIcons.wrench, size: lane.space.s64),
        title: l10n.live_working_title,
        primary: home,
      ),
    };
  }
}

/// PLAN §9's six stops as a JourneyRail, in roadside_core's order; the booking says where it is.
Widget bookingRail(AppLocalizations l10n, Booking booking) => JourneyRail(
  stops: [
    for (final stop in core.JourneyStop.values)
      JourneyStop(
        label: switch (stop) {
          core.JourneyStop.requested => l10n.stop_requested,
          core.JourneyStop.accepted => l10n.stop_accepted,
          core.JourneyStop.onTheWay => l10n.stop_on_the_way,
          core.JourneyStop.arrived => l10n.stop_arrived,
          core.JourneyStop.working => l10n.stop_working,
          core.JourneyStop.done => l10n.stop_done,
        },
        signal: switch (stop) {
          core.JourneyStop.requested => LaneSignal.wait,
          core.JourneyStop.accepted || core.JourneyStop.onTheWay => LaneSignal.route,
          core.JourneyStop.arrived || core.JourneyStop.done => LaneSignal.go,
          core.JourneyStop.working => LaneSignal.work,
        },
      ),
  ],
  current: booking.status.journeyStop?.index ?? 0,
);

/// U9: who's coming, as a TrustPass that slides up, with the start code and where the trip is.
class _Assigned extends ConsumerWidget {
  const _Assigned({required this.booking, required this.bookingId, required this.cancel});

  final Booking booking;
  final String bookingId;
  final Widget? cancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final card = booking.mechanicCard;
    final code = ref.watch(startCodeProvider(bookingId)).value;
    final title = switch (booking.status) {
      BookingStatus.accepted => l10n.assigned_title,
      BookingStatus.arriving => l10n.assigned_on_the_way,
      _ => l10n.assigned_arrived,
    };
    final pass = card == null
        ? const SizedBox.shrink()
        : card.mechanicType == MechanicType.workshop
        ? TrustPass.workshop(
            name: card.name,
            shopName: card.shopName ?? '',
            rating: card.jobsCompleted > 0 ? card.rating : null,
            jobs: card.jobsCompleted,
            startCode: code,
          )
        : TrustPass.independent(
            name: card.name,
            years: card.experienceYears ?? 0,
            travelRegNo: card.travelVehicleRegNo ?? '',
            rating: card.jobsCompleted > 0 ? card.rating : null,
            jobs: card.jobsCompleted,
            startCode: code,
          );
    final inset = lane.space.s16;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(inset),
                children: [
                  Semantics(header: true, liveRegion: true, child: Text(title, style: lane.text.headline)),
                  SizedBox(height: lane.space.s16),
                  bookingRail(l10n, booking),
                  SizedBox(height: lane.space.s24),
                  _SlideUp(child: pass),
                ],
              ),
            ),
            if (cancel != null) Padding(padding: EdgeInsets.all(inset), child: cancel),
          ],
        ),
      ),
    );
  }
}

/// Slides its child up once when it first appears (still with reduced motion).
class _SlideUp extends StatelessWidget {
  const _SlideUp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final motion = context.lane.motion;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: motion.enabled ? 1 : 0, end: 0),
      duration: motion.enabled ? motion.calm : Duration.zero,
      curve: motion.enter,
      builder: (context, t, child) => FractionalTranslation(translation: Offset(0, t * 0.3), child: child),
      child: child,
    );
  }
}
