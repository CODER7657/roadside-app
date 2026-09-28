// Starter for packages/lane_ui/lib/src/tokens/ (PLAN.md §6). P1 moves this into lane_ui on day 1.
// Apps never import this directly: they use `context.lane` from LaneTheme.
import 'package:flutter/material.dart';

@immutable
class LaneColors extends ThemeExtension<LaneColors> {
  const LaneColors({
    required this.bg,
    required this.surface,
    required this.surfaceSunken,
    required this.line,
    required this.ink,
    required this.inkMuted,
    required this.inkSubtle,
    required this.wait,
    required this.route,
    required this.go,
    required this.work,
    required this.stop,
  });

  final Color bg, surface, surfaceSunken, line, ink, inkMuted, inkSubtle;

  /// Signal colours: status = colour. `stop` (red) is only for SOS, danger and destructive actions.
  final Color wait, route, go, work, stop;

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

  static const day = LaneColors(
    bg: Color(0xFFF4F3EE),
    surface: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFEAE8E1),
    line: Color(0xFFD9D6CC),
    ink: Color(0xFF14161B),
    inkMuted: Color(0xFF4A5160),
    inkSubtle: Color(0xFF5F6676),
    wait: Color(0xFF9A5B00),
    route: Color(0xFF1E5BFF),
    go: Color(0xFF0B7A43),
    work: Color(0xFF5B3DF5),
    stop: Color(0xFFC4262C),
  );

  static const night = LaneColors(
    bg: Color(0xFF0E1014),
    surface: Color(0xFF181B21),
    surfaceSunken: Color(0xFF0A0B0E),
    line: Color(0xFF2A2F38),
    ink: Color(0xFFEEF0F3),
    inkMuted: Color(0xFFA9B0BD),
    inkSubtle: Color(0xFF8A92A0),
    wait: Color(0xFFFFC247),
    route: Color(0xFF7EA2FF),
    go: Color(0xFF4BD28A),
    work: Color(0xFFA594FF),
    stop: Color(0xFFFF6B6E),
  );

  static const glare = LaneColors(
    bg: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFFFFFFF),
    line: Color(0xFF000000),
    ink: Color(0xFF000000),
    inkMuted: Color(0xFF000000),
    inkSubtle: Color(0xFF14161B),
    wait: Color(0xFF9A5B00),
    route: Color(0xFF1E5BFF),
    go: Color(0xFF0B7A43),
    work: Color(0xFF5B3DF5),
    stop: Color(0xFFC4262C),
  );

  @override
  LaneColors copyWith() => this;

  @override
  LaneColors lerp(LaneColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return LaneColors(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surfaceSunken: l(surfaceSunken, other.surfaceSunken),
      line: l(line, other.line),
      ink: l(ink, other.ink),
      inkMuted: l(inkMuted, other.inkMuted),
      inkSubtle: l(inkSubtle, other.inkSubtle),
      wait: l(wait, other.wait),
      route: l(route, other.route),
      go: l(go, other.go),
      work: l(work, other.work),
      stop: l(stop, other.stop),
    );
  }
}

abstract final class LaneSpace {
  static const s4 = 4.0, s8 = 8.0, s12 = 12.0, s16 = 16.0, s20 = 20.0;
  static const s24 = 24.0, s32 = 32.0, s48 = 48.0, s64 = 64.0;
}

abstract final class LaneRadius {
  static const r6 = Radius.circular(6);
  static const r12 = Radius.circular(12);
  static const r16 = Radius.circular(16);
  static const r24 = Radius.circular(24);
  static const pill = Radius.circular(999);
}

abstract final class LaneTouch {
  static const min = 48.0, primary = 56.0, critical = 64.0;
}

abstract final class LaneMotion {
  static const instant = Duration(milliseconds: 100);
  static const quick = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 280);
  static const calm = Duration(milliseconds: 450);
  static const breath = Duration(seconds: 10);
  static const enter = Easing.emphasizedDecelerate;
  static const exit = Easing.emphasizedAccelerate;
  static const move = Curves.easeInOutCubic;
}

/// Family names as declared in lane_ui/pubspec.yaml (files in assets/fonts/).
abstract final class LaneFonts {
  static const sans = 'Onest';
  static const hindi = 'AnekDevanagari';
  static const gujarati = 'AnekGujarati';
  static const hero = 'InstrumentSerif';
  static const mono = 'JetBrainsMono';
}
