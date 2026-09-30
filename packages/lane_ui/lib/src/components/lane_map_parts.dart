// Parts that sit on a map: CenterPin and AccuracyBadge (PLAN.md §6.12, §11).
import 'package:flutter/material.dart';

import '../theme/lane_theme.dart';
import 'lane_badges.dart';
import 'lane_feedback.dart';
import 'lane_icons.dart';

/// The fixed pin in the middle of a map the user drags underneath. Its tip is exactly at
/// the centre of the widget, so put it where the chosen point is (`LaneMapScaffold.overlay`
/// already centres it above the dock). While [lifted] it rises with a shadow on the ground,
/// so it reads as "picked up". Decorative: screen readers get the address instead.
class CenterPin extends StatelessWidget {
  const CenterPin({super.key, this.lifted = false});

  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    final head = lane.touch.min;
    final rise = lane.space.s12;
    final duration = lane.motion.enabled ? lane.motion.quick : Duration.zero;
    return ExcludeSemantics(
      child: IgnorePointer(
        // Twice the pin's height: the tip sits on the centre line.
        child: SizedBox(
          width: head,
          height: (head + lane.space.s16) * 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ground shadow: wider when lifted.
              AnimatedScale(
                scale: lifted ? 1.4 : 1,
                duration: duration,
                child: Container(
                  width: lane.space.s12,
                  height: lane.space.s4,
                  decoration: BoxDecoration(
                    color: c.ink.withValues(alpha: 0.3),
                    borderRadius: lane.radius.pill,
                  ),
                ),
              ),
              AnimatedSlide(
                offset: Offset(0, lifted ? -rise / (head + lane.space.s16) : 0),
                duration: duration,
                curve: lane.motion.move,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: head,
                    height: head + lane.space.s16,
                    child: CustomPaint(
                      painter: _PinPainter(fill: c.beacon, ink: c.ink, dot: c.onBeacon),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  _PinPainter({required this.fill, required this.ink, required this.dot});

  final Color fill;
  final Color ink;
  final Color dot;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final centre = Offset(r, r);
    final tip = Offset(r, size.height);
    // A teardrop: the head circle with a point down to the tip.
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(r - r * 0.6, r + r * 0.8)
      ..arcToPoint(Offset(r + r * 0.6, r + r * 0.8), radius: Radius.circular(r), largeArc: true)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = ink,
    );
    canvas.drawCircle(centre, r * 0.3, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(_PinPainter old) => old.fill != fill || old.ink != ink || old.dot != dot;
}

/// How far the location can be trusted: "±12 m" in `go` up to 20 m, `wait` up to 50 m, and
/// grey with "Adjust pin" beyond that (PLAN §6.12). Null [meters] means still locating.
class AccuracyBadge extends StatelessWidget {
  const AccuracyBadge({super.key, required this.meters});

  /// Good enough to book without touching the pin (PLAN §11).
  static const goodMeters = 20.0;
  static const fairMeters = 50.0;

  final double? meters;

  @override
  Widget build(BuildContext context) {
    final strings = laneStrings(context);
    final m = meters;
    if (m == null) {
      return SignalBadge(
        signal: LaneSignal.wait,
        icon: LaneIcons.hourglass,
        label: strings.accuracy_locating,
      );
    }
    final rounded = m.round();
    final (signal, label) = switch (m) {
      <= goodMeters => (LaneSignal.go, strings.accuracy_meters(rounded)),
      <= fairMeters => (LaneSignal.wait, strings.accuracy_meters(rounded)),
      _ => (LaneSignal.neutral, strings.accuracy_adjust(rounded)),
    };
    return Semantics(
      label: strings.accuracy_semantics(rounded),
      excludeSemantics: true,
      child: SignalBadge(signal: signal, icon: LaneIcons.navigation, label: label),
    );
  }
}
