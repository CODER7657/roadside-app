import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;

import '../../../_local_ui/schematic_map.dart';
import '../../../l10n/app_localizations.dart';
import '../../approvals/data/mechanic_admin_api.dart' show AdminActionException, AdminActionFailure;
import '../../bookings/data/bookings_repository.dart';
import '../../console/application/city_filter.dart';
import '../../console/presentation/labels.dart';
import '../application/live_bookings.dart';

/// A3 Live bookings (PLAN §10 admin 3, wireframe A3): active bookings on a map and in a list;
/// the selected one shows its vertical Journey Rail and can be cancelled by the admin.
class LiveScreen extends ConsumerWidget {
  const LiveScreen({super.key});

  static const splitAbove = 1000.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final bookings = ref.watch(liveBookingsProvider);
    final list = bookings.value ?? const <BookingEntry>[];
    final selectedId = ref.watch(selectedBookingProvider);
    final selected = list.where((e) => e.id == selectedId).firstOrNull ?? list.firstOrNull;

    if (bookings.hasError && !bookings.hasValue) {
      return ErrorState(
        message: l10n.live_load_failed,
        onRetry: () => ref.invalidate(activeBookingsProvider),
      );
    }

    return LayoutBuilder(
      builder: (context, box) {
        final map = _LiveMap(bookings: list, selectedId: selected?.id);
        final listView = _LiveList(bookings: bookings, selectedId: selected?.id);
        final detail = selected == null
            ? Text(l10n.live_empty, style: lane.text.body.copyWith(color: lane.color.inkMuted))
            : _BookingDetail(entry: selected);
        final mapHeight = box.maxHeight * 0.5;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Filters(),
            Gap(lane.space.s16),
            Expanded(
              child: box.maxWidth >= splitAbove
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              SizedBox(height: mapHeight, child: map),
                              Gap(lane.space.s16),
                              Expanded(child: listView),
                            ],
                          ),
                        ),
                        Gap(lane.space.s24),
                        Expanded(flex: 2, child: SingleChildScrollView(child: detail)),
                      ],
                    )
                  : ListView(
                      children: [
                        SizedBox(height: mapHeight, child: map),
                        Gap(lane.space.s16),
                        SizedBox(height: mapHeight, child: listView),
                        Gap(lane.space.s24),
                        detail,
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final f = ref.watch(liveFiltersProvider);
    final n = ref.read(liveFiltersProvider.notifier);
    final groupGap = SizedBox(width: lane.space.s16);
    return Wrap(
      spacing: lane.space.s8,
      runSpacing: lane.space.s8,
      children: [
        for (final s in <BookingStatus?>[null, ...kActiveStatuses])
          LaneChip(
            label: s == null ? l10n.live_status_all : bookingStatusLabel(l10n, s),
            selected: f.status == s,
            onSelected: (_) => n.status(s),
          ),
        groupGap,
        for (final v in <VehicleType?>[null, ...VehicleType.values])
          LaneChip(
            label: v == null ? l10n.live_vehicle_all : vehicleLabel(l10n, v),
            selected: f.vehicle == v,
            onSelected: (_) => n.vehicle(v),
          ),
      ],
    );
  }
}

class _LiveMap extends ConsumerWidget {
  const _LiveMap({required this.bookings, required this.selectedId});

  final List<BookingEntry> bookings;
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = Language.values.firstWhere(
      (l) => l.value == Localizations.localeOf(context).languageCode,
      orElse: () => Language.en,
    );
    final city = ref.watch(cityFilterProvider);
    final areas = ref.watch(serviceAreasProvider).value ?? const <CityId, ServiceArea>{};
    final live = selectedId == null ? null : ref.watch(liveLocationProvider(selectedId!)).value;
    return SchematicMap(
      semanticLabel: l10n.live_map_label(bookings.length),
      areas: [
        for (final MapEntry(key: id, value: a) in areas.entries)
          if (city == null || id == city)
            MapArea(
              lat: a.center.latitude,
              lng: a.center.longitude,
              radiusKm: a.radiusKm,
              label: a.name.of(language),
            ),
      ],
      dots: [
        for (final e in bookings)
          MapDot(
            id: e.id,
            lat: e.booking.pickup.geopoint.latitude,
            lng: e.booking.pickup.geopoint.longitude,
            signal: bookingSignal(e.booking.status),
            label: bookingRef(e.id),
          ),
      ],
      selectedId: selectedId,
      mechanic: live == null
          ? null
          : (lat: live.mechanicGeopoint.latitude, lng: live.mechanicGeopoint.longitude),
      onTapDot: (id) => ref.read(selectedBookingProvider.notifier).select(id),
    );
  }
}

class _LiveList extends ConsumerWidget {
  const _LiveList({required this.bookings, required this.selectedId});

  final AsyncValue<List<BookingEntry>> bookings;
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    if (!bookings.hasValue) {
      return SkeletonGroup(child: SkeletonBlock(height: lane.touch.critical * 2));
    }
    final list = bookings.requireValue;
    if (list.isEmpty) {
      return Center(
        child: Text(l10n.live_empty, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
      );
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final e = list[i];
        final b = e.booking;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: e.id == selectedId ? lane.color.surfaceSunken : null,
            borderRadius: lane.radius.r12,
          ),
          child: LaneListTile(
            title: bookingTitle(l10n, e.id, b.problemType),
            subtitle: [
              cityLabel(l10n, b.cityId),
              vehicleLabel(l10n, b.vehicle.type),
              if (b.createdAt != null) DateFormat.Hm().format(toIst(b.createdAt!)),
            ].join(' · '),
            trailing: SignalBadge(signal: bookingSignal(b.status), label: bookingStatusLabel(l10n, b.status)),
            onTap: () => ref.read(selectedBookingProvider.notifier).select(e.id),
          ),
        );
      },
    );
  }
}

class _BookingDetail extends ConsumerStatefulWidget {
  const _BookingDetail({required this.entry});

  final BookingEntry entry;

  @override
  ConsumerState<_BookingDetail> createState() => _BookingDetailState();
}

class _BookingDetailState extends ConsumerState<_BookingDetail> {
  final _reason = TextEditingController();
  bool _cancelling = false;

  @override
  void didUpdateWidget(_BookingDetail old) {
    super.didUpdateWidget(old);
    if (old.entry.id != widget.entry.id) {
      _reason.clear();
      _cancelling = false;
    }
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(cancellingProvider.notifier).cancel(widget.entry.id, _reason.text);
      if (!mounted) return;
      setState(() => _cancelling = false);
      LaneToast.show(context, l10n.live_cancelled);
    } on AdminActionException catch (e) {
      if (!mounted) return;
      LaneToast.show(context, switch (e.failure) {
        AdminActionFailure.unavailable => l10n.approvals_error_unavailable,
        AdminActionFailure.precondition => l10n.live_cancel_refused,
        AdminActionFailure.notAllowed => l10n.approvals_error_not_allowed,
        AdminActionFailure.unknown => l10n.approvals_error_unknown,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final b = widget.entry.booking;
    final busy = ref.watch(cancellingProvider);
    final muted = lane.text.body.copyWith(color: lane.color.inkMuted);
    final inset = lane.space.s24;
    String? time(DateTime? t) => t == null ? null : DateFormat.Hm().format(toIst(t));
    final t = b.timestamps;

    return DecoratedBox(
      decoration: BoxDecoration(color: lane.color.surface, borderRadius: lane.radius.r16),
      child: Padding(
        padding: EdgeInsets.all(inset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bookingTitle(l10n, widget.entry.id, b.problemType), style: lane.text.headline),
            Gap(lane.space.s8),
            Text(
              [cityLabel(l10n, b.cityId), '${b.vehicle.brand} ${b.vehicle.model}'].join(' · '),
              style: muted,
            ),
            Gap(lane.space.s8),
            PlateChip(regNo: b.vehicle.regNo),
            Gap(lane.space.s16),
            Text(b.pickup.address, style: lane.text.body),
            if (b.pickup.landmark.isNotEmpty) Text(b.pickup.landmark, style: muted),
            Gap(lane.space.s16),
            if (b.customerCard != null)
              Text(
                l10n.live_customer('${b.customerCard!.name} · ${b.customerCard!.phone}'),
                style: lane.text.body,
              ),
            if (b.mechanicCard != null)
              Text(
                l10n.live_mechanic('${b.mechanicCard!.name} · ${b.mechanicCard!.phone}'),
                style: lane.text.body,
              ),
            if (b.mechanicCard == null) Text(l10n.live_searching(b.searchRadiusKm), style: muted),
            Gap(lane.space.s24),
            JourneyRail(
              direction: Axis.vertical,
              current: b.status.journeyStop?.index ?? 0,
              ended: b.status.isTerminal && b.status != BookingStatus.completed,
              stops: [
                JourneyStop(
                  label: l10n.booking_status_requested,
                  signal: LaneSignal.wait,
                  time: time(t.requested),
                ),
                JourneyStop(
                  label: l10n.booking_status_accepted,
                  signal: LaneSignal.route,
                  time: time(t.accepted),
                ),
                JourneyStop(
                  label: l10n.booking_status_arriving,
                  signal: LaneSignal.route,
                  time: time(t.arriving),
                ),
                JourneyStop(label: l10n.booking_status_arrived, signal: LaneSignal.go, time: time(t.arrived)),
                JourneyStop(
                  label: l10n.booking_status_in_progress,
                  signal: LaneSignal.work,
                  time: time(t.started),
                ),
                JourneyStop(
                  label: l10n.booking_status_completed,
                  signal: LaneSignal.go,
                  time: time(t.completed),
                ),
              ],
            ),
            Gap(lane.space.s24),
            if (canTransition(b.status, BookingStatus.cancelled, Actor.admin)) ...[
              if (_cancelling) ...[
                LaneTextField(
                  label: l10n.live_cancel_reason_label,
                  hint: l10n.live_cancel_reason_hint,
                  controller: _reason,
                  maxLength: 300,
                  onChanged: (_) => setState(() {}),
                ),
                Gap(lane.space.s12),
                Wrap(
                  spacing: lane.space.s8,
                  runSpacing: lane.space.s8,
                  children: [
                    LaneButton.danger(
                      label: l10n.live_cancel_confirm,
                      loading: busy,
                      onPressed: _reason.text.trim().length < 3 || busy ? null : _cancel,
                    ),
                    LaneButton.ghost(
                      label: l10n.approvals_block_cancel,
                      onPressed: () => setState(() => _cancelling = false),
                    ),
                  ],
                ),
              ] else
                LaneButton.secondary(
                  label: l10n.live_cancel,
                  onPressed: () => setState(() => _cancelling = true),
                ),
              Gap(lane.space.s8),
              Text(l10n.live_cancel_note, style: lane.text.caption.copyWith(color: lane.color.inkMuted)),
            ],
          ],
        ),
      ),
    );
  }
}
