import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;

import '../../../l10n/app_localizations.dart';
import '../application/live_booking.dart';
import '../application/marker_glide.dart';
import 'contact_actions.dart';
import 'tracking_map.dart';

/// A reading older than this is shown as stale (the app sends every 5 s; PLAN §11).
const staleAfter = Duration(seconds: 30);

/// U10 Live tracking (`arriving`, `arrived`): the map with the mechanic gliding between
/// readings, the rail, a rolling ETA, Call, and the start code large.
class TrackingView extends ConsumerStatefulWidget {
  const TrackingView({
    super.key,
    required this.bookingId,
    required this.booking,
    required this.rail,
    this.cancel,
  });

  final String bookingId;
  final Booking booking;
  final Widget rail;
  final Widget? cancel;

  @override
  ConsumerState<TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends ConsumerState<TrackingView> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: MarkerGlide.window,
    value: 1,
  );
  MarkerGlide? _glide;
  Timer? _ageTick;

  /// Set once initState is done: readings after that may rebuild and animate.
  bool _started = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(liveLocationProvider(widget.bookingId), (_, next) {
      final live = next.value;
      if (live == null) return;
      final point = (lat: live.mechanicGeopoint.latitude, lng: live.mechanicGeopoint.longitude);
      final glide = _glide;
      if (glide == null || !_started) {
        // The first reading (possibly during initState, where setState isn't allowed): no glide.
        _glide = MarkerGlide.at(point, live.heading);
        _t.value = 1;
        if (_started) setState(() {});
        return;
      }
      setState(() => _glide = glide.next(_t.value, point, live.heading));
      if (context.lane.motion.enabled) {
        _t.forward(from: 0);
      } else {
        _t.value = 1;
      }
    }, fireImmediately: true);
    _started = true;
    // "Last updated N min ago" keeps counting without new readings.
    _ageTick = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ageTick?.cancel();
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final b = widget.booking;
    final card = b.mechanicCard;
    final name = card?.name ?? '';
    final live = ref.watch(liveLocationProvider(widget.bookingId)).value;
    final code = ref.watch(startCodeProvider(widget.bookingId)).value;
    final mapBuilder = ref.watch(trackingMapProvider);
    final pickup = (lat: b.pickup.geopoint.latitude, lng: b.pickup.geopoint.longitude);
    final arrived = b.status == BookingStatus.arrived;
    // Server-stamped; unknown until the first write settles, and unknown isn't stale.
    final updated = live?.updatedAt;
    final age = updated == null ? null : ref.read(laneClockProvider)().difference(updated);
    final stale = age != null && age > staleAfter;

    return LaneMapScaffold(
      map: AnimatedBuilder(
        animation: _t,
        builder: (context, _) {
          final glide = _glide;
          return mapBuilder(
            pickup: pickup,
            mechanic: arrived ? null : glide?.positionAt(_t.value),
            heading: glide?.headingAt(_t.value) ?? 0,
          );
        },
      ),
      dock: LaneDock(
        header: widget.rail,
        children: [
          Semantics(
            header: true,
            liveRegion: true,
            child: Text(
              arrived ? l10n.tracking_arrived(name) : l10n.tracking_on_the_way(name),
              style: lane.text.title,
            ),
          ),
          SizedBox(height: lane.space.s8),
          if (!arrived) ...[
            if (live == null)
              Text(l10n.tracking_waiting(name), style: lane.text.body.copyWith(color: lane.color.inkMuted))
            else if (!stale)
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  LaneRollingNumber(value: l10n.tracking_eta(live.etaMinutes)),
                  SizedBox(width: lane.space.s8),
                  Text(l10n.tracking_away, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
                ],
              ),
            if (stale)
              Semantics(
                container: true,
                liveRegion: true,
                child: Text(
                  l10n.tracking_stale(age.inMinutes < 1 ? 1 : age.inMinutes),
                  style: lane.text.body.copyWith(color: lane.color.ink),
                ),
              ),
          ],
          if (card?.travelVehicleRegNo case final plate? when plate.isNotEmpty) ...[
            SizedBox(height: lane.space.s12),
            Align(
              alignment: Alignment.centerLeft,
              child: PlateChip(regNo: plate),
            ),
          ],
          if (card != null) ...[
            SizedBox(height: lane.space.s16),
            ContactActions(bookingId: widget.bookingId, booking: b),
          ],
          if (code != null) ...[
            SizedBox(height: lane.space.s24),
            Text(
              l10n.tracking_start_code.toUpperCase(),
              style: lane.text.caps.copyWith(color: lane.color.inkMuted),
            ),
            SizedBox(height: lane.space.s8),
            Center(child: LaneOtpDisplay(code: code)),
            SizedBox(height: lane.space.s8),
            Text(
              l10n.tracking_start_code_hint,
              style: lane.text.caption.copyWith(color: lane.color.inkMuted),
            ),
          ],
          if (widget.cancel != null) ...[SizedBox(height: lane.space.s16), widget.cancel!],
        ],
      ),
    );
  }
}
