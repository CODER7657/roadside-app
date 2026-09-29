// LaneMapScaffold + LaneDock: the one-thumb map layout (PLAN.md §6.5 ④, §6.13).
import 'package:flutter/material.dart';

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
  });

  final Widget map;
  final LaneDock dock;
  final Widget? overlay;

  /// Floating map buttons (recenter, ☀ Glare, SOS), top right, top to bottom.
  final List<Widget> actions;

  final ValueChanged<double>? onDockExtentChanged;

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
