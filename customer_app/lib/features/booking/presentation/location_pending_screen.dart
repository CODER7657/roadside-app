import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';

/// Stands in for U6 Confirm location until #107 replaces this route.
class LocationPendingScreen extends StatelessWidget {
  const LocationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    return LaneStatusScaffold(
      visual: LaneIcon(LaneIcons.location, size: lane.space.s64 + lane.space.s32),
      title: l10n.home_placeholder_title,
      message: l10n.home_placeholder_body,
      primary: LaneButton.primary(label: l10n.booking_back_home, onPressed: () => context.go(AppRoutes.home)),
    );
  }
}
