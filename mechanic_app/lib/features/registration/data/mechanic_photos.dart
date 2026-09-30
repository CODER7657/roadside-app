import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

// Picking and preparing photos. Same pipeline as customer_app's booking photos
// (lib/features/booking/data/photo_pipeline.dart): scaled, re-encoded, EXIF stripped.

/// Where a photo comes from.
enum PhotoSource { camera, gallery }

/// PLAN §10: photos are at most 1600 px on the long side and 500 KB, as JPEG.
abstract final class PhotoLimits {
  static const maxSide = 1600;
  static const maxBytes = 500 * 1024;
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

typedef JpegEncoder = Future<Uint8List> Function(Uint8List bytes, int quality);

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

/// Uploads M1 photos to the paths the storage rules allow (#102). The Firebase implementation
/// (#120) must set `contentType: image/jpeg`: the rules only accept image content types.
abstract interface class MechanicPhotoUploader {
  /// Profile, shop and toolkit photos → `mechanics/{uid}/shop/{fileName}`. Returns the
  /// **download URL** (shown to customers through the mechanicCard).
  Future<String> uploadShopPhoto({required String fileName, required Uint8List bytes});

  /// ID proof, selfie with ID, address proof → `mechanics/{uid}/kyc/{fileName}`, write once.
  /// Returns the **Storage path**, never a URL: KYC stays admin-only (PLAN §8).
  Future<String> uploadKycDocument({required String fileName, required Uint8List bytes});
}

/// Until Firebase is wired (#120): keeps nothing and returns Storage-shaped values.
class FakeMechanicPhotoUploader implements MechanicPhotoUploader {
  FakeMechanicPhotoUploader({this.uid = 'me', this.failNext = 0});

  final String uid;

  /// How many of the next uploads fail (tests).
  int failNext;
  final uploaded = <String>[];

  void _maybeFail() {
    if (failNext > 0) {
      failNext--;
      throw Exception('upload failed');
    }
  }

  @override
  Future<String> uploadShopPhoto({required String fileName, required Uint8List bytes}) async {
    _maybeFail();
    final path = 'mechanics/$uid/shop/$fileName';
    uploaded.add(path);
    return 'https://firebasestorage.googleapis.com/v0/b/demo-roadside/o/${Uri.encodeComponent(path)}?alt=media';
  }

  @override
  Future<String> uploadKycDocument({required String fileName, required Uint8List bytes}) async {
    _maybeFail();
    final path = 'mechanics/$uid/kyc/$fileName';
    uploaded.add(path);
    return path;
  }
}
