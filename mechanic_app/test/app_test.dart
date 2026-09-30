import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:mechanic_app/app/app.dart';
import 'package:mechanic_app/app/env.dart';
import 'package:mechanic_app/app/flavor.dart';
import 'package:mechanic_app/features/first_run/application/first_run.dart';
import 'package:mechanic_app/features/home/presentation/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mechanic_app/features/registration/application/registration.dart';

import 'support.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

late SharedPreferences prefs;

/// First run already done, so the app opens on home.
Future<void> finishedFirstRun() async {
  SharedPreferences.setMockInitialValues({
    'first_run.language': 'en',
    'first_run.onboarded': true,
    'first_run.consent_version': kConsentVersion,
    'first_run.consent_at': '2026-09-29T10:15:00.000Z',
  });
  prefs = await SharedPreferences.getInstance();
}

Widget app(AppFlavor flavor) => ProviderScope(
  overrides: [
    flavorProvider.overrideWithValue(flavor),
    sharedPreferencesProvider.overrideWithValue(prefs),
    registrationRepositoryProvider.overrideWithValue(approvedMechanic()),
    laneBatterySourceProvider.overrideWithValue(_NoBattery()),
    laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 29, 6, 30)),
  ],
  child: const MechanicApp(),
);

/// Lets the splash's short delay pass, then settles on the next screen.
Future<void> pastSplash(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  setUp(finishedFirstRun);

  for (final flavor in AppFlavor.values) {
    testWidgets('boots into LaneApp and reaches home (${flavor.name})', (tester) async {
      await tester.pumpWidget(app(flavor));
      await pastSplash(tester);
      expect(find.byType(LaneApp), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text("Jobs near you, when you're ready"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('home fits at 320 px and 200% text in Hindi', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await prefs.setString('first_run.language', 'hi');
    await tester.pumpWidget(app(AppFlavor.dev));
    await pastSplash(tester);
    expect(find.text('आपके पास के काम, जब आप तैयार हों'), findsOneWidget);
    expect(tester.element(find.byType(HomeScreen)).lane.script, LaneScript.devanagari);
    expect(tester.takeException(), isNull);
  });

  test('every ARB key exists in en, hi and gu', () {
    Set<String> keys(String code) =>
        (jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync()) as Map<String, dynamic>).keys
            .where((k) => !k.startsWith('@'))
            .toSet();
    final en = keys('en');
    expect(keys('hi'), en);
    expect(keys('gu'), en);
    expect(
      en.every(RegExp(r'^[a-z]+(_[a-z0-9]+)+$').hasMatch),
      isTrue,
      reason: 'keys are screen_element_purpose',
    );
  });

  test('no maps key is baked into test or CI builds', () {
    expect(AppEnv.hasMapsKey, isFalse);
    final example = jsonDecode(File('env/example.json').readAsStringSync()) as Map<String, dynamic>;
    expect(example.keys, contains('OLA_MAPS_API_KEY'));
    expect(example['OLA_MAPS_API_KEY'], isEmpty);
  });
}
