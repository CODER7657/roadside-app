import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../permissions/application/permission_service.dart';
import '../../permissions/presentation/permission_explainer_screen.dart';
import '../../registration/presentation/registration_labels.dart';
import '../application/online.dart';
import '../data/jobs_repository.dart';

/// Whole rupees with Indian grouping: ₹1,25,000.
String formatRupees(int amount) =>
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(amount);

/// M3 Dashboard (PLAN §10, wireframe M3, `LaneListScaffold`): the big online toggle, today's
/// jobs and earnings, and recent jobs.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool on) async {
    final controller = ref.read(onlineProvider.notifier);
    if (!on) return controller.goOffline();
    // C7 explainer first; nothing happens if the mechanic says Not now.
    if (!await ensurePermission(context, ref, AppPermission.location)) return;
    await controller.goOnline();
    // Offers arrive as notifications; asked once, and going online doesn't wait for it.
    if (context.mounted && ref.read(onlineProvider).isOnline) {
      await ensurePermission(context, ref, AppPermission.notifications);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final online = ref.watch(onlineProvider);
    final today = ref.watch(todaySummaryProvider).value ?? TodaySummary.empty;
    final timeFormat = DateFormat.jm(Localizations.localeOf(context).toLanguageTag());
    final sectionTop = lane.space.s24;
    final sectionBottom = lane.space.s8;

    final items = <Widget>[
      _OnlineCard(state: online, onChanged: (on) => _toggle(context, ref, on)),
      SizedBox(height: lane.space.s16),
      Row(
        children: [
          Expanded(
            child: _Stat(label: l10n.dashboard_jobs_today, value: '${today.count}'),
          ),
          SizedBox(width: lane.space.s12),
          Expanded(
            child: _Stat(label: l10n.dashboard_earned_today, value: formatRupees(today.earned)),
          ),
        ],
      ),
      Padding(
        // Named tokens: tool/lint_design.sh misreads token names like `s24` as magic numbers.
        padding: EdgeInsets.only(top: sectionTop, bottom: sectionBottom),
        child: Text(l10n.dashboard_recent_jobs, style: lane.text.title.copyWith(color: lane.color.ink)),
      ),
      if (today.jobs.isEmpty)
        Text(l10n.dashboard_no_jobs_yet, style: lane.text.body.copyWith(color: lane.color.inkMuted))
      else
        for (final job in today.jobs)
          LaneListTile(
            title: '${l10n.problemType(job.problemType)} · ${l10n.vehicleType(job.vehicleType)}',
            subtitle: timeFormat.format(job.completedAt.toLocal()),
            leading: LaneIcon(problemIcon(job.problemType), size: lane.space.s32),
            trailing: Text(formatRupees(job.amount), style: lane.text.label.copyWith(color: lane.color.ink)),
          ),
      SizedBox(height: lane.space.s24),
      LaneButton.secondary(label: l10n.home_help, onPressed: () => context.push(AppRoutes.help)),
    ];

    return LaneListScaffold(
      title: l10n.dashboard_title,
      itemCount: items.length,
      itemBuilder: (context, i) => items[i],
      // Never reached: the toggle is always there.
      empty: const SizedBox.shrink(),
    );
  }
}

class _OnlineCard extends ConsumerWidget {
  const _OnlineCard({required this.state, required this.onChanged});

  final OnlineState state;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final c = lane.color;
    final l10n = AppLocalizations.of(context);
    final (label, subtitle) = switch (state.phase) {
      OnlinePhase.online => (l10n.dashboard_online, l10n.dashboard_online_body),
      OnlinePhase.goingOnline => (l10n.dashboard_online, l10n.dashboard_finding_location),
      OnlinePhase.offline => (l10n.dashboard_offline, l10n.dashboard_offline_body),
    };
    // Named token: tool/lint_design.sh misreads token names like `s16` as magic numbers.
    final inset = lane.space.s16;

    return Container(
      padding: EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: state.isOnline ? c.signal.goTint : c.surface,
        borderRadius: lane.radius.r16,
        border: Border.all(color: state.isOnline ? c.signal.go : c.line, width: lane.stroke.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LaneSwitch(
            big: true,
            label: label,
            subtitle: subtitle,
            value: state.isOnline,
            onChanged: onChanged,
          ),
          if (state.problem case final problem?) ...[
            SizedBox(height: lane.space.s8),
            Semantics(
              liveRegion: true,
              child: Text(
                problem == OnlineProblem.gpsOff ? l10n.dashboard_gps_off : l10n.dashboard_lost_connection,
                style: lane.text.body.copyWith(color: c.ink),
              ),
            ),
            if (problem == OnlineProblem.gpsOff) ...[
              SizedBox(height: lane.space.s8),
              LaneButton.secondary(
                label: l10n.dashboard_turn_on_location,
                onPressed: () => ref.read(locationServiceProvider).openSettings(),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final inset = lane.space.s16;
    return Container(
      padding: EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: lane.color.surface,
        borderRadius: lane.radius.r16,
        border: Border.all(color: lane.color.line, width: lane.stroke.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: lane.text.caption.copyWith(color: lane.color.inkMuted)),
          SizedBox(height: lane.space.s4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: LaneRollingNumber(value: value),
          ),
        ],
      ),
    );
  }
}
