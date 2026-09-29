import 'dart:convert';
import 'dart:io';

import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/env.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

Widget app(AppFlavor flavor) => ProviderScope(
  overrides: [
    flavorProvider.overrideWithValue(flavor),
    laneBatterySourceProvider.overrideWithValue(_NoBattery()),
    laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 29, 6, 30)),
  ],
  child: const RoadsideApp(),
);

void main() {
  for (final flavor in AppFlavor.values) {
    testWidgets('boots into LaneApp on the home route (${flavor.name})', (tester) async {
      await tester.pumpWidget(app(flavor));
      await tester.pumpAndSettle();
      expect(find.byType(LaneApp), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Help on the road, in minutes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('follows the phone language: Hindi and Gujarati', (tester) async {
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.platformDispatcher.localesTestValue = [const Locale('hi', 'IN')];
    await tester.pumpWidget(app(AppFlavor.dev));
    await tester.pumpAndSettle();
    expect(find.text('सड़क पर मदद, मिनटों में'), findsOneWidget);
    final lane = tester.element(find.byType(HomeScreen)).lane;
    expect(lane.script, LaneScript.devanagari);

    tester.platformDispatcher.localesTestValue = [const Locale('gu', 'IN')];
    await tester.pumpAndSettle();
    expect(find.text('રસ્તા પર મદદ, મિનિટોમાં'), findsOneWidget);
  });

  testWidgets('fits at 320 px and 200% text in Hindi', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.platformDispatcher.localesTestValue = [const Locale('hi')];
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(app(AppFlavor.dev));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('every ARB key exists in en, hi and gu (until tool/check_strings.dart lands)', () {
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
