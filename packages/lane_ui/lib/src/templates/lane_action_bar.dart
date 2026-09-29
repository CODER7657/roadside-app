// The sticky bottom action area shared by the Flow, Status and Form templates.
import 'package:flutter/material.dart';

import '../theme/lane_theme.dart';

/// Holds a template's primary (and optional secondary) action at the bottom of the screen,
/// full width, above the safe area and the keyboard (PLAN §6.3 "thumb first").
///
/// The primary gets at least [minHeight] (56 dp for flows, 64 dp for critical actions) and
/// grows with large text instead of clipping it.
class LaneActionBar extends StatelessWidget {
  const LaneActionBar({super.key, required this.primary, this.secondary, this.minHeight});

  final Widget primary;
  final Widget? secondary;

  /// Defaults to `lane.touch.primary` (56 dp).
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    Widget sized(Widget child) => ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight ?? lane.touch.primary, minWidth: double.infinity),
      child: child,
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(lane.space.s16, lane.space.s12, lane.space.s16, lane.space.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            sized(primary),
            if (secondary != null) ...[SizedBox(height: lane.space.s8), sized(secondary!)],
          ],
        ),
      ),
    );
  }
}

/// A back button with a localised label (Material's, which covers en / hi / gu), at least
/// 48 dp.
class LaneBackButton extends StatelessWidget {
  const LaneBackButton({super.key, this.onPressed});

  /// Defaults to `Navigator.maybePop`.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return IconButton(
      onPressed: onPressed ?? () => Navigator.maybePop(context),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      constraints: BoxConstraints.tightFor(width: lane.touch.min, height: lane.touch.min),
      icon: Icon(Icons.arrow_back_rounded, color: lane.color.ink),
    );
  }
}
