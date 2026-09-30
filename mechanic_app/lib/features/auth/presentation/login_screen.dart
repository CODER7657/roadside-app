import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../app/router.dart';
import '../../../app/secure_window.dart';
import '../../../l10n/app_localizations.dart';
import '../application/auth.dart';
import '../data/auth_repository.dart';

/// `+91 98765 43210` for an Indian mobile in E.164; anything else as it is.
String displayPhone(String e164) {
  if (!e164.startsWith('+91') || e164.length != 13) return e164;
  final n = e164.substring(3);
  return '+91 ${n.substring(0, 5)} ${n.substring(5)}';
}

/// `0:24`.
String formatCountdown(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

String loginErrorText(AppLocalizations l10n, LoginError error) => switch (error) {
  LoginError.invalidNumber => l10n.login_error_invalid_number,
  LoginError.invalidCode => l10n.login_error_invalid_code,
  LoginError.codeExpired => l10n.login_error_code_expired,
  LoginError.tooManyAttempts => l10n.login_error_too_many,
  LoginError.network => l10n.login_error_network,
  LoginError.failed => l10n.login_error_failed,
};

/// C5 Phone login (PLAN §10 Common, wireframe C5, `LaneFlowScaffold` step 1 of 2). India
/// numbers only (SMS region policy).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _number;

  @override
  void initState() {
    super.initState();
    // Coming back from C6 ("Change number"): the number is there to edit.
    final phone = ref.read(loginProvider).phone;
    _number = TextEditingController(text: phone != null && phone.startsWith('+91') ? phone.substring(3) : '');
  }

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    final sent = await ref.read(loginProvider.notifier).sendCode(_number.text);
    if (sent && mounted) context.go(AppRoutes.loginCode);
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(loginProvider);
    final error = state.error;

    return SecureScreen(
      child: LaneFlowScaffold(
        step: 1,
        totalSteps: 2,
        stepLabel: l10n.flow_step_label(1, 2),
        title: l10n.login_phone_title,
        showBack: false,
        primary: LaneButton.primary(
          label: l10n.login_send_code,
          loading: state.busy,
          onPressed: state.busy ? null : _send,
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: lane.space.s32),
                child: Text(l10n.login_country_code, style: lane.text.title.copyWith(color: lane.color.ink)),
              ),
              SizedBox(width: lane.space.s12),
              Expanded(
                child: LaneTextField(
                  label: l10n.login_phone_label,
                  hint: l10n.login_phone_hint,
                  controller: _number,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  errorText: error == null ? null : loginErrorText(l10n, error),
                  onChanged: (_) {
                    if (error != null) ref.read(loginProvider.notifier).clearError();
                  },
                  onSubmitted: (_) => _send(),
                ),
              ),
            ],
          ),
          SizedBox(height: lane.space.s12),
          Text(l10n.login_phone_helper, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
        ],
      ),
    );
  }
}

/// C6 Enter OTP (wireframe C6, `LaneFlowScaffold` step 2 of 2). Android fills the code in by
/// itself (SMS Retriever, no SMS permission); typing all six digits verifies.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _code = '';
  Timer? _tick;

  /// Bumped to clear the boxes after a wrong code or a new SMS.
  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    // Redraws the "Resend in 0:24" countdown.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _back() {
    ref.read(loginProvider.notifier).changeNumber();
    context.go(AppRoutes.login);
  }

  Future<void> _verify() async {
    if (_code.length != 6) return;
    await ref.read(loginProvider.notifier).verify(_code);
    if (mounted && ref.read(loginProvider).error != null) {
      setState(() {
        _code = '';
        _attempt++;
      });
    }
  }

  Future<void> _resend() async {
    await ref.read(loginProvider.notifier).resend();
    if (mounted) setState(() => _attempt++);
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(loginProvider);
    final phone = state.phone;

    // Opened without a code on its way (e.g. after a restart): start at C5.
    if (!state.awaitingCode || phone == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.login);
      });
      return const Scaffold();
    }

    final error = state.error;
    final resendIn = ref.read(loginProvider.notifier).resendIn();

    return SecureScreen(
      child: LaneFlowScaffold(
        step: 2,
        totalSteps: 2,
        stepLabel: l10n.flow_step_label(2, 2),
        title: l10n.login_code_title,
        onBack: _back,
        primary: LaneButton.primary(
          label: l10n.login_verify,
          loading: state.busy,
          onPressed: state.busy || _code.length != 6 ? null : _verify,
        ),
        children: [
          Text(
            l10n.login_code_sent_to(displayPhone(phone)),
            style: lane.text.body.copyWith(color: lane.color.ink),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: LaneButton.ghost(label: l10n.login_change_number, onPressed: state.busy ? null : _back),
          ),
          SizedBox(height: lane.space.s16),
          LaneOtpInput(
            key: ValueKey(_attempt),
            length: 6,
            autofocus: true,
            enabled: !state.busy,
            errorText: error == null ? null : loginErrorText(l10n, error),
            onChanged: (v) => setState(() => _code = v),
            onCompleted: (v) {
              _code = v;
              unawaited(_verify());
            },
          ),
          SizedBox(height: lane.space.s16),
          Center(
            child: resendIn > Duration.zero
                ? Text(
                    l10n.login_resend_in(formatCountdown(resendIn)),
                    style: lane.text.body.copyWith(color: lane.color.inkMuted),
                  )
                : LaneButton.ghost(label: l10n.login_resend, onPressed: state.busy ? null : _resend),
          ),
        ],
      ),
    );
  }
}
