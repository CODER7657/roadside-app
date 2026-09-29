import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

const ist = Duration(hours: 5, minutes: 30);
final noonIst = DateTime.utc(2026, 9, 29, 12).subtract(ist);

/// Captures the context below LaneApp so tests can read `context.lane`.
late BuildContext captured;

Widget app({Locale? locale, Widget? offlineStrip, List<Override> overrides = const []}) => ProviderScope(
  overrides: [
    laneBatterySourceProvider.overrideWithValue(_NoBattery()),
    laneClockProvider.overrideWithValue(() => noonIst),
    ...overrides,
  ],
  child: LaneApp(
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('hi'), Locale('gu')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    offlineStrip: offlineStrip,
    home: Builder(
      builder: (context) {
        captured = context;
        return Text('screen', style: context.lane.text.body);
      },
    ),
  ),
);

void main() {
  testWidgets('provides context.lane in Day mode by default', (tester) async {
    await tester.pumpWidget(app());
    final lane = captured.lane;
    expect(lane.mode, LaneMode.day);
    expect(lane.color.bg, LaneColors.day.bg);
    expect(Theme.of(captured).scaffoldBackgroundColor, LaneColors.day.bg);
    expect(lane.script, LaneScript.latin);
  });

  testWidgets('cross-fades to a new mode over motion.standard without rebuilding the screen', (tester) async {
    await tester.pumpWidget(app());
    final screenElement = tester.element(find.text('screen'));
    final container = ProviderScope.containerOf(screenElement);

    container.read(ambientControllerProvider.notifier).setManual(LaneMode.night);
    await tester.pump();
    await tester.pump(LaneMotion.full.standard ~/ 2);
    final mid = captured.lane.color.bg;
    expect(mid, isNot(LaneColors.day.bg));
    expect(mid, isNot(LaneColors.night.bg));

    await tester.pumpAndSettle();
    expect(captured.lane.mode, LaneMode.night);
    expect(captured.lane.color.bg, LaneColors.night.bg);
    expect(tester.element(find.text('screen')), same(screenElement), reason: 'screen state kept');
  });

  testWidgets('switches through all four modes', (tester) async {
    await tester.pumpWidget(app());
    final container = ProviderScope.containerOf(tester.element(find.text('screen')));
    for (final (mode, bg) in [
      (LaneMode.glare, LaneColors.glare.bg),
      (LaneMode.saver, LaneColors.saver.bg),
      (LaneMode.night, LaneColors.night.bg),
      (LaneMode.day, LaneColors.day.bg),
    ]) {
      container.read(ambientControllerProvider.notifier).setManual(mode);
      await tester.pumpAndSettle();
      expect(captured.lane.mode, mode);
      expect(captured.lane.color.bg, bg);
    }
    expect(captured.lane.motion.enabled, isTrue);
    container.read(ambientControllerProvider.notifier).setManual(LaneMode.saver);
    await tester.pumpAndSettle();
    expect(captured.lane.motion.enabled, isFalse, reason: 'Saver turns motion off');
  });

  testWidgets('Hindi and Gujarati locales switch the type scale', (tester) async {
    await tester.pumpWidget(app(locale: const Locale('hi')));
    expect(captured.lane.script, LaneScript.devanagari);
    expect(captured.lane.text.body.fontFamily, 'packages/lane_ui/AnekDevanagari');
    expect(Theme.of(captured).textTheme.bodyMedium!.fontFamily, 'packages/lane_ui/AnekDevanagari');

    await tester.pumpWidget(app(locale: const Locale('gu')));
    expect(captured.lane.text.body.fontFamily, 'packages/lane_ui/AnekGujarati');
  });

  testWidgets('clamps system text scaling at 200%', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 3.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(app());
    expect(MediaQuery.textScalerOf(captured).scale(10), 20);
  });

  testWidgets('keeps text scaling below 200% as it is', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(app());
    expect(MediaQuery.textScalerOf(captured).scale(10), closeTo(13, 1e-9));
  });

  testWidgets('system reduce-motion turns Lane motion off', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(app());
    expect(captured.lane.motion.enabled, isFalse);
    expect(captured.lane.motion.standard, const Duration(milliseconds: 100));
  });

  testWidgets('shows the offline strip above the screen', (tester) async {
    await tester.pumpWidget(app(offlineStrip: const Text('offline')));
    final strip = tester.getTopLeft(find.text('offline'));
    final screen = tester.getTopLeft(find.text('screen'));
    expect(strip.dy, lessThan(screen.dy));
  });

  testWidgets('pages use the shared-axis transition', (tester) async {
    await tester.pumpWidget(app());
    final builders = Theme.of(captured).pageTransitionsTheme.builders;
    expect(builders[TargetPlatform.android], isA<LanePageTransitionsBuilder>());
  });

  testWidgets('without LaneApp, context.lane explains what is missing', (tester) async {
    late BuildContext bare;
    await tester.pumpWidget(
      Builder(
        builder: (c) {
          bare = c;
          return const SizedBox();
        },
      ),
    );
    expect(() => bare.lane, throwsA(isA<FlutterError>()));
  });

  testWidgets('LaneApp.router works with a RouterConfig', (tester) async {
    final router = _OneScreenRouter(const Text('routed'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => noonIst),
        ],
        child: LaneApp.router(routerConfig: router),
      ),
    );
    expect(find.text('routed'), findsOneWidget);
  });
}

/// Minimal RouterConfig standing in for go_router.
class _OneScreenRouter extends RouterConfig<Object> {
  _OneScreenRouter(Widget screen)
    : super(
        routerDelegate: _Delegate(screen),
        routeInformationParser: _Parser(),
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: RouteInformation(uri: Uri.parse('/')),
        ),
      );
}

class _Parser extends RouteInformationParser<Object> {
  @override
  Future<Object> parseRouteInformation(RouteInformation routeInformation) async => '/';
}

class _Delegate extends RouterDelegate<Object> with ChangeNotifier {
  _Delegate(this.screen);

  final Widget screen;

  @override
  Widget build(BuildContext context) => Navigator(
    pages: [MaterialPage<void>(child: screen)],
    onDidRemovePage: (_) {},
  );

  @override
  Future<bool> popRoute() async => false;

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}
