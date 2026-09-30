import 'dart:async';

import 'package:roadside_core/roadside_core.dart';

/// `users/{uid}` for U18: who is signed in, and the language notifications are sent in.
/// The rules (#99) let the owner change `language` with `updatedAt` = server time.
abstract interface class ProfileRepository {
  /// Null until there is an account (C5 creates `users/{uid}`, #96).
  Stream<AppUser?> watch();

  Future<void> setLanguage(Language language);
}

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._refs, this._uid);

  final RoadsideRefs _refs;
  final String _uid;

  @override
  Stream<AppUser?> watch() => _refs.user(_uid).snapshots().map((s) => s.data());

  @override
  Future<void> setLanguage(Language language) =>
      _refs.raw(_refs.user(_uid)).update(stampUpdate({'language': language.value}));
}

/// The profile kept in memory until #92 wires Firebase and #96 signs the customer in.
class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository([this._user]);

  AppUser? _user;
  final _changes = StreamController<AppUser?>.broadcast();

  /// While set, [watch] fails (for the error state).
  Object? failWatch;

  AppUser? get user => _user;

  @override
  Stream<AppUser?> watch() async* {
    if (failWatch case final error?) throw error;
    yield _user;
    yield* _changes.stream;
  }

  @override
  Future<void> setLanguage(Language language) async {
    final user = _user;
    if (user == null) return;
    _user = user.copyWith(language: language);
    _changes.add(_user);
  }
}
