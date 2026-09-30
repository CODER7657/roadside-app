import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roadside_core/roadside_core.dart';

import 'location_service.dart';

/// Writes `presence/{uid}` (PLAN §8), which dispatch reads to find mechanics nearby.
abstract interface class PresenceRepository {
  /// Online or offline at [at]. The first write creates the doc with the profile's [cityId]
  /// and no active booking (both 🔒 after that); later writes change only `isOnline`,
  /// `location` and `updatedAt`, as the rules require (#99). `updatedAt` is the server time.
  Future<void> write({required bool online, required LocationFix at, required CityId cityId});
}

/// Until Firebase is wired (#120, #123): remembers the writes.
class InMemoryPresenceRepository implements PresenceRepository {
  InMemoryPresenceRepository({this.failNext = 0});

  /// How many of the next writes fail (tests).
  int failNext;
  final writes = <({bool online, LocationFix at, CityId cityId})>[];

  bool? get isOnline => writes.isEmpty ? null : writes.last.online;

  @override
  Future<void> write({required bool online, required LocationFix at, required CityId cityId}) async {
    if (failNext > 0) {
      failNext--;
      throw Exception('write failed');
    }
    writes.add((online: online, at: at, cityId: cityId));
  }
}

class FirestorePresenceRepository implements PresenceRepository {
  FirestorePresenceRepository(this._db, this._uid);

  final FirebaseFirestore _db;
  final String _uid;

  @override
  Future<void> write({required bool online, required LocationFix at, required CityId cityId}) async {
    final ref = _db.doc('${Collections.presence}/$_uid');
    final fields = stampUpdate({
      'isOnline': online,
      'location': {'geopoint': GeoPoint(at.lat, at.lng), 'geohash': encodeGeohash(at.lat, at.lng)},
    });
    try {
      await ref.update(fields);
    } on FirebaseException catch (e) {
      if (e.code != 'not-found') rethrow;
      // First time online: the create rule wants the profile's city and no booking.
      await ref.set({...fields, 'cityId': cityId.value, 'activeBookingId': null});
    }
  }
}
