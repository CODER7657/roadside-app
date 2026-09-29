// Haptic vocabulary (PLAN.md §6.11): the same event always feels the same.
import 'package:flutter/services.dart';

/// Apps call these instead of `HapticFeedback.*` (tool/lint_design.sh blocks the latter).
abstract final class LaneHaptics {
  /// Gap between the two pulses of [alert].
  static const alertGap = Duration(milliseconds: 120);

  /// Select a chip or tile.
  static Future<void> select() => HapticFeedback.selectionClick();

  /// Press a primary button.
  static Future<void> press() => HapticFeedback.lightImpact();

  /// The booking status advances (the Journey Rail flows).
  static Future<void> statusAdvance() => HapticFeedback.mediumImpact();

  /// SOS armed (hold complete) or a new offer for the mechanic: two heavy pulses.
  static Future<void> alert() async {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(alertGap);
    await HapticFeedback.heavyImpact();
  }

  /// Something failed.
  static Future<void> error() => HapticFeedback.vibrate();
}
