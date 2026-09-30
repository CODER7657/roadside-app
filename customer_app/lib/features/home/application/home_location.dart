import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart' show ambientControllerProvider;
import 'package:roadside_core/roadside_core.dart';

import '../../booking/application/estimate.dart';
import '../../booking/application/pickup.dart';
import '../../booking/data/location.dart';
import '../../permissions/application/permission_service.dart';

enum HomeLocationStatus {
  /// Not asked yet (no permission): Home offers "Show my location".
  idle,
  locating,
  ready,
  gpsOff,

  /// No reading in 15 s.
  noFix,
}

@immutable
class HomeLocationState {
  const HomeLocationState({
    this.status = HomeLocationStatus.idle,
    this.fix,
    this.address,
    this.city,
    this.outside = false,
  });

  final HomeLocationStatus status;
  final LocationFix? fix;
  final String? address;

  /// The service area the customer is in (PLAN §8: nearest centre whose circle contains them).
  final ServiceArea? city;

  /// Located, and in no active service area: U1·Area.
  final bool outside;
}

/// Where the customer is, for U1 Home: the address, the city chip and U1·Area. Never
/// prompts for permission itself; [start] only locates if it's already granted.
class HomeLocationNotifier extends Notifier<HomeLocationState> {
  Completer<void>? _stop;
  int _run = 0;

  @override
  HomeLocationState build() {
    ref.onDispose(_stopGps);
    return const HomeLocationState();
  }

  void _stopGps() {
    final stop = _stop;
    if (stop != null && !stop.isCompleted) stop.complete();
  }

  /// On opening Home: locate only if location is already allowed.
  Future<void> start({required String languageCode}) async {
    PermissionAccess access;
    try {
      access = await ref.read(permissionServiceProvider).status(AppPermission.location);
    } catch (e, s) {
      // No platform plugin (tests, unsupported device): same as not granted.
      LaneLog.w('home permission check failed', error: e, stackTrace: s);
      access = PermissionAccess.askable;
    }
    if (!ref.mounted || access != PermissionAccess.granted) return;
    await locate(languageCode: languageCode);
  }

  /// After the C7 explainer said yes (or from [start]).
  Future<void> locate({required String languageCode}) async {
    _stopGps();
    final run = ++_run;
    final location = ref.read(locationServiceProvider);
    bool enabled;
    try {
      enabled = await location.serviceEnabled();
    } catch (_) {
      enabled = false;
    }
    if (!ref.mounted || run != _run) return;
    if (!enabled) {
      state = const HomeLocationState(status: HomeLocationStatus.gpsOff);
      return;
    }
    state = const HomeLocationState(status: HomeLocationStatus.locating);
    final stop = _stop = Completer<void>();
    LocationFix? fix;
    try {
      fix = await bestFix(location.fixes(), stop: stop.future);
    } catch (e, s) {
      LaneLog.w('home location failed', error: e, stackTrace: s);
    }
    if (!ref.mounted || run != _run) return;
    if (fix == null) {
      state = const HomeLocationState(status: HomeLocationStatus.noFix);
      return;
    }
    ref.read(ambientControllerProvider.notifier).updatePosition(fix.position.lat, fix.position.lng);

    final areas = await ref.read(priceCatalogProvider).serviceAreas();
    final cityId = resolveCity(fix.position.lat, fix.position.lng, areas);
    String? address;
    try {
      address = await ref.read(reverseGeocoderProvider).addressAt(fix.position, languageCode: languageCode);
    } catch (e, s) {
      LaneLog.w('home reverse geocode failed', error: e, stackTrace: s);
    }
    if (!ref.mounted || run != _run) return;
    state = HomeLocationState(
      status: HomeLocationStatus.ready,
      fix: fix,
      address: address,
      city: cityId == null ? null : areas[cityId],
      outside: cityId == null,
    );
  }
}

final homeLocationProvider = NotifierProvider.autoDispose<HomeLocationNotifier, HomeLocationState>(
  HomeLocationNotifier.new,
);
