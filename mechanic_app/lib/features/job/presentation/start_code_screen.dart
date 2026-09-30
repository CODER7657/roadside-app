import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../app/secure_window.dart';
import '../../../l10n/app_localizations.dart';
import '../../offers/application/offers.dart';
import '../application/job.dart';
import '../data/job_repository.dart';

/// Route of M6 for one job.
String startCodeRoute(String bookingId) => '/job/$bookingId/start';

/// The clock the lock countdown runs on. Tests override it.
final startCodeClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Minutes left on a lock, rounded up (at least 1 while locked).
int lockMinutesLeft(DateTime until, DateTime now) {
  final left = until.difference(now);
  if (left <= Duration.zero) return 0;
  return (left.inSeconds / 60).ceil();
}

/// M6 Start code (PLAN §9, §12.9; wireframe M6, `LaneFlowScaffold`): the mechanic types the
/// customer's 4-digit code, and `verifyStartOtp` checks it; the app never sees the code. 5 wrong
/// codes lock it for 10 minutes. The screen is kept out of screenshots (§12.7).
class StartCodeScreen extends ConsumerStatefulWidget {
  const StartCodeScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<StartCodeScreen> createState() => _StartCodeScreenState();
}

class _StartCodeScreenState extends ConsumerState<StartCodeScreen> {
  String _code = '';
  bool _busy = false;
  StartCodeResult? _last;

  /// Bumped to clear the boxes after a wrong code.
  int _attempt = 0;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Redraws the lock countdown.
    _tick = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted && _last is StartCodeLocked) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  DateTime? get _lockedUntil {
    final last = _last;
    if (last is! StartCodeLocked) return null;
    return last.until.isAfter(ref.read(startCodeClockProvider)()) ? last.until : null;
  }

  Future<void> _submit() async {
    if (_busy || _code.length != 4 || _lockedUntil != null) return;
    setState(() => _busy = true);
    final result = await ref.read(jobRepositoryProvider).verifyStartCode(widget.bookingId, _code);
    if (!mounted) return;
    switch (result) {
      case StartCodeAccepted() || StartCodeInvalidStatus():
        // M5 follows the booking: "Job in progress", or what happened instead.
        if (result is StartCodeAccepted) unawaited(LaneHaptics.statusAdvance());
        context.go(jobRoute(widget.bookingId));
      case StartCodeWrong() || StartCodeLocked() || StartCodeFailed():
        unawaited(LaneHaptics.error());
        setState(() {
          _busy = false;
          _last = result;
          _code = '';
          _attempt++;
        });
    }
  }

  String? _message(AppLocalizations l10n) {
    final lockedUntil = _lockedUntil;
    if (lockedUntil != null) {
      return l10n.start_code_locked(lockMinutesLeft(lockedUntil, ref.read(startCodeClockProvider)()));
    }
    return switch (_last) {
      StartCodeWrong(:final attemptsLeft) => l10n.start_code_wrong(attemptsLeft),
      StartCodeFailed() => l10n.start_code_failed,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final locked = _lockedUntil != null;
    final message = _message(l10n);

    return SecureScreen(
      child: LaneFlowScaffold(
        step: 1,
        totalSteps: 1,
        stepLabel: l10n.start_code_step,
        title: l10n.start_code_title,
        onBack: () => context.go(jobRoute(widget.bookingId)),
        primary: LaneButton.primary(
          label: l10n.start_code_submit,
          critical: true,
          loading: _busy,
          onPressed: _busy || locked || _code.length != 4 ? null : _submit,
        ),
        children: [
          Text(l10n.start_code_body, style: lane.text.body.copyWith(color: lane.color.ink)),
          SizedBox(height: lane.space.s24),
          LaneOtpInput(
            key: ValueKey(_attempt),
            autofocus: true,
            enabled: !_busy && !locked,
            errorText: message,
            onChanged: (v) => setState(() => _code = v),
            onCompleted: (v) {
              _code = v;
              unawaited(_submit());
            },
          ),
          SizedBox(height: lane.space.s16),
          Text(l10n.start_code_rule, style: lane.text.caption.copyWith(color: lane.color.inkMuted)),
        ],
      ),
    );
  }
}
