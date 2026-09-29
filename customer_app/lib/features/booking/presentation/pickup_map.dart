import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart';

import '../data/location.dart';

/// Builds the draggable map under U6's pin. The map reports the point under the pin when
/// a drag starts and when it settles; when [center] changes from outside (a new GPS
/// reading, "my location") it moves there.
typedef PickupMapBuilder = Widget Function({
  required LatLng center,
  required VoidCallback onMoveStarted,
  required ValueChanged<LatLng> onMoveEnded,
});

/// A plain grid until the map provider is chosen (PLAN §3: Ola Maps, locked after checking
/// its current terms). The real map replaces only this provider.
final pickupMapProvider = Provider<PickupMapBuilder>(
  (ref) =>
      ({required center, required onMoveStarted, required onMoveEnded}) =>
          GridPickupMap(center: center, onMoveStarted: onMoveStarted, onMoveEnded: onMoveEnded),
);

/// Placeholder map: a grid in Lane colours that pans like a map, at [metresPerPixel].
class GridPickupMap extends StatefulWidget {
  const GridPickupMap({
    super.key,
    required this.center,
    required this.onMoveStarted,
    required this.onMoveEnded,
    this.metresPerPixel = 1,
  });

  final LatLng center;
  final VoidCallback onMoveStarted;
  final ValueChanged<LatLng> onMoveEnded;
  final double metresPerPixel;

  static const _metresPerDegree = 111320.0;

  @override
  State<GridPickupMap> createState() => _GridPickupMapState();
}

class _GridPickupMapState extends State<GridPickupMap> {
  late LatLng _center = widget.center;

  /// Screen offset of the grid, in pixels, for painting.
  Offset _shift = Offset.zero;

  @override
  void didUpdateWidget(GridPickupMap old) {
    super.didUpdateWidget(old);
    if (widget.center != old.center && widget.center != _center) {
      setState(() => _center = widget.center);
    }
  }

  void _pan(DragUpdateDetails d) {
    final m = widget.metresPerPixel;
    final cosLat = math.cos(_center.lat * math.pi / 180).abs().clamp(0.01, 1.0);
    setState(() {
      _shift += d.delta;
      // Dragging the map right brings what's to the west under the pin.
      _center = (
        lat: (_center.lat + d.delta.dy * m / GridPickupMap._metresPerDegree).clamp(-85.0, 85.0),
        lng: _center.lng - d.delta.dx * m / (GridPickupMap._metresPerDegree * cosLat),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) => widget.onMoveStarted(),
      onPanUpdate: _pan,
      onPanEnd: (_) => widget.onMoveEnded(_center),
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _GridPainter(
            shift: _shift,
            spacing: lane.space.s48,
            background: lane.color.surfaceSunken,
            line: lane.color.line,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.shift, required this.spacing, required this.background, required this.line});

  final Offset shift;
  final double spacing;
  final Color background;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final paint = Paint()
      ..color = line
      ..strokeWidth = 1;
    final dx = shift.dx % spacing;
    final dy = shift.dy % spacing;
    for (var x = dx; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = dy; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.shift != shift || old.spacing != spacing || old.background != background || old.line != line;
}
