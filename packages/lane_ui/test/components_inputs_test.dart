// #84: LaneTextField, LaneChip, LaneSwitch, LaneListTile, SignalBadge, PlateChip.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:lane_ui/specimen.dart';

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

Color textColor(WidgetTester tester, String text) => tester.widget<Text>(find.text(text)).style!.color!;

void main() {
  group('LaneTextField', () {
    testWidgets('label above, 56 dp field, typing reaches onChanged', (tester) async {
      String? typed;
      await pumpIn(tester, column([LaneTextField(label: 'Landmark', onChanged: (v) => typed = v)]));
      expect(
        tester.getTopLeft(find.text('Landmark')).dy,
        lessThan(tester.getTopLeft(find.byType(TextField)).dy),
      );
      expect(tester.getSize(find.byType(TextField)).height, greaterThanOrEqualTo(56));
      await tester.enterText(find.byType(TextField), 'Near the petrol pump');
      expect(typed, 'Near the petrol pump');
    });

    testWidgets('error replaces helper, in signal.stop, announced as a live region', (tester) async {
      await pumpIn(
        tester,
        column([
          const LaneTextField(label: 'Reg no', helper: 'e.g. GJ01AB1234', errorText: 'Check the number'),
        ]),
      );
      expect(find.text('e.g. GJ01AB1234'), findsNothing);
      expect(textColor(tester, 'Check the number'), LaneColors.day.signal.stop);
      expect(
        tester.getSemantics(find.text('Check the number')),
        matchesSemantics(label: 'Check the number', isLiveRegion: true),
      );
    });

    testWidgets('focus ring is ink, not Beacon', (tester) async {
      await pumpIn(tester, column([const LaneTextField(label: 'Name')]));
      final deco = tester.widget<TextField>(find.byType(TextField)).decoration!;
      expect((deco.focusedBorder! as OutlineInputBorder).borderSide.color, LaneColors.day.ink);
    });
  });

  group('LaneChip', () {
    testWidgets('toggles with the selection haptic; selected is solid ink', (tester) async {
      final haptics = recordHaptics(tester);
      bool? got;
      await pumpIn(tester, column([LaneChip(label: 'Bharuch', selected: true, onSelected: (v) => got = v)]));
      await tester.tap(find.text('Bharuch'));
      expect(got, isFalse);
      expect(haptics, ['HapticFeedbackType.selectionClick']);
      expect(textColor(tester, 'Bharuch'), LaneColors.day.surface);
      expect(tester.getSize(find.byType(LaneChip)).height, greaterThanOrEqualTo(48));
      expect(
        tester.getSemantics(find.byType(LaneChip)),
        matchesSemantics(
          label: 'Bharuch',
          isSelected: true,
          hasSelectedState: true,
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
    });
  });

  group('LaneSwitch', () {
    testWidgets('the whole row toggles; big is the 64 dp online toggle', (tester) async {
      var value = false;
      await pumpIn(
        tester,
        StatefulBuilder(
          builder: (context, set) => column([
            LaneSwitch(label: 'Online', value: value, onChanged: (v) => set(() => value = v), big: true),
          ]),
        ),
      );
      expect(tester.getSize(find.byType(LaneSwitch)).height, greaterThanOrEqualTo(64));
      await tester.tap(find.text('Online'));
      await tester.pump();
      expect(value, isTrue);
      expect(
        tester.getSemantics(find.byType(LaneSwitch)),
        isSemantics(isToggled: true, hasToggledState: true),
      );
    });
  });

  group('LaneListTile', () {
    testWidgets('at least 56 dp, tappable, long titles stop at two lines', (tester) async {
      var taps = 0;
      await pumpIn(
        tester,
        column([LaneListTile(title: 'A very long title ' * 10, subtitle: 'sub', onTap: () => taps++)]),
      );
      expect(tester.getSize(find.byType(LaneListTile)).height, greaterThanOrEqualTo(56));
      await tester.tap(find.byType(LaneListTile));
      expect(taps, 1);
      expect(tester.widget<Text>(find.textContaining('A very long')).maxLines, 2);
    });
  });

  group('SignalBadge', () {
    for (final mode in LaneMode.values) {
      testWidgets('icon in the signal colour, label in ink ($mode)', (tester) async {
        await pumpIn(
          tester,
          column([for (final s in LaneSignal.values) SignalBadge(signal: s, label: s.name)]),
          mode: mode,
        );
        final lane = LaneTheme.of(mode);
        for (final s in LaneSignal.values) {
          expect(textColor(tester, s.name), lane.color.ink, reason: '${s.name} label');
          final icon = tester.widget<Icon>(
            find.descendant(of: find.widgetWithText(SignalBadge, s.name), matching: find.byType(Icon)),
          );
          expect(icon.color, s.colorIn(lane.color.signal), reason: '${s.name} icon');
        }
      });
    }

    testWidgets('Glare draws an outline instead of a tint', (tester) async {
      await pumpIn(
        tester,
        column([const SignalBadge(signal: LaneSignal.go, label: 'Arrived')]),
        mode: LaneMode.glare,
      );
      final box = tester.widget<Container>(
        find.descendant(of: find.byType(SignalBadge), matching: find.byType(Container)),
      );
      final deco = box.decoration! as BoxDecoration;
      expect(deco.color, LaneColors.glare.surface);
      expect((deco.border! as Border).top.width, 2);
    });
  });

  group('PlateChip', () {
    test('formats Indian and BH-series plates', () {
      expect(PlateChip.format('GJ01AB1234'), 'GJ 01 AB 1234');
      expect(PlateChip.format('gj 1 ab 99'), 'GJ 1 AB 99');
      expect(PlateChip.format('GJ-05-A-7'), 'GJ 05 A 7');
      expect(PlateChip.format('MH12 1234'), 'MH 12 1234');
      expect(PlateChip.format('22BH1234AA'), '22 BH 1234 AA');
      expect(PlateChip.format('22 bh 1234 a'), '22 BH 1234 A');
      expect(PlateChip.format('  odd   plate '), 'ODD PLATE');
    });

    for (final mode in LaneMode.values) {
      testWidgets('stays a white plate with black letters ($mode)', (tester) async {
        await pumpIn(tester, column([const PlateChip(regNo: 'GJ01AB1234')]), mode: mode);
        expect(textColor(tester, 'GJ 01 AB 1234'), PlateChip.ink);
        final deco =
            tester
                    .widget<DecoratedBox>(
                      find.descendant(of: find.byType(PlateChip), matching: find.byType(DecoratedBox)).first,
                    )
                    .decoration
                as BoxDecoration;
        expect(deco.color, PlateChip.plate);
      });
    }

    testWidgets('screen readers hear it letter by letter; it never truncates', (tester) async {
      await pumpIn(
        tester,
        SizedBox(width: 120, child: column([const PlateChip(regNo: 'GJ01AB1234', large: true)])),
      );
      expect(tester.getSemantics(find.byType(PlateChip)).label, 'G J 0 1 A B 1 2 3 4');
      expect(tester.widget<Text>(find.text('GJ 01 AB 1234')).overflow, isNull);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('the whole sample fits at 320 px, 200% text, Hindi', (tester) async {
    await pumpIn(
      tester,
      const LaneInputsSample(sample: 'एसजी हाईवे के पास, थलतेज'),
      locale: const Locale('hi'),
      scale: 2,
      size: const Size(320, 2200),
    );
    expect(tester.takeException(), isNull);
  });
}
