// A schematic "map" for the console: service-area circles and points, fitted to the box. It
// stands in for the real map (Ola Maps / MapLibre with the Lane style, PLAN §6.7) until the map
// key and style exist; the customer app uses the same kind of placeholder (pickup_map.dart).
// Takes no app strings or providers, so it can move into lane_ui or be swapped out whole.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lane_ui/lane_ui.dart';

class MapArea {
  const MapArea({required this.lat, required this.lng, required this.radiusKm, required this.label});

  final double lat;
  final double lng;
  final double radiusKm;
  final String label;
}

class MapDot {
  const MapDot({required this.id, required this.lat, required this.lng, required this.signal, this.label});

  final String id;
  final double lat;
  final double lng;
  final LaneSignal signal;

  /// Screen-reader text for the dot.
  final String? label;
}

class SchematicMap extends StatelessWidget {
  const SchematicMap({
    super.key,
    required this.areas,
    required this.dots,
    this.selectedId,
    this.mechanic,
    this.onTapDot,
    this.semanticLabel,
  });

  final List<MapArea> areas;
  final List<MapDot> dots;
  final String? selectedId;

  /// The selected booking's mechanic, drawn as an amber marker.
  final ({double lat, double lng})? mechanic;
  final ValueChanged<String>? onTapDot;
  final String? semanticLabel;

  /// Taps within this many logical pixels of a dot select it.
  static const hitRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return LayoutBuilder(
      builder: (context, box) {
        final projection = _Projection.fit(areas, dots, mechanic, box.biggest, lane.space.s32);
        return Semantics(
          label: semanticLabel,
          container: true,
          child: GestureDetector(
            onTapUp: onTapDot == null
                ? null
                : (details) {
                    MapDot? best;
                    var bestDistance = hitRadius;
                    for (final d in dots) {
                      final dist = (projection.offset(d.lat, d.lng) - details.localPosition).distance;
                      if (dist <= bestDistance) {
                        best = d;
                        bestDistance = dist;
                      }
                    }
                    if (best != null) onTapDot!(best.id);
                  },
            child: ClipRRect(
              borderRadius: lane.radius.r16,
              child: CustomPaint(
                size: box.biggest,
                painter: _MapPainter(
                  projection: projection,
                  areas: areas,
                  dots: dots,
                  selectedId: selectedId,
                  mechanic: mechanic,
                  colors: lane.color,
                  labelStyle: lane.text.caption.copyWith(color: lane.color.inkMuted),
                  dotRadius: lane.space.s8,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Equirectangular projection around the data's centre, scaled to fit with a margin.
class _Projection {
  _Projection(this.lat0, this.lng0, this.scale, this.center);

  factory _Projection.fit(
    List<MapArea> areas,
    List<MapDot> dots,
    ({double lat, double lng})? extra,
    Size size,
    double margin,
  ) {
    final lats = <double>[];
    final lngs = <double>[];
    for (final a in areas) {
      final dLat = a.radiusKm / 111.32;
      final dLng = a.radiusKm / (111.32 * math.cos(a.lat * math.pi / 180));
      lats.addAll([a.lat - dLat, a.lat + dLat]);
      lngs.addAll([a.lng - dLng, a.lng + dLng]);
    }
    for (final d in dots) {
      lats.add(d.lat);
      lngs.add(d.lng);
    }
    if (extra != null) {
      lats.add(extra.lat);
      lngs.add(extra.lng);
    }
    if (lats.isEmpty) return _Projection(0, 0, 1, size.center(Offset.zero));
    final minLat = lats.reduce(math.min), maxLat = lats.reduce(math.max);
    final minLng = lngs.reduce(math.min), maxLng = lngs.reduce(math.max);
    final lat0 = (minLat + maxLat) / 2;
    final lng0 = (minLng + maxLng) / 2;
    final k = math.cos(lat0 * math.pi / 180);
    final spanX = math.max((maxLng - minLng) * k, 0.01);
    final spanY = math.max(maxLat - minLat, 0.01);
    final scale = math.min((size.width - 2 * margin) / spanX, (size.height - 2 * margin) / spanY);
    return _Projection(lat0, lng0, scale, size.center(Offset.zero));
  }

  final double lat0;
  final double lng0;
  final double scale;
  final Offset center;

  Offset offset(double lat, double lng) =>
      center.translate((lng - lng0) * math.cos(lat0 * math.pi / 180) * scale, -(lat - lat0) * scale);

  double km(double km) => km / 111.32 * scale;
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.projection,
    required this.areas,
    required this.dots,
    required this.selectedId,
    required this.mechanic,
    required this.colors,
    required this.labelStyle,
    required this.dotRadius,
  });

  final _Projection projection;
  final List<MapArea> areas;
  final List<MapDot> dots;
  final String? selectedId;
  final ({double lat, double lng})? mechanic;
  final LaneColors colors;
  final TextStyle labelStyle;
  final double dotRadius;

  Color _signal(LaneSignal s) => switch (s) {
    LaneSignal.wait => colors.signal.wait,
    LaneSignal.route => colors.signal.route,
    LaneSignal.go => colors.signal.go,
    LaneSignal.work => colors.signal.work,
    LaneSignal.stop => colors.signal.stop,
    LaneSignal.neutral => colors.signal.neutral,
  };

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.surfaceSunken);

    final area = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = colors.line;
    final areaFill = Paint()..color = colors.surface;
    final labelRects = <Rect>[];
    for (final a in areas) {
      final c = projection.offset(a.lat, a.lng);
      final r = projection.km(a.radiusKm);
      canvas
        ..drawCircle(c, r, areaFill)
        ..drawCircle(c, r, area);
      final label = TextPainter(
        text: TextSpan(text: a.label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      // Above the circle, or below it when that would overlap an earlier label (Ankleshwar and
      // Bharuch are close).
      var at = c.translate(-label.width / 2, -r - label.height - 4);
      if (labelRects.any((rect) => rect.overlaps(at & label.size))) at = c.translate(-label.width / 2, r + 4);
      labelRects.add(at & label.size);
      label.paint(canvas, at);
    }

    for (final d in [...dots]..sort((a, b) => (a.id == selectedId ? 1 : 0) - (b.id == selectedId ? 1 : 0))) {
      final p = projection.offset(d.lat, d.lng);
      final selected = d.id == selectedId;
      final r = selected ? dotRadius * 1.5 : dotRadius;
      if (selected) canvas.drawCircle(p, r + 5, Paint()..color = colors.beacon);
      canvas
        ..drawCircle(p, r + 2, Paint()..color = colors.bg)
        ..drawCircle(p, r, Paint()..color = _signal(d.signal));
    }

    final m = mechanic;
    if (m != null) {
      final p = projection.offset(m.lat, m.lng);
      final s = dotRadius * 1.4;
      final path = Path()
        ..moveTo(p.dx, p.dy - s)
        ..lineTo(p.dx + s * 0.8, p.dy + s * 0.8)
        ..lineTo(p.dx - s * 0.8, p.dy + s * 0.8)
        ..close();
      canvas
        ..drawPath(path, Paint()..color = colors.beacon)
        ..drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = colors.bg,
        );
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.dots != dots ||
      old.areas != areas ||
      old.selectedId != selectedId ||
      old.mechanic != mechanic ||
      old.colors != colors;
}
