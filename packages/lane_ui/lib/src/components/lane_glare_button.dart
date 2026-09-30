// The ☀ Glare button for map screens (PLAN.md §6.5 ③, §6.10).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ambient/ambient_controller.dart';
import '../templates/lane_map_scaffold.dart';
import '../theme/lane_theme.dart';
import 'lane_feedback.dart';
import 'lane_icons.dart';

/// Switches Glare (pure black on white, heavier type) on and off for reading in sunlight.
///
/// A tap is the user's **manual choice**, which PLAN §6.5 ③ ranks above everything else,
/// so it works even in Saver (a low battery in bright sun must not leave a dark screen).
/// Tapping again hands back to the automatic modes. TalkBack hears a toggle.
class LaneGlareButton extends ConsumerWidget {
  const LaneGlareButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = laneStrings(context);
    final on = ref.watch(ambientControllerProvider.select((s) => s.manual == LaneMode.glare));
    return Semantics(
      container: true,
      toggled: on,
      child: LaneMapButton(
        icon: LaneIcons.sun,
        tooltip: on ? strings.glare_turn_off : strings.glare_turn_on,
        onPressed: () => ref.read(ambientControllerProvider.notifier).setManual(on ? null : LaneMode.glare),
      ),
    );
  }
}
