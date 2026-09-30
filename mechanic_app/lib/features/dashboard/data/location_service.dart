import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// One GPS reading.
@immutable
class LocationFix {
  const LocationFix({required this.lat, required this.lng, required this.accuracyMeters});

  final double lat;
  final double lng;
  final double accuracyMeters;
}

/// The phone's location. Permission is asked by the C7 explainer before this is used.
/// While online and idle the app is open, so while-in-use location is enough; the
/// foreground service for active jobs comes with #30.
abstract interface class LocationService {
  /// False when location (GPS) is switched off in the phone's quick settings.
  Future<bool> serviceEnabled();

  /// Opens the phone's location settings (to switch GPS on).
  Future<bool> openSettings();

  /// Readings as the phone moves at least [distanceFilterMeters].
  Stream<LocationFix> fixes({required int distanceFilterMeters});
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<bool> serviceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<bool> openSettings() => Geolocator.openLocationSettings();

  @override
  Stream<LocationFix> fixes({required int distanceFilterMeters}) => Geolocator.getPositionStream(
    locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: distanceFilterMeters),
  ).map((p) => LocationFix(lat: p.latitude, lng: p.longitude, accuracyMeters: p.accuracy));
}
