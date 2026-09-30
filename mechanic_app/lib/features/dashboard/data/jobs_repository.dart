import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:roadside_core/roadside_core.dart';

/// One finished job, as the dashboard lists it.
@immutable
class CompletedJob {
  const CompletedJob({
    required this.problemType,
    required this.vehicleType,
    required this.completedAt,
    required this.amount,
  });

  final ProblemType problemType;
  final VehicleType vehicleType;
  final DateTime completedAt;

  /// Whole rupees (`finalAmount`).
  final int amount;
}

/// Today's work: jobs completed since local midnight, newest first.
@immutable
class TodaySummary {
  const TodaySummary(this.jobs);

  static const empty = TodaySummary([]);

  final List<CompletedJob> jobs;

  int get count => jobs.length;
  int get earned => jobs.fold(0, (total, j) => total + j.amount);

  /// Keeps only jobs completed on [now]'s local day, newest first.
  static TodaySummary of(Iterable<CompletedJob> jobs, DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    final today = [
      for (final j in jobs)
        if (!j.completedAt.toLocal().isBefore(day) &&
            j.completedAt.toLocal().isBefore(day.add(const Duration(days: 1))))
          j,
    ]..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return TodaySummary(today);
  }
}

abstract interface class JobsRepository {
  /// Today's completed jobs for the signed-in mechanic.
  Stream<TodaySummary> watchToday(DateTime Function() now);
}

/// Until Firebase is wired (#120, #123).
class InMemoryJobsRepository implements JobsRepository {
  InMemoryJobsRepository([List<CompletedJob> jobs = const []]) : _jobs = [...jobs];

  final List<CompletedJob> _jobs;
  final _changes = StreamController<void>.broadcast();

  void add(CompletedJob job) {
    _jobs.add(job);
    _changes.add(null);
  }

  @override
  Stream<TodaySummary> watchToday(DateTime Function() now) async* {
    yield TodaySummary.of(_jobs, now());
    await for (final _ in _changes.stream) {
      yield TodaySummary.of(_jobs, now());
    }
  }
}

/// Reads the mechanic's latest bookings with the existing `bookings(mechanicId, createdAt desc)`
/// index, and keeps the ones completed today. 50 covers a very busy day.
class FirestoreJobsRepository implements JobsRepository {
  FirestoreJobsRepository(this._db, this._uid);

  final FirebaseFirestore _db;
  final String _uid;

  @override
  Stream<TodaySummary> watchToday(DateTime Function() now) =>
      // The raw collection, parsed per document below: the typed ref (withConverter) parses
      // while building the snapshot, so one bad document would fail the whole stream.
      _db
          .collection(Collections.bookings)
          .where('mechanicId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snap) => TodaySummary.of(_completed(snap.docs), now()));

  /// Completed jobs among [docs]. A document that doesn't parse is skipped (and logged without
  /// its contents) rather than blanking the whole dashboard.
  static List<CompletedJob> _completed(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final jobs = <CompletedJob>[];
    for (final doc in docs) {
      final Booking b;
      try {
        b = Booking.fromJson(doc.data());
      } catch (e) {
        LaneLog.w('dashboard: skipped unreadable booking', error: e);
        continue;
      }
      final completedAt = b.timestamps.completed;
      final amount = b.finalAmount;
      if (b.status != BookingStatus.completed || completedAt == null || amount == null) continue;
      jobs.add(
        CompletedJob(
          problemType: b.problemType,
          vehicleType: b.vehicle.type,
          completedAt: completedAt,
          amount: amount,
        ),
      );
    }
    return jobs;
  }
}
