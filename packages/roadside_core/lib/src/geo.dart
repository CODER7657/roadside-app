// Service-area lookup and geohash (PLAN.md §8, §11). Mirror of resolveCity(), distanceKm() and
// geohash() in firebase/functions (createBooking.ts, lib/geo.ts). The server decides; apps use this for the
// Home city chip and the 'not in your area yet' screen before calling createBooking.

import 'dart:math' as math;

import 'enums.dart';
import 'models/platform.dart';

const double _earthRadiusKm = 6371.0088;

double _rad(double deg) => deg * math.pi / 180;

/// Great-circle distance in km (haversine).
double distanceKm(double lat1, double lng1, double lat2, double lng2) {
  final dLat = _rad(lat2 - lat1);
  final dLng = _rad(lng2 - lng1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * _earthRadiusKm * math.asin(math.min(1, math.sqrt(a)));
}

const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

/// Standard base-32 geohash, as `geohash()` in Functions. Precision 10 ≈ 1.2 m × 0.6 m cells.
/// The mechanic app writes it to `presence.location.geohash`; dispatch queries by prefix.
String encodeGeohash(double lat, double lng, {int precision = 10}) {
  var latMin = -90.0, latMax = 90.0, lngMin = -180.0, lngMax = 180.0;
  final hash = StringBuffer();
  var bits = 0, bitCount = 0;
  var evenBit = true; // even bits encode longitude
  while (hash.length < precision) {
    if (evenBit) {
      final mid = (lngMin + lngMax) / 2;
      if (lng >= mid) {
        bits = (bits << 1) | 1;
        lngMin = mid;
      } else {
        bits <<= 1;
        lngMax = mid;
      }
    } else {
      final mid = (latMin + latMax) / 2;
      if (lat >= mid) {
        bits = (bits << 1) | 1;
        latMin = mid;
      } else {
        bits <<= 1;
        latMax = mid;
      }
    }
    evenBit = !evenBit;
    if (++bitCount == 5) {
      hash.write(_base32[bits]);
      bits = 0;
      bitCount = 0;
    }
  }
  return hash.toString();
}

/// The city a point belongs to: the nearest centre whose circle contains it (Ankleshwar and
/// Bharuch overlap). Null when it's in no circle, or when that city isn't active yet.
CityId? resolveCity(double lat, double lng, Map<CityId, ServiceArea> areas) {
  CityId? nearest;
  var nearestKm = double.infinity;
  areas.forEach((id, area) {
    final d = distanceKm(lat, lng, area.center.latitude, area.center.longitude);
    if (d <= area.radiusKm && d < nearestKm) {
      nearest = id;
      nearestKm = d;
    }
  });
  final found = nearest;
  return found != null && areas[found]!.active ? found : null;
}
