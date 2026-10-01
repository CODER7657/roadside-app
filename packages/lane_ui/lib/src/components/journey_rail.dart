// JourneyRail: the booking status as a lane line (PLAN.md §6.5 ①).
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/lane_theme.dart';
import '../tokens/lane_haptics.dart';
import 'lane_badges.dart';
import 'lane_feedback.dart';

/// One stop on the rail. The app passes the six from PLAN §9 in order:
/// Requested · Accepted · On the way · Arrived · Working · Done.
@immutable
class JourneyStop {
  const JourneyStop({required this.label, required this.signal, this.time});

  final String label;

  /// Its colour (§6.7): wait, route, route, go, work, go.
  final LaneSignal signal;

  /// "10:42", shown on the vertical rail (booking detail, admin).
  final String? time;
}

/// Stops joined by a lane line: solid up to the current stop, dashed after it. When
/// [current] moves forward, the dashes flow into the next stop over `motion.calm` with a
/// medium haptic. [ended] (cancelled, no mechanic) greys the whole rail; red is never used.
class JourneyRail extends StatefulWidget {
  const JourneyRail({
    super.key,
    required this.stops,
    required this.current,
    this.direction = Axis.horizontal,
    this.ended = false,
  }) : assert(current >= 0);

  final List<JourneyStop> stops;

  /// Index of the stop the booking is at.
  final int current;

  /// Horizontal on tracking and job screens; vertical (with labels and times) on detail views.
  final Axis direction;

  final bool ended;

  @override
  State<JourneyRail> createState() => _JourneyRailState();
}

class _JourneyRailState extends State<JourneyRail> with SingleTickerProviderStateMixin {
  late final AnimationController _flow = AnimationController(vsync: this, value: 1);
  late int _from = widget.current;

  @override
  void didUpdateWidget(JourneyRail old) {
    super.didUpdateWidget(old);
    if (widget.current > old.current && !widget.ended) {
      _from = old.current;
      LaneHaptics.statusAdvance();
      final motion = context.lane.motion;
      _flow
        ..duration = motion.calm
        ..forward(from: motion.enabled ? 0 : 1);
    } else if (widget.current != old.current) {
      _from = widget.current;
      _flow.value = 1;
    }
  }

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.current < widget.stops.length, 'current must index into stops');
    final lane = context.lane;
    final strings = laneStrings(context);
    final stop = widget.stops[widget.current];
    final label = widget.ended
        ? strings.journey_rail_cancelled(stop.label)
        : strings.journey_rail_step(widget.current + 1, widget.stops.length, stop.label);

    final rail = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _flow,
        builder: (context, _) => CustomPaint(
          painter: _RailPainter(
            count: widget.stops.length,
            // Progress along the line, in stops: flowing from the old stop to the new one.
            progress: _from + (widget.current - _from) * _flow.value,
            current: widget.current,
            colors: [
              for (final s in widget.stops)
                widget.ended ? lane.color.signal.neutral : s.signal.colorIn(lane.color.signal),
            ],
            base: lane.color.line,
            surface: lane.color.surface,
            direction: widget.direction,
            stroke: lane.space.s4,
            dot: lane.space.s16,
          ),
          size: widget.direction == Axis.horizontal
              ? Size(double.infinity, lane.space.s24)
              : Size(lane.space.s24, (widget.stops.length - 1) * lane.space.s64 + lane.space.s24),
        ),
      ),
    );

    return Semantics(
      label: label,
      container: true,
      excludeSemantics: true,
      child: widget.direction == Axis.horizontal
          ? SizedBox(height: lane.space.s24, width: double.infinity, child: rail)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                rail,
                SizedBox(width: lane.space.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (i, s) in widget.stops.indexed)
                        // Rows keep the dots' 64 dp pitch; the last may grow with large text.
                        ConstrainedBox(
                          constraints: i == widget.stops.length - 1
                              ? BoxConstraints(minHeight: lane.space.s24)
                              : BoxConstraints.tightFor(height: lane.space.s64),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  s.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: (i == widget.current ? lane.text.label : lane.text.body).copyWith(
                                    color: i <= widget.current ? lane.color.ink : lane.color.inkSubtle,
                                  ),
                                ),
                              ),
                              if (s.time != null)
                                Text(s.time!, style: lane.text.caption.copyWith(color: lane.color.inkMuted)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _RailPainter extends CustomPainter {
  _RailPainter({
    required this.count,
    required this.progress,
    required this.current,
    required this.colors,
    required this.base,
    required this.surface,
    required this.direction,
    required this.stroke,
    required this.dot,
  });

  final int count;
  final double progress;
  final int current;
  final List<Color> colors;
  final Color base;
  final Color surface;
  final Axis direction;
  final double stroke;
  final double dot;

  Offset _at(Size size, int i) {
    final r = dot / 2;
    if (direction == Axis.horizontal) {
      final x = count == 1 ? size.width / 2 : r + (size.width - dot) * i / (count - 1);
      return Offset(x, size.height / 2);
    }
    final y = count == 1 ? r : r + (size.height - dot) * i / (count - 1);
    return Offset(size.width / 2, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // Dashed base line between every pair of stops (the lane ahead).
    for (var i = 0; i < count - 1; i++) {
      final a = _at(size, i), b = _at(size, i + 1);
      final length = (b - a).distance;
      final dir = (b - a) / length;
      final dash = stroke * 2;
      for (var d = dot / 2 + stroke; d < length - dot / 2 - stroke; d += dash * 2) {
        canvas.drawLine(a + dir * d, a + dir * math.min(d + dash, length - dot / 2), line..color = base);
      }
    }

    // The travelled line, solid in each segment's colour, flowing up to [progress].
    for (var i = 0; i < count - 1; i++) {
      final fill = (progress - i).clamp(0.0, 1.0);
      if (fill <= 0) continue;
      final a = _at(size, i), b = _at(size, i + 1);
      canvas.drawLine(a, Offset.lerp(a, b, fill)!, line..color = colors[i + 1]);
    }

    // Stops: passed = filled, current = ring, ahead = hollow.
    for (var i = 0; i < count; i++) {
      final c = _at(size, i);
      final reached = i <= progress + 0.0001;
      final r = dot / 2;
      canvas.drawCircle(c, r, Paint()..color = reached ? colors[i] : surface);
      canvas.drawCircle(
        c,
        r - stroke / 4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke / 2
          ..color = reached ? colors[i] : base,
      );
      if (i == current && reached) {
        canvas.drawCircle(c, r * 0.4, Paint()..color = surface);
      }
    }
  }

  @override
  bool shouldRepaint(_RailPainter old) =>
      old.progress != progress ||
      old.current != current ||
      old.count != count ||
      old.direction != direction ||
      !_sameColors(old.colors) ||
      old.base != base ||
      old.surface != surface;

  bool _sameColors(List<Color> other) {
    if (other.length != colors.length) return false;
    for (var i = 0; i < colors.length; i++) {
      if (other[i] != colors[i]) return false;
    }
    return true;
  }
}
