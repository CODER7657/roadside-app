import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:lane_ui_example/main.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

void main() {
  testWidgets('switches modes and languages', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 29, 6, 30)), // noon IST
        ],
        child: const SpecimenApp(),
      ),
    );
    expect(find.text('LANE DAY'), findsOneWidget);

    for (final mode in ['night', 'glare', 'saver', 'day']) {
      await tester.tap(find.widgetWithText(ChoiceChip, mode));
      await tester.pumpAndSettle();
      expect(find.text('LANE ${mode.toUpperCase()}'), findsOneWidget);
    }

    await tester.tap(find.widgetWithText(ChoiceChip, 'हिन्दी'));
    await tester.pumpAndSettle();
    expect(find.text('सड़क पर मदद, मिनटों में'), findsWidgets);

    await tester.tap(find.widgetWithText(ChoiceChip, 'ગુજરાતી'));
    await tester.pumpAndSettle();
    expect(find.text('રસ્તા પર મદદ, મિનિટોમાં'), findsWidgets);
  });

  testWidgets('opens every template sample and comes back', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 29, 6, 30)),
        ],
        child: const SpecimenApp(),
      ),
    );
    for (final t in ['Map', 'Flow', 'Status', 'List', 'Form']) {
      await tester.tap(find.widgetWithText(ChoiceChip, t));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: t);
      expect(find.text('LANE DAY'), findsNothing, reason: '$t is on screen');
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pop();
      await tester.pumpAndSettle();
      expect(find.text('LANE DAY'), findsOneWidget);
    }
  });
}
