import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../l10n/app_localizations.dart';
import '../application/first_run.dart';

/// C3 Onboarding: three slides (help fast · live tracking · safe & verified), Next / Skip,
/// swipe to move. Lottie illustrations replace the pictograms when they're chosen (§6.6).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _index = 0;

  Future<void> _finish() async {
    await ref.read(firstRunProvider.notifier).completeOnboarding();
    if (mounted) context.go(FirstRunStep.consent);
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final slides = [
      (LaneIcons.mechanic, l10n.onboarding_slide1_title, l10n.onboarding_slide1_body),
      (LaneIcons.location, l10n.onboarding_slide2_title, l10n.onboarding_slide2_body),
      (LaneIcons.verified, l10n.onboarding_slide3_title, l10n.onboarding_slide3_body),
    ];
    final (icon, title, body) = slides[_index];
    final last = _index == slides.length - 1;

    return GestureDetector(
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v < 0 && !last) setState(() => _index++);
        if (v > 0 && _index > 0) setState(() => _index--);
      },
      child: LaneStatusScaffold(
        top: Padding(
          padding: EdgeInsets.fromLTRB(lane.space.s24, lane.space.s16, lane.space.s24, 0),
          child: LaneStepLane(step: _index + 1, total: slides.length),
        ),
        visual: AnimatedSwitcher(
          duration: lane.motion.standard,
          child: LaneIcon(icon, key: ValueKey(icon), size: lane.space.s64 * 2),
        ),
        title: title,
        message: body,
        primary: LaneButton.primary(
          label: last ? l10n.onboarding_start : l10n.onboarding_next,
          onPressed: last ? _finish : () => setState(() => _index++),
        ),
        secondary: last ? null : LaneButton.ghost(label: l10n.onboarding_skip, onPressed: _finish),
      ),
    );
  }
}
