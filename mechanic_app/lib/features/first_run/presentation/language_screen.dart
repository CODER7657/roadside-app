import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../_local_ui/first_run_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../application/first_run.dart';

/// Each language written in its own script, so anyone can find theirs (PLAN §10).
/// Not translated: these are the languages' own names.
const _languages = [('en', 'English'), ('hi', 'हिन्दी'), ('gu', 'ગુજરાતી')];

/// C2 Language: picking a language switches the whole app at once.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final chosen = ref.watch(firstRunProvider.select((s) => s.languageCode));
    // Before a choice, the phone's language (if supported) is shown as selected.
    final selected = chosen ?? Localizations.localeOf(context).languageCode;
    final controller = ref.read(firstRunProvider.notifier);

    return LaneFlowScaffold(
      step: 1,
      totalSteps: 3,
      stepLabel: l10n.flow_step_label(1, 3),
      title: l10n.language_title,
      showBack: false,
      primary: LaneButton.primary(
        label: l10n.language_continue,
        onPressed: () async {
          if (chosen == null) await controller.setLanguage(selected);
          if (context.mounted) context.go(FirstRunStep.onboarding);
        },
      ),
      children: [
        Text(l10n.language_body, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
        SizedBox(height: lane.space.s24),
        for (final (code, name) in _languages) ...[
          LanguageTile(
            nativeName: name,
            selected: selected == code,
            onTap: () => controller.setLanguage(code),
          ),
          SizedBox(height: lane.space.s12),
        ],
      ],
    );
  }
}
