import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../data/contacts_repository.dart';

// Seams: in memory until #92 wires Firebase (then FirestoreEmergencyContactsRepository).
final emergencyContactsRepositoryProvider = Provider<EmergencyContactsRepository>(
  (ref) => InMemoryEmergencyContactsRepository(),
);
final contactPickerProvider = Provider<ContactPicker>((ref) => const PlatformContactPicker());

final savedContactsProvider = StreamProvider.autoDispose<List<Contact>>(
  (ref) => ref.watch(emergencyContactsRepositoryProvider).watch(),
);

/// Why a contact couldn't be added.
enum ContactError { full, invalidPhone, duplicate }

/// A name for the rules (1–60 characters): the given one, or the number when there's none.
String contactName(String name, String phone) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return phone;
  return trimmed.characters.take(60).toString();
}

/// U17 while editing: the list the screen shows, and whether it differs from what's saved.
@immutable
class ContactsDraft {
  const ContactsDraft({
    this.contacts = const [],
    this.saved = const [],
    this.loaded = false,
    this.saving = false,
  });

  final List<Contact> contacts;
  final List<Contact> saved;
  final bool loaded;
  final bool saving;

  bool get full => contacts.length >= kMaxEmergencyContacts;
  bool get dirty => !listEquals(contacts, saved);

  ContactsDraft copyWith({List<Contact>? contacts, List<Contact>? saved, bool? loaded, bool? saving}) =>
      ContactsDraft(
        contacts: contacts ?? this.contacts,
        saved: saved ?? this.saved,
        loaded: loaded ?? this.loaded,
        saving: saving ?? this.saving,
      );
}

class ContactsEditor extends Notifier<ContactsDraft> {
  @override
  ContactsDraft build() {
    // Start from what's saved; later changes elsewhere don't overwrite unsaved edits.
    ref.listen(savedContactsProvider, (_, next) {
      final saved = next.value;
      if (saved == null) return;
      state = state.dirty && state.loaded
          ? state.copyWith(saved: saved)
          : state.copyWith(contacts: saved, saved: saved, loaded: true);
    });
    final saved = ref.read(savedContactsProvider).value;
    return saved == null ? const ContactsDraft() : ContactsDraft(contacts: saved, saved: saved, loaded: true);
  }

  /// Adds a contact from the picker or typed in. The phone is normalised to E.164
  /// (`98765 43210` → `+919876543210`).
  ContactError? add(String name, String rawPhone) {
    if (state.full) return ContactError.full;
    final phone = normalizePhone(rawPhone);
    if (phone == null) return ContactError.invalidPhone;
    if (state.contacts.any((c) => c.phone == phone)) return ContactError.duplicate;
    state = state.copyWith(
      contacts: [
        ...state.contacts,
        Contact(name: contactName(name, phone), phone: phone),
      ],
    );
    return null;
  }

  void remove(int index) {
    if (index < 0 || index >= state.contacts.length) return;
    state = state.copyWith(contacts: [...state.contacts]..removeAt(index));
  }

  /// Saves the list; false if it failed (the edits stay).
  Future<bool> save() async {
    if (state.saving) return false;
    state = state.copyWith(saving: true);
    try {
      await ref.read(emergencyContactsRepositoryProvider).save(state.contacts);
      state = state.copyWith(saved: state.contacts, saving: false);
      return true;
    } catch (e, s) {
      // No names or numbers in the logs.
      LaneLog.w('emergency contacts save failed', error: e, stackTrace: s);
      state = state.copyWith(saving: false);
      return false;
    }
  }
}

final contactsEditorProvider = NotifierProvider.autoDispose<ContactsEditor, ContactsDraft>(
  ContactsEditor.new,
);
