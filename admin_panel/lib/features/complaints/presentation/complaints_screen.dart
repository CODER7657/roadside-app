import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;

import '../../../l10n/app_localizations.dart';
import '../../auth/application/admin_session.dart';
import '../../bookings/data/bookings_repository.dart';
import '../../console/application/city_filter.dart';
import '../../console/presentation/labels.dart';
import '../data/complaints_repository.dart';

enum ComplaintsTab { open, resolved, reviews }

final complaintsTabProvider = NotifierProvider<_Choice<ComplaintsTab>, ComplaintsTab>(
  () => _Choice(ComplaintsTab.open),
);

/// Mechanic type filter (PLAN §10.0: A5 can be filtered by type). Null = both.
final complaintsTypeProvider = NotifierProvider<_Choice<MechanicType?>, MechanicType?>(() => _Choice(null));

final selectedComplaintProvider = NotifierProvider<_Choice<String?>, String?>(() => _Choice(null));

class _Choice<T> extends Notifier<T> {
  _Choice(this._initial);

  final T _initial;

  @override
  T build() => _initial;

  void set(T value) => state = value;
}

/// Whether [booking] passes the console city filter and the mechanic type filter. A booking that
/// hasn't loaded yet passes, so rows don't flicker in and out.
bool _matches(Booking? booking, CityId? city, MechanicType? type) =>
    booking == null ||
    ((city == null || booking.cityId == city) &&
        (type == null || booking.mechanicCard?.mechanicType == type));

/// A5 Complaints & reviews (PLAN §10 admin 5, wireframe A5). Payment disputes arrive here from
/// `disputePayment` (#117). Resolving writes the note and an audit entry in one batch.
class ComplaintsScreen extends ConsumerWidget {
  const ComplaintsScreen({super.key});

  static const splitAbove = 900.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final tab = ref.watch(complaintsTabProvider);
    final type = ref.watch(complaintsTypeProvider);
    final openCount = ref.watch(complaintsProvider(ComplaintStatus.open)).value?.length;
    final groupGap = SizedBox(width: lane.space.s16);

    final filters = Wrap(
      spacing: lane.space.s8,
      runSpacing: lane.space.s8,
      children: [
        LaneChip(
          label: openCount == null ? l10n.complaints_tab_open : l10n.complaints_tab_open_count(openCount),
          selected: tab == ComplaintsTab.open,
          onSelected: (_) => ref.read(complaintsTabProvider.notifier).set(ComplaintsTab.open),
        ),
        LaneChip(
          label: l10n.complaints_tab_resolved,
          selected: tab == ComplaintsTab.resolved,
          onSelected: (_) => ref.read(complaintsTabProvider.notifier).set(ComplaintsTab.resolved),
        ),
        LaneChip(
          label: l10n.complaints_tab_reviews,
          selected: tab == ComplaintsTab.reviews,
          onSelected: (_) => ref.read(complaintsTabProvider.notifier).set(ComplaintsTab.reviews),
        ),
        groupGap,
        for (final t in <MechanicType?>[null, ...MechanicType.values])
          LaneChip(
            label: t == null ? l10n.approvals_type_all : mechanicTypeLabel(l10n, t),
            selected: type == t,
            onSelected: (_) => ref.read(complaintsTypeProvider.notifier).set(t),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        filters,
        Gap(lane.space.s16),
        Expanded(
          child: tab == ComplaintsTab.reviews
              ? const _Reviews()
              : _Complaints(
                  status: tab == ComplaintsTab.open ? ComplaintStatus.open : ComplaintStatus.resolved,
                ),
        ),
      ],
    );
  }
}

class _Complaints extends ConsumerWidget {
  const _Complaints({required this.status});

  final ComplaintStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final complaints = ref.watch(complaintsProvider(status));
    if (!complaints.hasValue) {
      if (complaints.hasError) {
        return ErrorState(
          message: l10n.complaints_load_failed,
          onRetry: () => ref.invalidate(complaintsProvider(status)),
        );
      }
      return SkeletonGroup(child: SkeletonBlock(height: lane.touch.critical * 3));
    }
    final city = ref.watch(cityFilterProvider);
    final type = ref.watch(complaintsTypeProvider);
    final list = [
      for (final e in complaints.requireValue)
        if (_matches(ref.watch(bookingProvider(e.complaint.bookingId)).value, city, type)) e,
    ];
    if (list.isEmpty) {
      return Center(
        child: Text(
          status == ComplaintStatus.open ? l10n.complaints_empty_open : l10n.complaints_empty_resolved,
          style: lane.text.body.copyWith(color: lane.color.inkMuted),
        ),
      );
    }
    final selectedId = ref.watch(selectedComplaintProvider);
    final selected = list.where((e) => e.id == selectedId).firstOrNull ?? list.first;

    final listView = ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final e = list[i];
        final c = e.complaint;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: e.id == selected.id ? lane.color.surfaceSunken : null,
            borderRadius: lane.radius.r12,
          ),
          child: LaneListTile(
            title: bookingRef(c.bookingId),
            subtitle: c.text,
            trailing: SignalBadge(
              signal: _categorySignal(c.category),
              label: _categoryLabel(l10n, c.category),
            ),
            onTap: () => ref.read(selectedComplaintProvider.notifier).set(e.id),
          ),
        );
      },
    );
    final detail = _ComplaintDetail(entry: selected);

    return LayoutBuilder(
      builder: (context, box) => box.maxWidth >= ComplaintsScreen.splitAbove
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: listView),
                Gap(lane.space.s24),
                Expanded(flex: 3, child: SingleChildScrollView(child: detail)),
              ],
            )
          : ListView(
              children: [
                SizedBox(height: box.maxHeight / 2, child: listView),
                Gap(lane.space.s24),
                detail,
              ],
            ),
    );
  }
}

class _ComplaintDetail extends ConsumerStatefulWidget {
  const _ComplaintDetail({required this.entry});

  final ComplaintEntry entry;

  @override
  ConsumerState<_ComplaintDetail> createState() => _ComplaintDetailState();
}

class _ComplaintDetailState extends ConsumerState<_ComplaintDetail> {
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void didUpdateWidget(_ComplaintDetail old) {
    super.didUpdateWidget(old);
    if (old.entry.id != widget.entry.id) _note.clear();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _resolve() async {
    final l10n = AppLocalizations.of(context);
    final session = ref.read(adminSessionProvider);
    if (session is! SessionAdmin) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(complaintsRepositoryProvider)
          .resolve(widget.entry.id, resolution: _note.text.trim(), actorUid: session.user.uid);
      LaneLog.i('complaint resolved', {'complaintId': widget.entry.id});
      if (mounted) LaneToast.show(context, l10n.complaints_resolved);
    } catch (e, st) {
      LaneLog.w('resolving complaint failed', error: e, stackTrace: st);
      if (mounted) LaneToast.show(context, l10n.approvals_error_unknown);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final c = widget.entry.complaint;
    final booking = ref.watch(bookingProvider(c.bookingId)).value;
    final muted = lane.text.body.copyWith(color: lane.color.inkMuted);
    final inset = lane.space.s24;
    final rupees = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());

    final raisedBy = booking == null
        ? null
        : c.raisedBy == booking.customerId
        ? l10n.complaints_raised_by_customer(booking.customerCard?.name ?? '—')
        : c.raisedBy == booking.mechanicId
        ? l10n.complaints_raised_by_mechanic(booking.mechanicCard?.name ?? '—')
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(color: lane.color.surface, borderRadius: lane.radius.r16),
      child: Padding(
        padding: EdgeInsets.all(inset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.complaints_title(_categoryLabel(l10n, c.category), bookingRef(c.bookingId)),
              style: lane.text.headline,
            ),
            Gap(lane.space.s8),
            Text(
              [
                ?raisedBy,
                if (c.createdAt != null) DateFormat.yMMMd().add_Hm().format(toIst(c.createdAt!)),
              ].join(' · '),
              style: muted,
            ),
            Gap(lane.space.s16),
            Text(c.text, style: lane.text.bodyLarge),
            Gap(lane.space.s16),
            if (booking != null) ...[
              Text(
                [
                  cityLabel(l10n, booking.cityId),
                  bookingStatusLabel(l10n, booking.status),
                  if (booking.finalAmount != null) '₹${rupees.format(booking.finalAmount)}',
                  _paymentLabel(l10n, booking.paymentStatus),
                  if (booking.mechanicCard != null)
                    '${booking.mechanicCard!.name} (${mechanicTypeLabel(l10n, booking.mechanicCard!.mechanicType)})',
                ].join(' · '),
                style: muted,
              ),
              Gap(lane.space.s24),
            ],
            if (c.status == ComplaintStatus.resolved)
              Text(l10n.complaints_resolution(c.resolution ?? '—'), style: lane.text.body)
            else ...[
              LaneTextField(
                label: l10n.complaints_resolution_label,
                hint: l10n.complaints_resolution_hint,
                controller: _note,
                maxLines: 4,
                maxLength: 1000,
                onChanged: (_) => setState(() {}),
              ),
              Gap(lane.space.s12),
              LaneButton.primary(
                label: l10n.complaints_resolve,
                loading: _saving,
                onPressed: _note.text.trim().length < 3 || _saving ? null : _resolve,
              ),
              Gap(lane.space.s8),
              Text(l10n.complaints_audit_note, style: lane.text.caption.copyWith(color: lane.color.inkMuted)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Reviews extends ConsumerWidget {
  const _Reviews();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final reviews = ref.watch(reviewsProvider);
    if (!reviews.hasValue) {
      if (reviews.hasError) {
        return ErrorState(
          message: l10n.complaints_load_failed,
          onRetry: () => ref.invalidate(reviewsProvider),
        );
      }
      return SkeletonGroup(child: SkeletonBlock(height: lane.touch.critical * 3));
    }
    final city = ref.watch(cityFilterProvider);
    final type = ref.watch(complaintsTypeProvider);
    final list = [
      for (final e in reviews.requireValue)
        if (_matches(ref.watch(bookingProvider(e.bookingId)).value, city, type)) e,
    ];
    if (list.isEmpty) {
      return Center(
        child: Text(
          l10n.complaints_empty_reviews,
          style: lane.text.body.copyWith(color: lane.color.inkMuted),
        ),
      );
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final r = list[i].review;
        final booking = ref.watch(bookingProvider(list[i].bookingId)).value;
        final stars = l10n.complaints_stars(r.stars);
        return LaneListTile(
          title: [
            booking?.mechanicCard?.name ?? bookingRef(list[i].bookingId),
            if (booking != null) cityLabel(l10n, booking.cityId),
          ].join(' · '),
          subtitle: [
            if (r.comment.isNotEmpty) r.comment,
            if (r.tags.isNotEmpty) r.tags.join(', '),
          ].join('\n'),
          trailing: SignalBadge(
            signal: r.stars >= 4 ? LaneSignal.go : (r.stars == 3 ? LaneSignal.wait : LaneSignal.stop),
            icon: LaneIcons.star,
            label: stars,
          ),
        );
      },
    );
  }
}

LaneSignal _categorySignal(String category) => category == 'payment' ? LaneSignal.stop : LaneSignal.wait;

String _categoryLabel(AppLocalizations l10n, String category) => switch (category) {
  'payment' => l10n.complaints_category_payment,
  'service' => l10n.complaints_category_service,
  'safety' => l10n.complaints_category_safety,
  _ => l10n.complaints_category_other,
};

String _paymentLabel(AppLocalizations l10n, PaymentStatus s) => switch (s) {
  PaymentStatus.pending => l10n.payment_status_pending,
  PaymentStatus.customerMarkedPaid => l10n.payment_status_marked_paid,
  PaymentStatus.confirmed => l10n.payment_status_confirmed,
  PaymentStatus.disputed => l10n.payment_status_disputed,
};
