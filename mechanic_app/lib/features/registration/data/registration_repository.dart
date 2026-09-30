import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roadside_core/roadside_core.dart';

/// The signed-in mechanic, as registration needs it. The Firebase Auth implementation lands
/// with phone login (#123).
abstract interface class AuthSession {
  String get uid;

  /// E.164, from Auth. The KYC rules check it matches the signed-in phone number.
  String get phone;

  /// `getIdToken(true)`: picks up `role: mechanic, mechanicStatus: pending` set by
  /// onMechanicRegistered (#101) right after the profile is created.
  Future<void> refreshClaims();
}

/// Saves the M1 registration and reports where the mechanic stands.
abstract interface class RegistrationRepository {
  /// null until the profile exists, then the profile (its 🔒 `status` says where it stands).
  Stream<Mechanic?> watchProfile();

  /// Creates `mechanics/{uid}` and `mechanics/{uid}/private/kyc` in **one batch** (the KYC
  /// rule reads the profile with `getAfter`), then refreshes the ID token for the new claims.
  Future<void> submit(Mechanic profile, MechanicKyc kyc);
}

/// Until Firebase is wired (#120, #123): remembers the submission in memory.
class InMemoryRegistrationRepository implements RegistrationRepository {
  InMemoryRegistrationRepository({this.profile, this.failNext = 0});

  final _changes = StreamController<Mechanic?>.broadcast();

  /// How many of the next submits fail (tests).
  int failNext;
  Mechanic? profile;
  MechanicKyc? kyc;
  int claimRefreshes = 0;

  /// What the admin (A2) does; tests use it to move the mechanic along.
  void setStatus(MechanicStatus status) {
    profile = profile?.copyWith(status: status);
    _changes.add(profile);
  }

  @override
  Stream<Mechanic?> watchProfile() async* {
    yield profile;
    yield* _changes.stream;
  }

  @override
  Future<void> submit(Mechanic profile, MechanicKyc kyc) async {
    if (failNext > 0) {
      failNext--;
      throw Exception('submit failed');
    }
    this.profile = profile.copyWith(status: MechanicStatus.pending);
    this.kyc = kyc;
    claimRefreshes++;
    _changes.add(this.profile);
  }
}

class FirestoreRegistrationRepository implements RegistrationRepository {
  FirestoreRegistrationRepository(this._db, this._session) : _refs = RoadsideRefs(_db);

  final FirebaseFirestore _db;
  final AuthSession _session;
  final RoadsideRefs _refs;

  @override
  Stream<Mechanic?> watchProfile() => _refs.mechanic(_session.uid).snapshots().map((s) => s.data());

  @override
  Future<void> submit(Mechanic profile, MechanicKyc kyc) async {
    final uid = _session.uid;
    final batch = _db.batch()
      ..set(_refs.raw(_refs.mechanic(uid)), stampNew(profile.toJson()))
      // The phone always comes from Auth, whatever the draft said.
      ..set(_refs.raw(_refs.mechanicKyc(uid)), stampNew(kyc.copyWith(phone: _session.phone).toJson()));
    await batch.commit();
    await _session.refreshClaims();
  }
}
