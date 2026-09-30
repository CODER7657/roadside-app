import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../registration/application/registration.dart';
import '../data/jobs_repository.dart';
import '../data/location_service.dart';
import '../data/presence_repository.dart';

/// PLAN §11 Mechanic live location, while online and idle.
abstract final class PresenceTiming {
  /// Write on every [moveMeters] moved…
  static const moveMeters = 100;

  /// …and at least this often, so dispatch sees a fresh `updatedAt`.
  static const heartbeat = Duration(seconds: 60);

  /// Dispatch treats presence older than this as offline (#28); the app stops too.
  static const stale = Duration(minutes: 2);
}

enum OnlinePhase {
  offline,

  /// Waiting for the first GPS fix.
  goingOnline,
  online,
}

/// Why the mechanic isn't online (shown on M3).
enum OnlineProblem {
  /// Location switched off in quick settings.
  gpsOff,

  /// No fix or no successful write for [PresenceTiming.stale]: dispatch already treats the
  /// mechanic as offline, so the app says so and stops.
  lostConnection,
}

@immutable
class OnlineState {
  const OnlineState({this.phase = OnlinePhase.offline, this.problem, this.lastWriteAt});

  final OnlinePhase phase;
  final OnlineProblem? problem;

  /// The last presence write that worked.
  final DateTime? lastWriteAt;

  bool get isOnline => phase != OnlinePhase.offline;
}

// Seams: fakes until Firebase and a device are wired (#120, #123).
final locationServiceProvider = Provider<LocationService>((ref) => const GeolocatorLocationService());
final presenceRepositoryProvider = Provider<PresenceRepository>((ref) => InMemoryPresenceRepository());
final jobsRepositoryProvider = Provider<JobsRepository>((ref) => InMemoryJobsRepository());

/// The clock presence and "today" use. Tests override it.
final dashboardClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final todaySummaryProvider = StreamProvider<TodaySummary>(
  (ref) => ref.watch(jobsRepositoryProvider).watchToday(ref.watch(dashboardClockProvider)),
);

final onlineProvider = NotifierProvider<OnlineController, OnlineState>(OnlineController.new);

class OnlineController extends Notifier<OnlineState> {
  StreamSubscription<LocationFix>? _fixes;
  Timer? _heartbeat;
  LocationFix? _last;

  @override
  OnlineState build() {
    ref.onDispose(_stopTracking);
    return const OnlineState();
  }

  DateTime _now() => ref.read(dashboardClockProvider)();

  CityId? get _cityId => ref.read(mechanicProfileProvider).value?.cityId;

  /// Starts sharing location with dispatch. Location permission must already be granted
  /// (the screen runs the C7 explainer first).
  Future<void> goOnline() async {
    if (state.isOnline) return;
    final location = ref.read(locationServiceProvider);
    if (!await location.serviceEnabled()) {
      state = const OnlineState(problem: OnlineProblem.gpsOff);
      return;
    }
    state = OnlineState(phase: OnlinePhase.goingOnline, lastWriteAt: _now());
    _fixes = location
        .fixes(distanceFilterMeters: PresenceTiming.moveMeters)
        .listen(_onFix, onError: (Object _) => _check());
    _heartbeat = Timer.periodic(PresenceTiming.heartbeat, (_) => _beat());
  }

  /// Stops sharing and tells dispatch.
  Future<void> goOffline() async {
    final last = _last;
    _stopTracking();
    state = const OnlineState();
    final city = _cityId;
    if (last != null && city != null) {
      // Best effort: if it fails, the presence goes stale and dispatch skips it anyway.
      await ref
          .read(presenceRepositoryProvider)
          .write(online: false, at: last, cityId: city)
          .catchError((_) {});
    }
  }

  void _onFix(LocationFix fix) {
    _last = fix;
    unawaited(_write(fix));
  }

  /// Every [PresenceTiming.heartbeat]: rewrite the last fix so `updatedAt` stays fresh, and
  /// give up once nothing has worked for [PresenceTiming.stale].
  void _beat() {
    final last = _last;
    if (last != null) unawaited(_write(last));
    _check();
  }

  Future<void> _write(LocationFix fix) async {
    final city = _cityId;
    if (city == null || !state.isOnline) return;
    try {
      await ref.read(presenceRepositoryProvider).write(online: true, at: fix, cityId: city);
      if (state.isOnline) state = OnlineState(phase: OnlinePhase.online, lastWriteAt: _now());
    } catch (_) {
      _check();
    }
  }

  void _check() {
    final lastOk = state.lastWriteAt;
    if (state.isOnline && lastOk != null && _now().difference(lastOk) >= PresenceTiming.stale) {
      _stopTracking();
      state = const OnlineState(problem: OnlineProblem.lostConnection);
    }
  }

  void _stopTracking() {
    _heartbeat?.cancel();
    _heartbeat = null;
    unawaited(_fixes?.cancel());
    _fixes = null;
  }
}
