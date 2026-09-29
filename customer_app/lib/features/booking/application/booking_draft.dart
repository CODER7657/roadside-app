import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../data/photo_pipeline.dart';

final photoPickerProvider = Provider<PhotoPicker>((ref) => ImagePickerPhotoPicker());
final photoCompressorProvider = Provider<PhotoCompressor>((ref) => PhotoCompressor());

/// Fake until #92 wires Firebase Storage (then `FirebasePhotoUploader` with the signed-in uid).
final photoUploaderProvider = Provider<PhotoUploader>((ref) => FakePhotoUploader());

/// Random URL-safe id (22 chars, 128 bits): the draft id and `createBooking`'s
/// `idempotencyKey` (`^[A-Za-z0-9_-]{16,64}$`).
String newDraftToken([Random? random]) {
  final r = random ?? Random.secure();
  return base64Url.encode([for (var i = 0; i < 16; i++) r.nextInt(256)]).replaceAll('=', '');
}

enum PhotoUploadState { uploading, done, failed }

@immutable
class DraftPhoto {
  const DraftPhoto({
    required this.id,
    required this.bytes,
    this.state = PhotoUploadState.uploading,
    this.url,
  });

  final String id;

  /// The compressed JPEG, for the thumbnail and a retry.
  final Uint8List bytes;
  final PhotoUploadState state;

  /// Download URL once uploaded.
  final String? url;

  DraftPhoto copyWith({PhotoUploadState? state, String? url}) =>
      DraftPhoto(id: id, bytes: bytes, state: state ?? this.state, url: url ?? this.url);
}

/// Where the mechanic should come (U6), in `createBooking`'s `pickup` shape.
@immutable
class PickupDraft {
  const PickupDraft({
    required this.lat,
    required this.lng,
    required this.address,
    required this.accuracyMeters,
    this.landmark = '',
    this.plusCode = '',
  });

  final double lat;
  final double lng;
  final String address;
  final String landmark;
  final String plusCode;

  /// The GPS reading's accuracy (the pin itself was placed by the customer).
  final double accuracyMeters;
}

/// What the customer has chosen so far on U4–U7. One draft = one booking attempt: its
/// [idempotencyKey] stays the same across retries so `createBooking` makes one booking.
@immutable
class BookingDraft {
  const BookingDraft({
    required this.draftId,
    required this.idempotencyKey,
    this.vehicleId,
    this.problem,
    this.photos = const [],
    this.description = '',
    this.pickup,
  });

  final String draftId;
  final String idempotencyKey;
  final String? vehicleId;
  final ProblemType? problem;
  final List<DraftPhoto> photos;
  final String description;

  /// Set when U6 is confirmed. The customer always confirms the pin there, so
  /// `createBooking` gets `pinConfirmed: true`.
  final PickupDraft? pickup;

  bool get canAddPhoto => photos.length < PhotoLimits.maxPhotos;
  bool get uploading => photos.any((p) => p.state == PhotoUploadState.uploading);
  bool get hasFailedUpload => photos.any((p) => p.state == PhotoUploadState.failed);

  /// Only uploaded photos go to `createBooking`.
  List<String> get photoUrls => [
    for (final p in photos)
      if (p.url != null) p.url!,
  ];

  BookingDraft copyWith({
    String? vehicleId,
    ProblemType? problem,
    List<DraftPhoto>? photos,
    String? description,
    PickupDraft? pickup,
  }) => BookingDraft(
    draftId: draftId,
    idempotencyKey: idempotencyKey,
    vehicleId: vehicleId ?? this.vehicleId,
    problem: problem ?? this.problem,
    photos: photos ?? this.photos,
    description: description ?? this.description,
    pickup: pickup ?? this.pickup,
  );
}

/// Why adding a photo didn't work.
enum PhotoAddError { limit, tooLarge, failed }

class BookingDraftNotifier extends Notifier<BookingDraft> {
  @override
  BookingDraft build() => BookingDraft(draftId: newDraftToken(), idempotencyKey: newDraftToken());

  /// A fresh draft (Home → Get help), with the vehicle to fix.
  void start({String? vehicleId}) => state = build().copyWith(vehicleId: vehicleId);

  void setVehicle(String vehicleId) => state = state.copyWith(vehicleId: vehicleId);
  void setProblem(ProblemType problem) => state = state.copyWith(problem: problem);
  void setDescription(String text) => state = state.copyWith(description: text);
  void setPickup(PickupDraft pickup) => state = state.copyWith(pickup: pickup);

  /// Picks, compresses (EXIF stripped) and uploads a photo. Returns null on success or
  /// when the user backed out, else why it failed. The upload itself can fail and be
  /// retried from the thumbnail ([retryUpload]).
  Future<PhotoAddError?> addPhoto(PhotoSource source) async {
    if (!state.canAddPhoto) return PhotoAddError.limit;
    final draftId = state.draftId;
    final Uint8List? picked;
    final Uint8List bytes;
    try {
      picked = await ref.read(photoPickerProvider).pick(source);
      if (picked == null) return null;
      bytes = await ref.read(photoCompressorProvider).compress(picked);
    } on PhotoTooLargeException {
      return PhotoAddError.tooLarge;
    } catch (e, s) {
      LaneLog.w('booking photo pick failed', error: e, stackTrace: s);
      return PhotoAddError.failed;
    }
    // A new draft started while the picker or compressor ran: this photo isn't for it.
    if (!ref.mounted || state.draftId != draftId) return null;
    if (!state.canAddPhoto) return PhotoAddError.limit;
    final photo = DraftPhoto(id: newDraftToken(), bytes: bytes);
    state = state.copyWith(photos: [...state.photos, photo]);
    await _upload(photo);
    return null;
  }

  Future<void> retryUpload(String photoId) async {
    final photo = state.photos.where((p) => p.id == photoId).firstOrNull;
    if (photo == null || photo.state != PhotoUploadState.failed) return;
    _replace(photo.copyWith(state: PhotoUploadState.uploading));
    await _upload(photo);
  }

  /// Removes it from the booking. (Storage never lets clients delete; an uploaded file just
  /// isn't referenced.)
  void removePhoto(String photoId) => state = state.copyWith(
    photos: [
      for (final p in state.photos)
        if (p.id != photoId) p,
    ],
  );

  Future<void> _upload(DraftPhoto photo) async {
    final draftId = state.draftId;
    try {
      final url = await ref
          .read(photoUploaderProvider)
          .upload(draftId: draftId, fileName: '${photo.id}.jpg', bytes: photo.bytes);
      if (ref.mounted && state.draftId == draftId) {
        _replace(photo.copyWith(state: PhotoUploadState.done, url: url));
      }
    } catch (e, s) {
      LaneLog.w('booking photo upload failed', error: e, stackTrace: s);
      if (ref.mounted && state.draftId == draftId) _replace(photo.copyWith(state: PhotoUploadState.failed));
    }
  }

  void _replace(DraftPhoto photo) =>
      state = state.copyWith(photos: [for (final p in state.photos) p.id == photo.id ? photo : p]);
}

final bookingDraftProvider = NotifierProvider<BookingDraftNotifier, BookingDraft>(BookingDraftNotifier.new);
