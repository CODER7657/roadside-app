import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart' hide PriceRange;

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../application/job.dart';
import '../data/job_repository.dart';

/// M8 Confirm payment (PLAN §9 Payment, §12.9; wireframe M8, `LaneStatusScaffold`), shown by M5
/// once the job is completed. The customer pays the mechanic's UPI directly; the app never holds
/// money. By `paymentStatus`:
///   pending              → waiting for the customer's "I have paid"
///   customer_marked_paid → "Customer says they paid ₹N": Yes, received / Not received
///   confirmed            → done
///   disputed             → the team looks into it (a complaint went to the admins, A5)
class PaymentView extends ConsumerStatefulWidget {
  const PaymentView({super.key, required this.bookingId, required this.booking});

  final String bookingId;
  final Booking booking;

  @override
  ConsumerState<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends ConsumerState<PaymentView> {
  bool _busy = false;

  Future<void> _run(Future<PaymentOutcome> Function() call) async {
    if (_busy) return;
    setState(() => _busy = true);
    final outcome = await call();
    if (!mounted) return;
    setState(() => _busy = false);
    // ok / invalidStatus: the booking stream shows where it stands now.
    if (outcome == PaymentOutcome.failed) {
      unawaited(LaneHaptics.error());
      LaneToast.show(context, AppLocalizations.of(context).pay_error);
    } else if (outcome == PaymentOutcome.ok) {
      unawaited(LaneHaptics.statusAdvance());
    }
  }

  Future<void> _notReceived() async {
    final text = await showLaneSheet<String>(context, builder: (sheet) => const _DisputeSheet());
    if (text == null || text.trim().isEmpty || !mounted) return;
    await _run(() => ref.read(jobRepositoryProvider).disputePayment(widget.bookingId, text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final b = widget.booking;
    final amount = PriceRange.rupees(b.finalAmount ?? 0);
    final firstName = b.customerCard?.name.trim().split(RegExp(r'\s+')).first ?? '';
    final repo = ref.read(jobRepositoryProvider);
    final back = LaneButton.secondary(label: l10n.offer_back, onPressed: () => context.go(AppRoutes.home));

    Widget amountVisual(String caps) => Column(
      children: [
        Text(caps, style: lane.text.caps.copyWith(color: lane.color.inkMuted)),
        SizedBox(height: lane.space.s8),
        Text(amount, style: lane.text.display.copyWith(color: lane.color.ink)),
      ],
    );

    return switch (b.paymentStatus) {
      PaymentStatus.pending => LaneStatusScaffold(
        visual: amountVisual(l10n.pay_waiting_caps),
        title: l10n.pay_waiting_title,
        message: l10n.pay_waiting_body,
        primary: back,
      ),
      PaymentStatus.customerMarkedPaid => LaneStatusScaffold(
        visual: amountVisual(l10n.pay_claimed_caps),
        title: l10n.pay_claimed_title,
        message: firstName.isEmpty ? l10n.pay_claimed_body_anon : l10n.pay_claimed_body(firstName),
        primary: LaneButton.primary(
          label: l10n.pay_received,
          critical: true,
          loading: _busy,
          onPressed: _busy ? null : () => _run(() => repo.confirmPayment(widget.bookingId)),
        ),
        secondary: LaneButton.secondary(label: l10n.pay_not_received, onPressed: _busy ? null : _notReceived),
      ),
      PaymentStatus.confirmed => LaneStatusScaffold(
        visual: LaneIcon(LaneIcons.checkCircle, size: lane.space.s64 + lane.space.s32),
        title: l10n.pay_confirmed_title,
        message: l10n.pay_confirmed_body(amount),
        primary: LaneButton.primary(label: l10n.offer_back, onPressed: () => context.go(AppRoutes.home)),
      ),
      PaymentStatus.disputed => LaneStatusScaffold(
        visual: LaneIcon(LaneIcons.hourglass, size: lane.space.s64 + lane.space.s32),
        title: l10n.pay_disputed_title,
        message: l10n.pay_disputed_body,
        primary: LaneButton.primary(label: l10n.offer_back, onPressed: () => context.go(AppRoutes.home)),
      ),
    };
  }
}

/// "Not received": what went wrong, for the admin reviewing the complaint (required).
class _DisputeSheet extends StatefulWidget {
  const _DisputeSheet();

  @override
  State<_DisputeSheet> createState() => _DisputeSheetState();
}

class _DisputeSheetState extends State<_DisputeSheet> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LaneSheet(
      title: l10n.pay_dispute_title,
      primary: LaneButton.primary(
        label: l10n.pay_dispute_send,
        onPressed: _text.text.trim().isEmpty ? null : () => Navigator.of(context).pop(_text.text),
      ),
      children: [
        LaneTextField(
          label: l10n.pay_dispute_label,
          hint: l10n.pay_dispute_hint,
          controller: _text,
          maxLines: 3,
          maxLength: 1000,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}
