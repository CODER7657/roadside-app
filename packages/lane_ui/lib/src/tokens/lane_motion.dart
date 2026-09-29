// Motion tokens (PLAN.md §6.10).
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show Easing;

/// Durations and curves for every Lane animation.
///
/// When reduce-motion is on (system setting or Saver mode), [enabled] is false and every
/// duration becomes a 100 ms fade ([LaneMotion.reduced]). Custom animations must check
/// [enabled]; Lane components already do.
@immutable
class LaneMotion {
  const LaneMotion._({
    required this.enabled,
    required this.instant,
    required this.quick,
    required this.standard,
    required this.calm,
    required this.breath,
    required this.enter,
    required this.exit,
    required this.move,
  });

  static const full = LaneMotion._(
    enabled: true,
    instant: Duration(milliseconds: 100),
    quick: Duration(milliseconds: 180),
    standard: Duration(milliseconds: 280),
    calm: Duration(milliseconds: 450),
    breath: Duration(seconds: 10),
    enter: Easing.emphasizedDecelerate,
    exit: Easing.emphasizedAccelerate,
    move: Curves.easeInOutCubic,
  );

  static const reduced = LaneMotion._(
    enabled: false,
    instant: Duration(milliseconds: 100),
    quick: Duration(milliseconds: 100),
    standard: Duration(milliseconds: 100),
    calm: Duration(milliseconds: 100),
    breath: Duration.zero,
    enter: Curves.linear,
    exit: Curves.linear,
    move: Curves.linear,
  );

  /// False when motion is reduced: skip movement, springs and loops; fade instead.
  final bool enabled;

  /// Press states, toggles.
  final Duration instant;

  /// Chips, small reveals.
  final Duration quick;

  /// Dock snaps, page transitions, mode cross-fade.
  final Duration standard;

  /// Journey Rail flow, success check.
  final Duration calm;

  /// Searching pulse cycle. Zero when motion is reduced: show a still frame.
  final Duration breath;

  /// Things arriving.
  final Curve enter;

  /// Things leaving.
  final Curve exit;

  /// Things moving on screen.
  final Curve move;
}
