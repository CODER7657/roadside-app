// #85: SkeletonBlock, EmptyState, ErrorState, LaneToast, OfflineStrip and Lane's own strings.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:lane_ui/specimen.dart';
import 'package:lane_ui/src/l10n/lane_localizations.dart' show lookupLaneLocalizations;

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

const offlineEn = "You're offline. Calls and SMS still work.";

Future<void> pumpIn(WidgetTester tester, Widget child, {Locale locale = const Locale('en')}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: LanePreview(mode: LaneMode.day, locale: locale, child: child),
    ),
  );
  await tester.pump();
}

/// A real LaneApp, for the offline strip and the delegate wiring.
Widget app({bool? offline, Locale locale = const Locale('en'), Widget? home}) => ProviderScope(
  overrides: [
    laneBatterySourceProvider.overrideWithValue(_NoBattery()),
    laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 29, 6, 30)),
  ],
  child: LaneApp(
    offline: offline,
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('hi'), Locale('gu')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: home ?? const Scaffold(body: SafeArea(child: Text('screen'))),
  ),
);

void main() {
  group('strings', () {
    test('en, hi and gu all have every key', () {
      for (final code in ['en', 'hi', 'gu']) {
        final s = lookupLaneLocalizations(Locale(code));
        expect([
          s.offline_strip_message,
          s.error_state_title,
          s.error_state_retry,
          s.skeleton_loading,
        ], everyElement(isNotEmpty));
      }
      expect(lookupLaneLocalizations(const Locale('hi')).error_state_retry, 'फिर से कोशिश करें');
    });

    testWidgets('LaneApp adds the Lane delegate by itself', (tester) async {
      await tester.pumpWidget(
        app(
          locale: const Locale('gu'),
          home: Scaffold(body: ErrorState(onRetry: () {})),
        ),
      );
      expect(find.text('ફરી પ્રયાસ કરો'), findsOneWidget);
    });

    testWidgets('components fall back to English without the delegate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: LaneThemeData.build(LaneMode.day),
          home: Scaffold(body: ErrorState(onRetry: () {})),
        ),
      );
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  testWidgets('skeleton group is announced once as Loading; blocks are silent; no shimmer', (tester) async {
    await pumpIn(tester, Scaffold(body: SkeletonGroup.lines(lines: 4)));
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    expect(find.byType(SkeletonBlock), findsNWidgets(4));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('skeletons stay visible in Glare (outlined, not white on white)', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: LanePreview(
          mode: LaneMode.glare,
          child: Scaffold(body: SkeletonBlock(height: 16)),
        ),
      ),
    );
    final deco =
        tester
                .widget<Container>(
                  find.descendant(of: find.byType(SkeletonBlock), matching: find.byType(Container)),
                )
                .decoration!
            as BoxDecoration;
    expect((deco.border! as Border).top.color, LaneColors.glare.line);
  });

  testWidgets('empty state always has its action', (tester) async {
    var taps = 0;
    await pumpIn(
      tester,
      Scaffold(
        body: EmptyState(title: 'No bookings yet', actionLabel: 'Get help', onAction: () => taps++),
      ),
    );
    await tester.tap(find.text('Get help'));
    expect(taps, 1);
  });

  testWidgets('error state: calm icon (never red), default title, retry and alternative', (tester) async {
    var retries = 0, sms = 0;
    await pumpIn(
      tester,
      Scaffold(
        body: ErrorState(
          onRetry: () => retries++,
          alternativeLabel: 'Send location by SMS',
          onAlternative: () => sms++,
        ),
      ),
    );
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(tester.widget<LaneIcon>(find.byType(LaneIcon).first).color, LaneColors.day.inkMuted);
    await tester.tap(find.text('Try again'));
    await tester.tap(find.text('Send location by SMS'));
    expect((retries, sms), (1, 1));
  });

  group('LaneToast', () {
    Widget twoButtons() => Scaffold(
      body: Builder(
        builder: (c) => Column(
          children: [
            TextButton(onPressed: () => LaneToast.show(c, 'Saved'), child: const Text('one')),
            TextButton(onPressed: () => LaneToast.show(c, 'Copied'), child: const Text('two')),
            TextButton(
              onPressed: () => LaneToast.show(c, 'Lifted', bottomOffset: 300),
              child: const Text('lifted'),
            ),
          ],
        ),
      ),
    );

    testWidgets('shows, is announced, goes after 4 s; a new toast replaces the old', (tester) async {
      await pumpIn(tester, twoButtons());
      await tester.tap(find.text('one'));
      await tester.pump();
      expect(find.text('Saved'), findsOneWidget);
      expect(tester.getSemantics(find.text('Saved')), isSemantics(isLiveRegion: true));
      await tester.tap(find.text('two'));
      await tester.pump();
      expect(find.text('Saved'), findsNothing);
      expect(find.text('Copied'), findsOneWidget);
      await tester.pump(LaneToast.visibleFor);
      expect(find.text('Copied'), findsNothing);
    });

    testWidgets('sits above the given offset (the dock)', (tester) async {
      await pumpIn(tester, twoButtons());
      await tester.tap(find.text('lifted'));
      await tester.pumpAndSettle();
      expect(tester.getBottomLeft(find.text('Lifted')).dy, lessThan(800 - 300));
      LaneToast.hide();
    });
  });

  group('OfflineStrip in LaneApp', () {
    testWidgets('online: no strip, the screen keeps its top padding', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app(offline: false));
      await tester.pumpAndSettle();
      expect(find.text(offlineEn), findsNothing);
      expect(tester.getTopLeft(find.text('screen')).dy, 24);
    });

    testWidgets('offline: neutral strip under the status bar, announced, no double padding', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app(offline: true));
      await tester.pumpAndSettle();
      final msg = find.text(offlineEn);
      expect(msg, findsOneWidget);
      expect(tester.getTopLeft(msg).dy, greaterThanOrEqualTo(24), reason: 'below the status bar');
      final strip = tester.getRect(find.byType(OfflineStrip));
      expect(tester.getTopLeft(find.text('screen')).dy, strip.bottom, reason: 'screen starts right under it');
      final fill = tester.widget<ColoredBox>(
        find.descendant(of: find.byType(OfflineStrip), matching: find.byType(ColoredBox)),
      );
      expect(fill.color, LaneColors.day.inkMuted, reason: 'neutral grey, never red');
      expect(tester.getSemantics(msg), isSemantics(isLiveRegion: true));
    });

    testWidgets('speaks Hindi when the app does', (tester) async {
      await tester.pumpWidget(app(offline: true, locale: const Locale('hi')));
      await tester.pumpAndSettle();
      expect(find.text('आप ऑफ़लाइन हैं। कॉल और SMS अब भी काम करते हैं।'), findsOneWidget);
    });
  });

  testWidgets('the sample fits at 320 px, 200% text, Hindi', (tester) async {
    tester.view.physicalSize = const Size(320, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: LanePreview(
          mode: LaneMode.day,
          locale: Locale('hi'),
          textScale: 2,
          size: Size(320, 2200),
          child: LaneFeedbackSample(),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
