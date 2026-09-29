// Space, radius, touch-target and elevation tokens (PLAN.md §6.9).
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

/// 4 pt spacing scale. Use nothing else: `Gap(lane.space.s8)`, `EdgeInsets.all(lane.space.s16)`.
@immutable
class LaneSpace {
  const LaneSpace();

  final double s4 = 4;
  final double s8 = 8;
  final double s12 = 12;
  final double s16 = 16;
  final double s20 = 20;
  final double s24 = 24;
  final double s32 = 32;
  final double s48 = 48;
  final double s64 = 64;

  /// Phone grid: 16 dp side margins, 12 dp gutters (4 columns).
  double get phoneMargin => s16;
  double get phoneGutter => s12;
}

/// Corner radii. Modest on purpose: signage, not bubbles.
@immutable
class LaneRadius {
  const LaneRadius();

  /// Chips, plate.
  final BorderRadius r6 = const BorderRadius.all(Radius.circular(6));

  /// Inputs, buttons.
  final BorderRadius r12 = const BorderRadius.all(Radius.circular(12));

  /// Cards.
  final BorderRadius r16 = const BorderRadius.all(Radius.circular(16));

  /// Dock and sheet top corners.
  final BorderRadius r24 = const BorderRadius.all(Radius.circular(24));

  /// Badges, toggles.
  final BorderRadius pill = const BorderRadius.all(Radius.circular(999));
}

/// Minimum touch targets. Keep at least `space.s8` between tappable things.
@immutable
class LaneTouch {
  const LaneTouch();

  final double min = 48;

  /// Primary buttons.
  final double primary = 56;

  /// Get Help, Accept, SOS, Pay.
  final double critical = 64;
}

/// Flat elevation: only the dock and floating map buttons cast [float].
@immutable
class LaneShadows {
  const LaneShadows._(this.float);

  static const day = LaneShadows._([
    BoxShadow(color: Color(0x1F000000), offset: Offset(0, 4), blurRadius: 16),
  ]);

  static const night = LaneShadows._([
    BoxShadow(color: Color(0x66000000), offset: Offset(0, 4), blurRadius: 16),
  ]);

  final List<BoxShadow> float;
}

/// Border widths: 1 px hairlines, 2 px in Glare mode.
@immutable
class LaneStroke {
  const LaneStroke._(this.hairline);

  static const normal = LaneStroke._(1);
  static const glare = LaneStroke._(2);

  final double hairline;
}
