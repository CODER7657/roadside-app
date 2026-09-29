// #86: Phosphor duotone icons, ProblemTile, VehicleTile, LaneTileGrid, licence notices.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:lane_ui/specimen.dart';

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

void main() {
  group('icon assets', () {
    test('every LaneIcons entry has its SVG, declared in the pubspec folder', () {
      for (final i in LaneIcons.values) {
        final file = File('assets/icons/${i.file}.svg');
        expect(file.existsSync(), isTrue, reason: i.name);
        final svg = file.readAsStringSync();
        expect(svg, contains('currentColor'), reason: '${i.name} takes the line colour from the theme');
        expect(svg, isNot(contains('color="#')), reason: '${i.name} has no fixed line colour');
        if (i.tinted) expect(svg, contains('#FFB81C'), reason: '${i.name} keeps the Beacon fill');
      }
      expect(File('pubspec.yaml').readAsStringSync(), contains('- assets/icons/'));
    });

    test('every pictogram in assets/pictograms/lane is available', () {
      final repo = Directory('../../assets/pictograms/lane').listSync().map((f) => f.uri.pathSegments.last);
      final ours = LaneIcons.values.where((i) => i.tinted).map((i) => '${i.file}.svg').toSet();
      expect(repo.toSet(), ours);
    });

    test('problem and vehicle types from PLAN §8 map to their pictograms', () {
      expect(LaneIcons.forProblem('flat_tyre'), LaneIcons.flatTyre);
      expect(LaneIcons.forProblem('wont_start'), LaneIcons.wontStart);
      expect(LaneIcons.forProblem('something_new'), LaneIcons.other);
      expect(LaneIcons.forVehicle('ev'), LaneIcons.ev);
      expect(LaneIcons.forVehicle('scooter'), LaneIcons.scooter);
      expect(LaneIcons.forVehicle('truck'), LaneIcons.car);
    });
  });

  group('LaneIcon', () {
    testWidgets('takes size and colour from IconTheme, like Icon', (tester) async {
      await pumpIn(
        tester,
        const IconTheme(
          data: IconThemeData(size: 40, color: Color(0xFF123456)),
          child: Center(child: LaneIcon(LaneIcons.wrench)),
        ),
      );
      expect(tester.getSize(find.byType(SvgPicture)), const Size(40, 40));
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect((svg.bytesLoader as SvgAssetLoader).theme?.currentColor, const Color(0xFF123456));
    });

    testWidgets('decorative by default; labelled when asked', (tester) async {
      await pumpIn(
        tester,
        const Column(
          children: [
            LaneIcon(LaneIcons.sos),
            LaneIcon(LaneIcons.call, semanticLabel: 'Call'),
          ],
        ),
      );
      expect(find.bySemanticsLabel('Call'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('sos', caseSensitive: false)), findsNothing);
    });

    testWidgets('pictograms line up with the Night ink when no colour is set', (tester) async {
      await pumpIn(tester, const Center(child: LaneIcon(LaneIcons.car)), mode: LaneMode.night);
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect((svg.bytesLoader as SvgAssetLoader).theme?.currentColor, LaneColors.night.ink);
    });
  });

  group('tiles', () {
    testWidgets('ProblemTile: tap, selection haptic path, selected is announced and marked', (tester) async {
      var taps = 0;
      await pumpIn(
        tester,
        LaneTileGrid(
          children: [
            ProblemTile(icon: LaneIcons.battery, label: 'Battery', selected: true, onTap: () => taps++),
            ProblemTile(icon: LaneIcons.fuel, label: 'Fuel', onTap: () => taps++),
          ],
        ),
      );
      await tester.tap(find.text('Fuel'));
      expect(taps, 1);
      expect(
        tester.getSemantics(find.byType(ProblemTile).first),
        isSemantics(label: 'Battery', isSelected: true, isButton: true, hasTapAction: true),
      );
      expect(
        find.descendant(
          of: find.byType(ProblemTile).first,
          matching: find.byWidgetPredicate((w) => w is LaneIcon && w.icon == LaneIcons.checkCircle),
        ),
        findsOneWidget,
      );
    });

    testWidgets('LaneTileGrid: two per row, equal heights, odd count keeps its column', (tester) async {
      await pumpIn(
        tester,
        const LaneTileGrid(
          children: [
            ProblemTile(icon: LaneIcons.battery, label: 'Battery'),
            ProblemTile(icon: LaneIcons.wontStart, label: 'Won\'t start and makes a clicking noise'),
            ProblemTile(icon: LaneIcons.other, label: 'Other'),
          ],
        ),
      );
      final a = tester.getRect(find.byType(ProblemTile).at(0));
      final b = tester.getRect(find.byType(ProblemTile).at(1));
      final c = tester.getRect(find.byType(ProblemTile).at(2));
      expect(a.top, b.top);
      expect(a.height, b.height);
      expect(c.width, a.width);
      expect(c.top, greaterThan(a.bottom));
    });

    testWidgets('VehicleTile reads name, plate and detail as one button', (tester) async {
      await pumpIn(
        tester,
        VehicleTile(
          icon: LaneIcons.car,
          name: 'Maruti Swift',
          regNo: 'GJ01AB1234',
          detail: 'Petrol',
          onTap: () {},
        ),
      );
      expect(find.text('GJ 01 AB 1234'), findsOneWidget);
      expect(tester.getSemantics(find.byType(VehicleTile)).label, 'Maruti Swift, GJ 01 AB 1234, Petrol');
    });

    testWidgets('the sample fits at 320 px, 200% text, Hindi, in every mode', (tester) async {
      for (final mode in LaneMode.values) {
        await pumpIn(
          tester,
          const LaneIconsSample(problemLabels: {'wont_start': 'गाड़ी स्टार्ट नहीं हो रही'}),
          mode: mode,
          locale: const Locale('hi'),
          scale: 2,
          size: const Size(320, 2600),
        );
        expect(tester.takeException(), isNull, reason: mode.name);
      }
    });
  });

  testWidgets('licences page lists the fonts, ThreeUI and Phosphor', (tester) async {
    LaneLicenses.register();
    final packages = <String>{};
    await tester.runAsync(() async {
      await for (final l in LicenseRegistry.licenses) {
        packages.addAll(l.packages);
      }
    });
    expect(
      packages,
      containsAll([
        'Onest',
        'Instrument Serif',
        'JetBrains Mono',
        'Anek Devanagari',
        'Anek Gujarati',
        'ThreeUI Community',
        'Phosphor Icons',
      ]),
    );
  });
}
