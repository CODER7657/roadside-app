// Typography (PLAN.md §6.8): Onest (Latin), Anek Devanagari / Gujarati (hi / gu),
// Instrument Serif (brand hero, Latin only) and JetBrains Mono (numbers, codes, caps labels).
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

/// Font family names as declared in lane_ui's pubspec. Pass [package] with them.
abstract final class LaneFonts {
  static const package = 'lane_ui';
  static const sans = 'Onest';
  static const mono = 'JetBrainsMono';
  static const hero = 'InstrumentSerif';
  static const devanagari = 'AnekDevanagari';
  static const gujarati = 'AnekGujarati';
}

/// The writing system of the active locale. Picks the family and [LaneScriptMetrics].
enum LaneScript {
  latin(LaneFonts.sans, LaneScriptMetrics.latin),
  devanagari(LaneFonts.devanagari, LaneScriptMetrics.indic),
  gujarati(LaneFonts.gujarati, LaneScriptMetrics.indic);

  const LaneScript(this.family, this.metrics);

  /// UI family for this script.
  final String family;
  final LaneScriptMetrics metrics;

  static LaneScript of(Locale locale) => switch (locale.languageCode) {
    'hi' => LaneScript.devanagari,
    'gu' => LaneScript.gujarati,
    _ => LaneScript.latin,
  };
}

/// Optical match between scripts. Devanagari and Gujarati need a slightly bigger size and
/// a taller line so matras never clip. Never set `height:` by hand; these do it.
@immutable
class LaneScriptMetrics {
  const LaneScriptMetrics._({required this.sizeDelta, required this.lineHeightFactor});

  static const latin = LaneScriptMetrics._(sizeDelta: 0, lineHeightFactor: 1);
  static const indic = LaneScriptMetrics._(sizeDelta: 1, lineHeightFactor: 1.18);

  /// Added to the Latin size, in sp.
  final double sizeDelta;

  /// Multiplies the Latin line height.
  final double lineHeightFactor;
}

/// The Lane type scale for one script and mode. Read it through `context.lane.text`, and
/// only `.copyWith(color: …)` it.
@immutable
class LaneText {
  const LaneText._({
    required this.script,
    required this.hero,
    required this.display,
    required this.otp,
    required this.headline,
    required this.title,
    required this.bodyLarge,
    required this.body,
    required this.label,
    required this.caps,
    required this.caption,
  });

  /// Builds the scale. [glare] adds +100 weight and sets body to 19 sp (PLAN §6.5 ③).
  factory LaneText.build({required LaneScript script, required Color ink, bool glare = false}) {
    final m = script.metrics;
    final indic = script != LaneScript.latin;
    // Mixed text (a Hindi address in the English UI, "₹" in mono) falls back to the active
    // script's family first, then the other UI families.
    final fallbackOrder = {script.family, LaneFonts.sans, LaneFonts.devanagari, LaneFonts.gujarati};

    TextStyle style(
      String family,
      double size,
      double lineHeight,
      int weight, {
      bool scripted = true,
      double letterSpacing = 0,
      FontStyle fontStyle = FontStyle.normal,
    }) {
      final s = scripted ? size + m.sizeDelta : size;
      final lh = scripted ? lineHeight * m.lineHeightFactor : lineHeight;
      final w = glare ? math.min(weight + 100, 900) : weight;
      return TextStyle(
        package: LaneFonts.package,
        fontFamily: family,
        fontFamilyFallback: [...fallbackOrder.where((f) => f != family)],
        fontSize: s,
        height: lh / s,
        leadingDistribution: TextLeadingDistribution.even,
        fontWeight: _nearestWeight(w),
        fontVariations: [FontVariation.weight(w.toDouble())],
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        color: ink,
      );
    }

    final ui = script.family;
    return LaneText._(
      script: script,
      // Instrument Serif is Latin only: hi/gu titles fall back to Anek 600.
      hero: indic ? style(ui, 40, 42, 600) : style(LaneFonts.hero, 40, 42, 400),
      // Numbers stay Western digits in every language, so mono styles keep Latin metrics.
      display: style(LaneFonts.mono, 48, 52, 700, scripted: false),
      otp: style(LaneFonts.mono, 56, 60, 700, scripted: false),
      headline: style(ui, 30, 36, 700),
      title: style(ui, 22, 28, 600),
      bodyLarge: style(ui, 19, 26, 500),
      body: glare ? style(ui, 19, 26, 450) : style(ui, 17, 24, 450),
      label: style(ui, 15, 20, 600),
      // Signage caps: mono with +8% tracking. Devanagari and Gujarati have no capitals and
      // tracking breaks their joins, so hi/gu use the script family without it.
      caps: indic ? style(ui, 12, 16, 700) : style(LaneFonts.mono, 12, 16, 700, letterSpacing: 12 * 0.08),
      caption: style(ui, 13, 18, 450),
    );
  }

  final LaneScript script;

  /// Splash, onboarding, empty-state titles. Instrument Serif; Anek 600 in hi/gu.
  final TextStyle hero;

  /// ETA, amount. JetBrains Mono.
  final TextStyle display;

  /// The start code at arm's length (56 sp). JetBrains Mono.
  final TextStyle otp;

  /// Screen titles on flow steps.
  final TextStyle headline;

  /// Card titles, dock headers.
  final TextStyle title;

  /// Glare body, key sentences.
  final TextStyle bodyLarge;

  /// Default body text (17 sp; 19 sp in Glare).
  final TextStyle body;

  /// Buttons, chips, tabs.
  final TextStyle label;

  /// Signage labels ("PICKUP", "START CODE").
  final TextStyle caps;

  /// Helper text. The minimum size; never smaller.
  final TextStyle caption;

  /// The styles in PLAN §6.8 order, for specimens and tests.
  Map<String, TextStyle> get all => {
    'hero': hero,
    'display': display,
    'otp': otp,
    'headline': headline,
    'title': title,
    'bodyLarge': bodyLarge,
    'body': body,
    'label': label,
    'caps': caps,
    'caption': caption,
  };

  static FontWeight _nearestWeight(int w) =>
      FontWeight.values[((w / 100).round() - 1).clamp(0, FontWeight.values.length - 1)];
}
