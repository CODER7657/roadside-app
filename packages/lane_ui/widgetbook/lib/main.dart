// Lane component catalogue (PLAN §7.5). Every use case can be switched between
// Day / Night / Glare / Saver, en / hi / gu and text scale 1.0–2.0 from the addon panel.
// Run:  cd packages/lane_ui/widgetbook && flutter run -d chrome
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:lane_ui/specimen.dart';
import 'package:widgetbook/widgetbook.dart';

void main() => runApp(const ProviderScope(child: LaneWidgetbook()));

/// Sample text per language, so hi / gu use cases show real script.
const _sample = {
  'en': 'Near SG Highway, Thaltej',
  'hi': 'एसजी हाईवे के पास, थलतेज',
  'gu': 'એસજી હાઇવે પાસે, થલતેજ',
};

String sampleFor(BuildContext context) =>
    _sample[Localizations.localeOf(context).languageCode] ?? _sample['en']!;

class LaneWidgetbook extends StatelessWidget {
  const LaneWidgetbook({super.key});

  @override
  Widget build(BuildContext context) => Widgetbook.material(
    addons: [
      LocalizationAddon(
        locales: const [Locale('en'), Locale('hi'), Locale('gu')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
      ),
      TextScaleAddon(min: 1.0, max: LaneApp.maxTextScale, divisions: 4),
      // Applied last, so it reads the locale and text scale chosen above.
      ThemeAddon<LaneMode>(
        themes: [for (final m in LaneMode.values) WidgetbookTheme(name: m.name, data: m)],
        themeBuilder: (context, mode, child) => Center(
          child: LanePreview(
            mode: mode,
            locale: Localizations.localeOf(context),
            textScale: MediaQuery.textScalerOf(context).scale(1),
            child: child,
          ),
        ),
      ),
    ],
    directories: [
      WidgetbookCategory(
        name: 'Foundations',
        children: [
          WidgetbookComponent(
            name: 'Specimen',
            useCases: [
              WidgetbookUseCase(
                name: 'Type, signals and Beacon',
                builder: (context) => LaneSpecimen(locale: Localizations.localeOf(context), onLocale: (_) {}),
              ),
            ],
          ),
        ],
      ),
      WidgetbookCategory(
        name: 'Components',
        children: [
          WidgetbookComponent(
            name: 'LaneButton, LaneHoldButton, LaneSlideToConfirm',
            useCases: [
              WidgetbookUseCase(
                name: 'All variants and states',
                builder: (context) => LaneButtonsSample(
                  label: switch (Localizations.localeOf(context).languageCode) {
                    'hi' => 'मदद लें',
                    'gu' => 'મદદ મેળવો',
                    _ => 'Get help',
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      WidgetbookCategory(
        name: 'Inputs and badges',
        children: [
          WidgetbookComponent(
            name: 'LaneTextField, LaneChip, LaneSwitch, LaneListTile, SignalBadge, PlateChip',
            useCases: [
              WidgetbookUseCase(
                name: 'All states',
                builder: (context) => LaneInputsSample(sample: sampleFor(context)),
              ),
            ],
          ),
        ],
      ),
      WidgetbookCategory(
        name: 'Feedback',
        children: [
          WidgetbookComponent(
            name: 'SkeletonBlock, EmptyState, ErrorState, OfflineStrip',
            useCases: [
              WidgetbookUseCase(name: 'All states', builder: (context) => const LaneFeedbackSample()),
            ],
          ),
        ],
      ),
      WidgetbookCategory(
        name: 'Icons and tiles',
        children: [
          WidgetbookComponent(
            name: 'LaneIcon, ProblemTile, VehicleTile',
            useCases: [
              WidgetbookUseCase(name: 'All icons and tiles', builder: (context) => const LaneIconsSample()),
            ],
          ),
        ],
      ),
      WidgetbookCategory(
        name: 'Signature',
        children: [
          WidgetbookComponent(
            name: 'CenterPin, AccuracyBadge, PriceRange',
            useCases: [
              WidgetbookUseCase(name: 'All states', builder: (context) => const LaneMapPartsSample()),
            ],
          ),
          WidgetbookComponent(
            name: 'JourneyRail, TrustPass',
            useCases: [
              WidgetbookUseCase(
                name: 'Rails and workshop pass',
                builder: (context) => const LaneSignatureSample(),
              ),
            ],
          ),
          WidgetbookComponent(
            name: 'TrustPass (independent), LaneOtpInput, LaneRollingNumber, CountdownRing, BreathingPulse',
            useCases: [
              WidgetbookUseCase(
                name: 'Independent pass and numbers',
                builder: (context) => const LaneSignatureSample(page: 1),
              ),
            ],
          ),
        ],
      ),
      WidgetbookCategory(
        name: 'Templates',
        children: [
          for (final (name, template) in [
            ('LaneMapScaffold + LaneDock', 'map'),
            ('LaneFlowScaffold', 'flow'),
            ('LaneStatusScaffold', 'status'),
            ('LaneListScaffold', 'list'),
            ('LaneFormScaffold', 'form'),
          ])
            WidgetbookComponent(
              name: name,
              useCases: [
                WidgetbookUseCase(
                  name: 'Sample',
                  builder: (context) => LaneTemplateSample(template: template, sample: sampleFor(context)),
                ),
              ],
            ),
        ],
      ),
    ],
  );
}
