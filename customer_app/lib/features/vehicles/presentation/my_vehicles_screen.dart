import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../application/vehicles.dart';
import '../data/vehicle_repository.dart';
import 'vehicle_labels.dart';

/// U3 My vehicles: tap to make one the default, swipe to delete (with Undo), add more.
class MyVehiclesScreen extends ConsumerWidget {
  const MyVehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final vehicles = ref.watch(vehiclesProvider);
    final add = LaneButton.primary(
      label: l10n.vehicles_add,
      onPressed: () => context.push(AppRoutes.addVehicle),
    );

    return vehicles.when(
      loading: () => LaneListScaffold(
        title: l10n.vehicles_title,
        showBack: true,
        itemCount: 2,
        itemBuilder: (context, _) => SkeletonGroup.lines(lines: 2),
        empty: const SizedBox.shrink(),
      ),
      error: (_, _) => Scaffold(
        body: Center(child: ErrorState(onRetry: () => ref.invalidate(vehiclesProvider))),
      ),
      data: (list) => LaneListScaffold(
        title: l10n.vehicles_title,
        showBack: true,
        primary: list.isEmpty ? null : add,
        itemCount: list.length,
        itemBuilder: (context, i) => _VehicleRow(saved: list[i]),
        empty: EmptyState(
          title: l10n.vehicles_empty_title,
          message: l10n.vehicles_empty_body,
          illustration: LaneIcon(LaneIcons.car, size: context.lane.space.s64),
          actionLabel: l10n.vehicles_add,
          onAction: () => context.push(AppRoutes.addVehicle),
        ),
      ),
    );
  }
}

class _VehicleRow extends ConsumerWidget {
  const _VehicleRow({required this.saved});

  final SavedVehicle saved;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(vehicleRepositoryProvider);
    await repo.delete(saved.id);
    if (!context.mounted) return;
    LaneToast.show(
      context,
      l10n.vehicles_removed,
      actionLabel: l10n.vehicles_undo,
      onAction: () => repo.restore(saved),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final v = saved.vehicle;
    final repo = ref.read(vehicleRepositoryProvider);
    // Named token: tool/lint_design.sh misreads `s24` as a magic number (#46).
    final swipeInset = lane.space.s24;
    final detail = v.isDefault ? '${l10n.fuel(v.fuel)} · ${l10n.vehicles_default_label}' : l10n.fuel(v.fuel);

    return Semantics(
      // Swiping isn't reachable with TalkBack, so delete is also a named action.
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.vehicles_delete): () => _delete(context, ref),
      },
      child: Dismissible(
        key: ValueKey(saved.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: swipeInset),
          decoration: BoxDecoration(color: lane.color.signal.stop, borderRadius: lane.radius.r16),
          child: Text(l10n.vehicles_delete, style: lane.text.label.copyWith(color: lane.color.onSignal)),
        ),
        onDismissed: (_) => _delete(context, ref),
        child: VehicleTile(
          icon: LaneIcons.forVehicle(v.type.value),
          name: '${v.brand} ${v.model}',
          regNo: v.regNo,
          detail: detail,
          selected: v.isDefault,
          onTap: v.isDefault ? null : () => repo.setDefault(saved.id),
        ),
      ),
    );
  }
}
