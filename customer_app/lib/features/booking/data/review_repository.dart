import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roadside_core/roadside_core.dart';

/// What the customer writes on U14 (PLAN §8 `reviews/{bookingId}`).
class ReviewDraft {
  const ReviewDraft({required this.stars, this.tags = const [], this.comment = ''});

  /// `firestore.rules` (#99) limits.
  static const maxTags = 10;
  static const maxComment = 500;

  final int stars;
  final List<String> tags;
  final String comment;
}

/// Why a review couldn't be saved.
enum ReviewError {
  /// Already reviewed (the doc exists), or not allowed (not completed / not the customer's).
  notAllowed,

  /// Offline or unknown; the same review can be sent again.
  failed,
}

class ReviewException implements Exception {
  const ReviewException(this.error);

  final ReviewError error;
}

/// One review per completed booking, by its customer; never edited or deleted (rules #99).
abstract interface class ReviewRepository {
  /// Whether this booking has been reviewed.
  Future<bool> exists(String bookingId);

  /// Throws [ReviewException].
  Future<void> submit({
    required String bookingId,
    required String customerId,
    required String mechanicId,
    required ReviewDraft review,
  });
}

/// The exact document the rules accept: these keys only, `createdAt` = server time.
Map<String, Object?> reviewFields({
  required String customerId,
  required String mechanicId,
  required ReviewDraft review,
}) => stampCreated({
  'customerId': customerId,
  'mechanicId': mechanicId,
  'stars': review.stars.clamp(1, 5),
  'tags': review.tags.take(ReviewDraft.maxTags).toList(),
  'comment': review.comment.trim().length > ReviewDraft.maxComment
      ? review.comment.trim().substring(0, ReviewDraft.maxComment)
      : review.comment.trim(),
});

class FirestoreReviewRepository implements ReviewRepository {
  FirestoreReviewRepository(this._refs);

  static const queuedAfter = Duration(seconds: 8);

  final RoadsideRefs _refs;

  @override
  Future<bool> exists(String bookingId) async {
    try {
      return (await _refs.reviews.doc(bookingId).get()).exists;
    } on FirebaseException catch (e) {
      // The rules read `resource.data` of the review, so reading one that doesn't exist yet is
      // denied rather than "not found". For the booking's own customer that means: not reviewed.
      if (e.code == 'permission-denied') return false;
      rethrow;
    }
  }

  @override
  Future<void> submit({
    required String bookingId,
    required String customerId,
    required String mechanicId,
    required ReviewDraft review,
  }) async {
    try {
      // Offline, Firestore queues the write and this future only completes once the server
      // has it; don't keep the customer waiting: after [queuedAfter] it counts as sent.
      await _refs
          .raw(_refs.reviews.doc(bookingId))
          .set(reviewFields(customerId: customerId, mechanicId: mechanicId, review: review))
          .timeout(queuedAfter, onTimeout: () {});
    } on FirebaseException catch (e) {
      throw ReviewException(e.code == 'permission-denied' ? ReviewError.notAllowed : ReviewError.failed);
    }
  }
}

/// Until #92 wires Firebase: the same one-per-booking rule in memory.
class InMemoryReviewRepository implements ReviewRepository {
  final saved = <String, Map<String, Object?>>{};

  /// Set to make the next submit fail.
  ReviewError? failNext;

  @override
  Future<bool> exists(String bookingId) async => saved.containsKey(bookingId);

  @override
  Future<void> submit({
    required String bookingId,
    required String customerId,
    required String mechanicId,
    required ReviewDraft review,
  }) async {
    final fail = failNext;
    if (fail != null) {
      failNext = null;
      throw ReviewException(fail);
    }
    if (saved.containsKey(bookingId)) throw const ReviewException(ReviewError.notAllowed);
    saved[bookingId] = reviewFields(customerId: customerId, mechanicId: mechanicId, review: review);
  }
}
