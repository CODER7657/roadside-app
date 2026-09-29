// Loading, empty, error and feedback (PLAN.md §6.12, §6.3 ⑤ "never a dead end", §6.5 ⑩, §7.4).
import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/lane_localizations.dart';
import '../theme/lane_theme.dart';
import 'lane_button.dart';

/// Lane's own strings, falling back to English if an app forgot the delegate.
LaneLocalizations laneStrings(BuildContext context) =>
    LaneLocalizations.of(context) ?? lookupLaneLocalizations(const Locale('en'));

/// A still placeholder block (no shimmer: calmer, and cheaper on low-end phones).
/// Excluded from semantics; wrap a group in [SkeletonGroup] so it's announced once.
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({super.key, this.width, required this.height, this.radius});

  final double? width;
  final double height;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return ExcludeSemantics(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: lane.color.surfaceSunken,
          borderRadius: radius ?? lane.radius.r6,
          // Glare's sunken surface is white on white: outline instead (PLAN §6.7 Glare rule).
          border: lane.mode == LaneMode.glare
              ? Border.all(color: lane.color.line, width: lane.stroke.hairline)
              : null,
        ),
      ),
    );
  }
}

/// A set of skeleton blocks announced to screen readers once, as "Loading".
class SkeletonGroup extends StatelessWidget {
  const SkeletonGroup({super.key, required this.child});

  /// Skeleton lines for a typical list row or card.
  factory SkeletonGroup.lines({Key? key, int lines = 3}) =>
      SkeletonGroup(key: key, child: _SkeletonLines(lines));

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Semantics(label: laneStrings(context).skeleton_loading, container: true, child: child);
}

class _SkeletonLines extends StatelessWidget {
  const _SkeletonLines(this.lines);

  final int lines;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return LayoutBuilder(
      builder: (context, box) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines; i++) ...[
            if (i > 0) SizedBox(height: lane.space.s8),
            // The last line is shorter, like the end of a paragraph.
            SkeletonBlock(
              width: box.maxWidth * (i == lines - 1 && lines > 1 ? 0.6 : 1),
              height: lane.space.s16,
            ),
          ],
        ],
      ),
    );
  }
}

/// Nothing to show yet: an illustration, a title (brand hero type), one line and a
/// **required** action, so no list is ever a dead end (PLAN §6.3 ⑤).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.message,
    this.illustration,
  });

  final String title;
  final String? message;

  /// A Lottie or still (PLAN §6.6); defaults to a quiet icon.
  final Widget? illustration;

  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return Padding(
      padding: EdgeInsets.all(lane.space.s24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          illustration ?? Icon(Icons.inbox_outlined, size: lane.space.s64, color: lane.color.inkSubtle),
          SizedBox(height: lane.space.s24),
          Text(
            title,
            style: lane.text.hero.copyWith(color: lane.color.ink),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            SizedBox(height: lane.space.s12),
            Text(
              message!,
              style: lane.text.body.copyWith(color: lane.color.inkMuted),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: lane.space.s24),
          LaneButton.pill(label: actionLabel, onPressed: onAction),
        ],
      ),
    );
  }
}

/// Something failed: a calm neutral icon (red is only for danger), what happened, a retry
/// and optionally an alternative that works without the failed thing (e.g. "Send
/// location by SMS"). Never a bare "Error 500" (PLAN §6.15).
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.onRetry,
    this.title,
    this.message,
    this.retryLabel,
    this.alternativeLabel,
    this.onAlternative,
  }) : assert((alternativeLabel == null) == (onAlternative == null));

  /// Defaults to "Something went wrong" in the active language.
  final String? title;
  final String? message;

  final VoidCallback? onRetry;

  /// Defaults to "Try again".
  final String? retryLabel;

  final String? alternativeLabel;
  final VoidCallback? onAlternative;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final s = laneStrings(context);
    return Padding(
      padding: EdgeInsets.all(lane.space.s24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.cloud_off_rounded, size: lane.space.s48, color: lane.color.inkMuted),
          SizedBox(height: lane.space.s16),
          Text(
            title ?? s.error_state_title,
            style: lane.text.title.copyWith(color: lane.color.ink),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            SizedBox(height: lane.space.s8),
            Text(
              message!,
              style: lane.text.body.copyWith(color: lane.color.inkMuted),
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: lane.space.s24),
          LaneButton.primary(label: retryLabel ?? s.error_state_retry, onPressed: onRetry),
          if (alternativeLabel != null) ...[
            SizedBox(height: lane.space.s8),
            LaneButton.ghost(label: alternativeLabel!, onPressed: onAlternative),
          ],
        ],
      ),
    );
  }
}

/// A short message at the bottom of the screen, above the dock or action bar; it goes
/// away after [visibleFor]. One at a time: a new toast replaces the old one.
abstract final class LaneToast {
  /// PLAN §6.12.
  static const visibleFor = Duration(seconds: 4);

  static OverlayEntry? _current;
  static Timer? _timer;

  /// Shows [message]. [bottomOffset] lifts it above a dock or sticky button.
  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    double bottomOffset = 0,
  }) {
    hide();
    // The nearest overlay: it sits inside the Lane theme (LaneApp, Widgetbook and previews).
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => _Toast(
        message: message,
        actionLabel: actionLabel,
        onAction: onAction == null
            ? null
            : () {
                hide();
                onAction();
              },
        bottomOffset: bottomOffset,
      ),
    );
    _current = entry;
    overlay.insert(entry);
    _timer = Timer(visibleFor, hide);
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _current?.remove();
    _current = null;
  }
}

class _Toast extends StatelessWidget {
  const _Toast({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.bottomOffset,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double bottomOffset;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    return Positioned(
      left: lane.space.s16,
      right: lane.space.s16,
      bottom: MediaQuery.paddingOf(context).bottom + lane.space.s16 + bottomOffset,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: lane.motion.standard,
        curve: lane.motion.enter,
        builder: (context, t, child) => Opacity(
          opacity: t,
          // Announce as soon as it appears, not after the fade-in.
          alwaysIncludeSemantics: true,
          child: Transform.translate(offset: Offset(0, (1 - t) * lane.space.s16), child: child),
        ),
        child: Semantics(
          container: true,
          liveRegion: true,
          child: Material(
            color: c.ink,
            borderRadius: lane.radius.r12,
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: lane.space.s16, vertical: lane.space.s12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(message, style: lane.text.body.copyWith(color: c.surface)),
                  ),
                  if (actionLabel != null)
                    TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(minimumSize: Size(lane.touch.min, lane.touch.min)),
                      child: Text(actionLabel!, style: lane.text.label.copyWith(color: c.surface)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The honest-offline banner (PLAN §6.5 ⑩): neutral grey, never red, says what still works.
/// It slides in under the status bar (owning the top safe area while shown) and takes no
/// space when online. `LaneApp(offline: …)` places it for you.
class OfflineStrip extends StatelessWidget {
  const OfflineStrip({super.key, required this.offline, this.message});

  final bool offline;

  /// Defaults to "You're offline. Calls and SMS still work." in the active language.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    return AnimatedSize(
      duration: lane.motion.standard,
      curve: lane.motion.move,
      alignment: Alignment.topCenter,
      child: !offline
          ? const SizedBox(width: double.infinity)
          : Semantics(
              container: true,
              liveRegion: true,
              child: ColoredBox(
                color: c.inkMuted,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: lane.space.s16, vertical: lane.space.s8),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off_rounded, color: c.surface, size: lane.space.s20),
                        SizedBox(width: lane.space.s12),
                        Expanded(
                          child: Text(
                            message ?? laneStrings(context).offline_strip_message,
                            style: lane.text.label.copyWith(color: c.surface),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
