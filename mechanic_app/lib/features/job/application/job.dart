import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../auth/application/auth.dart';
import '../../dashboard/application/online.dart';
import '../../dashboard/data/location_service.dart';
import '../../permissions/application/permission_service.dart';
import '../data/job_repository.dart';

/// PLAN §11, during an active job.
abstract final class JobTiming {
  static const moveMeters = 10;
  static const interval = Duration(seconds: 5);

  /// A rough city average for the straight-line ETA until the map provider gives routes.
  static const kmPerHour = 20.0;
}

/// Statuses in which the mechanic's location is shared with the customer.
const kTrackedStatuses = {
  BookingStatus.accepted,
  BookingStatus.arriving,
  BookingStatus.arrived,
  BookingStatus.inProgress,
};

/// Minutes to the pickup at [JobTiming.kmPerHour] in a straight line; 0 once there. Kept
/// within the rules' 0–600.
int etaMinutes(LocationFix at, GeoPoint pickup) {
  final km = distanceKm(at.lat, at.lng, pickup.latitude, pickup.longitude);
  if (km < 0.05) return 0;
  return (km / JobTiming.kmPerHour * 60).ceil().clamp(1, 600);
}

// Seams: Firebase for a signed-in mechanic, the fakes otherwise (tests, no Firebase config).
final jobRepositoryProvider = Provider<JobRepository>((ref) {
  final signedIn = ref.watch(signedInFirebaseProvider);
  if (signedIn == null) return InMemoryJobRepository();
  final (firebase, _) = signedIn;
  return FirebaseJobRepository(firebase.firestore, firebase.functions);
});
final liveLocationRepositoryProvider = Provider<LiveLocationRepository>((ref) {
  final signedIn = ref.watch(signedInFirebaseProvider);
  if (signedIn == null) return InMemoryLiveLocationRepository();
  final (firebase, _) = signedIn;
  return FirestoreLiveLocationRepository(firebase.firestore);
});

final jobProvider = StreamProvider.family<Booking?, String>(
  (ref, bookingId) => ref.watch(jobRepositoryProvider).watch(bookingId),
);

/// Why the location isn't being shared, for the banner on M5.
enum JobLocationProblem {
  /// No location permission (never given, or taken back in Settings).
  permission,

  /// The phone's location is switched off.
  gpsOff,
}

@immutable
class JobTrackingState {
  const JobTrackingState({this.bookingId, this.lastFix, this.problem});

  /// The job being tracked, or null.
  final String? bookingId;
  final LocationFix? lastFix;

  /// Set while the job is on but its location can't be shared.
  final JobLocationProblem? problem;

  bool get isTracking => bookingId != null;
}

/// Shares the mechanic's location for one active job. Lives above the job screen, so leaving
/// the screen (or switching it off) doesn't stop it; only the end of the job does.
final jobTrackingProvider = NotifierProvider<JobTrackingController, JobTrackingState>(
  JobTrackingController.new,
);

class JobTrackingController extends Notifier<JobTrackingState> {
  StreamSubscription<LocationFix>? _fixes;
  GeoPoint? _pickup;
  ForegroundTracking? _notification;
  bool _starting = false;

  @override
  JobTrackingState build() {
    ref.onDispose(_cancel);
    return const JobTrackingState();
  }

  /// Starts (or keeps) tracking [bookingId]. [notification] is the foreground-service
  /// notification text, in the app's language. Without location permission, or with the
  /// phone's location off, it doesn't start and says why in [JobTrackingState.problem].
  Future<void> start({
    required String bookingId,
    required GeoPoint pickup,
    required ForegroundTracking notification,
  }) async {
    _pickup = pickup;
    _notification = notification;
    if (state.bookingId == bookingId && (_fixes != null || _starting)) return;
    _cancel();
    // Keep showing a known problem while checking again, so the banner doesn't flicker.
    state = JobTrackingState(
      bookingId: bookingId,
      problem: state.bookingId == bookingId ? state.problem : null,
    );
    _starting = true;
    try {
      final problem = await _check();
      // Stopped or moved to another job while checking.
      if (state.bookingId != bookingId) return;
      if (problem != null) {
        state = JobTrackingState(bookingId: bookingId, problem: problem);
        return;
      }
      _fixes = ref
          .read(locationServiceProvider)
          .fixes(
            distanceFilterMeters: JobTiming.moveMeters,
            interval: JobTiming.interval,
            foreground: notification,
          )
          .listen((fix) => unawaited(_write(bookingId, fix)), onError: (Object _) {});
      state = JobTrackingState(bookingId: bookingId, lastFix: state.lastFix);
    } finally {
      _starting = false;
    }
  }

  /// After the mechanic allowed location or switched it on: try again.
  Future<void> retry() async {
    final bookingId = state.bookingId;
    final pickup = _pickup;
    final notification = _notification;
    if (bookingId == null || pickup == null || notification == null || _fixes != null) return;
    await start(bookingId: bookingId, pickup: pickup, notification: notification);
  }

  Future<JobLocationProblem?> _check() async {
    final access = await ref.read(permissionServiceProvider).status(AppPermission.location);
    if (access != PermissionAccess.granted) return JobLocationProblem.permission;
    if (!await ref.read(locationServiceProvider).serviceEnabled()) return JobLocationProblem.gpsOff;
    return null;
  }

  /// The job ended (completed or cancelled): stop sharing.
  void stop() {
    _cancel();
    state = const JobTrackingState();
  }

  Future<void> _write(String bookingId, LocationFix fix) async {
    if (state.bookingId != bookingId) return;
    state = JobTrackingState(bookingId: bookingId, lastFix: fix);
    final pickup = _pickup;
    if (pickup == null) return;
    try {
      await ref
          .read(liveLocationRepositoryProvider)
          .write(bookingId, fix, etaMinutes: etaMinutes(fix, pickup));
    } catch (_) {
      // The next fix (5 s) tries again; markArrived says so if the position goes stale.
    }
  }

  void _cancel() {
    unawaited(_fixes?.cancel());
    _fixes = null;
  }
}
