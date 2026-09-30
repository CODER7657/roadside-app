import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../l10n/app_localizations.dart';
import '../application/admin_session.dart';

/// A0 Admin sign-in (PLAN §10 admin, §12.11): Google only, for allow-listed admins. There's no
/// phone login and no sign-up. Non-admins land here with "Not authorised", already signed out.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  static const background = AssetImage('assets/images/warp-amber.jpg');

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _failed = false;

  Future<void> _signIn() async {
    setState(() => _failed = false);
    try {
      await ref.read(adminSessionProvider.notifier).signIn();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(adminSessionProvider);

    final signInButton = LaneButton.primary(
      label: l10n.signin_google_button,
      onPressed: _signIn,
      loading: session is SessionLoading,
    );

    return switch (session) {
      SessionUnconfigured() => LaneStatusScaffold(
        visual: LaneIcon(LaneIcons.cloudSlash, size: lane.space.s64),
        title: l10n.signin_unconfigured_title,
        message: l10n.signin_unconfigured_body,
      ),
      SessionNotAuthorised(:final email) => LaneStatusScaffold(
        background: SignInScreen.background,
        visual: LaneIcon(LaneIcons.warning, size: lane.space.s64, color: lane.color.ink),
        title: l10n.signin_not_authorised_title,
        message: l10n.signin_not_authorised_body(email ?? l10n.signin_unknown_account),
        primary: LaneButton.secondary(label: l10n.signin_not_authorised_retry, onPressed: _signIn),
      ),
      SessionLoading() || SessionSignedOut() || SessionAdmin() => LaneStatusScaffold(
        background: SignInScreen.background,
        visual: LaneIcon(LaneIcons.shield, size: lane.space.s64),
        title: session is SessionLoading ? l10n.signin_checking_title : l10n.signin_title,
        message: _failed ? l10n.signin_error_message : l10n.signin_body,
        primary: signInButton,
      ),
    };
  }
}
