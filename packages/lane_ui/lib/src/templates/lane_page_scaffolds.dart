// Flow, Status, List and Form templates (PLAN.md §6.13). Every screen uses exactly one.
// Templates take text from the app (ARB), never hard-coded.
import 'package:flutter/material.dart';

import '../theme/lane_theme.dart';
import 'lane_action_bar.dart';

/// Step progress drawn as a lane line: done segments in ink, the current one in Beacon,
/// the rest as the lane's base line.
class LaneStepLane extends StatelessWidget {
  const LaneStepLane({super.key, required this.step, required this.total})
    : assert(total > 0 && step >= 1 && step <= total);

  /// 1-based.
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return Row(
      children: [
        for (var i = 1; i <= total; i++) ...[
          if (i > 1) SizedBox(width: lane.space.s4),
          Expanded(
            child: AnimatedContainer(
              duration: lane.motion.calm,
              curve: lane.motion.move,
              height: lane.space.s4,
              decoration: BoxDecoration(
                color: i < step
                    ? lane.color.ink
                    : i == step
                    ? lane.color.beacon
                    : lane.color.line,
                borderRadius: lane.radius.pill,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// A step in a multi-step flow: step header ("2 of 4" + progress lane), scrollable
/// content, sticky primary (PLAN §6.13). Add vehicle, problem, photos, registration, payment.
class LaneFlowScaffold extends StatelessWidget {
  const LaneFlowScaffold({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.stepLabel,
    required this.title,
    required this.children,
    required this.primary,
    this.secondary,
    this.onBack,
    this.showBack = true,
  });

  final int step;
  final int totalSteps;

  /// Localised "2 of 4" (the template can't build the string itself).
  final String stepLabel;

  final String title;
  final List<Widget> children;
  final Widget primary;
  final Widget? secondary;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(lane.space.s4, lane.space.s4, lane.space.s16, 0),
              child: Row(
                children: [
                  if (showBack) LaneBackButton(onPressed: onBack) else SizedBox(width: lane.space.s12),
                  Expanded(
                    child: Semantics(
                      label: stepLabel,
                      excludeSemantics: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stepLabel, style: lane.text.caps.copyWith(color: lane.color.inkMuted)),
                          SizedBox(height: lane.space.s8),
                          LaneStepLane(step: step, total: totalSteps),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(lane.space.s16, lane.space.s24, lane.space.s16, lane.space.s16),
                children: [
                  Text(title, style: lane.text.headline),
                  SizedBox(height: lane.space.s24),
                  ...children,
                ],
              ),
            ),
            LaneActionBar(primary: primary, secondary: secondary),
          ],
        ),
      ),
    );
  }
}

/// Large centred status visual, one or two lines, action at the bottom (PLAN §6.13).
/// Searching, no mechanic, approval pending, job done.
///
/// [background] (a pre-rendered ThreeUI still, PLAN §6.17) sits under a scrim of at least
/// 60% `bg` so text keeps its contrast.
class LaneStatusScaffold extends StatelessWidget {
  const LaneStatusScaffold({
    super.key,
    required this.visual,
    required this.title,
    this.message,
    this.primary,
    this.secondary,
    this.background,
    this.scrimOpacity = minScrimOpacity,
    this.top,
  }) : assert(scrimOpacity >= minScrimOpacity && scrimOpacity <= 1);

  /// PLAN §6.17: always at least 60% `bg` over a background image.
  static const minScrimOpacity = 0.6;

  /// `BreathingPulse`, a success check or an illustration.
  final Widget visual;
  final String title;
  final String? message;
  final Widget? primary;
  final Widget? secondary;
  final ImageProvider? background;
  final double scrimOpacity;

  /// Optional row at the top (e.g. a close or back button).
  final Widget? top;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final content = SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?top,
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: lane.space.s24, vertical: lane.space.s24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight - lane.space.s48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      visual,
                      SizedBox(height: lane.space.s32),
                      Text(title, style: lane.text.headline, textAlign: TextAlign.center),
                      if (message != null) ...[
                        SizedBox(height: lane.space.s12),
                        Text(
                          message!,
                          style: lane.text.body.copyWith(color: lane.color.inkMuted),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (primary != null) LaneActionBar(primary: primary!, secondary: secondary),
          if (primary == null) SizedBox(height: MediaQuery.paddingOf(context).bottom + lane.space.s16),
        ],
      ),
    );

    return Scaffold(
      body: background == null
          ? content
          : Stack(
              fit: StackFit.expand,
              children: [
                Image(image: background!, fit: BoxFit.cover, excludeFromSemantics: true),
                ColoredBox(color: lane.color.bg.withValues(alpha: scrimOpacity)),
                content,
              ],
            ),
    );
  }
}

/// Large title, filter chips, list, empty state (PLAN §6.13). History, notifications,
/// vehicles, earnings. [empty] is required: every list names its next action (§6.3 ⑤).
class LaneListScaffold extends StatelessWidget {
  const LaneListScaffold({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    required this.empty,
    this.filters,
    this.primary,
    this.onRefresh,
    this.showBack = false,
    this.onBack,
    this.subtitle,
    this.controller,
  });

  final String title;

  /// A line under the title, e.g. who a chat is with and where they are.
  final String? subtitle;

  /// For lists that follow their newest item, like the chat.
  final ScrollController? controller;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Shown instead of the list when [itemCount] is 0 (`EmptyState` with an action).
  final Widget empty;

  /// A row of `LaneChip`s. Scrolls sideways when it doesn't fit.
  final List<Widget>? filters;

  final Widget? primary;
  final RefreshCallback? onRefresh;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final scroll = CustomScrollView(
      controller: controller,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(lane.space.s16, lane.space.s8, lane.space.s16, lane.space.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showBack)
                  Padding(
                    padding: EdgeInsets.only(bottom: lane.space.s8),
                    child: Transform.translate(
                      offset: Offset(-lane.space.s12, 0),
                      child: LaneBackButton(onPressed: onBack),
                    ),
                  ),
                Text(title, style: lane.text.headline),
                if (subtitle != null) ...[
                  SizedBox(height: lane.space.s4),
                  Text(subtitle!, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
                ],
              ],
            ),
          ),
        ),
        if (filters != null && filters!.isNotEmpty)
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(lane.space.s16, 0, lane.space.s16, lane.space.s16),
              child: Row(
                children: [
                  for (final (i, f) in filters!.indexed) ...[if (i > 0) SizedBox(width: lane.space.s8), f],
                ],
              ),
            ),
          ),
        if (itemCount == 0)
          SliverFillRemaining(hasScrollBody: false, child: Center(child: empty))
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(lane.space.s16, 0, lane.space.s16, lane.space.s24),
            sliver: SliverList.separated(
              itemCount: itemCount,
              itemBuilder: itemBuilder,
              separatorBuilder: (_, _) => SizedBox(height: lane.space.s8),
            ),
          ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        bottom: primary == null,
        child: Column(
          children: [
            Expanded(
              child: onRefresh == null ? scroll : RefreshIndicator(onRefresh: onRefresh!, child: scroll),
            ),
            if (primary != null) LaneActionBar(primary: primary!),
          ],
        ),
      ),
    );
  }
}

/// Title, fields, sticky save (PLAN §6.13). Profile, emergency contacts, settings.
class LaneFormScaffold extends StatelessWidget {
  const LaneFormScaffold({
    super.key,
    required this.title,
    required this.children,
    this.primary,
    this.showBack = true,
    this.onBack,
  });

  final String title;
  final List<Widget> children;

  /// The sticky save action.
  final Widget? primary;

  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return Scaffold(
      body: SafeArea(
        bottom: primary == null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showBack)
              Padding(
                padding: EdgeInsets.fromLTRB(lane.space.s4, lane.space.s4, 0, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: LaneBackButton(onPressed: onBack),
                ),
              ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(lane.space.s16, lane.space.s8, lane.space.s16, lane.space.s24),
                children: [
                  Text(title, style: lane.text.headline),
                  SizedBox(height: lane.space.s24),
                  for (final (i, c) in children.indexed) ...[if (i > 0) SizedBox(height: lane.space.s16), c],
                ],
              ),
            ),
            if (primary != null) LaneActionBar(primary: primary!),
          ],
        ),
      ),
    );
  }
}
