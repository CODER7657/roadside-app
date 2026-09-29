// Local sunrise and sunset, computed on the phone with no network (PLAN.md §6.5 ③).
// NOAA solar-position equations (https://gml.noaa.gov/grad/solcalc/calcdetails.html);
// accurate to about a minute, which is plenty for switching the palette.
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// A point on Earth in degrees (east longitude positive).
@immutable
class LanePosition {
  const LanePosition(this.lat, this.lng);

  /// Fallback until the app shares a fix: Ahmedabad, the largest launch city. Sunset in
  /// Ankleshwar and Bharuch is within a few minutes of it.
  static const fallback = LanePosition(23.0225, 72.5714);

  final double lat;
  final double lng;

  @override
  bool operator ==(Object other) => other is LanePosition && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);
}

/// Sunrise and sunset (UTC) for one calendar date at one place.
@immutable
class SolarDay {
  const SolarDay._(this.sunrise, this.sunset, {this.polar});

  /// Null [sunrise]/[sunset] with [polar] set means the sun doesn't cross the horizon.
  factory SolarDay.of(DateTime date, LanePosition at) {
    final midnight = DateTime.utc(date.year, date.month, date.day);
    // Evaluate the sun at local solar noon for this date.
    final noonGuess = midnight.add(Duration(minutes: (720 - 4 * at.lng).round()));
    final sun = _Sun.at(noonGuess);

    final lat = _rad(at.lat);
    final cosHa =
        math.cos(_rad(90.833)) / (math.cos(lat) * math.cos(sun.declination)) -
        math.tan(lat) * math.tan(sun.declination);
    if (cosHa > 1) return const SolarDay._(null, null, polar: PolarDay.night);
    if (cosHa < -1) return const SolarDay._(null, null, polar: PolarDay.day);

    final haMinutes = 4 * _deg(math.acos(cosHa));
    final noonMinutes = 720 - 4 * at.lng - sun.equationOfTimeMinutes;
    Duration m(double minutes) => Duration(milliseconds: (minutes * 60000).round());
    return SolarDay._(midnight.add(m(noonMinutes - haMinutes)), midnight.add(m(noonMinutes + haMinutes)));
  }

  final DateTime? sunrise;
  final DateTime? sunset;
  final PolarDay? polar;
}

enum PolarDay { day, night }

/// True between local sunset and the next sunrise at [at].
bool isNightAt(DateTime now, LanePosition at) {
  final utc = now.toUtc();
  // The local calendar date at this longitude (solar time), so a UTC date boundary in the
  // middle of the Indian evening doesn't pick the wrong day.
  final local = utc.add(Duration(minutes: (4 * at.lng).round()));
  final day = SolarDay.of(local, at);
  if (day.polar != null) return day.polar == PolarDay.night;
  return utc.isBefore(day.sunrise!) || !utc.isBefore(day.sunset!);
}

class _Sun {
  _Sun._(this.declination, this.equationOfTimeMinutes);

  factory _Sun.at(DateTime utc) {
    final jd = utc.millisecondsSinceEpoch / Duration.millisecondsPerDay + 2440587.5;
    final t = (jd - 2451545) / 36525;

    final l0 = _rad((280.46646 + t * (36000.76983 + t * 0.0003032)) % 360);
    final m = _rad(357.52911 + t * (35999.05029 - 0.0001537 * t));
    final e = 0.016708634 - t * (0.000042037 + 0.0000001267 * t);
    final c =
        math.sin(m) * (1.914602 - t * (0.004817 + 0.000014 * t)) +
        math.sin(2 * m) * (0.019993 - 0.000101 * t) +
        math.sin(3 * m) * 0.000289;
    final omega = _rad(125.04 - 1934.136 * t);
    final lambda = _rad(_deg(l0) + c - 0.00569 - 0.00478 * math.sin(omega));
    final eps0 = 23 + (26 + (21.448 - t * (46.815 + t * (0.00059 - t * 0.001813))) / 60) / 60;
    final eps = _rad(eps0 + 0.00256 * math.cos(omega));

    final declination = math.asin(math.sin(eps) * math.sin(lambda));
    final y = math.pow(math.tan(eps / 2), 2).toDouble();
    final eot =
        y * math.sin(2 * l0) -
        2 * e * math.sin(m) +
        4 * e * y * math.sin(m) * math.cos(2 * l0) -
        0.5 * y * y * math.sin(4 * l0) -
        1.25 * e * e * math.sin(2 * m);
    return _Sun._(declination, 4 * _deg(eot));
  }

  final double declination;
  final double equationOfTimeMinutes;
}

double _rad(double deg) => deg * math.pi / 180;
double _deg(double rad) => rad * 180 / math.pi;
