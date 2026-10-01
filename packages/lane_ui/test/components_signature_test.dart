// #15: JourneyRail, TrustPass, LaneOtpDisplay / LaneOtpInput, LaneRollingNumber,
// BreathingPulse and CountdownRing.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:lane_ui/specimen.dart';
import 'package:lane_ui/src/l10n/lane_localizations.dart' show lookupLaneLocalizations;

class _FakeBrightness implements LaneBrightness {
  final calls = <String>[];

  @override
  Future<void> setMax() async => calls.add('max');

  @override
  Future<void> reset() async => calls.add('reset');
}

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

List<JourneyStop> stops() => [
  for (final (i, label) in LaneSignatureSample.defaultStops.indexed)
    JourneyStop(label: label, signal: LaneSignatureSample.signals[i]),
];

/// Reduced motion: the Saver mode sets `motion.enabled` false.
Widget rail(int current, {bool ended = false, Axis direction = Axis.horizontal}) => Scaffold(
  body: Padding(
    padding: const EdgeInsets.all(16),
    child: JourneyRail(stops: stops(), current: current, ended: ended, direction: direction),
  ),
);

void main() {
  test('en, hi and gu have every new key', () {
    for (final code in ['en', 'hi', 'gu']) {
      final s = lookupLaneLocalizations(Locale(code));
      expect([
        s.journey_rail_step(1, 6, 'x'),
        s.journey_rail_cancelled('x'),
        s.trust_verified,
        s.trust_verified_workshop,
        s.trust_verified_independent(3),
        s.trust_jobs(4),
        s.trust_start_code,
        s.trust_start_code_hint,
        s.otp_show_big,
        s.otp_close,
        s.otp_input_label,
        s.countdown_seconds_left(5),
      ], everyElement(isNotEmpty));
    }
  });

  group('JourneyRail', () {
    testWidgets('reads the current step', (tester) async {
      await pumpIn(tester, rail(2));
      expect(find.bySemanticsLabel('Step 3 of 6: On the way'), findsOneWidget);
    });

    testWidgets('reads the ended state', (tester) async {
      await pumpIn(tester, rail(1, ended: true));
      expect(find.bySemanticsLabel('Ended: Accepted'), findsOneWidget);
    });

    testWidgets('in Hindi', (tester) async {
      await pumpIn(tester, rail(0), locale: const Locale('hi'));
      expect(find.bySemanticsLabel('6 में से चरण 1: Requested'), findsOneWidget);
    });

    testWidgets('advancing flows over motion.calm with a haptic, then settles', (tester) async {
      final haptics = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') haptics.add('${call.arguments}');
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await pumpIn(tester, rail(1));
      await pumpIn(tester, rail(2));
      expect(haptics, isNotEmpty);
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.bySemanticsLabel('Step 3 of 6: On the way'), findsOneWidget);
    });

    testWidgets('going back (reset) or ending does not animate or buzz', (tester) async {
      final haptics = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') haptics.add('${call.arguments}');
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await pumpIn(tester, rail(3));
      await pumpIn(tester, rail(1));
      await pumpIn(tester, rail(4, ended: true));
      expect(haptics, isEmpty);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('reduced motion jumps straight to the new stop', (tester) async {
      await pumpIn(tester, rail(1), mode: LaneMode.saver);
      await pumpIn(tester, rail(2), mode: LaneMode.saver);
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('vertical shows every label and time', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(
          body: JourneyRail(
            stops: [
              JourneyStop(label: 'Requested', signal: LaneSignal.wait, time: '10:40'),
              JourneyStop(label: 'Accepted', signal: LaneSignal.route, time: '10:41'),
              JourneyStop(label: 'Done', signal: LaneSignal.go),
            ],
            current: 1,
            direction: Axis.vertical,
          ),
        ),
      );
      // The labels are drawn but the rail reads as one line.
      expect(find.text('Requested', skipOffstage: false), findsOneWidget);
      expect(find.text('10:41'), findsOneWidget);
      expect(find.bySemanticsLabel('Step 2 of 3: Accepted'), findsOneWidget);
    });

    testWidgets('vertical at 200% text: the last label is not cut to 24 dp', (tester) async {
      await pumpIn(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
              child: const JourneyRail(
                stops: [
                  JourneyStop(label: 'Requested', signal: LaneSignal.wait, time: '10:40'),
                  JourneyStop(label: 'Done', signal: LaneSignal.go, time: '10:51'),
                ],
                current: 1,
                direction: Axis.vertical,
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final done = tester.renderObject<RenderParagraph>(find.text('Done'));
      expect(done.size.height, greaterThan(24));
    });

    testWidgets('a single stop still paints', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(
          body: JourneyRail(
            stops: [JourneyStop(label: 'Only', signal: LaneSignal.go)],
            current: 0,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('TrustPass', () {
    testWidgets('workshop: shop name, verified workshop badge, rating, code and hint', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(
          body: SingleChildScrollView(
            child: TrustPass.workshop(
              name: 'Ramesh Patel',
              shopName: 'Shree Auto Garage',
              rating: 4.84,
              jobs: 126,
              vehicleTypes: ['bike', 'car'],
              startCode: '4827',
            ),
          ),
        ),
      );
      expect(find.text('Ramesh Patel'), findsOneWidget);
      expect(find.text('Shree Auto Garage'), findsOneWidget);
      expect(find.bySemanticsLabel('Verified workshop'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('126 jobs'), findsOneWidget);
      expect(find.text('START CODE'), findsOneWidget);
      expect(find.bySemanticsLabel('4 8 2 7'), findsOneWidget);
      expect(find.text('Share this code only when the mechanic is standing with you.'), findsOneWidget);
      expect(find.byType(PlateChip), findsNothing);
    });

    testWidgets('independent: years line and travel plate, no shop', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(
          body: TrustPass.independent(name: 'Suresh', years: 6, travelRegNo: 'gj01ab1234'),
        ),
      );
      expect(find.text('Verified independent mechanic · 6 yrs'), findsOneWidget);
      expect(find.bySemanticsLabel('Verified'), findsOneWidget);
      expect(find.byType(PlateChip), findsOneWidget);
      // New mechanic: no rating, no code.
      expect(find.textContaining('jobs'), findsNothing);
      expect(find.byType(LaneOtpDisplay), findsNothing);
    });

    testWidgets('unverified never claims to be verified', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(
          body: TrustPass.independent(name: 'Suresh', years: 6, travelRegNo: 'GJ01AB1234', verified: false),
        ),
      );
      expect(find.textContaining('Verified'), findsNothing);
      expect(find.byType(SignalBadge), findsNothing);
    });

    testWidgets('Gujarati at 200% text does not overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(
          home: LanePreview(
            mode: LaneMode.day,
            locale: Locale('gu'),
            textScale: 2,
            child: Scaffold(
              body: SingleChildScrollView(
                child: TrustPass.independent(
                  name: 'રમેશભાઈ પટેલ',
                  years: 12,
                  travelRegNo: 'GJ01AB1234',
                  rating: 4.5,
                  jobs: 1200,
                  vehicleTypes: ['bike', 'scooter', 'car', 'ev'],
                  startCode: '4827',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('LaneOtpDisplay', () {
    late _FakeBrightness brightness;
    setUp(() {
      brightness = _FakeBrightness();
      LaneOtpDisplay.brightness = brightness;
    });

    testWidgets('56 sp mono, digits 16 dp apart', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(
          body: Center(child: LaneOtpDisplay(code: '4827')),
        ),
      );
      final digit = tester.widget<Text>(find.text('4'));
      expect(digit.style!.fontSize, 56);
      expect(digit.style!.fontFamily, contains('JetBrains'));
      final gap = tester.getTopLeft(find.text('8')).dx - tester.getTopRight(find.text('4')).dx;
      expect(gap, closeTo(16, 0.5));
    });

    testWidgets('tap opens it full screen at max brightness; closing resets', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(
          body: Center(child: LaneOtpDisplay(code: '4827')),
        ),
      );
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();
      expect(brightness.calls, ['max']);
      expect(find.text('Close'), findsOneWidget);
      // The full-screen digits are bigger than the inline ones.
      expect(
        tester.getRect(find.text('4').last).height,
        greaterThan(tester.getRect(find.text('4', skipOffstage: false).first).height),
      );

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(brightness.calls, ['max', 'reset']);
      expect(find.text('Close'), findsNothing);
    });

    testWidgets('tapping anywhere on the full-screen code closes it', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(
          body: Center(child: LaneOtpDisplay(code: '4827')),
        ),
      );
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(180, 100));
      await tester.pumpAndSettle();
      expect(find.text('Close'), findsNothing);
      expect(brightness.calls.last, 'reset');
    });

    testWidgets('screen readers hear spaced digits and a hint', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpIn(
        tester,
        const Scaffold(
          body: Center(child: LaneOtpDisplay(code: '4827')),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('4 8 2 7')),
        matchesSemantics(label: '4 8 2 7', hint: 'Show large', isButton: true, hasTapAction: true),
      );
      handle.dispose();
    });

    testWidgets('inside a card in a list, the code is its own node; the card is not a button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpIn(
        tester,
        Scaffold(
          body: ListView(
            children: const [
              TrustPass.independent(name: 'Kiran', years: 6, travelRegNo: 'GJ01AB1234', startCode: '4821'),
            ],
          ),
        ),
      );
      final code = tester.getSemantics(find.byType(LaneOtpDisplay));
      expect(code.label, '4 8 2 1');
      expect(code.hint, 'Show large');
      final card = tester.getSemantics(find.text('Kiran'));
      expect(card.label, isNot(contains('4 8 2 1')));
      expect(card.flagsCollection.isButton, isFalse);
      handle.dispose();
    });

    testWidgets('fullscreenOnTap: false is just the digits', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(
          body: Center(child: LaneOtpDisplay(code: '4827', fullscreenOnTap: false)),
        ),
      );
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();
      expect(brightness.calls, isEmpty);
    });
  });

  group('LaneOtpInput', () {
    testWidgets('typing fills the boxes and completes once', (tester) async {
      final changes = <String>[];
      final done = <String>[];
      await pumpIn(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: LaneOtpInput(onChanged: changes.add, onCompleted: done.add),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '48');
      await tester.pump();
      expect(find.text('4'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(done, isEmpty);
      await tester.enterText(find.byType(TextField), '4827');
      await tester.pump();
      expect(done, ['4827']);
      expect(changes.last, '4827');
    });

    testWidgets('pasting keeps only digits and cuts to length', (tester) async {
      final done = <String>[];
      await pumpIn(tester, Scaffold(body: LaneOtpInput(length: 6, onCompleted: done.add)));
      await tester.enterText(find.byType(TextField), 'OTP: 123-456 789');
      await tester.pump();
      expect(done, ['123456']);
    });

    testWidgets('asks for SMS one-time-code autofill and a number pad', (tester) async {
      await pumpIn(tester, const Scaffold(body: LaneOtpInput()));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.autofillHints, [AutofillHints.oneTimeCode]);
      expect(field.keyboardType, TextInputType.number);
    });

    testWidgets('error text is shown and announced', (tester) async {
      await pumpIn(tester, const Scaffold(body: LaneOtpInput(errorText: 'Wrong code')));
      expect(find.text('Wrong code'), findsOneWidget);
      final region = tester.widget<Semantics>(
        find.ancestor(of: find.text('Wrong code'), matching: find.byType(Semantics)).first,
      );
      expect(region.properties.liveRegion, isTrue);
    });
  });

  group('LaneRollingNumber', () {
    testWidgets('rolls the changed digits and reads the whole value', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(
          body: Center(child: LaneRollingNumber(value: '7 min')),
        ),
      );
      expect(find.bySemanticsLabel('7 min'), findsOneWidget);
      await pumpIn(
        tester,
        const Scaffold(
          body: Center(child: LaneRollingNumber(value: '6 min')),
        ),
      );
      // Old and new digit both on screen mid-roll.
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('7'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('7'), findsNothing);
      expect(find.bySemanticsLabel('6 min'), findsOneWidget);
    });

    testWidgets('reduced motion swaps at once', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(body: LaneRollingNumber(value: '7')),
        mode: LaneMode.saver,
      );
      await pumpIn(
        tester,
        const Scaffold(body: LaneRollingNumber(value: '6')),
        mode: LaneMode.saver,
      );
      await tester.pump();
      expect(find.text('7'), findsNothing);
    });
  });

  group('BreathingPulse', () {
    testWidgets('breathes on a 10 s cycle', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(
          body: Center(child: BreathingPulse(child: SizedBox.square(dimension: 8))),
        ),
      );
      Transform ring() => tester.widget<Transform>(
        find.descendant(of: find.byType(BreathingPulse), matching: find.byType(Transform)).first,
      );
      final start = ring().transform.entry(0, 0);
      await tester.pump(const Duration(seconds: 5));
      final out = ring().transform.entry(0, 0);
      await tester.pump(const Duration(seconds: 5));
      final back = ring().transform.entry(0, 0);
      expect(out, greaterThan(start + 0.2));
      expect(back, closeTo(start, 0.01));
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('holds still with reduced motion', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(
          body: Center(child: BreathingPulse(child: SizedBox.square(dimension: 8))),
        ),
        mode: LaneMode.saver,
      );
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('CountdownRing', () {
    testWidgets('counts down 30 s, announces seconds left and expires once', (tester) async {
      var expired = 0;
      await pumpIn(
        tester,
        Scaffold(
          body: Center(
            child: CountdownRing(onExpired: () => expired++, child: const SizedBox(width: 200, height: 56)),
          ),
        ),
      );
      expect(find.bySemanticsLabel('30 seconds left'), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
      expect(find.bySemanticsLabel('20 seconds left'), findsOneWidget);
      await tester.pump(const Duration(seconds: 20));
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.bySemanticsLabel('0 seconds left'), findsOneWidget);
      expect(expired, 1);
      await tester.pump(const Duration(seconds: 5));
      expect(expired, 1);
    });

    testWidgets('the countdown is its own node; the wrapped button keeps its label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpIn(
        tester,
        Scaffold(
          body: Center(
            child: CountdownRing(
              child: LaneButton.primary(label: 'Accept', onPressed: () {}),
            ),
          ),
        ),
      );
      expect(tester.getSemantics(find.byType(CountdownRing)).label, '30 seconds left');
      final button = tester.getSemantics(find.byType(LaneButton));
      expect(button.label, 'Accept');
      expect(button.flagsCollection.isButton, isTrue);
      handle.dispose();
    });

    testWidgets('a late push starts part-drained', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(
          body: CountdownRing(elapsed: Duration(seconds: 25), child: SizedBox(width: 200, height: 56)),
        ),
      );
      expect(find.bySemanticsLabel('5 seconds left'), findsOneWidget);
    });

    testWidgets('already expired calls onExpired straight away', (tester) async {
      var expired = 0;
      await pumpIn(
        tester,
        Scaffold(
          body: CountdownRing(
            elapsed: const Duration(seconds: 40),
            onExpired: () => expired++,
            child: const SizedBox(width: 200, height: 56),
          ),
        ),
      );
      expect(expired, 1);
    });

    testWidgets('Hindi label', (tester) async {
      await pumpIn(
        tester,
        const Scaffold(body: CountdownRing(child: SizedBox(width: 200, height: 56))),
        locale: const Locale('hi'),
      );
      expect(find.bySemanticsLabel('30 सेकंड बाकी'), findsOneWidget);
    });
  });

  testWidgets('the signature sample renders both pages in every mode', (tester) async {
    for (final mode in LaneMode.values) {
      for (final page in [0, 1]) {
        await pumpIn(tester, LaneSignatureSample(page: page), mode: mode);
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull, reason: '$mode page $page');
      }
    }
  });
}
