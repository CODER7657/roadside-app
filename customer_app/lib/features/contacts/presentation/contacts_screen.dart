import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../l10n/app_localizations.dart';
import '../application/contacts.dart';
import '../data/contacts_repository.dart';

/// `+919876543021` → `+91 98xxx xx021` (wireframe U17): enough to recognise, not to read off
/// the screen. Other numbers keep only their last three digits.
String maskedPhone(String e164) {
  final m = RegExp(r'^\+91([6-9]\d)\d{5}(\d{3})$').firstMatch(e164);
  if (m != null) return '+91 ${m[1]}xxx xx${m[2]}';
  if (e164.length <= 4) return e164;
  return '${'x' * (e164.length - 3)}${e164.substring(e164.length - 3)}';
}

/// U17 Emergency contacts (PLAN §10 Customer 17, wireframe U17): up to three people SOS alerts.
/// Added from the phone's own picker (no contacts permission) or typed in; saved together.
class EmergencyContactsScreen extends ConsumerWidget {
  const EmergencyContactsScreen({super.key});

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final PickedContact? picked;
    try {
      picked = await ref.read(contactPickerProvider).pickPhone();
    } on PlatformException catch (e, s) {
      LaneLog.w('contact picker failed', error: e.code, stackTrace: s);
      if (context.mounted) LaneToast.show(context, l10n.contacts_picker_failed);
      return;
    } on MissingPluginException {
      if (context.mounted) LaneToast.show(context, l10n.contacts_picker_failed);
      return;
    }
    if (picked == null || !context.mounted) return;
    _report(context, ref.read(contactsEditorProvider.notifier).add(picked.name, picked.phone));
  }

  Future<void> _enter(BuildContext context, WidgetRef ref) async {
    final added = await showLaneSheet<bool>(context, builder: (_) => const _ManualContactSheet());
    if (added == true && context.mounted) FocusScope.of(context).unfocus();
  }

  static void _report(BuildContext context, ContactError? error) {
    if (error == null) return;
    final l10n = AppLocalizations.of(context);
    unawaited(LaneHaptics.error());
    LaneToast.show(context, switch (error) {
      ContactError.full => l10n.contacts_full,
      ContactError.invalidPhone => l10n.contacts_error_invalid,
      ContactError.duplicate => l10n.contacts_error_duplicate,
    });
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await ref.read(contactsEditorProvider.notifier).save();
    if (!context.mounted) return;
    if (ok) {
      unawaited(LaneHaptics.select());
      LaneToast.show(context, l10n.contacts_saved);
    } else {
      unawaited(LaneHaptics.error());
      LaneToast.show(context, l10n.contacts_save_failed);
    }
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final discard = await showLaneSheet<bool>(
      context,
      builder: (sheet) => LaneSheet(
        title: l10n.contacts_discard_title,
        primary: LaneButton.secondary(
          label: l10n.contacts_keep_editing,
          onPressed: () => Navigator.pop(sheet, false),
        ),
        secondary: LaneButton.ghost(
          label: l10n.contacts_discard,
          onPressed: () => Navigator.pop(sheet, true),
        ),
      ),
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final saved = ref.watch(savedContactsProvider);
    final draft = ref.watch(contactsEditorProvider);
    final muted = lane.text.body.copyWith(color: lane.color.inkMuted);

    final List<Widget> body;
    if (saved.hasError && !draft.loaded) {
      body = [ErrorState(message: l10n.contacts_error, onRetry: () => ref.invalidate(savedContactsProvider))];
    } else if (!draft.loaded) {
      body = [SkeletonGroup.lines(lines: 3)];
    } else {
      body = [
        Text(l10n.contacts_body, style: muted),
        SizedBox(height: lane.space.s16),
        if (draft.contacts.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: lane.space.s16),
            child: Text(l10n.contacts_empty, style: lane.text.body),
          ),
        for (final (i, c) in draft.contacts.indexed)
          LaneListTile(
            key: ValueKey(c.phone),
            title: c.name,
            subtitle: maskedPhone(c.phone),
            leading: LaneIcon(LaneIcons.call, size: lane.space.s32),
            trailing: IconButton(
              tooltip: l10n.contacts_remove(c.name),
              constraints: BoxConstraints.tightFor(width: lane.touch.min, height: lane.touch.min),
              onPressed: () => ref.read(contactsEditorProvider.notifier).remove(i),
              icon: LaneIcon(LaneIcons.close, color: lane.color.inkMuted),
            ),
          ),
        SizedBox(height: lane.space.s16),
        if (draft.full)
          Semantics(liveRegion: true, child: Text(l10n.contacts_full, style: muted))
        else ...[
          LaneButton.secondary(label: l10n.contacts_add_picker, onPressed: () => _pick(context, ref)),
          SizedBox(height: lane.space.s8),
          LaneButton.ghost(label: l10n.contacts_add_manual, onPressed: () => _enter(context, ref)),
        ],
      ];
    }

    return PopScope(
      canPop: !draft.dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard(context) && context.mounted) {
          ref.invalidate(contactsEditorProvider);
          Navigator.of(context).pop();
        }
      },
      child: LaneFormScaffold(
        title: l10n.contacts_title,
        primary: LaneButton.primary(
          label: l10n.contacts_save,
          loading: draft.saving,
          onPressed: draft.loaded && draft.dirty ? () => _save(context, ref) : null,
        ),
        children: body,
      ),
    );
  }
}

/// Typing a contact in: name (optional) and number.
class _ManualContactSheet extends ConsumerStatefulWidget {
  const _ManualContactSheet();

  @override
  ConsumerState<_ManualContactSheet> createState() => _ManualContactSheetState();
}

class _ManualContactSheetState extends ConsumerState<_ManualContactSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _add() {
    final l10n = AppLocalizations.of(context);
    final error = ref.read(contactsEditorProvider.notifier).add(_name.text, _phone.text);
    if (error == null) {
      Navigator.pop(context, true);
      return;
    }
    unawaited(LaneHaptics.error());
    setState(
      () => _error = switch (error) {
        ContactError.full => l10n.contacts_full,
        ContactError.invalidPhone => l10n.contacts_error_invalid,
        ContactError.duplicate => l10n.contacts_error_duplicate,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    return LaneSheet(
      title: l10n.contacts_manual_title,
      primary: LaneButton.primary(label: l10n.contacts_manual_add, onPressed: _add),
      children: [
        LaneTextField(
          label: l10n.contacts_name_label,
          controller: _name,
          maxLength: 60,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
        ),
        SizedBox(height: lane.space.s16),
        LaneTextField(
          label: l10n.contacts_phone_label,
          controller: _phone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.telephoneNumber],
          errorText: _error,
          onSubmitted: (_) => _add(),
        ),
      ],
    );
  }
}
