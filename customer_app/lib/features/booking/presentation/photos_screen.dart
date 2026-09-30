import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../permissions/application/permission_service.dart';
import '../../permissions/presentation/permission_explainer_screen.dart';
import '../application/booking_draft.dart';
import '../data/photo_pipeline.dart';
import 'problem_screen.dart' show bookingSteps;

/// U5 Photos and details, optional: up to 4 photos (compressed, EXIF stripped, uploaded
/// as they're added) and a short description. Next waits for uploads; a failed one is
/// retried or removed.
class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key});

  /// `createBooking` trims and caps the description at 500.
  static const maxDescription = 500;

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen> {
  bool _adding = false;

  BookingDraftNotifier get _notifier => ref.read(bookingDraftProvider.notifier);

  Future<void> _add(PhotoSource source) async {
    final l10n = AppLocalizations.of(context);
    // Camera goes through the C7 explainer first; the gallery uses the system photo picker.
    if (source == PhotoSource.camera && !await ensurePermission(context, ref, AppPermission.camera)) return;
    setState(() => _adding = true);
    final error = await _notifier.addPhoto(source);
    if (!mounted) return;
    setState(() => _adding = false);
    final message = switch (error) {
      null => null,
      PhotoAddError.limit => l10n.photos_error_limit,
      PhotoAddError.tooLarge => l10n.photos_error_too_large,
      PhotoAddError.failed => l10n.photos_error_failed,
    };
    if (message != null) {
      unawaited(LaneHaptics.error());
      LaneToast.show(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(bookingDraftProvider);
    final empty = draft.photos.isEmpty && draft.description.trim().isEmpty;

    return LaneFlowScaffold(
      step: 2,
      totalSteps: bookingSteps,
      stepLabel: l10n.booking_step(2, bookingSteps),
      title: l10n.photos_title,
      primary: LaneButton.primary(
        label: l10n.booking_next,
        loading: draft.uploading,
        onPressed: draft.hasFailedUpload ? null : () => context.push(AppRoutes.bookLocation),
      ),
      secondary: empty
          ? LaneButton.ghost(label: l10n.photos_skip, onPressed: () => context.push(AppRoutes.bookLocation))
          : null,
      children: [
        Text(l10n.photos_body, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
        SizedBox(height: lane.space.s16),
        for (final (i, photo) in draft.photos.indexed) ...[
          _PhotoRow(
            number: i + 1,
            photo: photo,
            onRetry: () => _notifier.retryUpload(photo.id),
            onRemove: () => _notifier.removePhoto(photo.id),
          ),
          SizedBox(height: lane.space.s8),
        ],
        if (draft.hasFailedUpload) ...[
          Semantics(
            container: true,
            liveRegion: true,
            child: Text(l10n.photos_error_upload, style: lane.text.body.copyWith(color: lane.color.ink)),
          ),
          SizedBox(height: lane.space.s8),
        ],
        if (draft.photos.isNotEmpty)
          Text(
            l10n.photos_count(draft.photos.length, PhotoLimits.maxPhotos),
            style: lane.text.caption.copyWith(color: lane.color.inkMuted),
          ),
        if (draft.canAddPhoto) ...[
          SizedBox(height: lane.space.s8),
          LaneButton.secondary(
            label: l10n.photos_take,
            loading: _adding,
            onPressed: () => _add(PhotoSource.camera),
          ),
          SizedBox(height: lane.space.s8),
          LaneButton.ghost(
            label: l10n.photos_gallery,
            onPressed: _adding ? null : () => _add(PhotoSource.gallery),
          ),
        ],
        SizedBox(height: lane.space.s24),
        LaneTextField(
          label: l10n.description_label,
          hint: l10n.description_hint,
          initialValue: draft.description,
          maxLength: PhotosScreen.maxDescription,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          onChanged: _notifier.setDescription,
        ),
      ],
    );
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({required this.number, required this.photo, required this.onRetry, required this.onRemove});

  final int number;
  final DraftPhoto photo;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final thumb = lane.touch.primary;
    final (status, icon) = switch (photo.state) {
      PhotoUploadState.uploading => (l10n.photos_uploading(number), LaneIcons.hourglass),
      PhotoUploadState.failed => (l10n.photos_retry(number), LaneIcons.warning),
      PhotoUploadState.done => (null, LaneIcons.checkCircle),
    };
    return LaneListTile(
      title: status ?? l10n.photos_item(number),
      leading: ClipRRect(
        borderRadius: lane.radius.r12,
        child: Image.memory(
          photo.bytes,
          width: thumb,
          height: thumb,
          fit: BoxFit.cover,
          excludeFromSemantics: true,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LaneIcon(icon, size: lane.space.s24),
          IconButton(
            tooltip: l10n.photos_remove(number),
            constraints: BoxConstraints.tightFor(width: lane.touch.min, height: lane.touch.min),
            onPressed: onRemove,
            icon: LaneIcon(LaneIcons.close, size: lane.space.s24),
          ),
        ],
      ),
      onTap: photo.state == PhotoUploadState.failed ? onRetry : null,
    );
  }
}
