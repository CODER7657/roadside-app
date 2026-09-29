// Colour tokens (PLAN.md §6.7). Mirrored in design/tokens.json (test/tokens_json_test.dart
// keeps the two in sync). Contrast ratios are checked in test/contrast_test.dart.
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

/// Signal colours: status = colour, everywhere (PLAN §6.5 ②).
///
/// `stop` (red) is only for SOS, danger and destructive actions. Ended-without-success
/// statuses use [neutral] (grey), never red.
@immutable
class LaneSignals {
  const LaneSignals({
    required this.wait,
    required this.route,
    required this.go,
    required this.work,
    required this.stop,
    required this.neutral,
    required this.waitTint,
    required this.routeTint,
    required this.goTint,
    required this.workTint,
    required this.stopTint,
    required this.neutralTint,
  });

  /// Builds the signals and their `…Tint` badge backgrounds (the colour at 12% on
  /// [surface]). With [outlineTints] (Glare mode) tints are plain [surface]; badges draw a
  /// 2 px outline instead.
  ///
  /// On a tint, the badge **label is `ink`** and the signal colour is only for the icon and
  /// dot: Day `route` is 4.4:1 on its own tint, below the 4.5:1 text minimum.
  factory LaneSignals.on({
    required Color surface,
    required Color wait,
    required Color route,
    required Color go,
    required Color work,
    required Color stop,
    required Color neutral,
    bool outlineTints = false,
  }) {
    Color tint(Color c) =>
        outlineTints ? surface : Color.alphaBlend(c.withValues(alpha: tintOpacity), surface);
    return LaneSignals(
      wait: wait,
      route: route,
      go: go,
      work: work,
      stop: stop,
      neutral: neutral,
      waitTint: tint(wait),
      routeTint: tint(route),
      goTint: tint(go),
      workTint: tint(work),
      stopTint: tint(stop),
      neutralTint: tint(neutral),
    );
  }

  /// Opacity of a signal colour over `surface` for its tint.
  static const tintOpacity = 0.12;

  /// Waiting / searching (`requested`).
  final Color wait;

  /// On the way, information, map route (`accepted`, `arriving`).
  final Color route;

  /// Arrived, success, paid (`arrived`, `completed`).
  final Color go;

  /// Job in progress (`in_progress`).
  final Color work;

  /// SOS / danger / destructive only.
  final Color stop;

  /// Ended without success (`cancelled`, `no_mechanic_found`).
  final Color neutral;

  final Color waitTint, routeTint, goTint, workTint, stopTint, neutralTint;

  static LaneSignals lerp(LaneSignals a, LaneSignals b, double t) {
    Color l(Color x, Color y) => Color.lerp(x, y, t)!;
    return LaneSignals(
      wait: l(a.wait, b.wait),
      route: l(a.route, b.route),
      go: l(a.go, b.go),
      work: l(a.work, b.work),
      stop: l(a.stop, b.stop),
      neutral: l(a.neutral, b.neutral),
      waitTint: l(a.waitTint, b.waitTint),
      routeTint: l(a.routeTint, b.routeTint),
      goTint: l(a.goTint, b.goTint),
      workTint: l(a.workTint, b.workTint),
      stopTint: l(a.stopTint, b.stopTint),
      neutralTint: l(a.neutralTint, b.neutralTint),
    );
  }
}

/// The colour set for one ambient mode. Read it through `context.lane.color`.
@immutable
class LaneColors {
  const LaneColors({
    required this.bg,
    required this.surface,
    required this.surfaceSunken,
    required this.line,
    required this.ink,
    required this.inkMuted,
    required this.inkSubtle,
    required this.onSignal,
    required this.signal,
  });

  /// Screen background ("Chalk" by day, "Asphalt" at night).
  final Color bg;

  /// Cards, dock.
  final Color surface;

  /// Inputs, wells.
  final Color surfaceSunken;

  /// Dividers, 1 px borders (2 px in Glare).
  final Color line;

  /// Primary text.
  final Color ink;

  /// Secondary text.
  final Color inkMuted;

  /// Captions and hints. Never for important information.
  final Color inkSubtle;

  /// Text and icons on a solid signal fill.
  final Color onSignal;

  final LaneSignals signal;

  /// Primary action fill. **Never text or an icon on a light background** (1.7:1); always
  /// a fill with [onBeacon] on top.
  Color get beacon => LaneBrand.beacon;

  /// Text and icons on [beacon].
  Color get onBeacon => LaneBrand.onBeacon;

  static final day = LaneColors(
    bg: const Color(0xFFF4F3EE),
    surface: const Color(0xFFFFFFFF),
    surfaceSunken: const Color(0xFFEAE8E1),
    line: const Color(0xFFD9D6CC),
    ink: const Color(0xFF14161B),
    inkMuted: const Color(0xFF4A5160),
    inkSubtle: const Color(0xFF5F6676),
    onSignal: const Color(0xFFFFFFFF),
    signal: LaneSignals.on(
      surface: const Color(0xFFFFFFFF),
      wait: const Color(0xFF9A5B00),
      route: const Color(0xFF1E5BFF),
      go: const Color(0xFF0B7A43),
      work: const Color(0xFF5B3DF5),
      stop: const Color(0xFFC4262C),
      neutral: const Color(0xFF4A5160),
    ),
  );

  static final night = LaneColors(
    bg: const Color(0xFF0E1014),
    surface: const Color(0xFF181B21),
    surfaceSunken: const Color(0xFF0A0B0E),
    line: const Color(0xFF2A2F38),
    ink: const Color(0xFFEEF0F3),
    inkMuted: const Color(0xFFA9B0BD),
    inkSubtle: const Color(0xFF8A92A0),
    // On Night signal fills, use Day ink (PLAN §6.7).
    onSignal: const Color(0xFF14161B),
    signal: LaneSignals.on(
      surface: const Color(0xFF181B21),
      wait: const Color(0xFFFFC247),
      route: const Color(0xFF7EA2FF),
      go: const Color(0xFF4BD28A),
      work: const Color(0xFFA594FF),
      stop: const Color(0xFFFF6B6E),
      neutral: const Color(0xFFA9B0BD),
    ),
  );

  /// Glare: pure black on white (21:1), Day signal colours, tints replaced by outlines.
  static final glare = LaneColors(
    bg: const Color(0xFFFFFFFF),
    surface: const Color(0xFFFFFFFF),
    surfaceSunken: const Color(0xFFFFFFFF),
    line: const Color(0xFF000000),
    ink: const Color(0xFF000000),
    inkMuted: const Color(0xFF000000),
    inkSubtle: const Color(0xFF14161B),
    onSignal: const Color(0xFFFFFFFF),
    signal: LaneSignals.on(
      surface: const Color(0xFFFFFFFF),
      wait: const Color(0xFF9A5B00),
      route: const Color(0xFF1E5BFF),
      go: const Color(0xFF0B7A43),
      work: const Color(0xFF5B3DF5),
      stop: const Color(0xFFC4262C),
      neutral: const Color(0xFF000000),
      outlineTints: true,
    ),
  );

  /// Saver uses the Night palette (OLED saves power).
  static final saver = night;

  static LaneColors lerp(LaneColors a, LaneColors b, double t) {
    Color l(Color x, Color y) => Color.lerp(x, y, t)!;
    return LaneColors(
      bg: l(a.bg, b.bg),
      surface: l(a.surface, b.surface),
      surfaceSunken: l(a.surfaceSunken, b.surfaceSunken),
      line: l(a.line, b.line),
      ink: l(a.ink, b.ink),
      inkMuted: l(a.inkMuted, b.inkMuted),
      inkSubtle: l(a.inkSubtle, b.inkSubtle),
      onSignal: l(a.onSignal, b.onSignal),
      signal: LaneSignals.lerp(a.signal, b.signal, t),
    );
  }
}

/// Brand and ThreeUI button colours (PLAN §6.7, §6.12). Only `lane_ui` components use the
/// button colours; apps use `LaneButton.*`.
abstract final class LaneBrand {
  static const beacon = Color(0xFFFFB81C);
  static const onBeacon = Color(0xFF14161B);

  // ThreeUI "Launch Button" → LaneButton.primary
  static const launchGradient = [Color(0xFFFDE68A), Color(0xFFFCD34D), Color(0xFFF59E0B)];
  static const launchText = Color(0xFF451A03);
  static const launchRing = Color(0xFFFBBF24);
  static const launchLedge = Color(0xFFB45309);

  // ThreeUI "Spinning Border Button" → LaneButton.secondary
  static const quietGradient = [Color(0xFF27272A), Color(0xFF09090B)];
  static const quietText = Color(0xFFA1A1AA);

  // ThreeUI "Gradient CTA" → LaneButton.pill (onboarding / marketing only)
  static const pillGradient = [Color(0xFFFFEBB1), Color(0xFFFFC438)];
  static const pillText = Color(0xFF7C2D12);
}
