import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../booking/application/booking_draft.dart';
import '../../booking/application/estimate.dart';
import '../../booking/application/live_booking.dart';
import '../../booking/application/pickup.dart';
import '../../booking/data/plus_code.dart';
import '../../booking/presentation/tracking_map.dart';
import '../../help/presentation/help_screen.dart' show launchLinkProvider, supportContactsProvider;
import '../../permissions/application/permission_service.dart';
import '../../permissions/presentation/permission_explainer_screen.dart';
import '../../vehicles/application/vehicles.dart';
import '../application/home_location.dart';

/// U1 Home (PLAN §10 Customer 1): the map at the customer's location, the city they're in,
/// their default vehicle and GET HELP. Outside every active service area it becomes U1·Area:
/// the three cities and "Send my location by SMS". A booking already in progress is one
/// tap away. Never prompts for location by itself; "Show my location" goes through C7.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  HomeLocationNotifier get _location => ref.read(homeLocationProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _location.start(languageCode: Localizations.localeOf(context).languageCode);
    });
  }

  Future<void> _askLocation() async {
    final languageCode = Localizations.localeOf(context).languageCode;
    if (await ensurePermission(context, ref, AppPermission.location) && mounted) {
      await _location.locate(languageCode: languageCode);
    }
  }

  void _getHelp() {
    ref.read(bookingDraftProvider.notifier).start(vehicleId: ref.read(defaultVehicleProvider)?.id);
    context.push(AppRoutes.bookProblem);
  }

  Future<void> _smsLocation(LocationFixLike at) async {
    final l10n = AppLocalizations.of(context);
    final phone = ref.read(supportContactsProvider).phone;
    final link = 'https://maps.google.com/?q=${at.lat.toStringAsFixed(6)},${at.lng.toStringAsFixed(6)}';
    final body = l10n.home_sms_body(link, encodePlusCode(at.lat, at.lng));
    final ok = await ref.read(launchLinkProvider)(Uri.parse('sms:$phone?body=${Uri.encodeComponent(body)}'));
    if (!ok && mounted) LaneToast.show(context, l10n.home_sms_failed);
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final here = ref.watch(homeLocationProvider);
    final vehicle = ref.watch(defaultVehicleProvider)?.vehicle;
    final mapBuilder = ref.watch(trackingMapProvider);
    final languageCode = Localizations.localeOf(context).languageCode;
    final position = here.fix?.position ?? fallbackCenter;
    final supportPhone = ref.watch(supportContactsProvider).phone;

    // A booking the customer left mid-way (back to Home from Searching or tracking).
    final active = ref.watch(activeBookingProvider);
    final activeBooking = active == null ? null : ref.watch(liveBookingProvider(active.bookingId)).value;
    final inProgress = activeBooking != null && activeBooking.status.isActive;

    final city = here.city;
    final Widget? chip = city != null
        ? SignalBadge(
            signal: LaneSignal.go,
            icon: LaneIcons.navigation,
            label: city.name.inLanguage(languageCode),
          )
        : here.outside
        ? SignalBadge(signal: LaneSignal.neutral, label: l10n.home_city_outside)
        : null;

    final (String? status, String? actionLabel, VoidCallback? action) = switch (here.status) {
      HomeLocationStatus.idle => (l10n.home_no_location, l10n.home_show_location, _askLocation),
      HomeLocationStatus.locating => (l10n.home_locating, null, null),
      HomeLocationStatus.gpsOff => (
        l10n.location_gps_off,
        l10n.location_turn_on,
        () => ref.read(locationServiceProvider).openSettings(),
      ),
      HomeLocationStatus.noFix => (l10n.home_no_fix, l10n.location_retry, _askLocation),
      HomeLocationStatus.ready => (null, null, null),
    };

    final outside = here.outside && here.fix != null;
    final Widget primary = outside && supportPhone.isNotEmpty
        ? LaneButton.primary(
            label: l10n.home_sms_location,
            critical: true,
            onPressed: () => _smsLocation(position),
          )
        : LaneButton.primary(label: l10n.home_get_help, critical: true, onPressed: _getHelp);

    return LaneMapScaffold(
      map: mapBuilder(pickup: position),
      actions: const [LaneGlareButton()],
      dock: LaneDock(
        header: chip == null ? null : Align(alignment: Alignment.centerLeft, child: chip),
        primary: primary,
        children: [
          if (inProgress) ...[
            LaneListTile(
              title: l10n.home_booking_active,
              subtitle: l10n.home_booking_open,
              leading: LaneIcon(LaneIcons.mechanic, size: lane.space.s32),
              onTap: () => context.push(AppRoutes.booking(active!.bookingId)),
            ),
            SizedBox(height: lane.space.s16),
          ],
          if (outside) ...[
            Semantics(header: true, child: Text(l10n.home_outside_title, style: lane.text.title)),
            SizedBox(height: lane.space.s8),
            Text(l10n.home_outside_body, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
            SizedBox(height: lane.space.s16),
          ] else if (here.address != null) ...[
            Semantics(
              container: true,
              liveRegion: true,
              child: Text(here.address!, style: lane.text.bodyLarge),
            ),
            SizedBox(height: lane.space.s16),
          ],
          if (status != null) ...[
            Semantics(
              container: true,
              liveRegion: true,
              child: Text(status, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
            ),
            if (actionLabel != null) ...[
              SizedBox(height: lane.space.s8),
              LaneButton.secondary(label: actionLabel, onPressed: action),
            ],
            SizedBox(height: lane.space.s16),
          ],
          if (vehicle != null)
            VehicleTile(
              icon: LaneIcons.forVehicle(vehicle.type.value),
              name: '${vehicle.brand} ${vehicle.model}',
              regNo: vehicle.regNo,
              onTap: () => context.push(AppRoutes.vehicles),
            )
          else
            LaneButton.ghost(
              label: l10n.problem_add_vehicle,
              onPressed: () => context.push(AppRoutes.addVehicle),
            ),
          SizedBox(height: lane.space.s8),
          LaneButton.ghost(label: l10n.home_help, onPressed: () => context.push(AppRoutes.help)),
        ],
      ),
    );
  }
}

/// Anything with a latitude and longitude (a GPS reading or the fallback centre).
typedef LocationFixLike = ({double lat, double lng});

extension on LocalizedText {
  String inLanguage(String code) => switch (code) {
    'hi' => hi,
    'gu' => gu,
    _ => en,
  };
}
