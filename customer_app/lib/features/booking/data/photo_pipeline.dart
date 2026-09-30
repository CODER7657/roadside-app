import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

/// Where a booking photo comes from.
enum PhotoSource { camera, gallery }

/// PLAN §10 U5: photos are at most 1600 px on the long side and 500 KB, as JPEG.
abstract final class PhotoLimits {
  static const maxSide = 1600;
  static const maxBytes = 500 * 1024;

  /// `createBooking` accepts up to 4 photo URLs.
  static const maxPhotos = 4;
}

/// Opens the camera or gallery. Returns the image already scaled to fit
/// [PhotoLimits.maxSide], or null if the user backed out.
abstract interface class PhotoPicker {
  Future<Uint8List?> pick(PhotoSource source);
}

class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: source == PhotoSource.camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: PhotoLimits.maxSide.toDouble(),
      maxHeight: PhotoLimits.maxSide.toDouble(),
      requestFullMetadata: false,
    );
    return file?.readAsBytes();
  }
}

/// The photo couldn't get under [PhotoLimits.maxBytes] even at the lowest quality.
class PhotoTooLargeException implements Exception {
  const PhotoTooLargeException();
}

/// Re-encodes a photo as JPEG under [PhotoLimits.maxBytes] with **all EXIF removed**
/// (GPS position, device, time: PLAN §12), stepping the quality down until it fits.
class PhotoCompressor {
  PhotoCompressor({JpegEncoder? encode}) : _encode = encode ?? _pluginEncode;

  /// Qualities tried in order; the first result under the limit wins.
  static const qualities = [85, 75, 65, 55, 45, 35];

  final JpegEncoder _encode;

  static Future<Uint8List> _pluginEncode(Uint8List bytes, int quality) =>
      FlutterImageCompress.compressWithList(
        bytes,
        // The picker already fit the image in 1600 px; these only stop the plugin upscaling.
        minWidth: PhotoLimits.maxSide,
        minHeight: PhotoLimits.maxSide,
        quality: quality,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

  Future<Uint8List> compress(Uint8List bytes) async {
    for (final q in qualities) {
      final out = await _encode(bytes, q);
      if (out.lengthInBytes <= PhotoLimits.maxBytes) return out;
    }
    throw const PhotoTooLargeException();
  }
}

typedef JpegEncoder = Future<Uint8List> Function(Uint8List bytes, int quality);

/// Uploads a prepared photo to `users/{uid}/bookings/{draftId}/{fileName}` (storage rules,
/// #102) and returns its download URL for `createBooking`. The Firebase implementation (#92)
/// must set `contentType: image/jpeg`: the rules only accept image content types.
abstract interface class PhotoUploader {
  Future<String> upload({required String draftId, required String fileName, required Uint8List bytes});
}

/// Until Firebase is wired (#92): keeps nothing and returns a Storage-shaped URL.
class FakePhotoUploader implements PhotoUploader {
  FakePhotoUploader({this.delay = Duration.zero});

  final Duration delay;
  final uploaded = <String>[];

  @override
  Future<String> upload({required String draftId, required String fileName, required Uint8List bytes}) async {
    await Future<void>.delayed(delay);
    final path = Uri.encodeComponent('users/me/bookings/$draftId/$fileName');
    uploaded.add(path);
    return 'https://firebasestorage.googleapis.com/v0/b/demo-roadside/o/$path?alt=media';
  }
}
