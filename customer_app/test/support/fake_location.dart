import 'dart:async';

import 'package:customer_app/features/booking/data/location.dart';

/// GPS the test drives: add readings to [readings] by hand.
class FakeLocationService implements LocationService {
  bool enabled = true;
  var readings = StreamController<LocationFix>.broadcast();
  int settingsOpened = 0;

  void add(double lat, double lng, double accuracy) =>
      readings.add(LocationFix(position: (lat: lat, lng: lng), accuracyMeters: accuracy));

  @override
  Future<bool> serviceEnabled() async => enabled;

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }

  @override
  Stream<LocationFix> fixes() => readings.stream;
}

/// Addresses the test sets; null means "no street address".
class FakeGeocoder implements ReverseGeocoder {
  String? Function(LatLng point) answer = (p) => 'Near SG Highway, Thaltej';
  Object? error;
  final asked = <(LatLng, String)>[];

  @override
  Future<String?> addressAt(LatLng point, {required String languageCode}) async {
    asked.add((point, languageCode));
    if (error != null) throw error!;
    return answer(point);
  }
}
