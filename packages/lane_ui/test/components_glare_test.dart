// #20: the ☀ Glare button and how it ranks against the automatic modes.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SemanticsNode;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';

class FakeBattery implements LaneBatterySource {
  final _c = StreamController<LaneBatteryStatus>.broadcast();
  void emit(LaneBatteryStatus s) => _c.add(s);

  @override
  Stream<LaneBatteryStatus> watch() => _c.stream;
}

/// 10:30 IST on a clear day in Ahmedabad: Day by default.
DateTime noon() => DateTime.utc(2026, 9, 29, 5);

Future<ProviderContainer> pump(
  WidgetTester tester,
  FakeBattery battery, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        laneBatterySourceProvider.overrideWithValue(battery),
        laneClockProvider.overrideWithValue(noon),
      ],
      child: LaneApp(
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('hi'), Locale('gu')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const Scaffold(body: Center(child: LaneGlareButton())),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(LaneGlareButton)));
}

void main() {
  testWidgets('tap turns Glare on, tap again hands back to the automatic mode', (tester) async {
    final battery = FakeBattery();
    final c = await pump(tester, battery);
    expect(c.read(laneModeProvider), LaneMode.day);
    expect(find.byTooltip('Sunlight mode: high contrast for bright light'), findsOneWidget);

    await tester.tap(find.byType(LaneGlareButton));
    await tester.pumpAndSettle();
    expect(c.read(laneModeProvider), LaneMode.glare);
    expect(find.byTooltip('Turn off sunlight mode'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(LaneGlareButton))).extension<LaneTheme>()!.mode,
      LaneMode.glare,
    );

    await tester.tap(find.byType(LaneGlareButton));
    await tester.pumpAndSettle();
    expect(c.read(laneModeProvider), LaneMode.day);
  });

  testWidgets('off again restores a mode chosen in settings, not Auto', (tester) async {
    final battery = FakeBattery();
    final c = await pump(tester, battery);
    c.read(ambientControllerProvider.notifier).setManual(LaneMode.night);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(LaneGlareButton));
    await tester.pumpAndSettle();
    expect(c.read(laneModeProvider), LaneMode.glare);

    await tester.tap(find.byType(LaneGlareButton));
    await tester.pumpAndSettle();
    expect(c.read(laneModeProvider), LaneMode.night);
    expect(c.read(ambientControllerProvider).manual, LaneMode.night);

    // A settings change while Glare is on wins; the ☀ button then goes to Auto.
    await tester.tap(find.byType(LaneGlareButton));
    await tester.pumpAndSettle();
    c.read(ambientControllerProvider.notifier).setManual(LaneMode.glare);
    await tester.tap(find.byType(LaneGlareButton));
    await tester.pumpAndSettle();
    expect(c.read(ambientControllerProvider).manual, isNull);
  });

  testWidgets('beats Saver: low battery in bright sun still gets a readable screen', (tester) async {
    final battery = FakeBattery();
    final c = await pump(tester, battery);
    battery.emit(const LaneBatteryStatus(level: 9));
    await tester.pumpAndSettle();
    expect(c.read(laneModeProvider), LaneMode.saver);

    await tester.tap(find.byType(LaneGlareButton));
    await tester.pumpAndSettle();
    expect(c.read(laneModeProvider), LaneMode.glare);

    await tester.tap(find.byType(LaneGlareButton));
    await tester.pumpAndSettle();
    expect(c.read(laneModeProvider), LaneMode.saver, reason: 'back to what the battery needs');
  });

  testWidgets('TalkBack hears a toggle with its state', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, FakeBattery());
    SemanticsNode node() => tester.getSemantics(find.byType(LaneGlareButton));
    expect(node().flagsCollection.isToggled.toBoolOrNull(), isFalse);
    await tester.tap(find.byType(LaneGlareButton));
    await tester.pumpAndSettle();
    expect(node().flagsCollection.isToggled.toBoolOrNull(), isTrue);
    handle.dispose();
  });

  testWidgets('Gujarati tooltip', (tester) async {
    await pump(tester, FakeBattery(), locale: const Locale('gu'));
    expect(find.byTooltip('તડકા મોડ: તેજ પ્રકાશ માટે ઊંચો કોન્ટ્રાસ્ટ'), findsOneWidget);
  });
}
