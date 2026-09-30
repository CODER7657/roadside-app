import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../vehicles/application/vehicles.dart';
import '../application/booking_draft.dart';
import '../application/estimate.dart';
import '../data/booking_service.dart';
import 'booking_labels.dart';
import 'problem_screen.dart' show bookingSteps;

/// U7 Price estimate: what's being fixed, where, and the price range for it; Book calls
/// `createBooking` with the draft's idempotency key, so a double tap or a retry after a
/// network error makes one booking. Every server error has a plain message and one action.
class PriceScreen extends ConsumerStatefulWidget {
  const PriceScreen({super.key});

  @override
  ConsumerState<PriceScreen> createState() => _PriceScreenState();
}

class _PriceScreenState extends ConsumerState<PriceScreen> {
  bool _booking = false;
  BookingException? _error;

  Future<void> _book() async {
    if (_booking) return;
    setState(() {
      _booking = true;
      _error = null;
    });
    try {
      final booking = await ref.read(bookingServiceProvider).createBooking(ref.read(bookingDraftProvider));
      if (!mounted) return;
      ref.read(activeBookingProvider.notifier).set(booking);
      // Replace the flow: back from Searching goes Home, never into a booked estimate.
      context.go(AppRoutes.searching);
    } on BookingException catch (e) {
      _errorHaptic();
      if (mounted) setState(() => _error = e);
    } catch (e) {
      _errorHaptic();
      if (mounted) setState(() => _error = const BookingException(BookingException.unknown));
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  void _errorHaptic() => LaneHaptics.error().ignore();

  /// The message and the one action for a failure (PLAN §7.4: never a dead end).
  (String, String?, VoidCallback?) _explain(AppLocalizations l10n, BookingException e) => switch (e.code) {
    BookingException.outOfArea => (
      l10n.price_error_out_of_area,
      l10n.price_change_pickup,
      () => context.pop(),
    ),
    BookingException.activeBookingExists => (
      l10n.price_error_active_booking,
      l10n.price_open_booking,
      () => context.go(AppRoutes.searching),
    ),
    BookingException.servicePaused => (l10n.price_error_paused, null, null),
    BookingException.priceUnavailable => (
      l10n.price_error_unavailable,
      l10n.price_get_support,
      () => context.push(AppRoutes.help),
    ),
    BookingException.vehicleNotFound => (
      l10n.price_error_vehicle,
      l10n.price_choose_vehicle,
      () => context.push(AppRoutes.vehicles),
    ),
    BookingException.rateLimited => (l10n.price_error_rate_limited, null, null),
    _ => (l10n.price_error_network, null, null),
  };

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(bookingDraftProvider);
    final estimate = ref.watch(estimateProvider);
    final vehicle = (ref.watch(vehiclesProvider).value ?? const [])
        .where((v) => v.id == draft.vehicleId)
        .firstOrNull
        ?.vehicle;
    final error = _error ?? (estimate.error is BookingException ? estimate.error! as BookingException : null);
    final ready = estimate is AsyncData<Estimate>;

    return LaneFlowScaffold(
      step: bookingSteps,
      totalSteps: bookingSteps,
      stepLabel: l10n.booking_step(bookingSteps, bookingSteps),
      title: l10n.price_title,
      primary: LaneButton.primary(
        label: l10n.price_book,
        critical: true,
        loading: _booking,
        // Only with a loaded estimate: out of area, no price etc. would fail on the server too.
        onPressed: ready ? _book : null,
      ),
      children: [
        if (vehicle != null && draft.problem != null)
          Text(
            '${vehicle.brand} ${vehicle.model} · ${l10n.problemType(draft.problem!)}',
            style: lane.text.label,
          ),
        if (draft.pickup case final pickup?) ...[
          SizedBox(height: lane.space.s4),
          Text(pickup.address, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
        ],
        SizedBox(height: lane.space.s24),
        switch (estimate) {
          AsyncData(:final value) => PriceRange(min: value.min, max: value.max, includes: value.includes),
          AsyncError() => const SizedBox.shrink(),
          _ => SkeletonGroup.lines(),
        },
        if (ready) ...[
          SizedBox(height: lane.space.s16),
          Text(l10n.price_note, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
        ],
        if (error != null) ...[
          SizedBox(height: lane.space.s16),
          _ErrorBlock(explanation: _explain(l10n, error)),
        ] else if (estimate.hasError)
          ErrorState(title: l10n.price_error_network, onRetry: () => ref.invalidate(estimateProvider)),
      ],
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({required this.explanation});

  final (String, String?, VoidCallback?) explanation;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final (message, actionLabel, action) = explanation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(container: true, liveRegion: true, child: Text(message, style: lane.text.body)),
        if (actionLabel != null) ...[
          SizedBox(height: lane.space.s8),
          LaneButton.secondary(label: actionLabel, onPressed: action),
        ],
      ],
    );
  }
}
