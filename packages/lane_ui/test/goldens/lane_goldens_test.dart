// Visual snapshots of the specimen and every template (PLAN §7.6): all four modes, plus
// Hindi at 200% text. A change shows up as a failing test with a diff image under
// test/goldens/failures/ (uploaded by CI).
import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:lane_ui/specimen.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

const _variants = <(String, LaneMode, Locale, double)>[
  ('day', LaneMode.day, Locale('en'), 1.0),
  ('night', LaneMode.night, Locale('en'), 1.0),
  ('glare', LaneMode.glare, Locale('en'), 1.0),
  ('saver', LaneMode.saver, Locale('en'), 1.0),
  ('day · hi · 200%', LaneMode.day, Locale('hi'), 2.0),
];

const _hiStops = ['अनुरोध', 'स्वीकार', 'रास्ते में', 'पहुँच गए', 'काम जारी', 'पूरा'];

const _samples = {'en': 'Near SG Highway, Thaltej', 'hi': 'एसजी हाईवे के पास, थलतेज'};

Widget _scope(Widget child) => ProviderScope(
  overrides: [
    laneBatterySourceProvider.overrideWithValue(_NoBattery()),
    laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 29, 6, 30)),
  ],
  child: child,
);

GoldenTestGroup _group(Widget Function(Locale locale) screen) => GoldenTestGroup(
  columns: _variants.length,
  children: [
    for (final (name, mode, locale, scale) in _variants)
      GoldenTestScenario(
        name: name,
        child: LanePreview(mode: mode, locale: locale, textScale: scale, child: screen(locale)),
      ),
  ],
);

void main() {
  goldenTest(
    'specimen in every mode',
    fileName: 'specimen',
    builder: () => _group((locale) => _scope(LaneSpecimen(locale: locale, onLocale: (_) {}))),
  );

  goldenTest(
    'buttons and gestures in every mode',
    fileName: 'components_buttons',
    // The loading beam repeats forever, so pump a frame instead of settling.
    pumpBeforeTest: (tester) => tester.pump(const Duration(milliseconds: 400)),
    builder: () =>
        _group((locale) => LaneButtonsSample(label: locale.languageCode == 'hi' ? 'मदद लें' : 'Get help')),
  );

  goldenTest(
    'inputs, chips and badges in every mode',
    fileName: 'components_inputs',
    builder: () => _group((locale) => LaneInputsSample(sample: _samples[locale.languageCode]!)),
  );

  goldenTest(
    'loading, empty, error and offline in every mode',
    fileName: 'components_feedback',
    builder: () => _group((_) => const LaneFeedbackSample()),
  );

  goldenTest(
    'icons, problem and vehicle tiles in every mode',
    fileName: 'components_icons',
    builder: () => _group(
      (locale) => LaneIconsSample(
        problemLabels: locale.languageCode == 'hi'
            ? const {'flat_tyre': 'टायर पंचर', 'battery': 'बैटरी', 'wont_start': 'गाड़ी स्टार्ट नहीं हो रही'}
            : const {},
      ),
    ),
  );

  for (final page in [0, 1]) {
    goldenTest(
      'signature components (page ${page + 1}) in every mode',
      fileName: 'components_signature_${page + 1}',
      // The pulse and the countdown run on, so pump a frame instead of settling.
      pumpBeforeTest: (tester) => tester.pump(const Duration(milliseconds: 400)),
      builder: () => _group(
        (locale) => LaneSignatureSample(
          page: page,
          stops: locale.languageCode == 'hi' ? _hiStops : LaneSignatureSample.defaultStops,
          name: locale.languageCode == 'hi' ? 'रमेश पटेल' : 'Ramesh Patel',
        ),
      ),
    );
  }

  for (final template in ['map', 'flow', 'status', 'list', 'form']) {
    goldenTest(
      '$template template in every mode',
      fileName: 'template_$template',
      pumpBeforeTest: (tester) => tester.pumpAndSettle(),
      builder: () =>
          _group((locale) => LaneTemplateSample(template: template, sample: _samples[locale.languageCode]!)),
    );
  }
}
