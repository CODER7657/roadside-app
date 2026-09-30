import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// One GPS reading. [heading] (degrees) and [speed] (m/s) are 0 when the phone doesn't know.
@immutable
class LocationFix {
  const LocationFix({
    required this.lat,
    required this.lng,
    required this.accuracyMeters,
    this.heading = 0,
    this.speed = 0,
  });

  final double lat;
  final double lng;
  final double accuracyMeters;
  final double heading;
  final double speed;
}

/// The visible notification that keeps location running with the screen off during a job
/// (PLAN §11: a foreground service of type `location`, so no background-location permission).
@immutable
class ForegroundTracking {
  const ForegroundTracking({required this.title, required this.text});

  final String title;
  final String text;
}

/// The phone's location. Permission is asked by the C7 explainer before this is used.
abstract interface class LocationService {
  /// False when location (GPS) is switched off in the phone's quick settings.
  Future<bool> serviceEnabled();

  /// Opens the phone's location settings (to switch GPS on).
  Future<bool> openSettings();

  /// Readings as the phone moves at least [distanceFilterMeters], at most every [interval].
  /// With [foreground], Android runs the stream as a foreground service with that notification,
  /// so it keeps going with the screen off (M5, #30). Idle online tracking (M3) doesn't need it.
  Stream<LocationFix> fixes({
    required int distanceFilterMeters,
    Duration? interval,
    ForegroundTracking? foreground,
  });
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<bool> serviceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<bool> openSettings() => Geolocator.openLocationSettings();

  @override
  Stream<LocationFix> fixes({
    required int distanceFilterMeters,
    Duration? interval,
    ForegroundTracking? foreground,
  }) {
    final settings = defaultTargetPlatform == TargetPlatform.android
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: distanceFilterMeters,
            intervalDuration: interval,
            foregroundNotificationConfig: foreground == null
                ? null
                : ForegroundNotificationConfig(
                    notificationTitle: foreground.title,
                    notificationText: foreground.text,
                    notificationChannelName: foreground.title,
                    enableWakeLock: true,
                    setOngoing: true,
                  ),
          )
        : LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: distanceFilterMeters);
    return Geolocator.getPositionStream(locationSettings: settings).map(
      (p) => LocationFix(
        lat: p.latitude,
        lng: p.longitude,
        accuracyMeters: p.accuracy,
        heading: p.heading < 0 ? 0 : p.heading,
        speed: p.speed < 0 ? 0 : p.speed,
      ),
    );
  }
}
