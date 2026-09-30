import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:lane_ui/lane_ui.dart' as ui show PriceRange;
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../help/presentation/help_screen.dart' show launchLinkProvider;
import '../application/estimate.dart';
import '../data/booking_service.dart';
import '../data/upi.dart';
import 'booking_rail.dart';

/// U12 Job in progress: the Working stop on the rail and how long the work has been going.
class WorkingView extends ConsumerStatefulWidget {
  const WorkingView({super.key, required this.booking});

  final Booking booking;

  @override
  ConsumerState<WorkingView> createState() => _WorkingViewState();
}

class _WorkingViewState extends ConsumerState<WorkingView> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final b = widget.booking;
    final name = b.mechanicCard?.name ?? '';
    final started = b.timestamps.started;
    final String message;
    if (started == null) {
      message = l10n.working_started;
    } else {
      final minutes = ref.read(laneClockProvider)().difference(started).inMinutes.clamp(0, 24 * 60);
      final at = DateFormat.Hm(Localizations.localeOf(context).toLanguageTag()).format(started.toLocal());
      message = l10n.working_since(at, minutes);
    }
    return LaneStatusScaffold(
      visual: Column(
        children: [
          bookingRail(l10n, b),
          SizedBox(height: lane.space.s32),
          LaneIcon(LaneIcons.wrench, size: lane.space.s64),
        ],
      ),
      title: l10n.working_title(name),
      message: message,
    );
  }
}

/// U13 Payment and what follows it (PLAN §9 Payment, #128): pay the mechanic's UPI directly,
/// say "I have paid", then wait for them to confirm; or report a problem.
class PaymentView extends ConsumerStatefulWidget {
  const PaymentView({super.key, required this.bookingId, required this.booking});

  final String bookingId;
  final Booking booking;

  @override
  ConsumerState<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends ConsumerState<PaymentView> {
  bool _busy = false;

  Future<void> _run(Future<void> Function(BookingService s) action) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action(ref.read(bookingServiceProvider));
      // The booking stream shows the new payment state.
    } on BookingException catch (e) {
      // Moved on already (the other side acted): the stream catches up; nothing to say.
      if (e.code != BookingException.invalidPaymentStatus && mounted) {
        LaneHaptics.error().ignore();
        LaneToast.show(context, l10n.payment_error_network);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pay(Uri uri) async {
    final l10n = AppLocalizations.of(context);
    final ok = await ref.read(launchLinkProvider)(uri);
    if (!ok && mounted) LaneToast.show(context, l10n.payment_no_upi_app);
  }

  Future<void> _copy(String upiId) async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: upiId));
    if (mounted) LaneToast.show(context, l10n.payment_upi_copied);
  }

  Future<void> _dispute() async {
    final l10n = AppLocalizations.of(context);
    final text = await showLaneSheet<String>(context, builder: (_) => const _DisputeSheet());
    if (text == null || !mounted) return;
    await _run((s) => s.disputePayment(widget.bookingId, text));
    if (mounted) LaneToast.show(context, l10n.payment_dispute_sent);
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final b = widget.booking;
    final card = b.mechanicCard;
    final name = card?.name ?? '';
    final amount = b.finalAmount;
    final home = LaneButton.primary(
      label: l10n.booking_back_home,
      onPressed: () => context.go(AppRoutes.home),
    );
    final problem = LaneButton.ghost(label: l10n.payment_problem, loading: _busy, onPressed: _dispute);

    switch (b.paymentStatus) {
      case PaymentStatus.customerMarkedPaid:
        return LaneStatusScaffold(
          visual: LaneIcon(LaneIcons.hourglass, size: lane.space.s64),
          title: l10n.payment_waiting_title(name),
          message: amount == null ? null : l10n.payment_waiting_body(ui.PriceRange.rupees(amount)),
          primary: home,
          secondary: problem,
        );
      case PaymentStatus.confirmed:
        return LaneStatusScaffold(
          visual: LaneIcon(LaneIcons.checkCircle, size: lane.space.s64),
          title: amount == null
              ? l10n.payment_confirmed_title_plain
              : l10n.payment_confirmed_title(ui.PriceRange.rupees(amount)),
          message: l10n.payment_confirmed_body(name),
          // U14 Rate & review arrives with #134.
          primary: home,
        );
      case PaymentStatus.disputed:
        return LaneStatusScaffold(
          visual: LaneIcon(LaneIcons.warning, size: lane.space.s64),
          title: l10n.payment_disputed_title,
          message: l10n.payment_disputed_body,
          primary: home,
          secondary: LaneButton.secondary(
            label: l10n.price_get_support,
            onPressed: () => context.push(AppRoutes.help),
          ),
        );
      case PaymentStatus.pending:
        break;
    }

    // Pending: the amount, and how to pay it.
    final upiId = card?.upiId ?? '';
    final payee = (card?.upiName ?? '').isNotEmpty ? card!.upiName : name;
    final uri = amount == null
        ? null
        : upiPayUri(upiId: upiId, payeeName: payee, amount: amount, bookingId: widget.bookingId);
    final inset = lane.space.s16;
    final gap = SizedBox(height: lane.space.s16);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(inset),
                children: [
                  bookingRail(l10n, b),
                  SizedBox(height: lane.space.s24),
                  Semantics(header: true, child: Text(l10n.payment_title(name), style: lane.text.headline)),
                  gap,
                  if (amount == null)
                    Text(l10n.payment_no_amount, style: lane.text.body)
                  else ...[
                    ui.PriceRange(min: amount, max: amount),
                    SizedBox(height: lane.space.s4),
                    Text(
                      l10n.payment_estimate_was(
                        ui.PriceRange.rupees(b.priceEstimate.min),
                        ui.PriceRange.rupees(b.priceEstimate.max),
                      ),
                      style: lane.text.caption.copyWith(color: lane.color.inkMuted),
                    ),
                  ],
                  gap,
                  if (uri != null) ...[
                    // Payee from KYC beside the ID, so the customer sees who gets the money.
                    Text(payee, style: lane.text.label),
                    Text(upiId, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
                    gap,
                    Center(
                      child: LaneQrCode(
                        data: uri.toString(),
                        semanticLabel: l10n.payment_qr_label(ui.PriceRange.rupees(amount!), payee),
                        size: lane.space.s64 * 3,
                      ),
                    ),
                    SizedBox(height: lane.space.s8),
                    Text(
                      l10n.payment_qr_hint,
                      textAlign: TextAlign.center,
                      style: lane.text.caption.copyWith(color: lane.color.inkMuted),
                    ),
                    SizedBox(height: lane.space.s8),
                    LaneButton.ghost(label: l10n.payment_copy_upi, onPressed: () => _copy(upiId)),
                  ] else if (amount != null)
                    Text(l10n.payment_cash(name), style: lane.text.body),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(inset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (uri != null) ...[
                    LaneButton.primary(
                      label: l10n.payment_pay_upi,
                      critical: true,
                      onPressed: () => _pay(uri),
                    ),
                    SizedBox(height: lane.space.s8),
                  ],
                  LaneButton.secondary(
                    label: l10n.payment_i_have_paid,
                    loading: _busy,
                    onPressed: amount == null ? null : () => _run((s) => s.markPaid(widget.bookingId)),
                  ),
                  SizedBox(height: lane.space.s8),
                  problem,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Something's wrong with the payment": a required description, then a complaint (#128).
class _DisputeSheet extends StatefulWidget {
  const _DisputeSheet();

  /// `disputePayment` accepts up to 1000 characters.
  static const maxText = 1000;

  @override
  State<_DisputeSheet> createState() => _DisputeSheetState();
}

class _DisputeSheetState extends State<_DisputeSheet> {
  String _text = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = _text.trim();
    return LaneSheet(
      title: l10n.payment_dispute_title,
      primary: LaneButton.danger(
        label: l10n.payment_dispute_send,
        onPressed: text.isEmpty ? null : () => Navigator.of(context).pop(text),
      ),
      secondary: LaneButton.ghost(label: l10n.cancel_keep_open, onPressed: () => Navigator.of(context).pop()),
      children: [
        LaneTextField(
          label: l10n.payment_dispute_label,
          hint: l10n.payment_dispute_hint,
          maxLength: _DisputeSheet.maxText,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (v) => setState(() => _text = v),
        ),
      ],
    );
  }
}
