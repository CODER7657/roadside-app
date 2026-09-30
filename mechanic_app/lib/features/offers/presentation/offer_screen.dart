import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart' hide PriceRange;

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../registration/presentation/registration_labels.dart';
import '../application/offers.dart';
import '../data/offer_alerts.dart';
import '../data/offer_repository.dart';

/// Why M4 closed without the mechanic getting the job.
enum OfferClosed { expired, withdrawn, taken, notAvailable }

/// M4 Incoming offer (PLAN §10, §11; wireframe M4): full screen, like an incoming call. Problem,
/// vehicle and plate, distance, area and price; **never the exact address or the customer's
/// phone** (those come with the job, after accept). A 30 s `CountdownRing` wraps
/// `LaneSlideToConfirm` (works with gloves), with Decline below.
class OfferScreen extends ConsumerStatefulWidget {
  const OfferScreen({super.key, required this.offerId});

  final String offerId;

  @override
  ConsumerState<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends ConsumerState<OfferScreen> {
  bool _responding = false;
  bool _failed = false;
  OfferClosed? _closed;

  /// Bumped to reset the slider after a failed attempt.
  int _attempt = 0;

  /// Read once: `ref` can't be used in dispose().
  late final OfferAlerts _alerts;

  @override
  void initState() {
    super.initState();
    _alerts = ref.read(offerAlertsProvider);
    unawaited(LaneHaptics.alert());
    unawaited(_alerts.showOverLockScreen(true));
  }

  @override
  void dispose() {
    unawaited(_alerts.showOverLockScreen(false));
    unawaited(_alerts.cancel(widget.offerId));
    super.dispose();
  }

  void _leave() => context.go(AppRoutes.home);

  Future<void> _respond({required bool accept}) async {
    if (_responding) return;
    setState(() {
      _responding = true;
      _failed = false;
    });
    final response = await ref.read(offerRepositoryProvider).respond(widget.offerId, accept: accept);
    if (!mounted) return;
    setState(() => _responding = false);
    switch (response.outcome) {
      case OfferOutcome.accepted:
        unawaited(LaneHaptics.statusAdvance());
        context.go(jobRoute(response.bookingId!));
      case OfferOutcome.declined:
        _leave();
      case OfferOutcome.expired:
        setState(() => _closed = OfferClosed.expired);
      case OfferOutcome.unavailable:
        setState(() => _closed = OfferClosed.taken);
      case OfferOutcome.notAvailable:
        setState(() => _closed = OfferClosed.notAvailable);
      case OfferOutcome.failed:
        unawaited(LaneHaptics.error());
        setState(() {
          _failed = true;
          _attempt++;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final offer = ref.watch(offerProvider(widget.offerId));

    // The server moved it on while M4 was open (declined elsewhere, withdrawn, expired).
    final closed =
        _closed ??
        switch (offer.value?.state) {
          OfferState.expired => OfferClosed.expired,
          OfferState.declined => OfferClosed.withdrawn,
          OfferState.accepted when !_responding => OfferClosed.taken,
          _ => null,
        };
    if (offer.hasValue && offer.value == null) return _ClosedView(reason: OfferClosed.taken, onBack: _leave);
    if (closed != null) return _ClosedView(reason: closed, onBack: _leave);
    final o = offer.value;
    if (o == null) return Scaffold(body: Center(child: SkeletonGroup.lines()));

    final now = ref.read(offerClockProvider)();
    if (!o.expiresAt.isAfter(now)) return _ClosedView(reason: OfferClosed.expired, onBack: _leave);

    return _PendingView(
      offer: o,
      elapsed: elapsedOf(o, now),
      attempt: _attempt,
      responding: _responding,
      failedMessage: _failed ? l10n.offer_failed : null,
      onAccept: () => _respond(accept: true),
      onDecline: () => _respond(accept: false),
      onExpired: () {
        if (mounted && !_responding) setState(() => _closed = OfferClosed.expired);
      },
    );
  }
}

class _PendingView extends StatelessWidget {
  const _PendingView({
    required this.offer,
    required this.elapsed,
    required this.attempt,
    required this.responding,
    required this.failedMessage,
    required this.onAccept,
    required this.onDecline,
    required this.onExpired,
  });

  final Offer offer;
  final Duration elapsed;
  final int attempt;
  final bool responding;
  final String? failedMessage;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onExpired;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final km = offer.distanceKm.toStringAsFixed(1);

    // Named token: tool/lint_design.sh misreads token names like `s8` as magic numbers.
    final rowGap = lane.space.s8;
    Widget row(String label, String value) => Padding(
      padding: EdgeInsets.only(bottom: rowGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
          ),
          SizedBox(width: lane.space.s12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: lane.text.label.copyWith(color: lane.color.ink),
            ),
          ),
        ],
      ),
    );

    return LaneStatusScaffold(
      visual: Column(
        children: [
          LaneIcon(problemIcon(offer.problemType), size: lane.space.s64 + lane.space.s16),
          SizedBox(height: lane.space.s12),
          Text(
            '${l10n.problemType(offer.problemType)} · ${l10n.vehicleType(offer.vehicleType)}',
            textAlign: TextAlign.center,
            style: lane.text.title.copyWith(color: lane.color.ink),
          ),
          SizedBox(height: lane.space.s8),
          PlateChip(regNo: offer.regNo, large: true),
          SizedBox(height: lane.space.s16),
          row(l10n.offer_distance, l10n.offer_distance_value(km)),
          // Locality only: the exact address comes with the job, after accept.
          row(l10n.offer_area, offer.areaName),
          SizedBox(height: lane.space.s8),
          PriceRange(min: offer.priceEstimate.min, max: offer.priceEstimate.max),
          if (failedMessage != null) ...[
            SizedBox(height: lane.space.s12),
            Semantics(
              liveRegion: true,
              child: Text(
                failedMessage!,
                textAlign: TextAlign.center,
                style: lane.text.body.copyWith(color: lane.color.signal.stop),
              ),
            ),
          ],
        ],
      ),
      title: l10n.offer_title,
      primary: CountdownRing(
        elapsed: elapsed,
        onExpired: onExpired,
        child: LaneSlideToConfirm(
          key: ValueKey(attempt),
          label: l10n.offer_slide_accept,
          onConfirmed: responding ? null : onAccept,
        ),
      ),
      secondary: LaneButton.ghost(label: l10n.offer_decline, onPressed: responding ? null : onDecline),
    );
  }
}

class _ClosedView extends StatelessWidget {
  const _ClosedView({required this.reason, required this.onBack});

  final OfferClosed reason;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final (title, body) = switch (reason) {
      OfferClosed.expired => (l10n.offer_expired_title, l10n.offer_expired_body),
      OfferClosed.withdrawn => (l10n.offer_withdrawn_title, l10n.offer_withdrawn_body),
      OfferClosed.taken => (l10n.offer_taken_title, l10n.offer_taken_body),
      OfferClosed.notAvailable => (l10n.offer_not_available_title, l10n.offer_not_available_body),
    };
    return LaneStatusScaffold(
      visual: LaneIcon(LaneIcons.hourglass, size: lane.space.s64 + lane.space.s32),
      title: title,
      message: body,
      primary: LaneButton.primary(label: l10n.offer_back, onPressed: onBack),
    );
  }
}

/// M5 placeholder: where an accepted job lands until Navigate (#30).
class JobAcceptedScreen extends StatelessWidget {
  const JobAcceptedScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    return LaneStatusScaffold(
      visual: LaneIcon(LaneIcons.checkCircle, size: lane.space.s64 + lane.space.s32),
      title: l10n.job_accepted_title,
      message: l10n.job_accepted_body,
      primary: LaneButton.secondary(label: l10n.offer_back, onPressed: () => context.go(AppRoutes.home)),
    );
  }
}
