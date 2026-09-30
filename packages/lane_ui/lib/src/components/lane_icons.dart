// Phosphor duotone icons (MIT) and the problem / vehicle tiles (PLAN.md §6.12).
//
// Rendered from SVGs in assets/icons/ with flutter_svg rather than phosphor_flutter: that
// package hasn't been updated since May 2024, which fails the PLAN §3 "maintained in the
// last 12 months" rule. The shapes are identical: each file is a Phosphor core icon.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/lane_theme.dart';
import '../tokens/lane_colors.dart';
import '../tokens/lane_haptics.dart';
import 'lane_badges.dart';

/// Every icon Lane ships. Pictograms ([tinted]) are drawn with an ink line and a Beacon
/// fill; glyphs are one colour with a 20% duotone shape. The Phosphor name is in each doc.
enum LaneIcons {
  // Problems (PLAN §8 problemType)
  /// warning-diamond
  accident('problem_accident', tinted: true),

  /// car-battery
  battery('problem_battery', tinted: true),

  /// tire
  flatTyre('problem_flat_tyre', tinted: true),

  /// gas-pump
  fuel('problem_fuel', tinted: true),

  /// wrench
  other('problem_other', tinted: true),

  /// thermometer-hot
  overheating('problem_overheating', tinted: true),

  /// engine
  wontStart('problem_wont_start', tinted: true),

  // Vehicles (PLAN §8 vehicle type)
  /// motorcycle
  bike('vehicle_bike', tinted: true),

  /// car-profile
  car('vehicle_car', tinted: true),

  /// charging-station
  ev('vehicle_ev', tinted: true),

  /// moped
  scooter('vehicle_scooter', tinted: true),

  // UI pictograms
  /// phone
  call('ui_call', tinted: true),

  /// chat-circle-dots
  chat('ui_chat', tinted: true),

  /// traffic-cone
  cone('ui_cone', tinted: true),

  /// map-pin-area
  location('ui_location', tinted: true),

  /// toolbox
  mechanic('ui_mechanic', tinted: true),

  /// road-horizon
  road('ui_road', tinted: true),

  /// share-network
  share('ui_share', tinted: true),

  /// shield-check
  shield('ui_shield', tinted: true),

  /// siren
  sos('ui_sos', tinted: true),

  /// steering-wheel
  steering('ui_steering', tinted: true),

  /// qr-code
  upi('ui_upi', tinted: true),

  /// seal-check
  verified('ui_verified', tinted: true),

  // Glyphs (one colour)
  arrowLeft('glyph_arrow_left'),
  caretDoubleRight('glyph_caret_double_right'),
  caretRight('glyph_caret_right'),
  check('glyph_check'),
  checkCircle('glyph_check_circle'),
  cloudSlash('glyph_cloud_slash'),
  hourglass('glyph_hourglass_medium'),
  minusCircle('glyph_minus_circle'),
  navigation('glyph_navigation_arrow'),
  tray('glyph_tray'),
  warning('glyph_warning'),
  wifiSlash('glyph_wifi_slash'),
  wrench('glyph_wrench'),
  close('glyph_x'),
  star('glyph_star'),
  sun('glyph_sun');

  const LaneIcons(this.file, {this.tinted = false});

  final String file;

  /// Ink line + Beacon fill (pictogram) instead of a single colour (glyph).
  final bool tinted;

  String get asset => 'packages/lane_ui/assets/icons/$file.svg';

  /// The pictogram for a PLAN §8 `problemType`.
  static LaneIcons forProblem(String problemType) => switch (problemType) {
    'flat_tyre' => flatTyre,
    'battery' => battery,
    'wont_start' => wontStart,
    'overheating' => overheating,
    'accident' => accident,
    'fuel' => fuel,
    _ => other,
  };

  /// The pictogram for a PLAN §8 vehicle `type`.
  static LaneIcons forVehicle(String type) => switch (type) {
    'bike' => bike,
    'scooter' => scooter,
    'ev' => ev,
    _ => car,
  };
}

/// Draws a [LaneIcons] entry. Takes size and colour from the surrounding [IconTheme] like
/// Flutter's `Icon`. Decorative unless [semanticLabel] is given (Lane always pairs icons
/// with words, PLAN §6.16).
class LaneIcon extends StatelessWidget {
  const LaneIcon(this.icon, {super.key, this.size, this.color, this.semanticLabel});

  final LaneIcons icon;
  final double? size;

  /// The line colour (pictograms) or the whole glyph colour.
  final Color? color;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final s = size ?? theme.size ?? 24;
    final c = color ?? theme.color ?? context.lane.color.ink;
    final svg = SvgPicture.asset(
      icon.asset,
      width: s,
      height: s,
      theme: SvgTheme(currentColor: c),
      excludeFromSemantics: true,
    );
    return semanticLabel == null ? svg : Semantics(label: semanticLabel, image: true, child: svg);
  }
}

/// The soft Beacon well a pictogram sits in on tiles.
Color _well(LaneTheme lane) => lane.mode == LaneMode.glare
    ? lane.color.surface
    : Color.alphaBlend(LaneBrand.beacon.withValues(alpha: 0.14), lane.color.surface);

class _TileFrame extends StatelessWidget {
  const _TileFrame({required this.selected, required this.label, required this.onTap, required this.child});

  final bool selected;
  final String label;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    void tap() {
      LaneHaptics.select();
      onTap!();
    }

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap == null ? null : tap,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: lane.radius.r16,
          // Selected: a heavier ink edge (weight, not colour, carries the meaning).
          side: BorderSide(color: selected ? c.ink : c.line, width: selected ? 2 : lane.stroke.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap == null ? null : tap, child: child),
      ),
    );
  }
}

/// A problem in the 2-column picker (U4): pictogram in a Beacon well, then the word.
class ProblemTile extends StatelessWidget {
  const ProblemTile({super.key, required this.icon, required this.label, this.selected = false, this.onTap});

  final LaneIcons icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return _TileFrame(
      selected: selected,
      label: label,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: lane.space.s64 * 1.75),
        child: Padding(
          padding: EdgeInsets.all(lane.space.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Well(icon: icon, lane: lane),
                  const Spacer(),
                  if (selected) LaneIcon(LaneIcons.checkCircle, color: lane.color.ink, size: lane.space.s24),
                ],
              ),
              SizedBox(height: lane.space.s12),
              Text(label, style: lane.text.label.copyWith(color: lane.color.ink)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A saved vehicle (U2, U3, the Home vehicle chip): pictogram, name and its [PlateChip].
class VehicleTile extends StatelessWidget {
  const VehicleTile({
    super.key,
    required this.icon,
    required this.name,
    required this.regNo,
    this.detail,
    this.selected = false,
    this.onTap,
  });

  final LaneIcons icon;

  /// "Maruti Swift"
  final String name;
  final String regNo;

  /// "Petrol · default"
  final String? detail;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    return _TileFrame(
      selected: selected,
      label: [name, PlateChip.format(regNo), ?detail].join(', '),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(lane.space.s16),
        child: Row(
          children: [
            _Well(icon: icon, lane: lane),
            SizedBox(width: lane.space.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: lane.text.title.copyWith(color: c.ink)),
                  if (detail != null) Text(detail!, style: lane.text.caption.copyWith(color: c.inkMuted)),
                  SizedBox(height: lane.space.s8),
                  PlateChip(regNo: regNo),
                ],
              ),
            ),
            if (selected) LaneIcon(LaneIcons.checkCircle, color: c.ink, size: lane.space.s24),
          ],
        ),
      ),
    );
  }
}

class _Well extends StatelessWidget {
  const _Well({required this.icon, required this.lane});

  final LaneIcons icon;
  final LaneTheme lane;

  @override
  Widget build(BuildContext context) => Container(
    width: lane.touch.min,
    height: lane.touch.min,
    decoration: BoxDecoration(
      color: _well(lane),
      borderRadius: lane.radius.r12,
      border: lane.mode == LaneMode.glare
          ? Border.all(color: lane.color.line, width: lane.stroke.hairline)
          : null,
    ),
    alignment: Alignment.center,
    child: LaneIcon(icon, size: lane.space.s32, color: lane.color.ink),
  );
}

/// Lays tiles out in equal-height rows of [columns] (2 for problems, PLAN §10 U4). Works
/// inside any scroll view without shrink-wrapping.
class LaneTileGrid extends StatelessWidget {
  const LaneTileGrid({super.key, required this.children, this.columns = 2});

  final List<Widget> children;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < columns; j++) ...[
                if (j > 0) SizedBox(width: lane.space.s12),
                Expanded(child: i + j < children.length ? children[i + j] : const SizedBox.shrink()),
              ],
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, r) in rows.indexed) ...[if (i > 0) SizedBox(height: lane.space.s12), r],
      ],
    );
  }
}
