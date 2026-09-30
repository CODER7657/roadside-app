import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../help/presentation/help_screen.dart';
import '../application/registration.dart';

/// M2 Approval pending (wireframe: LaneStatusScaffold on the ThreeUI still). The wording
/// follows the mechanic type (PLAN §10.0): independents hear about the verification call.
/// Also shown, with its own wording, while an account is blocked.
class PendingScreen extends ConsumerWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(mechanicProfileProvider).value;
    final phone = ref.watch(supportContactsProvider).phone;
    final launch = ref.read(launchLinkProvider);
    final blocked = profile?.status == MechanicStatus.blocked;
    final independent = profile?.mechanicType == MechanicType.independent;
    // Named token: tool/lint_design.sh misreads token names like `s8` as magic numbers.
    final rowGap = lane.space.s8;

    final checklist = blocked
        ? const <(String, String, bool)>[]
        : [
            (independent ? l10n.pending_item_details : l10n.pending_item_shop, l10n.pending_received, true),
            (independent ? l10n.pending_item_id_selfie : l10n.pending_item_id, l10n.pending_checking, false),
            if (independent) (l10n.pending_item_call, l10n.pending_call_waiting, false),
          ];

    return LaneStatusScaffold(
      background: const AssetImage('assets/images/splash_horizon.jpg'),
      visual: Column(
        children: [
          LaneIcon(blocked ? LaneIcons.warning : LaneIcons.hourglass, size: lane.space.s64 + lane.space.s32),
          if (checklist.isNotEmpty) SizedBox(height: lane.space.s24),
          for (final (item, state, done) in checklist)
            Padding(
              padding: EdgeInsets.only(bottom: rowGap),
              // Item above its state, so long hi/gu text at 200% wraps instead of overflowing.
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LaneIcon(done ? LaneIcons.checkCircle : LaneIcons.hourglass, size: lane.space.s20),
                  SizedBox(width: lane.space.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item, style: lane.text.body.copyWith(color: lane.color.ink)),
                        Text(state, style: lane.text.caption.copyWith(color: lane.color.inkMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      title: blocked ? l10n.pending_blocked_title : l10n.pending_title,
      message: blocked
          ? l10n.pending_blocked_body
          : (independent ? l10n.pending_body_independent : l10n.pending_body_workshop),
      primary: phone.isEmpty
          ? null
          : LaneButton.secondary(
              label: l10n.help_call_support,
              icon: const LaneIcon(LaneIcons.call),
              onPressed: () => launch(Uri(scheme: 'tel', path: phone)),
            ),
      secondary: LaneButton.ghost(label: l10n.home_help, onPressed: () => context.push(AppRoutes.help)),
    );
  }
}
