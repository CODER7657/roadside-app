import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../application/first_run.dart';

/// C1 Splash: ThreeUI horizon still under a scrim, then on to the first unfinished
/// first-run step, or home. Force-update and remote checks join here with #92.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // Long enough to read the brand line; a quick fade with reduced motion.
      await Future<void>.delayed(context.lane.motion.calm);
      if (!mounted) return;
      context.go(ref.read(firstRunProvider).nextStep ?? AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    return LaneStatusScaffold(
      background: const AssetImage('assets/images/splash_horizon.jpg'),
      visual: LaneIcon(LaneIcons.road, size: lane.space.s64 + lane.space.s32),
      title: l10n.splash_tagline,
      message: l10n.splash_loading,
    );
  }
}
