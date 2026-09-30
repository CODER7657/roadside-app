import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;
import 'package:roadside_core/roadside_core.dart' as core show JourneyStop;

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../dashboard/data/location_service.dart';
import '../../dashboard/application/online.dart';
import '../../help/presentation/help_screen.dart';
import '../../permissions/application/permission_service.dart';
import '../../permissions/presentation/permission_explainer_screen.dart';
import '../application/job.dart';
import '../data/job_repository.dart';
import 'start_code_screen.dart';

/// Directions in the phone's maps app (the in-app map waits for the provider, PLAN §3).
Uri directionsTo(GeoPoint p) => Uri.https('www.google.com', '/maps/dir/', {
  'api': '1',
  'destination': '${p.latitude},${p.longitude}',
  'travelmode': 'driving',
});

/// M5 Navigate (PLAN §10 M5, §11; wireframe M5, `LaneMapScaffold`): the accepted job. The
/// exact address and the customer's phone are shown here, after accept. Location is shared
/// with the customer every 5 s / 10 m through a foreground service, so it keeps going with the
/// screen off.
class JobScreen extends ConsumerStatefulWidget {
  const JobScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends ConsumerState<JobScreen> {
  bool _busy = false;

  /// Back from the phone's Settings (location switched on or allowed): try sharing again.
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => unawaited(ref.read(jobTrackingProvider.notifier).retry()),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _allowLocation() async {
    if (await ensurePermission(context, ref, AppPermission.location)) {
      await ref.read(jobTrackingProvider.notifier).retry();
    }
  }

  void _syncTracking(Booking? b) {
    final tracking = ref.read(jobTrackingProvider.notifier);
    if (b == null) return;
    if (kTrackedStatuses.contains(b.status)) {
      final l10n = AppLocalizations.of(context);
      unawaited(
        tracking.start(
          bookingId: widget.bookingId,
          pickup: b.pickup.geopoint,
          notification: ForegroundTracking(title: l10n.job_tracking_title, text: l10n.job_tracking_text),
        ),
      );
    } else if (ref.read(jobTrackingProvider).bookingId == widget.bookingId) {
      tracking.stop();
    }
  }

  Future<void> _step(Future<TripOutcome> Function(String) call) async {
    if (_busy) return;
    setState(() => _busy = true);
    final outcome = await call(widget.bookingId);
    if (!mounted) return;
    setState(() => _busy = false);
    final l10n = AppLocalizations.of(context);
    final message = switch (outcome) {
      TripOutcome.ok || TripOutcome.invalidStatus => null, // the booking stream shows what's next
      TripOutcome.notAtPickup => l10n.job_error_not_at_pickup,
      TripOutcome.locationUnavailable => l10n.job_error_location,
      TripOutcome.failed => l10n.job_error_failed,
    };
    if (outcome == TripOutcome.ok) unawaited(LaneHaptics.statusAdvance());
    if (message != null) {
      unawaited(LaneHaptics.error());
      LaneToast.show(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final job = ref.watch(jobProvider(widget.bookingId));
    ref.listen(jobProvider(widget.bookingId), (_, next) => _syncTracking(next.value));
    // The first value arrives before any listener change; start tracking for it too.
    if (job.hasValue && !ref.read(jobTrackingProvider).isTracking) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncTracking(job.value);
      });
    }

    final b = job.value;
    if (!job.hasValue) return Scaffold(body: Center(child: SkeletonGroup.lines()));
    if (b == null) return _Ended(title: l10n.job_missing_title, body: l10n.job_missing_body);
    if (b.status == BookingStatus.cancelled) {
      return _Ended(title: l10n.job_cancelled_title, body: l10n.job_cancelled_body);
    }
    if (b.status == BookingStatus.completed) {
      return _Ended(title: l10n.job_done_title, body: l10n.job_done_body);
    }

    final problem = ref.watch(
      jobTrackingProvider.select((s) => s.bookingId == widget.bookingId ? s.problem : null),
    );
    final repo = ref.read(jobRepositoryProvider);
    final primary = switch (b.status) {
      BookingStatus.accepted => LaneButton.primary(
        label: l10n.job_start_trip,
        loading: _busy,
        onPressed: _busy ? null : () => _step(repo.startTrip),
      ),
      BookingStatus.arriving => LaneButton.primary(
        label: l10n.job_arrived,
        critical: true,
        loading: _busy,
        onPressed: _busy ? null : () => _step(repo.markArrived),
      ),
      // M6: the customer's start code starts the work.
      BookingStatus.arrived => LaneButton.primary(
        label: l10n.job_enter_start_code,
        onPressed: () => context.go(startCodeRoute(widget.bookingId)),
      ),
      _ => null,
    };

    return LaneMapScaffold(
      map: const _PlaceholderMap(),
      showBack: false,
      actions: [
        LaneMapButton(
          icon: LaneIcons.navigation,
          tooltip: l10n.job_open_in_maps,
          onPressed: () => ref.read(launchLinkProvider)(directionsTo(b.pickup.geopoint)),
        ),
      ],
      dock: LaneDock(
        initial: LaneDockSnap.half,
        header: _Rail(status: b.status),
        primary: primary,
        children: [
          if (problem != null)
            _LocationBanner(
              problem: problem,
              onFix: problem == JobLocationProblem.permission
                  ? _allowLocation
                  : () => ref.read(locationServiceProvider).openSettings(),
            ),
          _Details(bookingId: widget.bookingId, booking: b),
        ],
      ),
    );
  }
}

/// CLAUDE.md: location screens handle permission-denied and GPS-off. Without location the
/// customer can't see the mechanic coming and `markArrived` can't confirm the arrival.
class _LocationBanner extends StatelessWidget {
  const _LocationBanner({required this.problem, required this.onFix});

  final JobLocationProblem problem;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final (message, action) = switch (problem) {
      JobLocationProblem.permission => (l10n.job_location_needed, l10n.job_allow_location),
      JobLocationProblem.gpsOff => (l10n.job_gps_off, l10n.job_turn_on_location),
    };
    return Padding(
      padding: EdgeInsets.only(bottom: lane.space.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(message, style: lane.text.body.copyWith(color: lane.color.signal.stop)),
          ),
          SizedBox(height: lane.space.s8),
          LaneButton.secondary(label: action, icon: const LaneIcon(LaneIcons.location), onPressed: onFix),
        ],
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // PLAN §9's six stops, in roadside_core's order (same as the customer app).
    final stops = [
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
    ];
    return JourneyRail(stops: stops, current: status.journeyStop?.index ?? 0);
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.bookingId, required this.booking});

  final String bookingId;
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final b = booking;
    final customer = b.customerCard;
    final firstName = customer?.name.trim().split(RegExp(r'\s+')).first ?? '';
    final fix = ref.watch(jobTrackingProvider.select((s) => s.bookingId == bookingId ? s.lastFix : null));
    final launch = ref.read(launchLinkProvider);

    final headline = switch (b.status) {
      BookingStatus.accepted => l10n.job_headline_accepted,
      BookingStatus.arriving => l10n.job_headline_arriving,
      BookingStatus.arrived => l10n.job_headline_arrived,
      _ => l10n.job_headline_working,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(headline, style: lane.text.title.copyWith(color: lane.color.ink)),
        if (fix != null && (b.status == BookingStatus.accepted || b.status == BookingStatus.arriving)) ...[
          SizedBox(height: lane.space.s4),
          Text(switch (etaMinutes(fix, b.pickup.geopoint)) {
            0 => l10n.job_eta_here,
            final minutes => l10n.job_eta(minutes),
          }, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
        ],
        SizedBox(height: lane.space.s12),
        if (firstName.isNotEmpty)
          Text(
            b.pickup.landmark.isEmpty ? firstName : '$firstName · ${b.pickup.landmark}',
            style: lane.text.label.copyWith(color: lane.color.ink),
          ),
        Text(b.pickup.address, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
        SizedBox(height: lane.space.s12),
        Wrap(
          spacing: lane.space.s8,
          runSpacing: lane.space.s8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PlateChip(regNo: b.vehicle.regNo),
            Text(
              '${b.vehicle.brand} ${b.vehicle.model}',
              style: lane.text.body.copyWith(color: lane.color.ink),
            ),
          ],
        ),
        if (b.status == BookingStatus.arrived) ...[
          SizedBox(height: lane.space.s12),
          Text(l10n.job_ask_start_code, style: lane.text.body.copyWith(color: lane.color.ink)),
        ],
        SizedBox(height: lane.space.s16),
        Row(
          children: [
            Expanded(
              child: LaneButton.secondary(
                label: l10n.job_open_in_maps,
                icon: const LaneIcon(LaneIcons.navigation),
                onPressed: () => launch(directionsTo(b.pickup.geopoint)),
              ),
            ),
            if (customer != null && customer.phone.isNotEmpty) ...[
              SizedBox(width: lane.space.s8),
              Expanded(
                child: LaneButton.secondary(
                  label: l10n.job_call,
                  icon: const LaneIcon(LaneIcons.call),
                  onPressed: () => launch(Uri(scheme: 'tel', path: customer.phone)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Until the map provider is chosen (PLAN §3; same as customer_app's pickup map). "Open in
/// Maps" gives turn-by-turn directions meanwhile.
class _PlaceholderMap extends StatelessWidget {
  const _PlaceholderMap();

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return ColoredBox(
      color: lane.color.surfaceSunken,
      child: Align(
        alignment: const Alignment(0, -0.5),
        child: LaneIcon(LaneIcons.location, size: lane.space.s64),
      ),
    );
  }
}

class _Ended extends StatelessWidget {
  const _Ended({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    return LaneStatusScaffold(
      visual: LaneIcon(LaneIcons.checkCircle, size: lane.space.s64 + lane.space.s32),
      title: title,
      message: body,
      primary: LaneButton.primary(label: l10n.offer_back, onPressed: () => context.go(AppRoutes.home)),
    );
  }
}
