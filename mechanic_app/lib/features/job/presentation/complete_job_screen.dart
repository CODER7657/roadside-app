import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart' hide PriceRange;
import 'package:roadside_core/roadside_core.dart' as core show PriceRange;

import '../../../_local_ui/photo_slot.dart';
import '../../../l10n/app_localizations.dart';
import '../../offers/application/offers.dart';
import '../../permissions/application/permission_service.dart';
import '../../permissions/presentation/permission_explainer_screen.dart';
import '../../registration/application/registration.dart';
import '../../registration/data/mechanic_photos.dart';
import '../application/job.dart';
import '../data/job_repository.dart';

/// Route of M7 for one job.
String completeJobRoute(String bookingId) => '/job/$bookingId/complete';

/// PLAN §9 / `completeJob`: up to 5 before and 5 after photos.
const kMaxWorkPhotos = 5;

String rangeText(({int min, int max}) b) => '${PriceRange.rupees(b.min)}–${PriceRange.rupees(b.max)}';

String estimateText(core.PriceRange e) => '${PriceRange.rupees(e.min)}–${PriceRange.rupees(e.max)}';

/// M7 Job complete (PLAN §9; wireframe M7, `LaneFlowScaffold`): before and after photos (at
/// least one after), the final amount (a reason when it's outside 0.5× the estimate's minimum
/// to 3× its maximum), then slide to finish, which uploads the photos and calls `completeJob`.
class CompleteJobScreen extends ConsumerStatefulWidget {
  const CompleteJobScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<CompleteJobScreen> createState() => _CompleteJobScreenState();
}

class _CompleteJobScreenState extends ConsumerState<CompleteJobScreen> {
  final _before = <Uint8List>[];
  final _after = <Uint8List>[];

  /// Photos already uploaded (by identity), so a retry after a failed `completeJob` doesn't
  /// upload them again on mobile data, or leave extra copies in `work/`.
  final _uploaded = Map<Uint8List, String>.identity();
  final _amount = TextEditingController();
  AmountReason? _reason;
  bool _busy = false;
  bool _showErrors = false;

  /// From the server when its bounds differ from ours (shouldn't happen, but it has the say).
  ({int min, int max})? _serverBounds;

  /// Bumped to reset the slider after a failed attempt.
  int _attempt = 0;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  int? get _amountValue => int.tryParse(_amount.text);

  Future<void> _addPhoto(List<Uint8List> into) async {
    final l10n = AppLocalizations.of(context);
    final source = await showLaneSheet<PhotoSource>(
      context,
      builder: (sheet) => LaneSheet(
        title: l10n.register_photo_source_title,
        primary: LaneButton.primary(
          label: l10n.register_photo_camera,
          onPressed: () => Navigator.of(sheet).pop(PhotoSource.camera),
        ),
        secondary: LaneButton.secondary(
          label: l10n.register_photo_gallery,
          onPressed: () => Navigator.of(sheet).pop(PhotoSource.gallery),
        ),
      ),
    );
    if (source == null || !mounted) return;
    // PLAN §13: the C7 explainer before Android's camera prompt.
    if (source == PhotoSource.camera && !await ensurePermission(context, ref, AppPermission.camera)) return;
    try {
      final raw = await ref.read(photoPickerProvider).pick(source);
      if (raw == null) return;
      final bytes = await ref.read(photoCompressorProvider).compress(raw);
      if (mounted) setState(() => into.add(bytes));
    } on PhotoTooLargeException {
      if (mounted) LaneToast.show(context, l10n.register_photo_too_large);
    }
  }

  Future<void> _finish(Booking b) async {
    final l10n = AppLocalizations.of(context);
    final amount = _amountValue;
    final needsReason = amount != null && _needsReason(amount, b);
    if (_after.isEmpty || amount == null || amount <= 0 || (needsReason && _reason == null)) {
      setState(() {
        _showErrors = true;
        _attempt++;
      });
      unawaited(LaneHaptics.error());
      return;
    }
    setState(() => _busy = true);

    final uploader = ref.read(workPhotoUploaderProvider);
    final List<String> before;
    final List<String> after;
    try {
      Future<List<String>> upload(List<Uint8List> photos, String base) => Future.wait([
        for (final bytes in photos)
          if (_uploaded[bytes] case final url?)
            Future.value(url)
          else
            uploader
                .upload(bookingId: widget.bookingId, fileName: uniquePhotoName(base), bytes: bytes)
                .then((url) => _uploaded[bytes] = url),
      ]);
      before = await upload(_before, 'before');
      after = await upload(_after, 'after');
    } catch (_) {
      _failed(l10n.complete_error_upload);
      return;
    }

    final result = await ref
        .read(jobRepositoryProvider)
        .completeJob(
          widget.bookingId,
          finalAmount: amount,
          beforePhotoUrls: before,
          afterPhotoUrls: after,
          amountReason: needsReason ? _reason : null,
        );
    if (!mounted) return;
    switch (result) {
      case JobCompleted():
        unawaited(LaneHaptics.statusAdvance());
        // The job is over: stop sharing the location now, not when M5 next sees the booking.
        ref.read(jobTrackingProvider.notifier).stop();
        // M5 follows the booking to M8 (payment).
        context.go(jobRoute(widget.bookingId));
      case AmountNeedsReason(:final min, :final max):
        setState(() {
          _busy = false;
          _serverBounds = (min: min, max: max);
          _showErrors = true;
          _attempt++;
        });
      case CompleteRejected(problem: CompleteProblem.invalidStatus):
        context.go(jobRoute(widget.bookingId));
      case CompleteRejected(problem: CompleteProblem.photoInvalid):
        _failed(l10n.complete_error_photo);
      case CompleteRejected(problem: CompleteProblem.failed):
        _failed(l10n.complete_error_failed);
    }
  }

  void _failed(String message) {
    if (!mounted) return;
    unawaited(LaneHaptics.error());
    LaneToast.show(context, message);
    setState(() {
      _busy = false;
      _attempt++;
    });
  }

  ({int min, int max}) _bounds(Booking b) => _serverBounds ?? amountBounds(b.priceEstimate);

  bool _needsReason(int amount, Booking b) {
    final bounds = _bounds(b);
    return amount < bounds.min || amount > bounds.max;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final job = ref.watch(jobProvider(widget.bookingId));
    final b = job.value;
    if (b == null) return Scaffold(body: Center(child: SkeletonGroup.lines()));
    // Not (or no longer) in progress: M5 knows what to show.
    if (b.status != BookingStatus.inProgress && !_busy) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(jobRoute(widget.bookingId));
      });
      return const Scaffold();
    }

    final lane = context.lane;
    final amount = _amountValue;
    final needsReason = amount != null && _needsReason(amount, b);
    final rowGap = lane.space.s8;

    Widget photos(List<Uint8List> list, {required bool required}) => Wrap(
      spacing: rowGap,
      runSpacing: rowGap,
      children: [
        for (final (i, bytes) in list.indexed)
          PhotoSlot(
            label: l10n.complete_photo_label(i + 1),
            addLabel: l10n.register_photo_add,
            bytes: bytes,
            removeLabel: l10n.register_photo_remove,
            onRemove: _busy
                ? null
                : () => setState(() {
                    _uploaded.remove(list.removeAt(i));
                  }),
            onTap: () {},
          ),
        if (list.length < kMaxWorkPhotos)
          PhotoSlot(
            label: l10n.complete_photo_label(list.length + 1),
            addLabel: l10n.register_photo_add,
            hasError: required && _showErrors && list.isEmpty,
            onTap: _busy ? () {} : () => _addPhoto(list),
          ),
      ],
    );

    return LaneFlowScaffold(
      step: 1,
      totalSteps: 1,
      stepLabel: l10n.complete_step,
      title: l10n.complete_title,
      onBack: _busy ? null : () => context.go(jobRoute(widget.bookingId)),
      primary: LaneSlideToConfirm(
        key: ValueKey(_attempt),
        label: l10n.complete_slide,
        onConfirmed: _busy ? null : () => _finish(b),
      ),
      children: [
        Text(l10n.complete_after, style: lane.text.label.copyWith(color: lane.color.ink)),
        SizedBox(height: lane.space.s8),
        photos(_after, required: true),
        if (_showErrors && _after.isEmpty) ...[
          SizedBox(height: lane.space.s4),
          Text(
            l10n.complete_after_required,
            style: lane.text.caption.copyWith(color: lane.color.signal.stop),
          ),
        ],
        SizedBox(height: lane.space.s16),
        Text(l10n.complete_before, style: lane.text.label.copyWith(color: lane.color.ink)),
        SizedBox(height: lane.space.s8),
        photos(_before, required: false),
        SizedBox(height: lane.space.s24),
        LaneTextField(
          key: const ValueKey('finalAmount'),
          label: l10n.complete_amount_label,
          hint: l10n.complete_amount_hint,
          controller: _amount,
          enabled: !_busy,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
          helper: l10n.complete_estimate(estimateText(b.priceEstimate)),
          errorText: _showErrors && (amount == null || amount <= 0) ? l10n.complete_amount_required : null,
          onChanged: (_) => setState(() {}),
        ),
        if (needsReason) ...[
          SizedBox(height: lane.space.s16),
          Text(
            l10n.complete_reason_title(rangeText(_bounds(b))),
            style: lane.text.body.copyWith(color: lane.color.ink),
          ),
          SizedBox(height: lane.space.s8),
          Wrap(
            spacing: rowGap,
            runSpacing: rowGap,
            children: [
              for (final r in AmountReason.values)
                LaneChip(
                  label: switch (r) {
                    AmountReason.extraWork => l10n.complete_reason_extra_work,
                    AmountReason.parts => l10n.complete_reason_parts,
                    AmountReason.discount => l10n.complete_reason_discount,
                    AmountReason.other => l10n.complete_reason_other,
                  },
                  selected: _reason == r,
                  onSelected: _busy ? null : (_) => setState(() => _reason = r),
                ),
            ],
          ),
          if (_showErrors && _reason == null) ...[
            SizedBox(height: lane.space.s4),
            Text(
              l10n.complete_reason_required,
              style: lane.text.caption.copyWith(color: lane.color.signal.stop),
            ),
          ],
        ],
      ],
    );
  }
}
