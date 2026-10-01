import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../_local_ui/first_run_widgets.dart';
import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../contacts/application/contacts.dart';
import '../../first_run/application/first_run.dart';
import '../application/settings.dart';

/// Each language written in its own script, as on C2. Not translated.
const _languages = [('en', 'English'), ('hi', 'हिन्दी'), ('gu', 'ગુજરાતી')];

/// `+919876543210` → `+91 98765 43210` (wireframe U18). Other numbers as stored.
String formatPhone(String e164) {
  final m = RegExp(r'^\+91(\d{5})(\d{5})$').firstMatch(e164);
  return m == null ? e164 : '+91 ${m[1]} ${m[2]}';
}

/// U18 Profile & settings (PLAN §10 Customer 18, wireframe U18): who is signed in, language,
/// display mode, arrival chime, and the ways to emergency contacts, privacy and licenses.
/// Settings are kept on the phone, so they work offline and before sign-in.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static String displayModeLabel(AppLocalizations l10n, LaneMode? mode) => switch (mode) {
    LaneMode.day => l10n.profile_display_day,
    LaneMode.night => l10n.profile_display_night,
    LaneMode.glare => l10n.profile_display_glare,
    LaneMode.saver || null => l10n.profile_display_auto,
  };

  static String _displayModeHint(AppLocalizations l10n, LaneMode? mode) => switch (mode) {
    LaneMode.day => l10n.profile_display_day_hint,
    LaneMode.night => l10n.profile_display_night_hint,
    LaneMode.glare => l10n.profile_display_glare_hint,
    LaneMode.saver || null => l10n.profile_display_auto_hint,
  };

  Future<void> _chooseLanguage(BuildContext context, WidgetRef ref, String current) async {
    final l10n = AppLocalizations.of(context);
    final code = await showLaneSheet<String>(
      context,
      builder: (sheet) => LaneSheet(
        title: l10n.profile_language_title,
        children: [
          for (final (code, name) in _languages) ...[
            LanguageTile(
              nativeName: name,
              selected: code == current,
              onTap: () => Navigator.pop(sheet, code),
            ),
            SizedBox(height: context.lane.space.s12),
          ],
        ],
      ),
    );
    if (code != null && code != current) await ref.read(settingsProvider.notifier).setLanguage(code);
  }

  Future<void> _chooseDisplayMode(BuildContext context, WidgetRef ref, LaneMode? current) async {
    final l10n = AppLocalizations.of(context);
    // A record, so "Auto" (null) can be told apart from closing the sheet.
    final picked = await showLaneSheet<({LaneMode? mode})>(
      context,
      builder: (sheet) => LaneSheet(
        title: l10n.profile_display_mode,
        children: [
          for (final mode in kDisplayModes)
            _Choice(
              title: displayModeLabel(l10n, mode),
              subtitle: _displayModeHint(l10n, mode),
              selected: mode == current,
              onTap: () => Navigator.pop(sheet, (mode: mode)),
            ),
        ],
      ),
    );
    if (picked != null) await ref.read(settingsProvider.notifier).setDisplayMode(picked.mode);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final profile = ref.watch(profileProvider);
    final contacts = ref.watch(savedContactsProvider);
    // What is in effect now: the ☀ button on the map also sets the manual mode.
    final mode = ref.watch(ambientControllerProvider.select((s) => s.manual));
    final language =
        ref.watch(firstRunProvider.select((s) => s.languageCode)) ??
        Localizations.localeOf(context).languageCode;
    final caret = LaneIcon(LaneIcons.caretRight, size: lane.space.s20);
    // A stale value beats an error; an error shows even while Riverpod retries it.
    final Widget? account = switch (profile) {
      AsyncValue(:final value?) => _Account(user: value),
      AsyncValue(hasError: true) => ErrorState(
        message: l10n.profile_error,
        onRetry: () => ref.invalidate(profileProvider),
      ),
      AsyncValue(isLoading: true) => SkeletonGroup.lines(lines: 2),
      _ => null, // No account before sign-in (#96).
    };

    return LaneFormScaffold(
      title: l10n.profile_title,
      children: [
        ?account,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LaneListTile(
              title: l10n.profile_language,
              subtitle: _languages.firstWhere((l) => l.$1 == language, orElse: () => _languages.first).$2,
              trailing: caret,
              onTap: () => _chooseLanguage(context, ref, language),
            ),
            LaneListTile(
              title: l10n.profile_display_mode,
              subtitle: displayModeLabel(l10n, mode),
              trailing: caret,
              onTap: () => _chooseDisplayMode(context, ref, mode),
            ),
            LaneSwitch(
              label: l10n.profile_chime,
              subtitle: l10n.profile_chime_hint,
              value: settings.arrivalChime,
              onChanged: ref.read(settingsProvider.notifier).setArrivalChime,
            ),
            LaneListTile(
              title: l10n.profile_contacts,
              subtitle: switch (contacts) {
                AsyncData(:final value) => l10n.profile_contacts_count(value.length),
                _ => null,
              },
              trailing: caret,
              onTap: () => context.push(AppRoutes.emergencyContacts),
            ),
            LaneListTile(
              title: l10n.profile_privacy,
              trailing: caret,
              onTap: () => context.push(AppRoutes.privacy),
            ),
            LaneListTile(
              title: l10n.profile_licenses,
              trailing: caret,
              onTap: () => showLicensePage(context: context, applicationName: l10n.app_title),
            ),
          ],
        ),
        // Delete account (C10) and Sign out arrive with sign-in (#96).
      ],
    );
  }
}

/// The signed-in customer: name and their own number.
class _Account extends StatelessWidget {
  const _Account({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return Semantics(
      container: true,
      child: Row(
        children: [
          LaneIcon(LaneIcons.userCircle, size: lane.space.s48, color: lane.color.inkMuted),
          SizedBox(width: lane.space.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: lane.text.title),
                Text(formatPhone(user.phone), style: lane.text.body.copyWith(color: lane.color.inkMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One option in a single-choice sheet: the whole row is the target; the chosen one has a tick.
class _Choice extends StatelessWidget {
  const _Choice({required this.title, required this.subtitle, required this.selected, required this.onTap});

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: LaneListTile(
        title: title,
        subtitle: subtitle,
        trailing: selected
            ? LaneIcon(LaneIcons.checkCircle, color: lane.color.ink, size: lane.space.s24)
            : null,
        onTap: () {
          LaneHaptics.select();
          onTap();
        },
      ),
    );
  }
}
