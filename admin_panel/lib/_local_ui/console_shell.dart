// ConsoleShell (PLAN §6.13): the admin template. Left rail nav, top filter bar, 12-column
// content up to 1440 wide with 24 margins. Night by default (set by the app).
//
// Lives here until it moves into lane_ui (PLAN §2: build it under _local_ui, then request it).
// It takes no app strings or providers, so the move is a copy.

import 'package:flutter/material.dart';
import 'package:lane_ui/lane_ui.dart';

class ConsoleNavItem {
  const ConsoleNavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final LaneIcons icon;
  final bool selected;
  final VoidCallback onTap;
}

class ConsoleShell extends StatelessWidget {
  const ConsoleShell({
    super.key,
    required this.title,
    required this.nav,
    required this.child,
    this.filters,
    this.trailing,
  });

  /// Below this width the rail shows icons only.
  static const compactBreakpoint = 1100.0;

  /// PLAN §6.9: admin content is at most 1440 wide.
  static const maxContentWidth = 1440.0;

  static const _railWidth = 248.0;

  final String title;
  final List<ConsoleNavItem> nav;
  final Widget child;

  /// The top filter bar, e.g. the city chips.
  final Widget? filters;

  /// Top-right: account and sign-out.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final compact = MediaQuery.sizeOf(context).width < compactBreakpoint;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Rail(
            nav: nav,
            compact: compact,
            width: compact ? lane.touch.critical + lane.space.s16 : _railWidth,
          ),
          VerticalDivider(
            width: lane.stroke.hairline,
            thickness: lane.stroke.hairline,
            color: lane.color.line,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: lane.space.s24, vertical: lane.space.s16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: lane.text.headline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (trailing != null) ...[Gap(lane.space.s16), trailing!],
                    ],
                  ),
                ),
                if (filters != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(lane.space.s24, 0, lane.space.s24, lane.space.s16),
                    child: Align(alignment: AlignmentDirectional.centerStart, child: filters),
                  ),
                Divider(
                  height: lane.stroke.hairline,
                  thickness: lane.stroke.hairline,
                  color: lane.color.line,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: maxContentWidth),
                      child: Padding(padding: EdgeInsets.all(lane.space.s24), child: child),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.nav, required this.compact, required this.width});

  final List<ConsoleNavItem> nav;
  final bool compact;
  final double width;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return ColoredBox(
      color: lane.color.surface,
      child: SizedBox(
        width: width,
        child: SafeArea(
          right: false,
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: lane.space.s24, horizontal: lane.space.s8),
            children: [
              Padding(
                padding: EdgeInsets.only(left: lane.space.s12, bottom: lane.space.s24),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: LaneIcon(LaneIcons.road, size: lane.space.s32),
                ),
              ),
              for (final item in nav) _RailItem(item: item, compact: compact),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({required this.item, required this.compact});

  final ConsoleNavItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final selected = item.selected;
    final row = Container(
      constraints: BoxConstraints(minHeight: lane.touch.min),
      padding: EdgeInsets.symmetric(horizontal: lane.space.s12),
      decoration: BoxDecoration(
        color: selected ? lane.color.surfaceSunken : null,
        borderRadius: lane.radius.r12,
        border: selected
            ? BorderDirectional(
                start: BorderSide(color: lane.color.beacon, width: lane.space.s4),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          LaneIcon(item.icon, size: lane.space.s24, color: selected ? lane.color.ink : lane.color.inkMuted),
          if (!compact) ...[
            Gap(lane.space.s12),
            Expanded(
              child: Text(
                item.label,
                style: lane.text.label.copyWith(color: selected ? lane.color.ink : lane.color.inkMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: lane.space.s4),
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        excludeSemantics: compact,
        child: Tooltip(
          message: compact ? item.label : '',
          child: InkWell(borderRadius: lane.radius.r12, onTap: item.onTap, child: row),
        ),
      ),
    );
  }
}
