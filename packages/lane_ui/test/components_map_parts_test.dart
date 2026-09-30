// #107: CenterPin and AccuracyBadge. #108: PriceRange.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:lane_ui/specimen.dart';

Future<void> pumpIn(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  LaneMode mode = LaneMode.day,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: LanePreview(mode: mode, locale: locale, child: child),
    ),
  );
  await tester.pump();
}

LaneSignal signalOf(WidgetTester tester) => tester.widget<SignalBadge>(find.byType(SignalBadge)).signal;

void main() {
  group('AccuracyBadge', () {
    for (final (meters, signal, label) in [
      (4.4, LaneSignal.go, '±4 m'),
      (20.0, LaneSignal.go, '±20 m'),
      (20.4, LaneSignal.wait, '±20 m'),
      (50.0, LaneSignal.wait, '±50 m'),
      (51.0, LaneSignal.neutral, '±51 m · Adjust pin'),
    ]) {
      testWidgets('$meters m → $signal "$label"', (tester) async {
        await pumpIn(tester, Scaffold(body: AccuracyBadge(meters: meters)));
        expect(signalOf(tester), signal);
        expect(find.text(label), findsOneWidget);
      });
    }

    testWidgets('locating before the first fix', (tester) async {
      await pumpIn(tester, const Scaffold(body: AccuracyBadge(meters: null)));
      expect(find.text('Finding your location'), findsOneWidget);
      expect(signalOf(tester), LaneSignal.wait);
    });

    testWidgets('reads the accuracy in words, in Gujarati too', (tester) async {
      await pumpIn(tester, const Scaffold(body: AccuracyBadge(meters: 12)));
      expect(find.bySemanticsLabel('Location accurate to 12 metres'), findsOneWidget);
      await pumpIn(tester, const Scaffold(body: AccuracyBadge(meters: 12)), locale: const Locale('gu'));
      expect(find.bySemanticsLabel('લોકેશન 12 મીટર સુધી ચોક્કસ'), findsOneWidget);
    });
  });

  group('CenterPin', () {
    testWidgets('its tip is on the centre line; lifting raises it', (tester) async {
      await pumpIn(tester, const Scaffold(body: Center(child: CenterPin())));
      final box = tester.getRect(find.byType(CenterPin));
      final pin = find.descendant(of: find.byType(CenterPin), matching: find.byType(CustomPaint));
      expect(tester.getRect(pin).bottom, closeTo(box.center.dy, 0.5));

      await pumpIn(tester, const Scaffold(body: Center(child: CenterPin(lifted: true))));
      await tester.pumpAndSettle();
      expect(tester.getRect(pin).bottom, lessThan(box.center.dy - 8));
    });

    testWidgets('lifts instantly with reduced motion', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(body: Center(child: CenterPin())),
        mode: LaneMode.saver,
      );
      await pumpIn(
        tester,
        const Scaffold(body: Center(child: CenterPin(lifted: true))),
        mode: LaneMode.saver,
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('is hidden from screen readers and lets drags through to the map', (tester) async {
      var dragged = false;
      await pumpIn(
        tester,
        Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: GestureDetector(onPanUpdate: (_) => dragged = true)),
              const Center(child: CenterPin()),
            ],
          ),
        ),
      );
      await tester.drag(find.byType(CenterPin), const Offset(0, 40));
      expect(dragged, isTrue);
      final semantics = tester.getSemantics(find.byType(CenterPin));
      expect(semantics.label, isEmpty);
    });
  });

  group('PriceRange', () {
    test('Indian digit grouping', () {
      expect(PriceRange.rupees(350), '₹350');
      expect(PriceRange.rupees(1250), '₹1,250');
      expect(PriceRange.rupees(125000), '₹1,25,000');
    });

    testWidgets('a range in mono, read as "min to max", with what is included', (tester) async {
      await pumpIn(tester, const Scaffold(body: PriceRange(min: 350, max: 600, includes: 'Puncture repair')));
      expect(find.text('₹350–₹600'), findsOneWidget);
      expect(find.text('Puncture repair'), findsOneWidget);
      expect(find.bySemanticsLabel('₹350 to ₹600'), findsOneWidget);
      final style = tester.widget<Text>(find.text('₹350–₹600')).style!;
      expect(style.fontFamily, contains('JetBrains'));
    });

    testWidgets('one amount when min equals max; Hindi reading', (tester) async {
      await pumpIn(tester, const Scaffold(body: PriceRange(min: 500, max: 500)));
      expect(find.text('₹500'), findsOneWidget);
      await pumpIn(tester, const Scaffold(body: PriceRange(min: 350, max: 600)), locale: const Locale('hi'));
      expect(find.bySemanticsLabel('₹350 से ₹600'), findsOneWidget);
    });

    testWidgets('scales down instead of truncating at 200% on a narrow screen', (tester) async {
      tester.view.physicalSize = const Size(200, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(
          home: LanePreview(
            mode: LaneMode.day,
            textScale: 2,
            size: Size(200, 400),
            child: Scaffold(body: PriceRange(min: 125000, max: 250000)),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('₹1,25,000–₹2,50,000'), findsOneWidget);
    });
  });

  testWidgets('sample renders in every mode', (tester) async {
    for (final mode in LaneMode.values) {
      await pumpIn(tester, const LaneMapPartsSample(), mode: mode);
      expect(tester.takeException(), isNull, reason: '$mode');
    }
  });
}
