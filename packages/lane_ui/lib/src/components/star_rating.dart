// StarRating: 48 dp stars with a spring on select (PLAN.md §6.12, U14).
import 'package:flutter/material.dart';

import '../theme/lane_theme.dart';
import '../tokens/lane_haptics.dart';
import 'lane_feedback.dart';
import 'lane_icons.dart';

/// Five tappable stars (0 = not rated yet). The chosen stars spring up to full size; with
/// reduced motion they just change. TalkBack treats it as one slider ("3 of 5 stars"),
/// adjustable with the volume keys or a swipe up/down.
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.value, required this.label, this.onChanged});

  static const max = 5;

  /// 0–5.
  final int value;

  /// What is being rated, e.g. "Rating for Kiran Patel".
  final String label;
  final ValueChanged<int>? onChanged;

  void _set(int stars) {
    final v = stars.clamp(1, max);
    if (v == value) return;
    LaneHaptics.select().ignore();
    onChanged?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final strings = laneStrings(context);
    final motion = lane.motion;
    final enabled = onChanged != null;
    String read(int v) => v == 0 ? strings.star_rating_none : strings.star_rating_value(v);
    return Semantics(
      container: true,
      slider: true,
      enabled: enabled,
      label: label,
      value: read(value),
      increasedValue: value < max ? read(value + 1) : null,
      decreasedValue: value > 1 ? read(value - 1) : null,
      onIncrease: enabled && value < max ? () => _set(value + 1) : null,
      onDecrease: enabled && value > 1 ? () => _set(value - 1) : null,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < max; i++)
              GestureDetector(
                key: ValueKey('star-${i + 1}'),
                behavior: HitTestBehavior.opaque,
                onTap: enabled ? () => _set(i + 1) : null,
                child: SizedBox.square(
                  dimension: lane.touch.min,
                  child: Center(
                    child: AnimatedScale(
                      scale: i < value ? 1 : 0.8,
                      duration: motion.enabled ? motion.calm : Duration.zero,
                      curve: Curves.elasticOut,
                      child: LaneIcon(
                        LaneIcons.star,
                        size: lane.space.s32,
                        color: i < value ? lane.color.signal.wait : lane.color.inkSubtle,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
