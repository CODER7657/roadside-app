import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../permissions/application/permission_service.dart';
import '../../permissions/presentation/permission_explainer_screen.dart';
import '../application/pickup.dart';
import 'pickup_map.dart';

/// U6 Confirm location: the map drags under a fixed [CenterPin]; the dock shows the
/// accuracy, the address (or Plus Code), a landmark field and Confirm pickup. Handles no
/// permission, GPS off and no reading by letting the customer place the pin by hand.
class ConfirmLocationScreen extends ConsumerStatefulWidget {
  const ConfirmLocationScreen({super.key});

  /// `createBooking` caps the landmark at 120.
  static const maxLandmark = 120;

  @override
  ConsumerState<ConfirmLocationScreen> createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends ConsumerState<ConfirmLocationScreen> {
  PickupNotifier get _notifier => ref.read(pickupProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _locate());
  }

  Future<void> _locate() async {
    if (!mounted) return;
    final languageCode = Localizations.localeOf(context).languageCode;
    final permitted = await ensurePermission(context, ref, AppPermission.location);
    if (!mounted) return;
    await _notifier.locate(permitted: permitted, languageCode: languageCode);
  }

  Future<void> _turnOnGps() async {
    await ref.read(locationServiceProvider).openSettings();
    await _locate();
  }

  void _confirm() {
    if (_notifier.confirm()) context.push(AppRoutes.bookPrice);
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final pickup = ref.watch(pickupProvider);
    final mapBuilder = ref.watch(pickupMapProvider);
    final pin = pickup.pin;
    final fix = pickup.fix;

    final (String? problem, String? actionLabel, VoidCallback? action) = switch (pickup.status) {
      PickupStatus.noPermission => (l10n.location_no_permission, l10n.location_allow, _locate),
      PickupStatus.gpsOff => (l10n.location_gps_off, l10n.location_turn_on, _turnOnGps),
      PickupStatus.noFix => (l10n.location_no_fix, null, null),
      _ => (null, null, null),
    };
    final showBadge = pickup.status == PickupStatus.locating || fix != null;
    final address = pickup.addressLoading
        ? l10n.location_finding_address
        : pickup.address ?? (pin == null ? null : l10n.location_no_address);

    return LaneMapScaffold(
      map: pin == null
          ? ColoredBox(color: lane.color.surfaceSunken)
          : mapBuilder(center: pin, onMoveStarted: _notifier.dragStarted, onMoveEnded: _notifier.dragEnded),
      overlay: CenterPin(lifted: pickup.dragging),
      actions: [
        if (fix != null)
          IconButton.filledTonal(
            tooltip: l10n.location_recenter,
            constraints: BoxConstraints.tightFor(width: lane.touch.min, height: lane.touch.min),
            onPressed: _notifier.recenter,
            icon: LaneIcon(LaneIcons.navigation, size: lane.space.s24),
          ),
      ],
      dock: LaneDock(
        header: showBadge
            ? Align(
                alignment: Alignment.centerLeft,
                child: AccuracyBadge(meters: fix?.accuracyMeters),
              )
            : null,
        primary: LaneButton.primary(
          label: l10n.location_confirm,
          critical: true,
          onPressed: pickup.canConfirm ? _confirm : null,
        ),
        children: [
          Text(l10n.location_title, style: lane.text.title),
          SizedBox(height: lane.space.s4),
          Text(l10n.location_hint, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
          if (problem != null) ...[
            SizedBox(height: lane.space.s12),
            Semantics(container: true, liveRegion: true, child: Text(problem, style: lane.text.body)),
            if (actionLabel != null) ...[
              SizedBox(height: lane.space.s8),
              LaneButton.secondary(label: actionLabel, onPressed: action),
            ],
          ],
          if (address != null) ...[
            SizedBox(height: lane.space.s16),
            Semantics(container: true, liveRegion: true, child: Text(address, style: lane.text.bodyLarge)),
          ],
          if (pickup.plusCode case final code?) ...[
            SizedBox(height: lane.space.s4),
            Text(
              l10n.location_plus_code(code),
              style: lane.text.caption.copyWith(color: lane.color.inkMuted),
            ),
          ],
          SizedBox(height: lane.space.s16),
          LaneTextField(
            label: l10n.location_landmark_label,
            hint: l10n.location_landmark_hint,
            initialValue: pickup.landmark,
            maxLength: ConfirmLocationScreen.maxLandmark,
            textCapitalization: TextCapitalization.sentences,
            onChanged: _notifier.setLandmark,
          ),
          if (pickup.farFromFix) ...[
            SizedBox(height: lane.space.s16),
            Semantics(
              container: true,
              liveRegion: true,
              child: Text(l10n.location_far_warning, style: lane.text.body),
            ),
            SizedBox(height: lane.space.s8),
            LaneSwitch(
              label: l10n.location_someone_else,
              value: pickup.forSomeoneElse,
              onChanged: _notifier.setForSomeoneElse,
            ),
          ],
        ],
      ),
    );
  }
}
