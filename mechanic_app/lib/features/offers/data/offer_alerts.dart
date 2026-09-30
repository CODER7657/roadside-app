import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// A data push from dispatch (#28): `{type: 'offer' | 'offer_withdrawn', offerId, bookingId}`.
/// It never carries an address, a phone number or coordinates.
@immutable
class OfferPush {
  const OfferPush({required this.withdrawn, required this.offerId, required this.bookingId});

  final bool withdrawn;
  final String offerId;
  final String bookingId;

  /// Null for pushes that aren't about offers (status updates from #32 and anything malformed).
  static OfferPush? parse(Map<String, dynamic> data) {
    final type = data['type'];
    final offerId = data['offerId'];
    final bookingId = data['bookingId'];
    if ((type != 'offer' && type != 'offer_withdrawn') || offerId is! String || bookingId is! String) {
      return null;
    }
    if (offerId.isEmpty || bookingId.isEmpty) return null;
    return OfferPush(withdrawn: type == 'offer_withdrawn', offerId: offerId, bookingId: bookingId);
  }
}

/// Getting an offer in front of the mechanic when the app isn't: the `offers` channel and a
/// full-screen intent (PLAN §6.11), like an incoming call.
abstract interface class OfferAlerts {
  /// Creates the `offers` channel. Safe to call more than once.
  Future<void> init();

  /// Posts the offer notification; it opens M4 full screen on a locked phone.
  Future<void> show(OfferPush push, {required String title, required String body});

  Future<void> cancel(String offerId);

  /// Lets M4 show over the lock screen and turn the screen on, only while it's open
  /// (`MainActivity.kt`). The rest of the app always needs the phone unlocked.
  Future<void> showOverLockScreen(bool show);
}

/// Stable notification id per offer, so a withdrawal can cancel it.
int notificationIdFor(String offerId) => offerId.hashCode & 0x7fffffff;

class LocalNotificationOfferAlerts implements OfferAlerts {
  LocalNotificationOfferAlerts([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const channelId = 'offers';
  static const _lockScreen = MethodChannel('roadside/lock_screen');

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channel = AndroidNotificationChannel(
    channelId,
    'Job offers',
    description: 'New jobs near you. Loud, and full screen like a call.',
    importance: Importance.max,
  );

  @override
  Future<void> init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  @override
  Future<void> show(OfferPush push, {required String title, required String body}) => _plugin.show(
    id: notificationIdFor(push.offerId),
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.call,
        fullScreenIntent: true,
        // Offers expire after 30 s (#28); don't leave a dead one in the shade.
        timeoutAfter: 30 * 1000,
        visibility: NotificationVisibility.public,
      ),
    ),
    payload: push.offerId,
  );

  @override
  Future<void> cancel(String offerId) => _plugin.cancel(id: notificationIdFor(offerId));

  @override
  Future<void> showOverLockScreen(bool show) async {
    try {
      await _lockScreen.invokeMethod<void>('showOverLockScreen', show);
    } on MissingPluginException {
      // Tests and non-Android builds.
    }
  }
}

/// No-op until the notification plugin is wired with FCM (#120); also for tests.
class SilentOfferAlerts implements OfferAlerts {
  final shown = <String>[];
  final cancelled = <String>[];
  final lockScreen = <bool>[];

  @override
  Future<void> init() async {}

  @override
  Future<void> show(OfferPush push, {required String title, required String body}) async =>
      shown.add(push.offerId);

  @override
  Future<void> cancel(String offerId) async => cancelled.add(offerId);

  @override
  Future<void> showOverLockScreen(bool show) async => lockScreen.add(show);
}
