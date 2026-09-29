import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';

/// A battery the test drives by hand.
class FakeBattery implements LaneBatterySource {
  final _out = StreamController<LaneBatteryStatus>.broadcast();

  void emit(LaneBatteryStatus s) => _out.add(s);

  @override
  Stream<LaneBatteryStatus> watch() => _out.stream;
}

const ist = Duration(hours: 5, minutes: 30);
DateTime istAt(int h, int m) => DateTime.utc(2026, 9, 29, h, m).subtract(ist);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('resolveLaneMode priority: manual > Saver > Glare > Night > Day', () {
    const low = LaneBatteryStatus(level: 15);
    const ok = LaneBatteryStatus(level: 16);
    const saverOn = LaneBatteryStatus(level: 80, powerSave: true);

    test('defaults to Day', () => expect(resolveLaneMode(), LaneMode.day));

    test('Night from sunset or from system dark mode', () {
      expect(resolveLaneMode(night: true), LaneMode.night);
      expect(resolveLaneMode(systemDark: true), LaneMode.night);
    });

    test('Glare beats Night', () {
      expect(resolveLaneMode(glare: true, night: true, systemDark: true), LaneMode.glare);
    });

    test('Saver at 15% or below, or with system battery saver; it beats Glare', () {
      expect(resolveLaneMode(battery: low), LaneMode.saver);
      expect(resolveLaneMode(battery: ok), LaneMode.day);
      expect(resolveLaneMode(battery: saverOn), LaneMode.saver);
      expect(resolveLaneMode(battery: low, glare: true, night: true), LaneMode.saver);
    });

    test('unknown battery never triggers Saver', () {
      expect(resolveLaneMode(battery: LaneBatteryStatus.unknown), LaneMode.day);
    });

    test("the user's manual choice beats everything", () {
      for (final m in LaneMode.values) {
        expect(resolveLaneMode(manual: m, battery: low, glare: true, night: true), m);
      }
    });
  });

  group('AmbientController', () {
    late FakeBattery battery;
    late DateTime now;
    late ProviderContainer container;

    setUp(() {
      battery = FakeBattery();
      now = istAt(12, 0);
      container = ProviderContainer(
        overrides: [
          laneBatterySourceProvider.overrideWithValue(battery),
          laneClockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);
    });

    LaneMode mode() => container.read(laneModeProvider);
    AmbientController ctrl() => container.read(ambientControllerProvider.notifier);

    test('is Day at noon and Night after sunset (fallback position: Ahmedabad)', () {
      expect(mode(), LaneMode.day);
      now = istAt(19, 0);
      ctrl().updatePosition(23.0225, 72.5714);
      expect(mode(), LaneMode.night);
    });

    test('follows the battery stream into and out of Saver', () async {
      container.listen(laneModeProvider, (_, _) {});
      battery.emit(const LaneBatteryStatus(level: 12));
      await Future<void>.delayed(Duration.zero);
      expect(mode(), LaneMode.saver);
      battery.emit(const LaneBatteryStatus(level: 40));
      await Future<void>.delayed(Duration.zero);
      expect(mode(), LaneMode.day);
    });

    test('Glare toggles; manual override wins and can be cleared', () {
      ctrl().toggleGlare();
      expect(mode(), LaneMode.glare);
      ctrl().setManual(LaneMode.night);
      expect(mode(), LaneMode.night);
      ctrl().setManual(null);
      expect(mode(), LaneMode.glare);
      ctrl().toggleGlare();
      expect(mode(), LaneMode.day);
    });
  });

  // Widget tests run in a fake-async zone, so the controller's periodic timer can be driven
  // with tester.pump. Containers are disposed inside the test so no timer is left pending.
  group('AmbientController timers', () {
    ProviderContainer containerAt(DateTime Function() clock) => ProviderContainer(
      overrides: [
        laneBatterySourceProvider.overrideWithValue(FakeBattery()),
        laneClockProvider.overrideWithValue(clock),
      ],
    );

    testWidgets('re-checks the clock every tick, so Night starts on time', (tester) async {
      var now = istAt(18, 20); // ~9 min before sunset in Ahmedabad
      final container = containerAt(() => now);
      expect(container.read(laneModeProvider), LaneMode.day);

      now = istAt(18, 40);
      await tester.pump(ambientTick);
      expect(container.read(laneModeProvider), LaneMode.night);
      container.dispose();
    });

    testWidgets('system dark mode switches to Night and back', (tester) async {
      final container = containerAt(() => istAt(12, 0));
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      expect(container.read(laneModeProvider), LaneMode.day);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pump();
      expect(container.read(laneModeProvider), LaneMode.night);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pump();
      expect(container.read(laneModeProvider), LaneMode.day);
      container.dispose();
    });
  });
}
