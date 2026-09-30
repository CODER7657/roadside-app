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

/// The clock offers count down against. Tests override it.
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

/// How much of the 30 s is already gone (the push can arrive late).
Duration elapsedOf(Offer offer, DateTime now, {Duration window = const Duration(seconds: 30)}) {
  final left = offer.expiresAt.difference(now);
  if (left <= Duration.zero) return window;
  final gone = window - left;
  return gone < Duration.zero ? Duration.zero : gone;
}
