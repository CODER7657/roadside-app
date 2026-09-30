import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart';

import '../data/location.dart';

/// Builds U10's map: the pickup and the mechanic's (already glided) position and heading.
typedef TrackingMapBuilder = Widget Function({required LatLng pickup, LatLng? mechanic, double heading});

/// A plain grid until the map provider is chosen (same seam as U6's `pickupMapProvider`).
final trackingMapProvider = Provider<TrackingMapBuilder>(
  (ref) =>
      ({required pickup, mechanic, heading = 0}) =>
          GridTrackingMap(pickup: pickup, mechanic: mechanic, heading: heading),
);

/// Placeholder map: the pickup in the middle of the visible map and the mechanic placed
/// around it to scale (zoomed out just enough to keep both in view), pointing their way.
class GridTrackingMap extends StatelessWidget {
  const GridTrackingMap({super.key, required this.pickup, this.mechanic, this.heading = 0});

  final LatLng pickup;
  final LatLng? mechanic;
  final double heading;

  static const _metresPerDegree = 111320.0;

  /// The mechanic's offset from the pickup in metres (east, north).
  static Offset metresFrom(LatLng pickup, LatLng point) {
    final cosLat = math.cos(pickup.lat * math.pi / 180);
    return Offset(
      (point.lng - pickup.lng) * _metresPerDegree * cosLat,
      (point.lat - pickup.lat) * _metresPerDegree,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final marker = lane.touch.min;
    return LayoutBuilder(
      builder: (context, box) {
        // Leave room for the dock: the pickup sits in the middle of the top half.
        final centre = Offset(box.maxWidth / 2, box.maxHeight / 4);
        final m = mechanic;
        Offset? mechanicAt;
        if (m != null) {
          final metres = metresFrom(pickup, m);
          final room = math.max(1.0, math.min(box.maxWidth / 2, box.maxHeight / 4) - marker);
          final distance = metres.distance;
          // 1 px per metre up close, zoomed out when the mechanic is further than fits.
          final scale = distance <= room ? 1.0 : room / distance;
          mechanicAt = centre + Offset(metres.dx, -metres.dy) * scale;
        }
        return Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: lane.color.surfaceSunken)),
            Positioned(
              left: centre.dx - marker / 2,
              top: centre.dy - marker,
              child: ExcludeSemantics(child: LaneIcon(LaneIcons.location, size: marker)),
            ),
            if (mechanicAt != null)
              Positioned(
                key: const ValueKey('mechanic-marker'),
                left: mechanicAt.dx - marker / 2,
                top: mechanicAt.dy - marker / 2,
                child: ExcludeSemantics(
                  child: Transform.rotate(
                    angle: heading * math.pi / 180,
                    child: LaneIcon(LaneIcons.navigation, size: marker, color: lane.color.signal.route),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
