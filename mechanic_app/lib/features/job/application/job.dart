import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../dashboard/application/online.dart';
import '../../dashboard/data/location_service.dart';
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

// Seams: fakes until Firebase is wired (#120, #123).
final jobRepositoryProvider = Provider<JobRepository>((ref) => InMemoryJobRepository());
final liveLocationRepositoryProvider = Provider<LiveLocationRepository>(
  (ref) => InMemoryLiveLocationRepository(),
);

final jobProvider = StreamProvider.family<Booking?, String>(
  (ref, bookingId) => ref.watch(jobRepositoryProvider).watch(bookingId),
);

@immutable
class JobTrackingState {
  const JobTrackingState({this.bookingId, this.lastFix});

  /// The job being tracked, or null.
  final String? bookingId;
  final LocationFix? lastFix;

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

  @override
  JobTrackingState build() {
    ref.onDispose(_cancel);
    return const JobTrackingState();
  }

  /// Starts (or keeps) tracking [bookingId]. [notification] is the foreground-service
  /// notification text, in the app's language.
  void start({
    required String bookingId,
    required GeoPoint pickup,
    required ForegroundTracking notification,
  }) {
    _pickup = pickup;
    if (state.bookingId == bookingId) return;
    _cancel();
    state = JobTrackingState(bookingId: bookingId);
    _fixes = ref
        .read(locationServiceProvider)
        .fixes(
          distanceFilterMeters: JobTiming.moveMeters,
          interval: JobTiming.interval,
          foreground: notification,
        )
        .listen((fix) => unawaited(_write(bookingId, fix)), onError: (Object _) {});
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
