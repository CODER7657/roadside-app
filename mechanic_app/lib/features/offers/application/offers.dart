import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roadside_core/roadside_core.dart';

import '../data/offer_alerts.dart';
import '../data/offer_repository.dart';

/// Route of M4 for one offer.
String offerRoute(String offerId) => '/offer/$offerId';

/// Route of the accepted job (M5 Navigate lands here with #30).
String jobRoute(String bookingId) => '/job/$bookingId';

// Seams: fakes until Firebase is wired (#120 FCM + notifications, #123 auth).
final offerRepositoryProvider = Provider<OfferRepository>((ref) => InMemoryOfferRepository());
final offerAlertsProvider = Provider<OfferAlerts>((ref) => SilentOfferAlerts());

/// The phone's clock, used only to draw the countdown ring. Tests override it.
final offerClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final offerProvider = StreamProvider.family<Offer?, String>(
  (ref, offerId) => ref.watch(offerRepositoryProvider).watch(offerId),
);

/// What to do with an offer push (#28). In the foreground, M4 opens straight away; otherwise the
/// `offers` notification (full screen on a locked phone) opens it. A withdrawal clears the
/// notification; an open M4 sees the offer's state change and closes itself.
Future<void> handleOfferPush(
  OfferPush push, {
  required bool appInForeground,
  required GoRouter router,
  required OfferAlerts alerts,
  required String title,
  required String body,
}) async {
  if (push.withdrawn) {
    await alerts.cancel(push.offerId);
    return;
  }
  if (appInForeground) {
    await router.push<void>(offerRoute(push.offerId));
  } else {
    await alerts.show(push, title: title, body: body);
  }
}

/// PLAN §11: offers last 30 s. Used when the offer doesn't carry its own window.
const kOfferWindow = Duration(seconds: 30);

/// The server's window for [offer]: `expiresAt − createdAt`, both server timestamps, so the
/// phone's clock doesn't come into it.
Duration offerWindow(Offer offer) {
  final created = offer.createdAt;
  if (created == null) return kOfferWindow;
  final window = offer.expiresAt.difference(created);
  return window > Duration.zero ? window : kOfferWindow;
}

/// How much of the window the push delay already used, for drawing the ring only. The phone's
/// clock may be off: a delay outside 0…window means it is, so the ring starts full instead.
/// Whether the offer has expired is the server's call (the offer's `state`, or
/// `error_offer_expired`), never this.
Duration elapsedOf(Offer offer, DateTime seenAt) {
  final created = offer.createdAt;
  if (created == null) return Duration.zero;
  final delay = seenAt.difference(created);
  return delay < Duration.zero || delay > offerWindow(offer) ? Duration.zero : delay;
}
