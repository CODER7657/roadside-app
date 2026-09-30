import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../app/firebase_providers.dart';

typedef ComplaintEntry = ({String id, Complaint complaint});
typedef ReviewEntry = ({String bookingId, Review review});

/// A5 reads and the one admin write: resolving a complaint, in a batch with its audit entry
/// (firestore.rules: admins may change only `status` and `resolution`).
class ComplaintsRepository {
  ComplaintsRepository(this._db);

  final FirebaseFirestore _db;

  Stream<List<ComplaintEntry>> watch(ComplaintStatus status) => _db
      .collection(Collections.complaints)
      .where('status', isEqualTo: status.value)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((q) => [for (final d in q.docs) (id: d.id, complaint: Complaint.fromJson(d.data()))]);

  Stream<List<ReviewEntry>> watchReviews({int limit = 200}) => _db
      .collection(Collections.reviews)
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((q) => [for (final d in q.docs) (bookingId: d.id, review: Review.fromJson(d.data()))]);

  Stream<Booking?> watchBooking(String id) => _db.doc('${Collections.bookings}/$id').snapshots().map((s) {
    final data = s.data();
    return data == null ? null : Booking.fromJson(data);
  });

  Future<void> resolve(String complaintId, {required String resolution, required String actorUid}) async {
    final batch = _db.batch()
      ..update(_db.doc('${Collections.complaints}/$complaintId'), {
        'status': ComplaintStatus.resolved.value,
        'resolution': resolution,
      })
      ..set(_db.collection(Collections.auditLogs).doc(), {
        'actorUid': actorUid,
        'action': 'complaint.resolve',
        'target': '${Collections.complaints}/$complaintId',
        'before': {'status': ComplaintStatus.open.value},
        'after': {'status': ComplaintStatus.resolved.value, 'resolution': resolution},
        'at': FieldValue.serverTimestamp(),
      });
    await batch.commit();
  }
}

final complaintsRepositoryProvider = Provider<ComplaintsRepository>(
  (ref) => ComplaintsRepository(ref.watch(firestoreProvider)),
);

final complaintsProvider = StreamProvider.family<List<ComplaintEntry>, ComplaintStatus>(
  (ref, status) => ref.watch(complaintsRepositoryProvider).watch(status),
);

final reviewsProvider = StreamProvider<List<ReviewEntry>>(
  (ref) => ref.watch(complaintsRepositoryProvider).watchReviews(),
);

/// The booking a complaint or review is about (city, mechanic type, amounts).
final bookingProvider = StreamProvider.family<Booking?, String>(
  (ref, id) => ref.watch(complaintsRepositoryProvider).watchBooking(id),
);
