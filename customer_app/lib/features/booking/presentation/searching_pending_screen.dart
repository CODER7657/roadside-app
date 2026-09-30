import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';

/// After `createBooking`: stands in for U8 Searching until #16 builds it (dispatch, radius,
/// cancel). Honest about what happened: the booking was sent.
class SearchingPendingScreen extends StatelessWidget {
  const SearchingPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    return LaneStatusScaffold(
      visual: BreathingPulse(child: LaneIcon(LaneIcons.mechanic, size: lane.space.s48)),
      title: l10n.searching_title,
      message: l10n.searching_body,
      primary: LaneButton.primary(label: l10n.booking_back_home, onPressed: () => context.go(AppRoutes.home)),
    );
  }
}
