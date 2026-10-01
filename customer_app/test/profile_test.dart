// #180: U18 Profile & settings.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/app/router.dart';
import 'package:customer_app/features/contacts/application/contacts.dart';
import 'package:customer_app/features/contacts/data/contacts_repository.dart';
import 'package:customer_app/features/contacts/presentation/contacts_screen.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
import 'package:customer_app/features/first_run/presentation/privacy_notice_screen.dart';
import 'package:customer_app/features/profile/application/settings.dart';
import 'package:customer_app/features/profile/data/profile_repository.dart';
import 'package:customer_app/features/profile/presentation/profile_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
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

/// Records language writes; can fail them.
class _Profiles extends InMemoryProfileRepository {
  _Profiles([super.user]);

  final languages = <Language>[];
  bool fail = false;

  @override
  Future<void> setLanguage(Language language) async {
    languages.add(language);
    if (fail) throw Exception('rejected');
    await super.setLanguage(language);
  }
}

const _firstRunDone = <String, Object>{
  'first_run.language': 'en',
  'first_run.onboarded': true,
  'first_run.consent_version': kConsentVersion,
  'first_run.consent_at': '2026-09-29T10:15:00.000Z',
};

Future<SharedPreferences> _prefs([Map<String, Object> extra = const {}]) async {
  SharedPreferences.setMockInitialValues({..._firstRunDone, ...extra});
  return SharedPreferences.getInstance();
}

Future<void> flush() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> settle(WidgetTester tester, {int frames = 6}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

void main() {
  setUpAll(FakeFirebaseFirestore.new);

  test('formatPhone groups an Indian number as on the wireframe', () {
    expect(formatPhone('+919876543210'), '+91 98765 43210');
    expect(formatPhone('+14155550100'), '+14155550100');
  });

  group('FirestoreProfileRepository', () {
    test('setLanguage changes only language and updatedAt (the rules allow those)', () async {
      final db = FakeFirebaseFirestore();
      await db.doc('users/u1').set(RoadsideFakes.customer.toJson());
      final before = (await db.doc('users/u1').get()).data()!;
      final repo = FirestoreProfileRepository(RoadsideRefs(db), 'u1');
      await repo.setLanguage(Language.gu);
      final after = (await db.doc('users/u1').get()).data()!;
      final changed = {
        for (final k in {...before.keys, ...after.keys})
          if (before[k].toString() != after[k].toString()) k,
      };
      expect(changed, {'language', 'updatedAt'});
      expect(after['language'], 'gu');
      expect(after['updatedAt'], isA<Timestamp>());
      expect((await repo.watch().first)?.language, Language.gu);
    });

    test('no users doc yet: watch gives null', () async {
      final repo = FirestoreProfileRepository(RoadsideRefs(FakeFirebaseFirestore()), 'u1');
      expect(await repo.watch().first, isNull);
    });
  });

  group('settings', () {
    late _Profiles profiles;

    Future<ProviderContainer> container([Map<String, Object> saved = const {}]) async {
      final prefs = await _prefs(saved);
      final c = createAppContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          profileRepositoryProvider.overrideWithValue(profiles),
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => RoadsideFakes.now),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    setUp(() => profiles = _Profiles(RoadsideFakes.customer));

    test('defaults: Auto and the chime on', () async {
      final c = await container();
      expect(c.read(settingsProvider).displayMode, isNull);
      expect(c.read(settingsProvider).arrivalChime, isTrue);
      expect(c.read(ambientControllerProvider).manual, isNull);
    });

    test('the saved display mode is applied before the first frame', () async {
      final c = await container({'settings.display_mode': 'night'});
      expect(c.read(ambientControllerProvider).manual, LaneMode.night);
      expect(c.read(laneModeProvider), LaneMode.night);
    });

    test('an unknown or Saver value falls back to Auto', () async {
      for (final bad in ['saver', 'sepia', '']) {
        final c = await container({'settings.display_mode': bad});
        expect(c.read(settingsProvider).displayMode, isNull, reason: bad);
        expect(c.read(ambientControllerProvider).manual, isNull, reason: bad);
      }
    });

    test('choices are kept and applied; Auto removes the saved value', () async {
      final c = await container();
      final prefs = c.read(sharedPreferencesProvider);
      await c.read(settingsProvider.notifier).setDisplayMode(LaneMode.glare);
      expect(c.read(laneModeProvider), LaneMode.glare);
      expect(prefs.getString('settings.display_mode'), 'glare');
      await c.read(settingsProvider.notifier).setDisplayMode(null);
      expect(c.read(ambientControllerProvider).manual, isNull);
      expect(prefs.containsKey('settings.display_mode'), isFalse);
      await c.read(settingsProvider.notifier).setArrivalChime(false);
      expect(c.read(settingsProvider).arrivalChime, isFalse);
      expect(prefs.getBool('settings.arrival_chime'), isFalse);
      expect(c.read(settingsProvider).displayMode, isNull, reason: 'one setting does not reset the other');
    });

    test('language: switches the app and, when signed in, the account', () async {
      final c = await container();
      c.listen(profileProvider, (_, _) {});
      await flush();
      await c.read(settingsProvider.notifier).setLanguage('hi');
      await flush();
      expect(c.read(firstRunProvider).languageCode, 'hi');
      expect(profiles.languages, [Language.hi]);
      expect(profiles.user?.language, Language.hi);
    });

    test('language: no account yet, only the app changes', () async {
      profiles = _Profiles();
      final c = await container();
      c.listen(profileProvider, (_, _) {});
      await flush();
      await c.read(settingsProvider.notifier).setLanguage('gu');
      expect(c.read(firstRunProvider).languageCode, 'gu');
      expect(profiles.languages, isEmpty);
    });

    test('language: a rejected account write still switches the app', () async {
      profiles.fail = true;
      final c = await container();
      c.listen(profileProvider, (_, _) {});
      await flush();
      await c.read(settingsProvider.notifier).setLanguage('gu');
      await flush();
      expect(c.read(firstRunProvider).languageCode, 'gu');
      expect(profiles.languages, [Language.gu]);
    });
  });

  group('U18 screen', () {
    late _Profiles profiles;
    late InMemoryEmergencyContactsRepository contacts;
    ProviderContainer? live;

    /// Disposes the app's container inside the test, so its ambient timer is gone before
    /// the binding checks for pending timers (tear-downs run after that check).
    void screenTest(String description, Future<void> Function(WidgetTester tester) body) =>
        testWidgets(description, (tester) async {
          await body(tester);
          await tester.pumpWidget(const SizedBox.shrink());
          live?.dispose();
          live = null;
        });

    Future<ProviderContainer> open(
      WidgetTester tester, {
      Map<String, Object> saved = const {},
      String language = 'en',
      Size size = const Size(400, 1000),
      double textScale = 1,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final prefs = await _prefs({...saved, 'first_run.language': language});
      final c = createAppContainer(
        overrides: [
          flavorProvider.overrideWithValue(AppFlavor.dev),
          sharedPreferencesProvider.overrideWithValue(prefs),
          profileRepositoryProvider.overrideWithValue(profiles),
          emergencyContactsRepositoryProvider.overrideWithValue(contacts),
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => RoadsideFakes.now),
        ],
      );
      live = c;
      await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const RoadsideApp()));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      unawaited(c.read(routerProvider).push(AppRoutes.profile));
      await settle(tester);
      expect(find.byType(ProfileScreen), findsOneWidget);
      return c;
    }

    setUp(() {
      profiles = _Profiles(RoadsideFakes.customer);
      contacts = InMemoryEmergencyContactsRepository(const [
        Contact(name: 'Mom', phone: '+919876500021'),
        Contact(name: 'Rahul', phone: '+919876543088'),
      ]);
    });

    screenTest('the account, then every row of the wireframe', (tester) async {
      await open(tester);
      expect(find.text('Profile & settings'), findsOneWidget);
      expect(find.text('Riya Shah'), findsOneWidget);
      expect(find.text('+91 98000 00001'), findsOneWidget);
      for (final row in ['Language', 'Display mode', 'Arrival chime', 'Emergency contacts']) {
        expect(find.text(row), findsOneWidget, reason: row);
      }
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);
      expect(find.text('2 saved'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Open-source licenses'), 100);
      expect(find.text('Privacy & data'), findsOneWidget);
    });

    screenTest('no account yet: no header, settings still there', (tester) async {
      profiles = _Profiles();
      contacts = InMemoryEmergencyContactsRepository();
      await open(tester);
      expect(find.text('Riya Shah'), findsNothing);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('None saved yet'), findsOneWidget);
    });

    screenTest('the account failing to load shows a retry; the settings stay usable', (tester) async {
      profiles.failWatch = Exception('offline');
      await open(tester);
      expect(find.text("Couldn't load your profile. Your settings still work."), findsOneWidget);
      expect(find.text('Arrival chime'), findsOneWidget);
      profiles.failWatch = null;
      await tester.tap(find.text('Try again'));
      await settle(tester);
      expect(find.text('Riya Shah'), findsOneWidget);
    });

    screenTest('display mode: choose Night, then back to Auto', (tester) async {
      final c = await open(tester);
      await tester.tap(find.text('Display mode'));
      await settle(tester);
      for (final option in ['Auto', 'Day', 'Night', 'Glare']) {
        expect(find.text(option), findsWidgets, reason: option);
      }
      expect(find.text('Day or Night by local sunset. Saver when the battery is low.'), findsOneWidget);
      await tester.tap(find.text('Night').last);
      await settle(tester);
      expect(c.read(laneModeProvider), LaneMode.night);
      expect(c.read(sharedPreferencesProvider).getString('settings.display_mode'), 'night');
      expect(find.text('Night'), findsOneWidget, reason: 'the row shows the choice');

      await tester.tap(find.text('Display mode'));
      await settle(tester);
      await tester.tap(find.text('Auto'));
      await settle(tester);
      expect(c.read(ambientControllerProvider).manual, isNull);
      expect(c.read(sharedPreferencesProvider).containsKey('settings.display_mode'), isFalse);
    });

    screenTest('closing the display sheet changes nothing', (tester) async {
      final c = await open(tester, saved: {'settings.display_mode': 'day'});
      expect(find.text('Day'), findsOneWidget);
      await tester.tap(find.text('Display mode'));
      await settle(tester);
      await tester.tapAt(const Offset(200, 20)); // the scrim
      await settle(tester);
      expect(c.read(ambientControllerProvider).manual, LaneMode.day);
      expect(c.read(sharedPreferencesProvider).getString('settings.display_mode'), 'day');
    });

    screenTest('☀ on the map shows as the mode in effect; off again, the saved Night is back', (
      tester,
    ) async {
      final c = await open(tester, saved: {'settings.display_mode': 'night'});
      expect(find.text('Night'), findsOneWidget);
      c.read(ambientControllerProvider.notifier).toggleManualGlare();
      await settle(tester);
      expect(find.text('Glare'), findsOneWidget);
      c.read(ambientControllerProvider.notifier).toggleManualGlare();
      await settle(tester);
      expect(find.text('Night'), findsOneWidget);
      expect(c.read(laneModeProvider), LaneMode.night);
    });

    screenTest('arrival chime switches off and stays off', (tester) async {
      final c = await open(tester);
      expect(tester.widget<LaneSwitch>(find.byType(LaneSwitch)).value, isTrue);
      await tester.tap(find.byType(LaneSwitch));
      await settle(tester);
      expect(tester.widget<LaneSwitch>(find.byType(LaneSwitch)).value, isFalse);
      expect(c.read(sharedPreferencesProvider).getBool('settings.arrival_chime'), isFalse);
    });

    screenTest('language: Hindi switches the screen and the account', (tester) async {
      await open(tester);
      await tester.tap(find.text('Language'));
      await settle(tester);
      await tester.tap(find.text('हिन्दी'));
      await settle(tester);
      expect(find.text('प्रोफ़ाइल और सेटिंग्स'), findsOneWidget);
      expect(find.text('हिन्दी'), findsOneWidget);
      expect(profiles.languages, [Language.hi]);
    });

    screenTest('rows open U17, the privacy notice and the licenses', (tester) async {
      await open(tester);
      await tester.tap(find.text('Emergency contacts'));
      await settle(tester);
      expect(find.byType(EmergencyContactsScreen), findsOneWidget);
      await tester.tap(find.byTooltip(const DefaultMaterialLocalizations().backButtonTooltip));
      await settle(tester);

      await tester.scrollUntilVisible(find.text('Open-source licenses'), 100);
      await tester.tap(find.text('Privacy & data'));
      await settle(tester);
      expect(find.byType(PrivacyNoticeScreen), findsOneWidget);
      await tester.tap(find.byTooltip(const DefaultMaterialLocalizations().backButtonTooltip));
      await settle(tester);

      await tester.tap(find.text('Open-source licenses'));
      await settle(tester);
      expect(find.byType(LicensePage), findsOneWidget);
    });

    for (final language in ['hi', 'gu']) {
      screenTest('fits at 320 px, 200% text, in $language', (tester) async {
        await open(tester, language: language, size: const Size(320, 800), textScale: 2);
        expect(tester.takeException(), isNull);
        final row = find.text(language == 'hi' ? 'डिस्प्ले मोड' : 'ડિસ્પ્લે મોડ');
        await tester.scrollUntilVisible(row, 100);
        await tester.tap(row);
        await settle(tester);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
