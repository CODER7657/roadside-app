// StatCard (PLAN §6.12 admin parts): a caps label over an Instrument Serif hero number.
// Lives here until it moves into lane_ui; takes no app strings or providers.

import 'package:flutter/material.dart';
import 'package:lane_ui/lane_ui.dart';

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value, this.caption});

  static const minWidth = 180.0;

  final String label;

  /// Already formatted, e.g. "42", "91%", "14 min", "—".
  final String value;

  /// Small note under the number, e.g. where a missing value will come from.
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final inset = lane.space.s20;
    return Semantics(
      container: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: minWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: lane.color.surface,
            borderRadius: lane.radius.r16,
            border: Border.all(color: lane.color.line, width: lane.stroke.hairline),
          ),
          child: Padding(
            padding: EdgeInsets.all(inset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: lane.text.caps.copyWith(color: lane.color.inkMuted)),
                Gap(lane.space.s8),
                Text(value, style: lane.text.hero),
                if (caption != null) ...[
                  Gap(lane.space.s4),
                  Text(caption!, style: lane.text.caption.copyWith(color: lane.color.inkSubtle)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
