import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../app/firebase_providers.dart';

/// `admins/{uid}`: the read-only list tool/admin maintains (PLAN §8 Roles).
typedef AdminEntry = ({String uid, String email});

/// A6 reads and writes. Each save is one batch with its `auditLogs` entry (firebase/README.md).
class SettingsRepository {
  SettingsRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _config =>
      _db.doc('${Collections.appConfig}/${Collections.appConfigPublic}');

  Stream<AppConfig?> watchConfig() => _config.snapshots().map((s) {
    final data = s.data();
    return data == null ? null : AppConfig.fromJson(data);
  });

  Stream<List<AdminEntry>> watchAdmins() => _db
      .collection(Collections.admins)
      .snapshots()
      .map((q) => [for (final d in q.docs) (uid: d.id, email: (d.data()['email'] as String?) ?? d.id)]);

  Future<void> saveConfig(AppConfig next, {required AppConfig? before, required String actorUid}) async {
    final batch = _db.batch()
      ..set(_config, next.toJson())
      ..set(_audit(), _log(actorUid, 'appConfig.update', _config.path, before?.toJson(), next.toJson()));
    await batch.commit();
  }

  /// Writes the whole document (the rules check every field), keeping `createdAt`.
  Future<void> saveArea(
    CityId city,
    ServiceArea next, {
    required ServiceArea before,
    required String actorUid,
  }) async {
    final ref = _db.doc('${Collections.serviceAreas}/${city.value}');
    final createdAt = before.createdAt;
    final data = stampUpdate({
      ...next.toJson(),
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt),
      'schemaVersion': kSchemaVersion,
    })..removeWhere((k, v) => k == 'createdAt' && v == null);
    final batch = _db.batch()
      ..set(ref, data)
      ..set(
        _audit(),
        _log(
          actorUid,
          'serviceArea.update',
          ref.path,
          {'active': before.active, 'radiusKm': before.radiusKm},
          {'active': next.active, 'radiusKm': next.radiusKm},
        ),
      );
    await batch.commit();
  }

  DocumentReference<Map<String, dynamic>> _audit() => _db.collection(Collections.auditLogs).doc();

  static Map<String, Object?> _log(
    String actor,
    String action,
    String target,
    Object? before,
    Object? after,
  ) => {
    'actorUid': actor,
    'action': action,
    'target': target,
    'before': before,
    'after': after,
    'at': FieldValue.serverTimestamp(),
  };
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(firestoreProvider)),
);

final appConfigProvider = StreamProvider<AppConfig?>(
  (ref) => ref.watch(settingsRepositoryProvider).watchConfig(),
);

final adminsProvider = StreamProvider<List<AdminEntry>>(
  (ref) => ref.watch(settingsRepositoryProvider).watchAdmins(),
);
