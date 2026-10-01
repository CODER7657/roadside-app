// LaneMapScaffold + LaneDock: the one-thumb map layout (PLAN.md §6.5 ④, §6.13).
import 'package:flutter/material.dart';

import '../components/lane_icons.dart';
import '../theme/lane_theme.dart';

/// The dock's three snap heights, as a fraction of the screen height.
enum LaneDockSnap {
  peek(0.22),
  half(0.5),
  full(0.9);

  const LaneDockSnap(this.fraction);

  final double fraction;
}

/// The bottom sheet on every map screen: a header, scrollable content and the primary
/// action pinned at the same spot on every screen (full width, 64 dp, 16 dp above the
/// bottom safe area). Drag it between [LaneDockSnap] heights.
class LaneDock extends StatelessWidget {
  const LaneDock({
    super.key,
    this.header,
    this.children = const [],
    this.primary,
    this.initial = LaneDockSnap.half,
    this.snaps = LaneDockSnap.values,
  });

  /// Pinned at the top of the dock (e.g. `AccuracyBadge`, `JourneyRail`).
  final Widget? header;

  final List<Widget> children;

  /// The screen's one primary action (PLAN §6.3 ③). Given at least 64 dp.
  final Widget? primary;

  final LaneDockSnap initial;
  final List<LaneDockSnap> snaps;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final sorted = [...snaps]..sort((a, b) => a.fraction.compareTo(b.fraction));
    final min = sorted.first.fraction;
    final max = sorted.last.fraction;

    return DraggableScrollableSheet(
      initialChildSize: initial.fraction.clamp(min, max),
      minChildSize: min,
      maxChildSize: max,
      snap: true,
      snapSizes: [for (final s in sorted) s.fraction],
      snapAnimationDuration: lane.motion.standard,
      builder: (context, scroll) => RepaintBoundary(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: lane.color.surface,
            borderRadius: BorderRadius.vertical(top: lane.radius.r24.topLeft),
            boxShadow: lane.shadow.float,
            border: Border(
              top: BorderSide(color: lane.color.line, width: lane.stroke.hairline),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: scroll,
                  slivers: [
                    SliverToBoxAdapter(child: _Handle(lane: lane)),
                    if (header != null)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(lane.space.s16, 0, lane.space.s16, lane.space.s12),
                        sliver: SliverToBoxAdapter(child: header),
                      ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: lane.space.s16),
                      sliver: SliverList.list(children: children),
                    ),
                  ],
                ),
              ),
              if (primary != null)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      lane.space.s16,
                      lane.space.s8,
                      lane.space.s16,
                      lane.space.s16,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: lane.touch.critical, minWidth: double.infinity),
                      child: primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle({required this.lane});

  final LaneTheme lane;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: lane.space.s12),
    child: Center(
      child: Container(
        width: lane.space.s32,
        height: lane.space.s4,
        decoration: BoxDecoration(color: lane.color.line, borderRadius: lane.radius.pill),
      ),
    ),
  );
}

/// Full-screen map, floating buttons top right, [LaneDock] at the bottom (PLAN §6.13).
///
/// [overlay] (e.g. `CenterPin`) is centred in the part of the map the dock leaves
/// visible, so the pin never hides under the dock. [onDockExtentChanged] reports the dock
/// height as a fraction of the screen, for camera padding (PLAN §6.7: fit the route above
/// the dock).
class LaneMapScaffold extends StatefulWidget {
  const LaneMapScaffold({
    super.key,
    required this.map,
    required this.dock,
    this.overlay,
    this.actions = const [],
    this.onDockExtentChanged,
    this.showBack = true,
  });

  final Widget map;
  final LaneDock dock;
  final Widget? overlay;

  /// Floating map buttons (recenter, ☀ Glare, SOS), top right, top to bottom.
  final List<Widget> actions;

  final ValueChanged<double>? onDockExtentChanged;

  /// A floating back button, top left, whenever this route can go back (never on a root
  /// screen such as Home). The system back gesture works either way.
  final bool showBack;

  @override
  State<LaneMapScaffold> createState() => _LaneMapScaffoldState();
}

class _LaneMapScaffoldState extends State<LaneMapScaffold> {
  late double _extent = widget.dock.initial.fraction;

  bool _onDock(DraggableScrollableNotification n) {
    if ((n.extent - _extent).abs() > 0.001) {
      setState(() => _extent = n.extent);
      widget.onDockExtentChanged?.call(n.extent);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final canPop = widget.showBack && (ModalRoute.of(context)?.canPop ?? false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, box) {
          final visibleMapHeight = box.maxHeight * (1 - _extent);
          return Stack(
            children: [
              Positioned.fill(child: widget.map),
              if (widget.overlay != null)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: visibleMapHeight,
                  child: IgnorePointer(child: Center(child: widget.overlay)),
                ),
              if (canPop)
                Positioned(
                  top: 0,
                  left: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(lane.space.s16),
                      child: LaneMapButton(
                        icon: LaneIcons.arrowLeft,
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                        onPressed: () => Navigator.maybePop(context),
                      ),
                    ),
                  ),
                ),
              if (widget.actions.isNotEmpty)
                Positioned(
                  top: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(lane.space.s16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final (i, a) in widget.actions.indexed) ...[
                            if (i > 0) SizedBox(height: lane.space.s8),
                            a,
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              NotificationListener<DraggableScrollableNotification>(
                onNotification: _onDock,
                child: widget.dock,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A round floating button on a map (back, recenter, ☀ Glare): `surface` fill, `shadow.float`,
/// 48 dp, with a tooltip that is also its screen-reader label.
class LaneMapButton extends StatelessWidget {
  const LaneMapButton({super.key, required this.icon, required this.tooltip, required this.onPressed});

  final LaneIcons icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final size = lane.touch.min;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: lane.color.surface,
        shape: BoxShape.circle,
        border: Border.all(color: lane.color.line, width: lane.stroke.hairline),
        boxShadow: lane.shadow.float,
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: BoxConstraints.tightFor(width: size, height: size),
        icon: LaneIcon(icon, color: lane.color.ink, size: lane.space.s24),
      ),
    );
  }
}

/// The SOS button for map screens (PLAN §6.13: top right, with ☀ Glare). Red is kept for SOS
/// (§6.5 ②) and it is a critical 64 dp target (§6.8). It only opens the SOS sheet; the 1.5 s
/// hold in there sends, so a pocket tap never alerts anyone.
class LaneSosButton extends StatelessWidget {
  const LaneSosButton({super.key, required this.tooltip, required this.onPressed});

  /// Also the screen-reader label, e.g. "Emergency SOS".
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final s = lane.color.signal;
    return Tooltip(
      message: tooltip,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(color: s.stop, shape: BoxShape.circle, boxShadow: lane.shadow.float),
          child: Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox.square(
                dimension: lane.touch.critical,
                child: Padding(
                  padding: EdgeInsets.all(lane.space.s12),
                  // Large text shrinks to fit the circle instead of covering the red.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    // "SOS" is understood in every language the app ships (PLAN §6.15).
                    child: Text('SOS', style: lane.text.label.copyWith(color: lane.color.onSignal)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
