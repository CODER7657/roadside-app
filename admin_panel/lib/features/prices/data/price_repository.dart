import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../app/firebase_providers.dart';

/// The new state of one `prices/{vehicleType_problemType}` document.
class PriceEdit {
  const PriceEdit({
    required this.vehicleType,
    required this.problemType,
    required this.before,
    required this.range,
    required this.cityOverrides,
  });

  final VehicleType vehicleType;
  final ProblemType problemType;

  /// The stored document, or null when it doesn't exist yet (then it's created).
  final Price? before;
  final PriceRange range;

  /// Empty = no overrides; the field is removed.
  final Map<CityId, PriceRange> cityOverrides;

  String get id => Price.idFor(vehicleType, problemType);
}

/// `prices/*` for A4 (PLAN §8 prices). Admin writes go in one batch with their `auditLogs`
/// entries (firebase/README.md): the rules allow both, and the batch saves all or nothing.
class PriceRepository {
  PriceRepository(this._db) : _refs = RoadsideRefs(_db);

  final FirebaseFirestore _db;
  final RoadsideRefs _refs;

  /// Prices by document id.
  Stream<Map<String, Price>> watch() =>
      _refs.prices.snapshots().map((q) => {for (final d in q.docs) d.id: d.data()});

  Future<void> save(List<PriceEdit> edits, {required String actorUid}) async {
    if (edits.isEmpty) return;
    final batch = _db.batch();
    for (final e in edits) {
      final ref = _refs.raw(_refs.prices.doc(e.id));
      final overrides = {
        for (final MapEntry(:key, :value) in e.cityOverrides.entries) key.value: value.toJson(),
      };
      final before = e.before;
      // The whole document, so removed overrides are really gone (update() would merge maps).
      final doc = <String, Object?>{
        'vehicleType': e.vehicleType.value,
        'problemType': e.problemType.value,
        'min': e.range.min,
        'max': e.range.max,
        'includes': before?.includes ?? '',
        if (overrides.isNotEmpty) 'cityOverrides': overrides,
      };
      if (before == null) {
        batch.set(ref, stampNew(doc));
      } else {
        final createdAt = before.createdAt;
        batch.set(
          ref,
          stampUpdate({
            ...doc,
            if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt),
            'schemaVersion': before.schemaVersion,
          }),
        );
      }
      batch.set(_refs.raw(_refs.auditLogs.doc()), {
        'actorUid': actorUid,
        'action': 'price.update',
        'target': 'prices/${e.id}',
        'before': before == null
            ? null
            : _summary(PriceRange(min: before.min, max: before.max), before.cityOverrides),
        'after': _summary(e.range, e.cityOverrides),
        'at': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  static Map<String, Object?> _summary(PriceRange range, Map<CityId, PriceRange>? overrides) => {
    'min': range.min,
    'max': range.max,
    'cityOverrides': {
      for (final MapEntry(:key, :value) in (overrides ?? const <CityId, PriceRange>{}).entries)
        key.value: value.toJson(),
    },
  };
}

final priceRepositoryProvider = Provider<PriceRepository>(
  (ref) => PriceRepository(ref.watch(firestoreProvider)),
);

final pricesProvider = StreamProvider<Map<String, Price>>(
  (ref) => ref.watch(priceRepositoryProvider).watch(),
);
