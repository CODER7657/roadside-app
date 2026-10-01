import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../booking/application/estimate.dart';
import '../../booking/application/live_booking.dart';
import '../../contacts/application/contacts.dart';
import '../application/sos.dart';

/// U1·SOS from the red SOS button on the map.
Future<void> showSosSheet(BuildContext context) =>
    showLaneSheet<void>(context, builder: (_) => const SosSheet());

/// U1·SOS (PLAN §6.5 ⑤, §10; wireframe U1·SOS, `LaneSheet`): hold 1.5 s to open the SMS app
/// addressed to the emergency contacts with the location and live trip; Call 112; Share trip
/// during a booking. Letting go early does nothing.
class SosSheet extends ConsumerStatefulWidget {
  const SosSheet({super.key});

  @override
  ConsumerState<SosSheet> createState() => _SosSheetState();
}

class _SosSheetState extends ConsumerState<SosSheet> {
  var _sending = false;

  Future<void> _alert() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _sending = true);
    final outcome = await ref.read(sosProvider).alertContacts(l10n);
    if (!mounted) return;
    setState(() => _sending = false);
    switch (outcome) {
      case SosOutcome.opened:
        // The customer still presses send in the SMS app (no SEND_SMS permission).
        LaneToast.show(context, l10n.sos_opened);
        Navigator.of(context).pop();
      case SosOutcome.failed:
        unawaited(LaneHaptics.error());
        LaneToast.show(context, l10n.sos_failed);
    }
  }

  Future<void> _call112() async {
    final l10n = AppLocalizations.of(context);
    if (!await ref.read(sosProvider).call112() && mounted) LaneToast.show(context, l10n.sos_call_failed);
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final contacts = ref.watch(savedContactsProvider);
    final count = contacts.value?.length;
    final active = ref.watch(activeBookingProvider);
    final booking = active == null ? null : ref.watch(liveBookingProvider(active.bookingId)).value;
    final inTrip = booking != null && booking.status.isActive;
    final muted = lane.text.body.copyWith(color: lane.color.inkMuted);

    return LaneSheet(
      title: l10n.sos_title,
      primary: LaneButton.secondary(label: l10n.sos_call_112, onPressed: _call112),
      secondary: inTrip
          ? LaneButton.secondary(
              label: l10n.sos_share_trip,
              onPressed: () => ref.read(sosProvider).shareTrip(l10n),
            )
          : null,
      children: [
        Text(switch (count) {
          null => l10n.sos_body_loading,
          0 => l10n.sos_body_no_contacts,
          final n => l10n.sos_body(n),
        }, style: muted),
        SizedBox(height: lane.space.s24),
        Center(
          child: LaneHoldButton(
            label: 'SOS',
            semanticsHint: l10n.sos_hold_hint,
            size: lane.touch.critical * 2,
            onConfirmed: _sending ? null : _alert,
          ),
        ),
        SizedBox(height: lane.space.s12),
        Semantics(
          liveRegion: true,
          child: Text(
            _sending ? l10n.sos_opening : l10n.sos_hold_caption,
            textAlign: TextAlign.center,
            style: muted,
          ),
        ),
        if (count == 0) ...[
          SizedBox(height: lane.space.s16),
          LaneButton.ghost(
            label: l10n.sos_add_contacts,
            onPressed: () {
              // The sheet's context is gone once it closes; the router isn't.
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              unawaited(router.push(AppRoutes.emergencyContacts));
            },
          ),
        ],
        SizedBox(height: lane.space.s8),
      ],
    );
  }
}
