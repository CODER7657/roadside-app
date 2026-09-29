import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';

/// Temporary home until U1 Home (#12). Proves the app boots into Lane with ARB strings.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    return LaneStatusScaffold(
      visual: LaneIcon(LaneIcons.road, size: lane.space.s64 + lane.space.s32),
      title: l10n.home_placeholder_title,
      message: l10n.home_placeholder_body,
      primary: LaneButton.secondary(label: l10n.home_help, onPressed: () => context.push(AppRoutes.help)),
    );
  }
}
