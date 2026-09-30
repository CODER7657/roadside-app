import 'package:lane_ui/lane_ui.dart';

import '../../../l10n/app_localizations.dart';

/// The console's screens (PLAN §10 admin, wireframes A1–A6), in rail order.
enum ConsoleSection {
  dashboard('/dashboard', LaneIcons.road),
  approvals('/approvals', LaneIcons.verified),
  live('/live', LaneIcons.location),
  prices('/prices', LaneIcons.upi),
  complaints('/complaints', LaneIcons.chat),
  settings('/settings', LaneIcons.wrench);

  const ConsoleSection(this.path, this.icon);

  final String path;
  final LaneIcons icon;

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
