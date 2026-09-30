import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../vehicles/application/vehicles.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../application/booking_draft.dart';
import 'booking_labels.dart';

/// Steps in the booking flow: U4 problem, U5 photos, U6 location, U7 price.
const bookingSteps = 4;

/// U4 Problem picker: the vehicle being fixed and a 2-column grid of the 7 PLAN §8
/// problems. With no vehicle yet, it asks to add one first.
class ProblemScreen extends ConsumerWidget {
  const ProblemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(bookingDraftProvider);
    final notifier = ref.read(bookingDraftProvider.notifier);
    final vehicles = ref.watch(vehiclesProvider);
    final list = vehicles.value ?? const <SavedVehicle>[];
    // The draft's vehicle if it still exists, else the default.
    final vehicle =
        list.where((v) => v.id == draft.vehicleId).firstOrNull ?? ref.watch(defaultVehicleProvider);

    final ready = vehicle != null && draft.problem != null;
    void next() {
      notifier.setVehicle(vehicle!.id);
      context.push(AppRoutes.bookPhotos);
    }

    return LaneFlowScaffold(
      step: 1,
      totalSteps: bookingSteps,
      stepLabel: l10n.booking_step(1, bookingSteps),
      title: l10n.problem_title,
      primary: LaneButton.primary(label: l10n.booking_next, onPressed: ready ? next : null),
      children: [
        if (vehicles.isLoading && !vehicles.hasValue)
          SkeletonGroup.lines()
        else if (vehicle == null)
          EmptyState(
            illustration: LaneIcon(LaneIcons.car, size: lane.space.s64),
            title: l10n.problem_no_vehicle_title,
            message: l10n.problem_no_vehicle_body,
            actionLabel: l10n.problem_add_vehicle,
            onAction: () => context.push(AppRoutes.addVehicle),
          )
        else ...[
          Text(l10n.problem_vehicle_label, style: lane.text.label),
          SizedBox(height: lane.space.s8),
          VehicleTile(
            icon: LaneIcons.forVehicle(vehicle.vehicle.type.value),
            name: '${vehicle.vehicle.brand} ${vehicle.vehicle.model}',
            regNo: vehicle.vehicle.regNo,
            onTap: () => context.push(AppRoutes.vehicles),
          ),
        ],
        SizedBox(height: lane.space.s24),
        LaneTileGrid(
          children: [
            for (final p in ProblemType.values)
              ProblemTile(
                icon: LaneIcons.forProblem(p.value),
                label: l10n.problemType(p),
                selected: draft.problem == p,
                onTap: () => notifier.setProblem(p),
              ),
          ],
        ),
      ],
    );
  }
}
