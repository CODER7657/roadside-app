import 'package:flutter/material.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../l10n/app_localizations.dart';

/// The full privacy notice, in the app's language (PLAN §12.12). Draft wording until the
/// policy in #55 is final; the published policy page will link here too.
class PrivacyNoticeScreen extends StatelessWidget {
  const PrivacyNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final sections = [
      (l10n.privacy_collect_title, l10n.privacy_collect_body),
      (l10n.privacy_use_title, l10n.privacy_use_body),
      (l10n.privacy_keep_title, l10n.privacy_keep_body),
      (l10n.privacy_rights_title, l10n.privacy_rights_body),
      (l10n.privacy_contact_title, l10n.privacy_contact_body),
    ];
    return LaneFormScaffold(
      title: l10n.privacy_title,
      children: [
        for (final (title, body) in sections)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: lane.text.title.copyWith(color: lane.color.ink)),
              SizedBox(height: lane.space.s8),
              Text(body, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
            ],
          ),
      ],
    );
  }
}
