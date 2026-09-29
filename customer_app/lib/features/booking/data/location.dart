import 'dart:async';

import 'package:flutter/widgets.dart' show Locale, ValueChanged, immutable;
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';

/// A point on the map.
typedef LatLng = ({double lat, double lng});

/// One GPS reading.
@immutable
class LocationFix {
  const LocationFix({required this.position, required this.accuracyMeters});

  final LatLng position;
  final double accuracyMeters;
}

/// The phone's location. Permission is asked by the C7 explainer before this is used.
abstract interface class LocationService {
  /// False when location (GPS) is switched off in the phone's quick settings.
  Future<bool> serviceEnabled();

  /// Opens the phone's location settings (to switch GPS on).
  Future<bool> openSettings();

  /// Readings at the best accuracy the phone can give, as they arrive.
  Stream<LocationFix> fixes();
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<bool> serviceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<bool> openSettings() => Geolocator.openLocationSettings();

  @override
  Stream<LocationFix> fixes() =>
      Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.best))
          .map((p) => LocationFix(position: (lat: p.latitude, lng: p.longitude), accuracyMeters: p.accuracy));
}

/// PLAN §11: wait for a reading within [target] metres, or [timeout], whichever comes
/// first; then the best reading so far (null if none came). [onFix] sees every reading, so
/// the accuracy badge can update while waiting.
Future<LocationFix?> bestFix(
  Stream<LocationFix> fixes, {
  Duration timeout = const Duration(seconds: 15),
  double target = 20,
  ValueChanged<LocationFix>? onFix,
}) async {
  LocationFix? best;
  final done = Completer<LocationFix?>();
  void finish() {
    if (!done.isCompleted) done.complete(best);
  }

  final timer = Timer(timeout, finish);
  final sub = fixes.listen(
    (f) {
      if (best == null || f.accuracyMeters < best!.accuracyMeters) best = f;
      onFix?.call(f);
      if (f.accuracyMeters <= target) finish();
    },
    onError: (Object e, StackTrace s) {
      if (!done.isCompleted) done.completeError(e, s);
    },
    onDone: finish,
  );
  try {
    return await done.future;
  } finally {
    timer.cancel();
    // Not awaited: the answer is known, and GPS shuts down in the background.
    unawaited(sub.cancel());
  }
}

/// Turns the pin's position into a street address.
abstract interface class ReverseGeocoder {
  /// A one-line address in [languageCode], or null if there's none (open road, no network).
  Future<String?> addressAt(LatLng point, {required String languageCode});
}

/// The phone's own geocoder (no API key). Swapped for the map provider's once it's chosen.
class PlatformReverseGeocoder implements ReverseGeocoder {
  const PlatformReverseGeocoder();

  /// `createBooking` accepts up to 300 characters.
  static const maxLength = 300;

  @override
  Future<String?> addressAt(LatLng point, {required String languageCode}) async {
    // Per call: geocoding 5.0.0's constructor drops its `locale` argument.
    final places = await geo.Geocoding().placemarkFromCoordinates(
      point.lat,
      point.lng,
      locale: Locale(languageCode, 'IN'),
    );
    if (places.isEmpty) return null;
    return formatAddress(places.first);
  }

  /// "Street, area, city" from the parts that are present, without repeats.
  static String? formatAddress(geo.Placemark p) {
    final parts = <String>[];
    for (final part in [p.street, p.subLocality, p.locality]) {
      final t = part?.trim() ?? '';
      if (t.isNotEmpty && !parts.contains(t)) parts.add(t);
    }
    if (parts.isEmpty) return null;
    final line = parts.join(', ');
    return line.length > maxLength ? line.substring(0, maxLength) : line;
  }
}
