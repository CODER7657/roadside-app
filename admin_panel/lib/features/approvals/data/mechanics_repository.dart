import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../app/firebase_providers.dart';

/// A mechanic with its uid (the document id).
typedef MechanicEntry = ({String uid, Mechanic mechanic});

/// Reads for A2 (admins may read `mechanics` and `mechanics/{uid}/private/kyc`; firestore.rules).
/// All writes go through the admin callables (#130), which also set claims and audit.
class MechanicsRepository {
  MechanicsRepository(FirebaseFirestore db) : _refs = RoadsideRefs(db);

  final RoadsideRefs _refs;

  /// Mechanics in [status], newest first (index: status + createdAt).
  Stream<List<MechanicEntry>> watch(MechanicStatus status) => _refs.mechanics
      .where('status', isEqualTo: status.value)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((q) => [for (final d in q.docs) (uid: d.id, mechanic: d.data())]);

  /// Listens on the plain document and converts here: fake_cloud_firestore doesn't re-emit
  /// withConverter document streams on updates (real Firestore does), and this works for both.
  Stream<MechanicKyc?> watchKyc(String uid) => _refs.raw(_refs.mechanicKyc(uid)).snapshots().map((s) {
    final data = s.data();
    return data == null ? null : MechanicKyc.fromJson(data);
  });
}

final mechanicsRepositoryProvider = Provider<MechanicsRepository>(
  (ref) => MechanicsRepository(ref.watch(firestoreProvider)),
);
