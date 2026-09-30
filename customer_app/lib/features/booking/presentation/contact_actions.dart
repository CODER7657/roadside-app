import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../help/presentation/help_screen.dart' show launchLinkProvider;

/// Call and Chat with the assigned mechanic, side by side (wireframes U10, U12). Call needs the
/// mechanic's number from the booking; Chat opens U11.
class ContactActions extends ConsumerWidget {
  const ContactActions({super.key, required this.bookingId, required this.booking});

  final String bookingId;
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final card = booking.mechanicCard;
    final name = card?.name ?? '';
    final phone = card?.phone ?? '';

    Future<void> call() async {
      final ok = await ref.read(launchLinkProvider)(Uri(scheme: 'tel', path: phone));
      if (!ok && context.mounted) LaneToast.show(context, l10n.tracking_call_failed);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (phone.isNotEmpty) ...[
          Expanded(
            child: LaneButton.secondary(label: l10n.tracking_call(name), onPressed: call),
          ),
          SizedBox(width: lane.space.s8),
        ],
        Expanded(
          child: LaneButton.secondary(
            label: l10n.chat_open,
            onPressed: () => context.push(AppRoutes.chat(bookingId)),
          ),
        ),
      ],
    );
  }
}
