import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:roadside_core/roadside_core.dart';

/// What `respondToOffer` (#28) said.
enum OfferOutcome {
  accepted,
  declined,

  /// Someone else's, gone, or no longer the booking's current offer (`error_offer_unavailable`).
  unavailable,

  /// Past its 30 s (`error_offer_expired`).
  expired,

  /// The mechanic went offline or already has a job (`error_not_available`).
  notAvailable,

  /// Network or anything unexpected: the screen offers to try again.
  failed,
}

@immutable
class OfferResponse {
  const OfferResponse(this.outcome, {this.bookingId});

  final OfferOutcome outcome;

  /// Set when accepted: the job to open next.
  final String? bookingId;
}

/// Maps a callable error message key (#23 `secureCall`) to an outcome.
OfferOutcome outcomeForError(String? messageKey) => switch (messageKey) {
  'error_offer_unavailable' => OfferOutcome.unavailable,
  'error_offer_expired' => OfferOutcome.expired,
  'error_not_available' => OfferOutcome.notAvailable,
  _ => OfferOutcome.failed,
};

/// Reads `offers/{offerId}` (readable only by that mechanic, #99) and answers it through the
/// `respondToOffer` callable. Clients never write offers or bookings.
abstract interface class OfferRepository {
  /// The offer as it changes (null if it doesn't exist or can't be read).
  Stream<Offer?> watch(String offerId);

  Future<OfferResponse> respond(String offerId, {required bool accept});
}

/// Until Firebase is wired (#120, #123).
class InMemoryOfferRepository implements OfferRepository {
  InMemoryOfferRepository([Map<String, Offer> offers = const {}]) : _offers = {...offers};

  final Map<String, Offer> _offers;
  final _changes = StreamController<String>.broadcast();

  /// What the next `respond` returns instead of the normal answer (tests).
  OfferOutcome? nextOutcome;
  final responses = <(String, bool)>[];

  /// What the server does (withdraw, expire); tests use it.
  void setState(String offerId, OfferState state) {
    _offers[offerId] = _offers[offerId]!.copyWith(state: state);
    _changes.add(offerId);
  }

  @override
  Stream<Offer?> watch(String offerId) async* {
    yield _offers[offerId];
    await for (final id in _changes.stream) {
      if (id == offerId) yield _offers[offerId];
    }
  }

  @override
  Future<OfferResponse> respond(String offerId, {required bool accept}) async {
    responses.add((offerId, accept));
    final forced = nextOutcome;
    nextOutcome = null;
    if (forced != null) return OfferResponse(forced);
    final offer = _offers[offerId];
    if (offer == null || offer.state != OfferState.pending) {
      return const OfferResponse(OfferOutcome.unavailable);
    }
    setState(offerId, accept ? OfferState.accepted : OfferState.declined);
    return accept
        ? OfferResponse(OfferOutcome.accepted, bookingId: offer.bookingId)
        : const OfferResponse(OfferOutcome.declined);
  }
}

class FirebaseOfferRepository implements OfferRepository {
  FirebaseOfferRepository(this._db, this._functions);

  final FirebaseFirestore _db;

  /// `FirebaseFunctions.instanceFor(region: 'asia-south1')`.
  final FirebaseFunctions _functions;

  @override
  Stream<Offer?> watch(String offerId) =>
      RoadsideRefs(_db).offers.doc(offerId).snapshots().map((s) => s.data());

  @override
  Future<OfferResponse> respond(String offerId, {required bool accept}) async {
    try {
      final result = await _functions.httpsCallable('respondToOffer').call<Map<String, dynamic>>({
        'offerId': offerId,
        'accept': accept,
      });
      final data = result.data;
      return data['state'] == 'accepted'
          ? OfferResponse(OfferOutcome.accepted, bookingId: data['bookingId'] as String?)
          : const OfferResponse(OfferOutcome.declined);
    } on FirebaseFunctionsException catch (e) {
      return OfferResponse(outcomeForError(e.message));
    } catch (_) {
      return const OfferResponse(OfferOutcome.failed);
    }
  }
}
