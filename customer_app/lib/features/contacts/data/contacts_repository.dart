import 'dart:async';

import 'package:flutter/services.dart';
import 'package:roadside_core/roadside_core.dart';

/// `users/{uid}.emergencyContacts`. The rules (#99) let the owner change them with
/// `updatedAt` = server time: at most 3, each `{name (1–60), phone (E.164)}`.
abstract interface class EmergencyContactsRepository {
  Stream<List<Contact>> watch();

  Future<void> save(List<Contact> contacts);
}

class FirestoreEmergencyContactsRepository implements EmergencyContactsRepository {
  FirestoreEmergencyContactsRepository(this._refs, this._uid);

  final RoadsideRefs _refs;
  final String _uid;

  @override
  Stream<List<Contact>> watch() =>
      _refs.user(_uid).snapshots().map((s) => s.data()?.emergencyContacts ?? const <Contact>[]);

  @override
  Future<void> save(List<Contact> contacts) => _refs
      .raw(_refs.user(_uid))
      .update(
        stampUpdate({
          'emergencyContacts': [for (final c in contacts) c.toJson()],
        }),
      );
}

/// Contacts kept in memory until #92 wires Firebase (and C5 creates `users/{uid}`).
class InMemoryEmergencyContactsRepository implements EmergencyContactsRepository {
  InMemoryEmergencyContactsRepository([List<Contact> initial = const []]) : _contacts = [...initial];

  List<Contact> _contacts;
  final _changes = StreamController<List<Contact>>.broadcast();

  /// How many of the next saves fail.
  int failNext = 0;

  List<Contact> get contacts => List.unmodifiable(_contacts);

  @override
  Stream<List<Contact>> watch() async* {
    yield contacts;
    yield* _changes.stream;
  }

  @override
  Future<void> save(List<Contact> contacts) async {
    if (failNext > 0) {
      failNext--;
      throw Exception('save failed');
    }
    _contacts = [...contacts];
    _changes.add(this.contacts);
  }
}

/// A contact chosen in the phone's own picker, as it came (not yet normalised).
typedef PickedContact = ({String name, String phone});

/// Opens the system contact picker for one phone number. No READ_CONTACTS permission: the
/// picker hands back only the chosen contact (`MainActivity`, `roadside/contact_picker`).
abstract interface class ContactPicker {
  /// Null when the user backed out.
  Future<PickedContact?> pickPhone();
}

class PlatformContactPicker implements ContactPicker {
  const PlatformContactPicker();

  static const _channel = MethodChannel('roadside/contact_picker');

  @override
  Future<PickedContact?> pickPhone() async {
    final picked = await _channel.invokeMapMethod<String, Object?>('pickPhone');
    if (picked == null) return null;
    return (name: (picked['name'] as String?) ?? '', phone: (picked['phone'] as String?) ?? '');
  }
}
