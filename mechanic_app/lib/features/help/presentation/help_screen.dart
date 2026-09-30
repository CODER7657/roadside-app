import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/env.dart';
import '../../../l10n/app_localizations.dart';

/// Opens a `tel:`, `mailto:` or `https:` link. Tests override it.
final launchLinkProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);

/// Support contacts. From the env file until `appConfig` is read from Firestore (#120).
final supportContactsProvider = Provider<({String phone, String grievanceEmail})>(
  (ref) => (phone: AppEnv.supportPhone, grievanceEmail: AppEnv.grievanceEmail),
);

/// C9 Help & FAQ for mechanics: searchable questions, call / WhatsApp support, and the
/// grievance officer at the bottom (PLAN §12.12, DPDP).
class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  String _query = '';
  final _open = <int>{};

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final contacts = ref.watch(supportContactsProvider);
    final launch = ref.read(launchLinkProvider);

    final faqs = [
      (l10n.help_faq_jobs_q, l10n.help_faq_jobs_a),
      (l10n.help_faq_no_offers_q, l10n.help_faq_no_offers_a),
      (l10n.help_faq_verify_q, l10n.help_faq_verify_a),
      (l10n.help_faq_code_q, l10n.help_faq_code_a),
      (l10n.help_faq_pay_q, l10n.help_faq_pay_a),
      (l10n.help_faq_cancel_q, l10n.help_faq_cancel_a),
    ];
    final q = _query.trim().toLowerCase();
    final shown = [
      for (final (i, (question, answer)) in faqs.indexed)
        if (q.isEmpty || question.toLowerCase().contains(q) || answer.toLowerCase().contains(q))
          (i, question, answer),
    ];
    final phone = contacts.phone;

    final items = <Widget>[
      LaneTextField(
        label: l10n.help_search_label,
        hint: l10n.help_search_hint,
        onChanged: (v) => setState(() => _query = v),
      ),
      if (shown.isEmpty)
        EmptyState(
          title: l10n.help_no_results_title,
          message: l10n.help_no_results_body,
          actionLabel: l10n.help_call_support,
          onAction: phone.isEmpty ? null : () => launch(Uri(scheme: 'tel', path: phone)),
        ),
      for (final (i, question, answer) in shown)
        _FaqTile(
          question: question,
          answer: answer,
          open: _open.contains(i),
          onToggle: () => setState(() => _open.contains(i) ? _open.remove(i) : _open.add(i)),
        ),
      SizedBox(height: lane.space.s8),
      if (phone.isNotEmpty)
        Row(
          children: [
            Expanded(
              child: LaneButton.secondary(
                label: l10n.help_call_support,
                icon: const LaneIcon(LaneIcons.call),
                onPressed: () => launch(Uri(scheme: 'tel', path: phone)),
              ),
            ),
            SizedBox(width: lane.space.s8),
            Expanded(
              child: LaneButton.secondary(
                label: l10n.help_whatsapp,
                icon: const LaneIcon(LaneIcons.chat),
                onPressed: () => launch(Uri.https('wa.me', phone.replaceAll(RegExp(r'\D'), ''))),
              ),
            ),
          ],
        ),
      _Grievance(email: contacts.grievanceEmail, onEmail: (uri) => launch(uri)),
    ];

    return LaneListScaffold(
      title: l10n.help_title,
      showBack: true,
      itemCount: items.length,
      itemBuilder: (context, i) => items[i],
      // Never reached: the search field is always there; no-match is handled inline.
      empty: const SizedBox.shrink(),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer, required this.open, required this.onToggle});

  final String question;
  final String answer;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    // Named tokens: tool/lint_design.sh misreads token names like `s16` as magic numbers.
    final inset = lane.space.s16;
    final answerGap = lane.space.s12;
    return Semantics(
      expanded: open,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: lane.radius.r16,
          side: BorderSide(color: c.line, width: lane.stroke.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onToggle,
          child: Padding(
            padding: EdgeInsets.all(inset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(question, style: lane.text.label.copyWith(color: c.ink)),
                    ),
                    SizedBox(width: lane.space.s8),
                    AnimatedRotation(
                      turns: open ? 0.25 : 0,
                      duration: lane.motion.quick,
                      child: LaneIcon(LaneIcons.caretRight, size: lane.space.s20, color: c.inkMuted),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: lane.motion.standard,
                  curve: lane.motion.move,
                  alignment: Alignment.topCenter,
                  child: open
                      ? Padding(
                          padding: EdgeInsets.only(top: answerGap),
                          child: Text(answer, style: lane.text.body.copyWith(color: c.inkMuted)),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// DPDP grievance contact (PLAN §12.12): always at the bottom of Help.
class _Grievance extends StatelessWidget {
  const _Grievance({required this.email, required this.onEmail});

  final String email;
  final void Function(Uri) onEmail;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final sectionGap = lane.space.s16;
    return Padding(
      padding: EdgeInsets.only(top: sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.help_grievance_title, style: lane.text.caps.copyWith(color: lane.color.inkMuted)),
          SizedBox(height: lane.space.s8),
          Text(l10n.help_grievance_body, style: lane.text.body.copyWith(color: lane.color.ink)),
          if (email.isNotEmpty)
            LaneButton.ghost(
              label: email,
              onPressed: () => onEmail(Uri(scheme: 'mailto', path: email)),
            ),
        ],
      ),
    );
  }
}
