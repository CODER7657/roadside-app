// PriceRange: "₹350–₹600" with what's included (PLAN.md §6.12, §6.5 ⑦).
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/lane_theme.dart';
import 'lane_feedback.dart';

/// An estimate in whole rupees, in the mono display face, never truncated (it scales down
/// instead). [includes] is the short "what's included" line from `prices`. Reads as
/// "₹350 to ₹600".
class PriceRange extends StatelessWidget {
  const PriceRange({super.key, required this.min, required this.max, this.includes});

  final int min;
  final int max;
  final String? includes;

  static final _grouping = NumberFormat('#,##,##0', 'en_IN');

  /// `₹1,250` (Indian digit grouping: ₹1,25,000).
  static String rupees(int amount) => '₹${_grouping.format(amount)}';

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final strings = laneStrings(context);
    final low = rupees(min);
    final high = rupees(max);
    final text = min == max ? low : '$low–$high';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: min == max ? low : strings.price_range_semantics(low, high),
          excludeSemantics: true,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(text, maxLines: 1, style: lane.text.display.copyWith(color: lane.color.ink)),
          ),
        ),
        if (includes != null && includes!.isNotEmpty) ...[
          SizedBox(height: lane.space.s4),
          Text(includes!, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
        ],
      ],
    );
  }
}
