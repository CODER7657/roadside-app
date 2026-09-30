import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../l10n/app_localizations.dart';
import '../../console/presentation/labels.dart';
import '../application/approvals.dart';
import '../data/mechanic_admin_api.dart';
import '../data/mechanics_repository.dart';

/// A2 Mechanic approvals (PLAN §10 admin 2, §10.0, wireframe A2): list on the left, the selected
/// mechanic on the right with a per-type checklist. Approve / block / log call go through the
/// admin callables (#130); KYC documents open as short-lived signed URLs, never downloaded.
class ApprovalsScreen extends ConsumerWidget {
  const ApprovalsScreen({super.key});

  /// Narrower than this, the list and the detail stack.
  static const splitAbove = 900.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final mechanics = ref.watch(filteredMechanicsProvider);
    final selectedUid = ref.watch(selectedMechanicProvider);
    final list = mechanics.value ?? const <MechanicEntry>[];
    final selected = list.where((e) => e.uid == selectedUid).firstOrNull ?? list.firstOrNull;

    return LayoutBuilder(
      builder: (context, box) {
        final listPanel = _MechanicList(mechanics: mechanics, selectedUid: selected?.uid);
        final detail = selected == null ? const SizedBox.shrink() : _MechanicDetail(entry: selected);
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
                        Expanded(flex: 2, child: listPanel),
                        Gap(lane.space.s24),
                        Expanded(flex: 3, child: SingleChildScrollView(child: detail)),
                      ],
                    )
                  : ListView(
                      children: [
                        SizedBox(height: box.maxHeight / 2, child: listPanel),
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

  static const searchWidth = 280.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final filters = ref.watch(approvalFiltersProvider);
    final notifier = ref.read(approvalFiltersProvider.notifier);
    // Wrap can't hold a Gap; a fixed box separates the chip groups.
    final groupGap = SizedBox(width: lane.space.s16);
    return Wrap(
      spacing: lane.space.s8,
      runSpacing: lane.space.s8,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        for (final s in MechanicStatus.values)
          LaneChip(
            label: mechanicStatusLabel(l10n, s),
            selected: filters.status == s,
            onSelected: (_) => notifier.status(s),
          ),
        groupGap,
        for (final t in <MechanicType?>[null, ...MechanicType.values])
          LaneChip(
            label: t == null ? l10n.approvals_type_all : mechanicTypeLabel(l10n, t),
            selected: filters.type == t,
            onSelected: (_) => notifier.type(t),
          ),
        groupGap,
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: searchWidth),
          child: LaneTextField(
            label: l10n.approvals_search_label,
            hint: l10n.approvals_search_hint,
            onChanged: notifier.search,
          ),
        ),
      ],
    );
  }
}

class _MechanicList extends ConsumerWidget {
  const _MechanicList({required this.mechanics, required this.selectedUid});

  final AsyncValue<List<MechanicEntry>> mechanics;
  final String? selectedUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(approvalFiltersProvider.select((f) => f.status));

    if (mechanics.hasValue) {
      final list = mechanics.requireValue;
      if (list.isEmpty) {
        return _Note(icon: LaneIcons.tray, title: l10n.approvals_empty(mechanicStatusLabel(l10n, status)));
      }
      final gap = lane.space.s4;
      return ListView.separated(
        itemCount: list.length,
        separatorBuilder: (_, _) => Gap(gap),
        itemBuilder: (context, i) {
          final e = list[i];
          final m = e.mechanic;
          final selected = e.uid == selectedUid;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: selected ? lane.color.surfaceSunken : null,
              borderRadius: lane.radius.r12,
            ),
            child: LaneListTile(
              title: m.name,
              subtitle: [
                mechanicTypeLabel(l10n, m.mechanicType),
                cityLabel(l10n, m.cityId),
                if (m.createdAt != null) _date(context, m.createdAt!),
              ].join(' · '),
              trailing: SignalBadge(signal: _signal(m.status), label: mechanicStatusLabel(l10n, m.status)),
              onTap: () => ref.read(selectedMechanicProvider.notifier).select(e.uid),
            ),
          );
        },
      );
    }
    if (mechanics.hasError) {
      return ErrorState(
        message: l10n.approvals_load_failed,
        onRetry: () => ref.invalidate(mechanicsByStatusProvider(status)),
      );
    }
    return SkeletonGroup(
      child: Column(children: [for (var i = 0; i < 5; i++) _SkeletonRow(height: lane.touch.critical)]),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final gap = context.lane.space.s8;
    return Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: SkeletonBlock(height: height),
    );
  }
}

class _MechanicDetail extends ConsumerStatefulWidget {
  const _MechanicDetail({required this.entry});

  final MechanicEntry entry;

  @override
  ConsumerState<_MechanicDetail> createState() => _MechanicDetailState();
}

class _MechanicDetailState extends ConsumerState<_MechanicDetail> {
  final _callNotes = TextEditingController();
  final _blockReason = TextEditingController();
  bool _blocking = false;

  @override
  void didUpdateWidget(_MechanicDetail old) {
    super.didUpdateWidget(old);
    if (old.entry.uid != widget.entry.uid) {
      _callNotes.clear();
      _blockReason.clear();
      _blocking = false;
    }
  }

  @override
  void dispose() {
    _callNotes.dispose();
    _blockReason.dispose();
    super.dispose();
  }

  String get _uid => widget.entry.uid;

  Future<void> _act(Future<void> Function() action, String success) async {
    final l10n = AppLocalizations.of(context);
    try {
      await action();
      if (mounted) LaneToast.show(context, success);
    } on AdminActionException catch (e) {
      if (mounted) LaneToast.show(context, _failure(l10n, e.failure));
    } catch (_) {
      if (mounted) LaneToast.show(context, _failure(l10n, AdminActionFailure.unknown));
    }
  }

  Future<void> _openDocument(KycDocument doc) async {
    final l10n = AppLocalizations.of(context);
    try {
      final url = await ref.read(approvalActionsProvider.notifier).documentUrl(_uid, doc);
      if (url == null) {
        if (mounted) LaneToast.show(context, l10n.approvals_document_missing);
        return;
      }
      await ref.read(documentOpenerProvider)(url);
    } on AdminActionException catch (e) {
      if (mounted) LaneToast.show(context, _failure(l10n, e.failure));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final m = widget.entry.mechanic;
    final kycAsync = ref.watch(kycProvider(_uid));
    final kyc = kycAsync.value;
    final ticked = ref.watch(checklistProvider.select((c) => c[_uid] ?? const <ChecklistItem>{}));
    final busy = ref.watch(approvalActionsProvider);
    final actions = ref.read(approvalActionsProvider.notifier);
    final independent = m.mechanicType == MechanicType.independent;
    final muted = lane.text.body.copyWith(color: lane.color.inkMuted);
    final inset = lane.space.s24;

    return DecoratedBox(
      decoration: BoxDecoration(color: lane.color.surface, borderRadius: lane.radius.r16),
      child: Padding(
        padding: EdgeInsets.all(inset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Who
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${m.name} · ${mechanicTypeLabel(l10n, m.mechanicType)}',
                    style: lane.text.headline,
                  ),
                ),
                SignalBadge(signal: _signal(m.status), label: mechanicStatusLabel(l10n, m.status)),
              ],
            ),
            Gap(lane.space.s8),
            Text(
              [
                cityLabel(l10n, m.cityId),
                if (independent && m.experienceYears != null) l10n.approvals_experience(m.experienceYears!),
                if (m.createdAt != null) l10n.approvals_registered(_date(context, m.createdAt!)),
              ].join(' · '),
              style: muted,
            ),
            Gap(lane.space.s16),
            if (independent) ...[
              if (m.baseArea != null) _Fact(label: l10n.approvals_base_area, value: m.baseArea!.locality),
              if (m.travelVehicle != null)
                _Fact(
                  label: l10n.approvals_travel_vehicle(vehicleLabel(l10n, m.travelVehicle!.type)),
                  child: PlateChip(regNo: m.travelVehicle!.regNo),
                ),
            ] else ...[
              _Fact(label: l10n.approvals_shop_name, value: m.shopName ?? '—'),
              _Fact(label: l10n.approvals_shop_address, value: m.shopAddress ?? '—'),
            ],
            _Fact(
              label: l10n.approvals_services,
              value: m.services.map((p) => problemLabel(l10n, p)).join(', '),
            ),
            _Fact(
              label: l10n.approvals_vehicle_types,
              value: m.vehicleTypes.map((v) => vehicleLabel(l10n, v)).join(', '),
            ),
            Gap(lane.space.s16),

            // Photos (download URLs from registration; shown to customers on the TrustPass)
            Text(l10n.approvals_photos, style: lane.text.title),
            Gap(lane.space.s8),
            Wrap(
              spacing: lane.space.s8,
              runSpacing: lane.space.s8,
              children: [
                _Photo(url: m.profilePhotoUrl, label: l10n.approvals_photo_profile),
                if (m.shopPhotoUrl != null) _Photo(url: m.shopPhotoUrl!, label: l10n.approvals_photo_shop),
                for (final (i, url) in (m.toolkitPhotoUrls ?? const <String>[]).indexed)
                  _Photo(url: url, label: l10n.approvals_photo_toolkit(i + 1)),
              ],
            ),
            Gap(lane.space.s24),

            // KYC
            Text(l10n.approvals_kyc, style: lane.text.title),
            Gap(lane.space.s8),
            if (kycAsync.isLoading && kyc == null)
              SkeletonGroup(child: SkeletonBlock(height: lane.touch.critical))
            else if (kyc == null)
              Text(l10n.approvals_kyc_missing, style: muted)
            else ...[
              _Fact(label: l10n.approvals_upi, value: '${kyc.upiId} · ${kyc.upiName}'),
              _Fact(label: l10n.approvals_phone, value: kyc.phone),
              if (kyc.referenceContact != null)
                _Fact(
                  label: l10n.approvals_reference,
                  value: '${kyc.referenceContact!.name} · ${kyc.referenceContact!.phone}',
                ),
              Gap(lane.space.s8),
              Wrap(
                spacing: lane.space.s8,
                runSpacing: lane.space.s8,
                children: [
                  for (final doc in _documentsOf(kyc))
                    LaneButton.secondary(
                      label: _documentLabel(l10n, doc),
                      loading: busy == ApprovalAction.openDocument,
                      onPressed: busy != null ? null : () => _openDocument(doc),
                    ),
                ],
              ),
              Gap(lane.space.s4),
              Text(
                l10n.approvals_documents_note,
                style: lane.text.caption.copyWith(color: lane.color.inkMuted),
              ),
            ],
            Gap(lane.space.s24),

            // Checklist (PLAN §10.0)
            if (m.status == MechanicStatus.pending) ...[
              Text(l10n.approvals_checklist, style: lane.text.title),
              Gap(lane.space.s8),
              for (final item in ChecklistItem.forType(m.mechanicType))
                LaneSwitch(
                  label: _checklistLabel(l10n, item),
                  value: ticked.contains(item),
                  onChanged: (on) => ref.read(checklistProvider.notifier).toggle(_uid, item, on),
                ),
              if (independent) ...[
                Gap(lane.space.s16),
                _VerificationCall(
                  call: kyc?.verificationCall,
                  notes: _callNotes,
                  busy: busy == ApprovalAction.logCall,
                  enabled: kyc != null && busy == null,
                  onLog: () => _act(() async {
                    await actions.logCall(_uid, _callNotes.text);
                    _callNotes.clear();
                  }, l10n.approvals_call_logged),
                ),
              ],
              Gap(lane.space.s24),
            ],

            // Decision
            if (m.status != MechanicStatus.blocked) ...[
              if (_blocking) ...[
                LaneTextField(
                  label: l10n.approvals_block_reason_label,
                  hint: l10n.approvals_block_reason_hint,
                  controller: _blockReason,
                  maxLength: 300,
                  onChanged: (_) => setState(() {}),
                ),
                Gap(lane.space.s12),
                Wrap(
                  spacing: lane.space.s8,
                  runSpacing: lane.space.s8,
                  children: [
                    LaneButton.danger(
                      label: l10n.approvals_block_confirm,
                      loading: busy == ApprovalAction.block,
                      onPressed: _blockReason.text.trim().length < 3 || busy != null
                          ? null
                          : () => _act(() async {
                              await actions.block(_uid, _blockReason.text);
                              if (mounted) setState(() => _blocking = false);
                            }, l10n.approvals_blocked),
                    ),
                    LaneButton.ghost(
                      label: l10n.approvals_block_cancel,
                      onPressed: () => setState(() => _blocking = false),
                    ),
                  ],
                ),
              ] else
                Wrap(
                  spacing: lane.space.s8,
                  runSpacing: lane.space.s8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (m.status == MechanicStatus.pending)
                      LaneButton.primary(
                        label: l10n.approvals_approve,
                        loading: busy == ApprovalAction.approve,
                        onPressed: canApprove(m, kyc, ticked) && busy == null
                            ? () => _act(() => actions.approve(_uid), l10n.approvals_approved)
                            : null,
                      ),
                    LaneButton.danger(
                      label: l10n.approvals_block,
                      onPressed: busy != null ? null : () => setState(() => _blocking = true),
                    ),
                  ],
                ),
              if (m.status == MechanicStatus.pending && !canApprove(m, kyc, ticked)) ...[
                Gap(lane.space.s8),
                Text(
                  _whyNot(l10n, m, kyc, ticked),
                  style: lane.text.caption.copyWith(color: lane.color.inkMuted),
                ),
              ],
              Gap(lane.space.s8),
              Text(l10n.approvals_audit_note, style: lane.text.caption.copyWith(color: lane.color.inkMuted)),
            ] else
              Text(l10n.approvals_blocked_note, style: muted),
          ],
        ),
      ),
    );
  }

  String _whyNot(AppLocalizations l10n, Mechanic m, MechanicKyc? kyc, Set<ChecklistItem> ticked) {
    if (kyc == null) return l10n.approvals_why_kyc;
    if (!ChecklistItem.forType(m.mechanicType).every(ticked.contains)) return l10n.approvals_why_checklist;
    return l10n.approvals_why_call;
  }
}

class _VerificationCall extends StatelessWidget {
  const _VerificationCall({
    required this.call,
    required this.notes,
    required this.busy,
    required this.enabled,
    required this.onLog,
  });

  final VerificationCall? call;
  final TextEditingController notes;
  final bool busy;
  final bool enabled;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final logged = call;
    if (logged != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LaneIcon(LaneIcons.checkCircle, size: lane.space.s24, color: lane.color.signal.go),
          Gap(lane.space.s8),
          Expanded(
            child: Text(
              l10n.approvals_call_done(_date(context, logged.at), logged.notes),
              style: lane.text.body,
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LaneTextField(
          label: l10n.approvals_call_notes_label,
          hint: l10n.approvals_call_notes_hint,
          controller: notes,
          maxLines: 3,
          maxLength: 500,
          enabled: enabled,
        ),
        Gap(lane.space.s8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ListenableBuilder(
            listenable: notes,
            builder: (context, _) => LaneButton.secondary(
              label: l10n.approvals_call_log,
              loading: busy,
              onPressed: enabled && notes.text.trim().length >= 3 ? onLog : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, this.value, this.child});

  static const labelWidth = 180.0;

  final String label;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final gap = lane.space.s8;
    return Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: labelWidth),
            child: Text(label, style: lane.text.label.copyWith(color: lane.color.inkMuted)),
          ),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: child ?? Text(value ?? '', style: lane.text.body),
            ),
          ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url, required this.label});

  static const size = Size(160, 120);

  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return Semantics(
      image: true,
      label: label,
      child: Tooltip(
        message: label,
        child: ClipRRect(
          borderRadius: lane.radius.r12,
          child: ColoredBox(
            color: lane.color.surfaceSunken,
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(size),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Center(child: LaneIcon(LaneIcons.cloudSlash, size: lane.space.s32)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.title});

  final LaneIcons icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LaneIcon(icon, size: lane.space.s48),
          Gap(lane.space.s12),
          Text(
            title,
            style: lane.text.body.copyWith(color: lane.color.inkMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

List<KycDocument> _documentsOf(MechanicKyc kyc) => [
  KycDocument.idProof,
  if (kyc.selfieWithIdPath != null) KycDocument.selfieWithId,
  if (kyc.addressProofPath != null) KycDocument.addressProof,
];

String _documentLabel(AppLocalizations l10n, KycDocument doc) => switch (doc) {
  KycDocument.idProof => l10n.approvals_document_id,
  KycDocument.selfieWithId => l10n.approvals_document_selfie,
  KycDocument.addressProof => l10n.approvals_document_address,
};

String _checklistLabel(AppLocalizations l10n, ChecklistItem item) => switch (item) {
  ChecklistItem.shopPhoto => l10n.approvals_check_shop_photo,
  ChecklistItem.idProof => l10n.approvals_check_id_proof,
  ChecklistItem.services => l10n.approvals_check_services,
  ChecklistItem.selfieMatchesId => l10n.approvals_check_selfie,
  ChecklistItem.addressProof => l10n.approvals_check_address,
  ChecklistItem.toolkitPhotos => l10n.approvals_check_toolkit,
};

String _failure(AppLocalizations l10n, AdminActionFailure f) => switch (f) {
  AdminActionFailure.unavailable => l10n.approvals_error_unavailable,
  AdminActionFailure.precondition => l10n.approvals_error_precondition,
  AdminActionFailure.notAllowed => l10n.approvals_error_not_allowed,
  AdminActionFailure.unknown => l10n.approvals_error_unknown,
};

LaneSignal _signal(MechanicStatus s) => switch (s) {
  MechanicStatus.pending => LaneSignal.wait,
  MechanicStatus.approved => LaneSignal.go,
  MechanicStatus.blocked => LaneSignal.stop,
};

String _date(BuildContext context, DateTime utc) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(utc.toLocal());
