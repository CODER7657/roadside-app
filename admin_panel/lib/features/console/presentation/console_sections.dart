import 'package:flutter/material.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../l10n/app_localizations.dart';

/// The console's screens (PLAN §10 admin, wireframes A1–A6), in rail order.
enum ConsoleSection {
  dashboard('/dashboard', LaneIcons.road, 53),
  approvals('/approvals', LaneIcons.verified, 50),
  live('/live', LaneIcons.location, 53),
  prices('/prices', LaneIcons.upi, 51),
  complaints('/complaints', LaneIcons.chat, 54),
  settings('/settings', LaneIcons.wrench, 54);

  const ConsoleSection(this.path, this.icon, this.issue);

  final String path;
  final LaneIcons icon;

  /// The issue that builds the screen; shown until it lands.
  final int issue;

  String label(AppLocalizations l10n) => switch (this) {
    ConsoleSection.dashboard => l10n.console_nav_dashboard,
    ConsoleSection.approvals => l10n.console_nav_approvals,
    ConsoleSection.live => l10n.console_nav_live,
    ConsoleSection.prices => l10n.console_nav_prices,
    ConsoleSection.complaints => l10n.console_nav_complaints,
    ConsoleSection.settings => l10n.console_nav_settings,
  };

  static ConsoleSection fromPath(String path) =>
      values.firstWhere((s) => path.startsWith(s.path), orElse: () => ConsoleSection.dashboard);
}

/// Stand-in body for a section whose screen hasn't landed yet.
class SectionPlaceholder extends StatelessWidget {
  const SectionPlaceholder({super.key, required this.section});

  final ConsoleSection section;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LaneIcon(section.icon, size: lane.space.s64),
          Gap(lane.space.s24),
          Text(l10n.console_section_coming_title, style: lane.text.headline, textAlign: TextAlign.center),
          Gap(lane.space.s8),
          Text(
            l10n.console_section_coming_body(section.issue.toString()),
            style: lane.text.body.copyWith(color: lane.color.inkMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
