import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// The runtime permissions the mechanic app asks for (PLAN §11). Nothing else: no
/// background location, SMS or contacts.
enum AppPermission {
  /// While the app is in use. During a job the foreground service (type `location`, #30)
  /// keeps it going with a visible notification, so background location is never needed.
  location,
  camera,
  notifications,

  /// Full-screen job offers (Android 14+ special access, not a pop-up): M4 shows over the
  /// lock screen like an incoming call.
  fullScreenOffers,
}

/// What the app can do about a permission right now.
enum PermissionAccess {
  granted,

  /// Not granted yet; asking shows the system prompt (or, for full-screen offers, the
  /// phone's settings page for it).
  askable,

  /// Denied for good (or restricted): only the phone's Settings can change it.
  blocked,
}

/// Wraps the platform so screens and tests don't touch plugins directly.
abstract interface class PermissionService {
  Future<PermissionAccess> status(AppPermission permission);

  /// Shows the system prompt (call only after the C7 explainer).
  Future<PermissionAccess> request(AppPermission permission);

  /// Opens this app's page in the phone's Settings.
  Future<bool> openSettings();
}

/// Full-screen intent access lives in `MainActivity.kt`: permission_handler doesn't cover it.
class FullScreenIntentChannel {
  const FullScreenIntentChannel();

  static const _channel = MethodChannel('roadside/full_screen_intent');

  /// True below Android 14, where no special access is needed.
  Future<bool> canUse() async => await _channel.invokeMethod<bool>('canUse') ?? false;

  /// Opens Settings › Full-screen notifications for this app. False if there's no such page.
  Future<bool> openSettings() async => await _channel.invokeMethod<bool>('openSettings') ?? false;
}

class PlatformPermissionService implements PermissionService {
  const PlatformPermissionService({this.fullScreen = const FullScreenIntentChannel()});

  final FullScreenIntentChannel fullScreen;

  static ph.Permission _of(AppPermission p) => switch (p) {
    AppPermission.location => ph.Permission.locationWhenInUse,
    AppPermission.camera => ph.Permission.camera,
    AppPermission.notifications => ph.Permission.notification,
    AppPermission.fullScreenOffers => throw ArgumentError('handled by FullScreenIntentChannel'),
  };

  static PermissionAccess _map(ph.PermissionStatus s) => switch (s) {
    ph.PermissionStatus.granted || ph.PermissionStatus.limited => PermissionAccess.granted,
    ph.PermissionStatus.permanentlyDenied || ph.PermissionStatus.restricted => PermissionAccess.blocked,
    _ => PermissionAccess.askable,
  };

  @override
  Future<PermissionAccess> status(AppPermission permission) async {
    if (permission == AppPermission.fullScreenOffers) {
      return await fullScreen.canUse() ? PermissionAccess.granted : PermissionAccess.askable;
    }
    return _map(await _of(permission).status);
  }

  @override
  Future<PermissionAccess> request(AppPermission permission) async {
    if (permission == AppPermission.fullScreenOffers) {
      // No prompt exists: open its settings page. The explainer re-checks when the app resumes.
      await fullScreen.openSettings();
      return status(permission);
    }
    return _map(await _of(permission).request());
  }

  @override
  Future<bool> openSettings() => ph.openAppSettings();
}

final permissionServiceProvider = Provider<PermissionService>((ref) => const PlatformPermissionService());
