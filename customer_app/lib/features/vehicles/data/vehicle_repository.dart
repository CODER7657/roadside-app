import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:roadside_core/roadside_core.dart';

/// A vehicle with its Firestore document id (`users/{uid}/vehicles/{id}`).
@immutable
class SavedVehicle {
  const SavedVehicle(this.id, this.vehicle);

  final String id;
  final Vehicle vehicle;
}

/// What U2 collects. `regNo` is stored normalised (`GJ01AB1234`), as the rules require.
@immutable
class VehicleDraft {
  const VehicleDraft({
    required this.type,
    required this.brand,
    required this.model,
    required this.regNo,
    required this.fuel,
    this.makeDefault = false,
  });

  final VehicleType type;
  final String brand;
  final String model;
  final String regNo;
  final Fuel fuel;
  final bool makeDefault;

  /// Exactly the fields `firestore.rules` accepts for a vehicle (PLAN §8).
  Map<String, Object?> toFields({required bool isDefault}) => {
    'type': type.value,
    'brand': brand.trim(),
    'model': model.trim(),
    'regNo': normalizeRegNo(regNo),
    'fuel': fuel.value,
    'isDefault': isDefault,
  };
}

/// The customer's vehicles. Exactly one is the default once any exist.
abstract interface class VehicleRepository {
  /// Oldest first.
  Stream<List<SavedVehicle>> watch();

  /// Adds a vehicle; the first one is always the default. Returns its id.
  Future<String> add(VehicleDraft draft);

  Future<void> setDefault(String id);

  /// Removes a vehicle; if it was the default, the oldest remaining one takes over.
  Future<void> delete(String id);

  /// Puts a just-deleted vehicle back (the Undo on the toast).
  Future<void> restore(SavedVehicle vehicle);
}

/// `users/{uid}/vehicles` in Firestore, written with the `roadside_core` stamps the rules
/// check. Used once sign-in lands (#96); until then the app runs on [InMemoryVehicleRepository].
class FirestoreVehicleRepository implements VehicleRepository {
  FirestoreVehicleRepository(this.refs, this.uid);

  final RoadsideRefs refs;
  final String uid;

  CollectionReference<Vehicle> get _col => refs.vehicles(uid);

  @override
  Stream<List<SavedVehicle>> watch() => _col
      .orderBy('createdAt')
      .snapshots()
      .map((s) => [for (final d in s.docs) SavedVehicle(d.id, d.data())]);

  @override
  Future<String> add(VehicleDraft draft) async {
    final existing = await _col.get();
    final makeDefault = draft.makeDefault || existing.docs.isEmpty;
    final ref = _col.doc();
    final batch = refs.db.batch()..set(refs.raw(ref), stampNew(draft.toFields(isDefault: makeDefault)));
    if (makeDefault) {
      for (final d in existing.docs.where((d) => d.data().isDefault)) {
        batch.update(refs.raw(d.reference), stampUpdate({'isDefault': false}));
      }
    }
    await batch.commit();
    return ref.id;
  }

  @override
  Future<void> setDefault(String id) async {
    final batch = refs.db.batch();
    for (final d in (await _col.get()).docs) {
      final shouldBe = d.id == id;
      if (d.data().isDefault != shouldBe) {
        batch.update(refs.raw(d.reference), stampUpdate({'isDefault': shouldBe}));
      }
    }
    await batch.commit();
  }

  @override
  Future<void> delete(String id) async {
    final docs = (await _col.get()).docs;
    final target = docs.where((d) => d.id == id).firstOrNull;
    if (target == null) return;
    final batch = refs.db.batch()..delete(refs.raw(target.reference));
    final rest = docs.where((d) => d.id != id).toList()
      ..sort((a, b) => (a.data().createdAt ?? DateTime(0)).compareTo(b.data().createdAt ?? DateTime(0)));
    if (target.data().isDefault && rest.isNotEmpty) {
      batch.update(refs.raw(rest.first.reference), stampUpdate({'isDefault': true}));
    }
    await batch.commit();
  }

  @override
  Future<void> restore(SavedVehicle saved) async {
    final v = saved.vehicle;
    final draft = VehicleDraft(type: v.type, brand: v.brand, model: v.model, regNo: v.regNo, fuel: v.fuel);
    // A restore is a new write (the rules stamp createdAt with request.time), under the old id.
    await refs.raw(_col.doc(saved.id)).set(stampNew(draft.toFields(isDefault: false)));
    if (v.isDefault) await setDefault(saved.id);
  }
}

/// Vehicles kept in memory: the app runs on this until Firebase and sign-in land
/// (#92, #96), as PLAN §16 plans for (fakes until the Firestore wiring).
class InMemoryVehicleRepository implements VehicleRepository {
  InMemoryVehicleRepository({List<SavedVehicle> seed = const [], DateTime Function()? clock})
    : _items = [...seed],
      _clock = clock ?? DateTime.now;

  final List<SavedVehicle> _items;
  final DateTime Function() _clock;
  final _changes = StreamController<List<SavedVehicle>>.broadcast();
  int _next = 0;

  List<SavedVehicle> get _snapshot => List.unmodifiable(_items);

  void _emit() => _changes.add(_snapshot);

  @override
  Stream<List<SavedVehicle>> watch() async* {
    yield _snapshot;
    yield* _changes.stream;
  }

  SavedVehicle _with(SavedVehicle s, {required bool isDefault}) =>
      SavedVehicle(s.id, s.vehicle.copyWith(isDefault: isDefault, updatedAt: _clock()));

  @override
  Future<String> add(VehicleDraft draft) async {
    final makeDefault = draft.makeDefault || _items.isEmpty;
    if (makeDefault) {
      for (var i = 0; i < _items.length; i++) {
        if (_items[i].vehicle.isDefault) _items[i] = _with(_items[i], isDefault: false);
      }
    }
    final f = draft.toFields(isDefault: makeDefault);
    final now = _clock();
    final id = 'local-${_next++}';
    _items.add(
      SavedVehicle(
        id,
        Vehicle(
          type: draft.type,
          brand: f['brand']! as String,
          model: f['model']! as String,
          regNo: f['regNo']! as String,
          fuel: draft.fuel,
          isDefault: makeDefault,
          createdAt: now,
          updatedAt: now,
        ),
      ),
    );
    _emit();
    return id;
  }

  @override
  Future<void> setDefault(String id) async {
    for (var i = 0; i < _items.length; i++) {
      final shouldBe = _items[i].id == id;
      if (_items[i].vehicle.isDefault != shouldBe) _items[i] = _with(_items[i], isDefault: shouldBe);
    }
    _emit();
  }

  @override
  Future<void> delete(String id) async {
    final i = _items.indexWhere((s) => s.id == id);
    if (i == -1) return;
    final wasDefault = _items.removeAt(i).vehicle.isDefault;
    if (wasDefault && _items.isNotEmpty) _items[0] = _with(_items[0], isDefault: true);
    _emit();
  }

  @override
  Future<void> restore(SavedVehicle saved) async {
    _items
      ..add(SavedVehicle(saved.id, saved.vehicle.copyWith(isDefault: false)))
      ..sort((a, b) => (a.vehicle.createdAt ?? DateTime(0)).compareTo(b.vehicle.createdAt ?? DateTime(0)));
    if (saved.vehicle.isDefault) return setDefault(saved.id);
    _emit();
  }
}
