// PLAN §6.13 templates. Done-when for #8: they render at 320 px width and 200% text.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

// Long Hindi copy: Devanagari is the tallest script and hi strings run long.
const longHi = 'एसजी हाईवे के पास, थलतेज, अहमदाबाद में आपकी गाड़ी के लिए निकटतम मैकेनिक को ढूँढ रहे हैं';
const title = 'अपनी गाड़ी की समस्या चुनें';

Widget host(Widget screen, {Locale locale = const Locale('hi')}) => ProviderScope(
  overrides: [
    laneBatterySourceProvider.overrideWithValue(_NoBattery()),
    laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 29, 6, 30)),
  ],
  child: LaneApp(
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('hi'), Locale('gu')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: screen,
  ),
);

Widget button(String label) => FilledButton(onPressed: () {}, child: Text(label));
List<Widget> body(int n) => [for (var i = 0; i < n; i++) Text('$i · $longHi')];

final templates = <String, Widget>{
  'map': LaneMapScaffold(
    map: const ColoredBox(color: Color(0xFFEEF0F2)),
    overlay: const Icon(Icons.location_on, key: Key('pin')),
    actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.my_location))],
    dock: LaneDock(header: const Text(title), primary: button('मदद लें'), children: body(6)),
  ),
  'flow': LaneFlowScaffold(
    step: 2,
    totalSteps: 4,
    stepLabel: '4 में से 2',
    title: title,
    primary: button('आगे बढ़ें'),
    secondary: button('छोड़ें'),
    children: body(8),
  ),
  'status': LaneStatusScaffold(
    visual: const Icon(Icons.radar, size: 96),
    title: title,
    message: longHi,
    primary: button('रद्द करें'),
  ),
  'list': LaneListScaffold(
    title: title,
    itemCount: 12,
    itemBuilder: (_, i) => Text('$i · $longHi'),
    empty: const Text('empty'),
    filters: [
      for (final f in ['सभी', 'अहमदाबाद', 'अंकलेश्वर', 'भरूच']) Chip(label: Text(f)),
    ],
  ),
  'form': LaneFormScaffold(
    title: title,
    primary: button('सहेजें'),
    children: [for (var i = 0; i < 5; i++) const TextField(decoration: InputDecoration(labelText: longHi))],
  ),
};

void setView(WidgetTester tester, Size size, {double bottomPadding = 0, double keyboard = 0}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding(bottom: bottomPadding);
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  addTearDown(tester.view.reset);
}

void main() {
  for (final (w, h, scale) in [(320.0, 640.0, 2.0), (360.0, 800.0, 1.0), (360.0, 800.0, 1.3)]) {
    for (final MapEntry(key: name, value: screen) in templates.entries) {
      testWidgets(
        '$name renders at ${w.toInt()} px, ${(scale * 100).toInt()}% text, Hindi, without overflow',
        (tester) async {
          setView(tester, Size(w, h));
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          await tester.pumpWidget(host(screen));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('dock primary sits full width, 16 dp above the bottom safe area, at least 64 dp', (
    tester,
  ) async {
    setView(tester, const Size(360, 800), bottomPadding: 24);
    await tester.pumpWidget(host(templates['map']!));
    await tester.pumpAndSettle();

    final primary = tester.getRect(find.widgetWithText(FilledButton, 'मदद लें'));
    expect(primary.height, greaterThanOrEqualTo(64));
    expect(primary.width, 360 - 2 * 16);
    expect(primary.bottom, 800 - 24 - 16);
  });

  testWidgets('dock snaps between peek, half and full; the pin stays centred above it', (tester) async {
    setView(tester, const Size(360, 800));
    final extents = <double>[];
    await tester.pumpWidget(
      host(
        LaneMapScaffold(
          map: const SizedBox.expand(),
          overlay: const SizedBox(key: Key('pin'), width: 10, height: 10),
          onDockExtentChanged: extents.add,
          dock: LaneDock(header: const Text('header'), children: body(20)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    double pinY() => tester.getCenter(find.byKey(const Key('pin'))).dy;
    expect(pinY(), closeTo(800 * (1 - LaneDockSnap.half.fraction) / 2, 1));

    // Drag the dock down: it snaps to peek, and the pin follows the bigger map area.
    await tester.drag(find.text('header'), const Offset(0, 180));
    await tester.pumpAndSettle();
    expect(extents.last, closeTo(LaneDockSnap.peek.fraction, 0.01));
    expect(pinY(), closeTo(800 * (1 - LaneDockSnap.peek.fraction) / 2, 1));

    // Drag it up past half: it snaps to full.
    await tester.drag(find.text('header'), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(extents.last, closeTo(LaneDockSnap.full.fraction, 0.01));
  });

  testWidgets('floating map buttons sit top right', (tester) async {
    setView(tester, const Size(360, 800));
    await tester.pumpWidget(host(templates['map']!));
    await tester.pumpAndSettle();
    final button = tester.getRect(find.byIcon(Icons.my_location));
    expect(button.right, greaterThan(360 - 80));
    expect(button.top, lessThan(100));
  });

  testWidgets('flow: step lane shows done / current / upcoming; back and step are labelled', (tester) async {
    await tester.pumpWidget(host(templates['flow']!, locale: const Locale('en')));
    final segments = tester
        .widgetList<AnimatedContainer>(
          find.descendant(of: find.byType(LaneStepLane), matching: find.byType(AnimatedContainer)),
        )
        .map((c) => (c.decoration! as BoxDecoration).color)
        .toList();
    expect(segments, [LaneColors.day.ink, LaneBrand.beacon, LaneColors.day.line, LaneColors.day.line]);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.bySemanticsLabel('4 में से 2'), findsOneWidget);
  });

  testWidgets('flow primary sits 16 dp above the bottom safe area', (tester) async {
    setView(tester, const Size(360, 800), bottomPadding: 24);
    await tester.pumpWidget(host(templates['form']!));
    await tester.pumpAndSettle();
    final primary = tester.getRect(find.widgetWithText(FilledButton, 'सहेजें'));
    expect(primary.bottom, 800 - 24 - 16);
    expect(primary.height, greaterThanOrEqualTo(56));
  });

  testWidgets('flow primary stays above the keyboard', (tester) async {
    setView(tester, const Size(360, 800), keyboard: 300);
    await tester.pumpWidget(host(templates['flow']!));
    await tester.pumpAndSettle();
    final primary = tester.getRect(find.widgetWithText(FilledButton, 'आगे बढ़ें'));
    expect(primary.bottom, lessThanOrEqualTo(800 - 300));
  });

  testWidgets('list shows its empty state when there are no items', (tester) async {
    await tester.pumpWidget(
      host(
        LaneListScaffold(
          title: 'History',
          itemCount: 0,
          itemBuilder: (_, _) => const SizedBox(),
          empty: const Text('No bookings yet'),
        ),
      ),
    );
    expect(find.text('No bookings yet'), findsOneWidget);
  });

  testWidgets('status background gets at least a 60% bg scrim', (tester) async {
    await tester.pumpWidget(
      host(
        LaneStatusScaffold(
          visual: const SizedBox(),
          title: 'Waiting for approval',
          background: MemoryImage(transparentPng),
        ),
      ),
    );
    final scrim = tester.widget<ColoredBox>(
      find.descendant(of: find.byType(Stack), matching: find.byType(ColoredBox)).first,
    );
    expect(scrim.color.a, greaterThanOrEqualTo(LaneStatusScaffold.minScrimOpacity));
    expect(
      () => LaneStatusScaffold(visual: const SizedBox(), title: 't', scrimOpacity: 0.3),
      throwsAssertionError,
    );
  });
}

/// A 1×1 transparent PNG.
final transparentPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);
