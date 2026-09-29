// #7 part 1: LaneButton, LaneHoldButton, LaneSlideToConfirm (PLAN §6.12, §6.5 ⑤, §6.11).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:lane_ui/specimen.dart';

/// Records haptic calls ("HapticFeedbackType.lightImpact", …).
List<String> recordHaptics(WidgetTester tester) {
  final calls = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
    return null;
  });
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
  return calls;
}

Future<void> pumpIn(
  WidgetTester tester,
  Widget child, {
  LaneMode mode = LaneMode.day,
  Locale locale = const Locale('en'),
  double scale = 1,
  Size size = const Size(360, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: LanePreview(mode: mode, locale: locale, textScale: scale, size: size, child: child),
    ),
  );
  await tester.pump();
}

Widget column(List<Widget> children) => Scaffold(
  body: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
  ),
);

/// Pumps real frames every 16 ms, like a device, so animations start when they should.
Future<void> frames(WidgetTester tester, Duration total) async {
  const frame = Duration(milliseconds: 16);
  for (var t = Duration.zero; t < total; t += frame) {
    await tester.pump(frame);
  }
}

Color labelColor(WidgetTester tester, String text) => tester.widget<Text>(find.text(text)).style!.color!;

void main() {
  group('LaneButton', () {
    testWidgets('tap fires once with the press haptic', (tester) async {
      final haptics = recordHaptics(tester);
      var taps = 0;
      await pumpIn(tester, column([LaneButton.primary(label: 'Go', onPressed: () => taps++)]));
      await tester.tap(find.text('Go'));
      expect(taps, 1);
      expect(haptics, ['HapticFeedbackType.lightImpact']);
    });

    testWidgets('disabled and loading buttons ignore taps', (tester) async {
      var taps = 0;
      await pumpIn(
        tester,
        column([
          const LaneButton.primary(label: 'Off', onPressed: null),
          LaneButton.primary(label: 'Busy', onPressed: () => taps++, loading: true),
        ]),
      );
      await tester.tap(find.text('Off'), warnIfMissed: false);
      await tester.tap(find.text('Busy'), warnIfMissed: false);
      expect(taps, 0);
      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
        reason: 'spinner only inside the button',
      );
      double opacityOf(String label) => tester
          .widget<Opacity>(find.ancestor(of: find.text(label), matching: find.byType(Opacity)).last)
          .opacity;
      expect(opacityOf('Off'), 0.4, reason: 'disabled reads as disabled');
      expect(opacityOf('Busy'), 1, reason: 'loading is not disabled-looking');
      expect(
        tester.getSemantics(find.byType(LaneButton).first),
        matchesSemantics(isButton: true, hasEnabledState: true, label: 'Off'),
      );
    });

    testWidgets('primary is 56 dp, critical 64 dp; secondary pill too', (tester) async {
      await pumpIn(
        tester,
        column([
          LaneButton.primary(label: 'a', onPressed: () {}),
          LaneButton.primary(label: 'b', onPressed: () {}, critical: true),
          LaneButton.secondary(label: 'c', onPressed: () {}),
          LaneButton.ghost(label: 'd', onPressed: () {}),
        ]),
      );
      double h(int i) => tester.getSize(find.byType(LaneButton).at(i)).height;
      expect(h(0), greaterThanOrEqualTo(56));
      expect(h(1), greaterThanOrEqualTo(64));
      expect(h(2), greaterThanOrEqualTo(56));
      expect(h(3), greaterThanOrEqualTo(48));
    });

    testWidgets('Launch face drops 2 dp while pressed and the layout does not move', (tester) async {
      await pumpIn(tester, column([LaneButton.primary(label: 'Press', onPressed: () {})]));
      final before = tester.getTopLeft(find.byType(LaneButton));
      final labelBefore = tester.getTopLeft(find.text('Press'));
      final gesture = await tester.startGesture(tester.getCenter(find.text('Press')));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.byType(LaneButton)), before);
      expect(tester.getTopLeft(find.text('Press')).dy - labelBefore.dy, closeTo(LaneButton.pressDepth, 0.01));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Press')), labelBefore);
    });

    for (final mode in LaneMode.values) {
      testWidgets('labels keep their own colour in ${mode.name} (never inherited ink)', (tester) async {
        await pumpIn(
          tester,
          column([
            LaneButton.primary(label: 'P', onPressed: () {}),
            LaneButton.secondary(label: 's', onPressed: () {}),
            LaneButton.pill(label: 'Pill', onPressed: () {}),
            LaneButton.danger(label: 'D', onPressed: () {}),
          ]),
          mode: mode,
        );
        final lane = LaneTheme.of(mode);
        expect(labelColor(tester, 'P'), LaneBrand.launchText);
        expect(labelColor(tester, 'S'), LaneBrand.quietText, reason: 'secondary label is uppercased');
        expect(labelColor(tester, 'Pill'), LaneBrand.pillText);
        expect(labelColor(tester, 'D'), lane.color.onSignal);
      });
    }

    testWidgets('danger is flat signal.stop, never the amber gradient', (tester) async {
      await pumpIn(tester, column([LaneButton.danger(label: 'Delete', onPressed: () {})]));
      final boxes = tester
          .widgetList<DecoratedBox>(
            find.descendant(of: find.byType(LaneButton), matching: find.byType(DecoratedBox)),
          )
          .map((b) => b.decoration)
          .whereType<BoxDecoration>();
      expect(boxes.any((d) => d.color == LaneColors.day.signal.stop), isTrue);
      expect(boxes.any((d) => d.gradient != null), isFalse);
    });

    testWidgets('secondary loading beam spins, and stays still with reduced motion', (tester) async {
      await pumpIn(tester, column([LaneButton.secondary(label: 'Call', onPressed: () {}, loading: true)]));
      expect(tester.hasRunningAnimations, isTrue);

      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        disableAnimations: true,
      );
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await pumpIn(tester, column([LaneButton.secondary(label: 'Call', onPressed: () {}, loading: true)]));
      await tester.pump(LaneButton.beamPeriod);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('long labels wrap instead of clipping at 320 px and 200% in Hindi', (tester) async {
      await pumpIn(
        tester,
        const LaneButtonsSample(label: 'निकटतम मैकेनिक से तुरंत मदद लें'),
        locale: const Locale('hi'),
        scale: 2,
        size: const Size(320, 1400),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    });
  });

  group('LaneHoldButton', () {
    testWidgets('fires once after a full 1.5 s hold, with the double heavy haptic', (tester) async {
      final haptics = recordHaptics(tester);
      var fired = 0;
      await pumpIn(
        tester,
        Center(
          child: LaneHoldButton(label: 'SOS', semanticsHint: 'hold', onConfirmed: () => fired++),
        ),
      );
      final g = await tester.startGesture(tester.getCenter(find.byType(LaneHoldButton)));
      await frames(tester, LaneHoldButton.holdDuration - const Duration(milliseconds: 100));
      expect(fired, 0);
      await frames(tester, const Duration(milliseconds: 300));
      await tester.pump(LaneHaptics.alertGap);
      expect(fired, 1);
      expect(haptics.where((h) => h == 'HapticFeedbackType.heavyImpact').length, 2);
      await g.up();
      await tester.pumpAndSettle();
      expect(fired, 1, reason: 'releasing after firing does not fire again');
    });

    testWidgets('letting go early cancels with no side effect', (tester) async {
      var fired = 0;
      await pumpIn(
        tester,
        Center(
          child: LaneHoldButton(label: 'SOS', semanticsHint: 'hold', onConfirmed: () => fired++),
        ),
      );
      final g = await tester.startGesture(tester.getCenter(find.byType(LaneHoldButton)));
      await frames(tester, const Duration(milliseconds: 1000));
      await g.up();
      await tester.pumpAndSettle();
      await frames(tester, LaneHoldButton.holdDuration);
      expect(fired, 0);
    });

    testWidgets('screen readers confirm with the long-press action and hear the hint', (tester) async {
      var fired = 0;
      await pumpIn(
        tester,
        Center(
          child: LaneHoldButton(label: 'SOS', semanticsHint: 'Hold to send SOS', onConfirmed: () => fired++),
        ),
      );
      final node = tester.getSemantics(find.byType(LaneHoldButton));
      expect(node.label, 'SOS');
      expect(node.hint, 'Hold to send SOS');
      tester.semantics.longPress(find.semantics.byLabel('SOS'));
      expect(fired, 1);
    });
  });

  group('LaneSlideToConfirm', () {
    Future<void> slide(WidgetTester tester, double fraction) async {
      final box = tester.getRect(find.byType(LaneSlideToConfirm));
      final start = Offset(box.left + 32, box.center.dy);
      await tester.dragFrom(start, Offset((box.width - 64) * fraction, 0));
      await tester.pumpAndSettle();
    }

    testWidgets('sliding past the threshold confirms once', (tester) async {
      var confirmed = 0;
      await pumpIn(
        tester,
        column([LaneSlideToConfirm(label: 'Slide to accept', onConfirmed: () => confirmed++)]),
      );
      await slide(tester, 0.95);
      await tester.pump(LaneHaptics.alertGap);
      expect(confirmed, 1);
      await slide(tester, 0.95);
      expect(confirmed, 1, reason: 'stays confirmed');
    });

    testWidgets('a short slide springs back without confirming', (tester) async {
      var confirmed = 0;
      await pumpIn(
        tester,
        column([LaneSlideToConfirm(label: 'Slide to accept', onConfirmed: () => confirmed++)]),
      );
      final thumbStart = tester.getTopLeft(find.byIcon(Icons.keyboard_double_arrow_right_rounded));
      await slide(tester, 0.5);
      expect(confirmed, 0);
      expect(tester.getTopLeft(find.byIcon(Icons.keyboard_double_arrow_right_rounded)), thumbStart);
    });

    testWidgets('is 64 dp tall and a screen-reader tap confirms', (tester) async {
      var confirmed = 0;
      await pumpIn(tester, column([LaneSlideToConfirm(label: 'Finish job', onConfirmed: () => confirmed++)]));
      expect(tester.getSize(find.byType(LaneSlideToConfirm)).height, 64);
      tester.semantics.tap(find.semantics.byLabel('Finish job'));
      await tester.pump(LaneHaptics.alertGap);
      expect(confirmed, 1);
    });

    testWidgets('disabled slider ignores drags', (tester) async {
      await pumpIn(tester, column([const LaneSlideToConfirm(label: 'Off', onConfirmed: null)]));
      final thumbStart = tester.getTopLeft(find.byIcon(Icons.keyboard_double_arrow_right_rounded));
      await slide(tester, 0.95);
      expect(tester.getTopLeft(find.byIcon(Icons.keyboard_double_arrow_right_rounded)), thumbStart);
    });
  });
}
