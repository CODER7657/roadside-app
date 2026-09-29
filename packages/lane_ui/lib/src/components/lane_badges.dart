// SignalBadge and PlateChip (PLAN.md §6.12, §6.5 ② and ⑨).
import 'package:flutter/material.dart';

import '../theme/lane_theme.dart';
import '../tokens/lane_colors.dart';
import 'lane_icons.dart';

/// The six signal meanings (PLAN §6.7). Apps map booking statuses to these.
enum LaneSignal {
  /// `requested`
  wait(LaneIcons.hourglass),

  /// `accepted`, `arriving`
  route(LaneIcons.navigation),

  /// `arrived`, `completed`, paid
  go(LaneIcons.checkCircle),

  /// `in_progress`
  work(LaneIcons.wrench),

  /// SOS, danger, destructive only
  stop(LaneIcons.warning),

  /// `cancelled`, `no_mechanic_found`
  neutral(LaneIcons.minusCircle);

  const LaneSignal(this.defaultIcon);

  /// Phosphor duotone glyph shown with the word.
  final LaneIcons defaultIcon;

  Color colorIn(LaneSignals s) => switch (this) {
    wait => s.wait,
    route => s.route,
    go => s.go,
    work => s.work,
    stop => s.stop,
    neutral => s.neutral,
  };

  Color tintIn(LaneSignals s) => switch (this) {
    wait => s.waitTint,
    route => s.routeTint,
    go => s.goTint,
    work => s.workTint,
    stop => s.stopTint,
    neutral => s.neutralTint,
  };
}

/// Status pill: signal colour + icon + word, never colour alone (PLAN §6.16).
///
/// The label is `ink` on the tint; the signal colour is only for the icon (Day `route`
/// is 4.4:1 on its own tint, below the text minimum). Glare draws a 2 px outline instead of
/// a tint.
class SignalBadge extends StatelessWidget {
  const SignalBadge({super.key, required this.signal, required this.label, this.icon});

  final LaneSignal signal;
  final String label;

  /// Defaults to [LaneSignal.defaultIcon].
  final LaneIcons? icon;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final s = lane.color.signal;
    final color = signal.colorIn(s);
    final glare = lane.mode == LaneMode.glare;
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: lane.space.s12, vertical: lane.space.s4),
        decoration: BoxDecoration(
          color: signal.tintIn(s),
          borderRadius: lane.radius.pill,
          border: glare ? Border.all(color: color, width: lane.stroke.hairline) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LaneIcon(icon ?? signal.defaultIcon, color: color, size: lane.space.s16),
            SizedBox(width: lane.space.s8),
            Flexible(
              child: Text(label, style: lane.text.label.copyWith(color: lane.color.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

/// An Indian number plate: white, 1.5 px black border, a small IND band and mono letters,
/// the same in every mode so a mechanic can match it at the roadside (PLAN §6.5 ⑨).
///
/// It never truncates: it scales down to fit. Screen readers hear it character by character.
class PlateChip extends StatelessWidget {
  const PlateChip({super.key, required this.regNo, this.large = false});

  /// Plate colours are fixed, like a real plate.
  static const plate = Color(0xFFFFFFFF);
  static const ink = Color(0xFF000000);
  static const borderWidth = 1.5;

  final String regNo;

  /// Bigger text for the offer and job screens.
  final bool large;

  /// Formats a raw registration number for display: `GJ01AB1234` → `GJ 01 AB 1234`,
  /// `22BH1234AA` → `22 BH 1234 AA`. Anything else is upper-cased with its spaces
  /// normalised.
  static String format(String regNo) {
    final raw = regNo.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    final bh = RegExp(r'^(\d{2})(BH)(\d{4})([A-Z]{1,2})$').firstMatch(raw);
    if (bh != null) return [bh[1], bh[2], bh[3], bh[4]].join(' ');
    final std = RegExp(r'^([A-Z]{2})(\d{1,2})([A-Z]{0,3})(\d{1,4})$').firstMatch(raw);
    if (std != null) return [std[1], std[2], std[3], std[4]].where((p) => p!.isNotEmpty).join(' ');
    return regNo.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final text = format(regNo);
    final style = (large ? lane.text.title : lane.text.label).copyWith(
      fontFamily: lane.text.display.fontFamily,
      fontFamilyFallback: lane.text.display.fontFamilyFallback,
      color: ink,
      letterSpacing: large ? 1.5 : 1,
    );

    return Semantics(
      // Spaced letters so TalkBack reads "G J 0 1 …", not a word.
      label: text.replaceAll(' ', '').split('').join(' '),
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: plate,
            borderRadius: lane.radius.r6,
            border: Border.all(color: ink, width: borderWidth),
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: lane.space.s4),
                  alignment: Alignment.bottomCenter,
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: ink, width: borderWidth),
                    ),
                  ),
                  child: Text('IND', style: lane.text.caps.copyWith(color: LaneColors.day.signal.route)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: lane.space.s8, vertical: lane.space.s4),
                  child: Text(text, style: style, maxLines: 1, softWrap: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
