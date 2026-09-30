import 'package:flutter/foundation.dart';

import '../data/location.dart';

/// Where to draw the mechanic between two readings (PLAN §6.5 ⑥, §11): instead of jumping
/// every 5 s, the marker moves in a straight line from where it was drawn to the new reading
/// as `t` goes 0 → 1 over the update window, and turns the short way round
/// (350° → 10° is +20°, not −340°). Never extrapolates past the reading.
@immutable
class MarkerGlide {
  const MarkerGlide({
    required this.from,
    required this.to,
    required this.fromHeading,
    required this.toHeading,
  });

  /// The mechanic app sends a reading every 5 s (PLAN §11).
  static const window = Duration(seconds: 5);

  /// Nothing to animate yet: the first reading.
  const MarkerGlide.at(LatLng point, double heading)
    : from = point,
      to = point,
      fromHeading = heading,
      toHeading = heading;

  final LatLng from;
  final LatLng to;
  final double fromHeading;
  final double toHeading;

  LatLng positionAt(double t) {
    final p = t.clamp(0.0, 1.0);
    return (lat: from.lat + (to.lat - from.lat) * p, lng: from.lng + (to.lng - from.lng) * p);
  }

  double headingAt(double t) =>
      normalizeHeading(fromHeading + shortestTurn(fromHeading, toHeading) * t.clamp(0.0, 1.0));

  /// A new reading arrived while the marker was drawn at `t`: glide on from right there, so
  /// a reading that comes early or late never makes the marker jump.
  MarkerGlide next(double t, LatLng point, double heading) =>
      MarkerGlide(from: positionAt(t), to: point, fromHeading: headingAt(t), toHeading: heading);
}

/// Degrees in [0, 360).
double normalizeHeading(double degrees) {
  final d = degrees % 360;
  return d < 0 ? d + 360 : d;
}

/// The signed turn from [from] to [to] the short way round, in (-180, 180].
double shortestTurn(double from, double to) {
  var d = normalizeHeading(to) - normalizeHeading(from);
  if (d > 180) d -= 360;
  if (d <= -180) d += 360;
  return d;
}
