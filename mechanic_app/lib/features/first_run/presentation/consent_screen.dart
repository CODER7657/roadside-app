import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../_local_ui/first_run_widgets.dart';
import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../application/first_run.dart';

/// C4 Privacy & consent (DPDP, PLAN §12.12) for mechanics: plain-language notice covering
/// KYC documents and on-the-job location, 18+ and agreement both required, then the consent
/// version and time are saved.
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _adult = false;
  bool _agreed = false;

  Future<void> _accept() async {
    await ref.read(firstRunProvider.notifier).acceptConsent();
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    return LaneFormScaffold(
      title: l10n.consent_title,
      showBack: false,
      primary: LaneButton.primary(label: l10n.consent_agree, onPressed: _adult && _agreed ? _accept : null),
      children: [
        Text(l10n.consent_intro, style: lane.text.bodyLarge.copyWith(color: lane.color.ink)),
        Column(
          children: [
            NoticeBullet(l10n.consent_point_collect),
            NoticeBullet(l10n.consent_point_location),
            NoticeBullet(l10n.consent_point_delete),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: LaneButton.ghost(
            label: l10n.consent_read_notice,
            onPressed: () => context.push(AppRoutes.privacy),
          ),
        ),
        ConsentCheck(label: l10n.consent_age, value: _adult, onChanged: (v) => setState(() => _adult = v)),
        ConsentCheck(
          label: l10n.consent_notice,
          value: _agreed,
          onChanged: (v) => setState(() => _agreed = v),
        ),
      ],
    );
  }
}
