// #179: U17 Emergency contacts.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/app/router.dart';
import 'package:customer_app/features/contacts/application/contacts.dart';
import 'package:customer_app/features/contacts/data/contacts_repository.dart';
import 'package:customer_app/features/contacts/presentation/contacts_screen.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:roadside_core/fakes.dart';
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;
import 'package:shared_preferences/shared_preferences.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

class _Picker implements ContactPicker {
  PickedContact? next;
  Object? error;
  int opened = 0;

  @override
  Future<PickedContact?> pickPhone() async {
    opened++;
    if (error != null) throw error!;
    return next;
  }
}

const mom = Contact(name: 'Mom', phone: '+919876500021');

Future<void> flush() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  setUpAll(FakeFirebaseFirestore.new);

  test('maskedPhone shows enough to recognise, not to read off', () {
    expect(maskedPhone('+919876543021'), '+91 98xxx xx021');
    expect(maskedPhone('+14155550100'), 'xxxxxxxxx100');
  });

  group('FirestoreEmergencyContactsRepository', () {
    test('changes only emergencyContacts and updatedAt (the rules allow those)', () async {
      final db = FakeFirebaseFirestore();
      await db.doc('users/u1').set(RoadsideFakes.customer.toJson());
      final before = (await db.doc('users/u1').get()).data()!;
      final repo = FirestoreEmergencyContactsRepository(RoadsideRefs(db), 'u1');
      await repo.save(const [mom]);
      final after = (await db.doc('users/u1').get()).data()!;
      final changed = {
        for (final k in {...before.keys, ...after.keys})
          if (before[k].toString() != after[k].toString()) k,
      };
      expect(changed, {'emergencyContacts', 'updatedAt'});
      expect(after['emergencyContacts'], [mom.toJson()]);
      expect(after['updatedAt'], isA<Timestamp>());
      expect(await repo.watch().first, [mom]);
    });
  });

  group('editor', () {
    late InMemoryEmergencyContactsRepository repo;
    late ProviderContainer c;

    setUp(() async {
      repo = InMemoryEmergencyContactsRepository(const [mom]);
      c = ProviderContainer(overrides: [emergencyContactsRepositoryProvider.overrideWithValue(repo)]);
      addTearDown(c.dispose);
      c.listen(contactsEditorProvider, (_, _) {});
      await flush();
    });

    ContactsEditor editor() => c.read(contactsEditorProvider.notifier);
    ContactsDraft draft() => c.read(contactsEditorProvider);

    test('starts from what is saved; nothing to save yet', () {
      expect(draft().loaded, isTrue);
      expect(draft().contacts, [mom]);
      expect(draft().dirty, isFalse);
    });

    test('numbers are normalised to E.164; a missing name becomes the number', () {
      expect(editor().add('  Rahul  ', '098765 43088'), isNull);
      expect(editor().add('', '+91-99999-00011'), isNull);
      expect(draft().contacts.map((c) => (c.name, c.phone)), [
        ('Mom', '+919876500021'),
        ('Rahul', '+919876543088'),
        ('+919999900011', '+919999900011'),
      ]);
      expect(draft().dirty, isTrue);
    });

    test('no duplicates, no invalid numbers, at most 3', () {
      expect(editor().add('Mom again', '98765 00021'), ContactError.duplicate);
      expect(editor().add('Short', '12345'), ContactError.invalidPhone);
      expect(editor().add('B', '9876543002'), isNull);
      expect(editor().add('C', '9876543003'), isNull);
      expect(draft().full, isTrue);
      expect(editor().add('D', '9876543004'), ContactError.full);
      expect(draft().contacts, hasLength(3));
    });

    test('names are capped at 60 characters (the rules)', () {
      editor().add('x' * 80, '9876543002');
      expect(draft().contacts.last.name.length, 60);
    });

    test('save writes the list; a failed save keeps the edits', () async {
      editor().remove(0);
      editor().add('Rahul', '9876543088');
      repo.failNext = 1;
      expect(await editor().save(), isFalse);
      expect(draft().dirty, isTrue);
      expect(repo.contacts, [mom]);
      expect(await editor().save(), isTrue);
      expect(repo.contacts.single.name, 'Rahul');
      expect(draft().dirty, isFalse);
    });
  });

  group('U17 screen', () {
    late InMemoryEmergencyContactsRepository repo;
    late _Picker picker;

    Future<ProviderContainer> open(
      WidgetTester tester, {
      String language = 'en',
      Size size = const Size(400, 900),
      double textScale = 1,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      SharedPreferences.setMockInitialValues({
        'first_run.language': language,
        'first_run.onboarded': true,
        'first_run.consent_version': kConsentVersion,
        'first_run.consent_at': '2026-09-29T10:15:00.000Z',
      });
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flavorProvider.overrideWithValue(AppFlavor.dev),
            sharedPreferencesProvider.overrideWithValue(prefs),
            emergencyContactsRepositoryProvider.overrideWithValue(repo),
            contactPickerProvider.overrideWithValue(picker),
            laneBatterySourceProvider.overrideWithValue(_NoBattery()),
            laneClockProvider.overrideWithValue(() => RoadsideFakes.now),
          ],
          child: const RoadsideApp(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      final c = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
      unawaited(c.read(routerProvider).push(AppRoutes.emergencyContacts));
      await settle(tester);
      return c;
    }

    setUp(() {
      repo = InMemoryEmergencyContactsRepository();
      picker = _Picker();
    });

    LaneButton save(WidgetTester tester) =>
        tester.widget<LaneButton>(find.widgetWithText(LaneButton, 'Save'));

    testWidgets('empty: what it is for, and two ways to add', (tester) async {
      await open(tester);
      expect(find.byType(EmergencyContactsScreen), findsOneWidget);
      expect(find.text('SOS sends these people your live location. Up to 3.'), findsOneWidget);
      expect(find.text('No contacts yet. Add someone who can help in an emergency.'), findsOneWidget);
      expect(find.text('ADD FROM CONTACTS'), findsOneWidget);
      expect(find.text('Enter a number'), findsOneWidget);
      expect(save(tester).onPressed, isNull);
    });

    testWidgets('add from the picker, masked on screen, then save', (tester) async {
      picker.next = (name: 'Mom', phone: '98765 00021');
      await open(tester);
      await tester.tap(find.text('ADD FROM CONTACTS'));
      await settle(tester);
      expect(picker.opened, 1);
      expect(find.text('Mom'), findsOneWidget);
      expect(find.text('+91 98xxx xx021'), findsOneWidget);
      await tester.tap(find.widgetWithText(LaneButton, 'Save'));
      await settle(tester);
      expect(repo.contacts, [mom]);
      expect(find.text('Contacts saved.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5)); // let the toast go
    });

    testWidgets('a picked number that cannot be used, or a picker error, says so', (tester) async {
      picker.next = (name: 'Office', phone: '0265 1234');
      await open(tester);
      await tester.tap(find.text('ADD FROM CONTACTS'));
      await settle(tester);
      expect(find.text("That number can't be used. Use a mobile number."), findsOneWidget);
      await settle(tester, frames: 12);
      picker.error = PlatformException(code: 'unavailable');
      await tester.tap(find.text('ADD FROM CONTACTS'));
      await settle(tester);
      expect(find.text("Couldn't open your contacts. Enter the number instead."), findsOneWidget);
      await tester.pump(const Duration(seconds: 5)); // let the toast go
    });

    testWidgets('type a contact in; an invalid number is shown on the field', (tester) async {
      await open(tester);
      await tester.tap(find.text('Enter a number'));
      await settle(tester);
      await tester.enterText(find.widgetWithText(LaneTextField, 'Name'), 'Rahul');
      await tester.enterText(find.widgetWithText(LaneTextField, 'Mobile number'), '123');
      await tester.tap(find.widgetWithText(LaneButton, 'Add'));
      await settle(tester);
      expect(find.text("That number can't be used. Use a mobile number."), findsOneWidget);
      await tester.enterText(find.widgetWithText(LaneTextField, 'Mobile number'), '98765 43088');
      await tester.tap(find.widgetWithText(LaneButton, 'Add'));
      await settle(tester);
      expect(find.text('Rahul'), findsOneWidget);
      expect(find.text('+91 98xxx xx088'), findsOneWidget);
    });

    testWidgets('three saved: no more add buttons, a note instead; remove brings them back', (tester) async {
      repo = InMemoryEmergencyContactsRepository(const [
        mom,
        Contact(name: 'Rahul', phone: '+919876543088'),
        Contact(name: 'Priya', phone: '+919876543099'),
      ]);
      await open(tester);
      expect(find.text('You can save up to 3 contacts.'), findsOneWidget);
      expect(find.text('ADD FROM CONTACTS'), findsNothing);
      await tester.tap(find.byTooltip('Remove Priya'));
      await settle(tester);
      expect(find.text('ADD FROM CONTACTS'), findsOneWidget);
      expect(save(tester).onPressed, isNotNull);
    });

    testWidgets('leaving with unsaved changes asks first; Keep editing stays', (tester) async {
      picker.next = (name: 'Mom', phone: '9876500021');
      await open(tester);
      await tester.tap(find.text('ADD FROM CONTACTS'));
      await settle(tester);
      await tester.tap(find.byTooltip(const DefaultMaterialLocalizations().backButtonTooltip));
      await settle(tester);
      expect(find.text('Discard your changes?'), findsOneWidget);
      await tester.tap(find.text('KEEP EDITING'));
      await settle(tester);
      expect(find.byType(EmergencyContactsScreen), findsOneWidget);
      await tester.tap(find.byTooltip(const DefaultMaterialLocalizations().backButtonTooltip));
      await settle(tester);
      await tester.tap(find.text('Discard'));
      await settle(tester);
      expect(find.byType(EmergencyContactsScreen), findsNothing);
      expect(repo.contacts, isEmpty);
    });

    testWidgets('fits at 320 px, 200% text, in Hindi', (tester) async {
      repo = InMemoryEmergencyContactsRepository(const [mom, Contact(name: 'राहुल', phone: '+919876543088')]);
      await open(tester, language: 'hi', size: const Size(320, 800), textScale: 2);
      expect(tester.takeException(), isNull);
      expect(find.text('आपातकालीन संपर्क'), findsOneWidget);
    });
  });
}

Future<void> settle(WidgetTester tester, {int frames = 6}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}
