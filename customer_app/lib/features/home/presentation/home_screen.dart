import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../booking/application/booking_draft.dart';
import '../../vehicles/application/vehicles.dart';

/// Temporary home until U1 Home (#12): shows the default vehicle (U1's vehicle chip will
/// read the same `defaultVehicleProvider`), starts a booking with Get help, and links to
/// vehicles (the vehicle tile) and help.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final vehicle = ref.watch(defaultVehicleProvider)?.vehicle;
    return LaneStatusScaffold(
      visual: Column(
        children: [
          LaneIcon(LaneIcons.road, size: lane.space.s64 + lane.space.s32),
          if (vehicle != null) ...[
            SizedBox(height: lane.space.s24),
            VehicleTile(
              icon: LaneIcons.forVehicle(vehicle.type.value),
              name: '${vehicle.brand} ${vehicle.model}',
              regNo: vehicle.regNo,
              onTap: () => context.push(AppRoutes.vehicles),
            ),
          ],
        ],
      ),
      title: l10n.home_placeholder_title,
      message: l10n.home_placeholder_body,
      primary: LaneButton.primary(
        label: l10n.home_get_help,
        critical: true,
        onPressed: () {
          ref.read(bookingDraftProvider.notifier).start(vehicleId: ref.read(defaultVehicleProvider)?.id);
          context.push(AppRoutes.bookProblem);
        },
      ),
      secondary: LaneButton.secondary(label: l10n.home_help, onPressed: () => context.push(AppRoutes.help)),
    );
  }
}
