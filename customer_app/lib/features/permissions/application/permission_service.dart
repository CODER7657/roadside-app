import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// The runtime permissions the customer app asks for (PLAN §11). Nothing else.
enum AppPermission { location, camera, notifications }

/// What the app can do about a permission right now.
enum PermissionAccess {
  granted,

  /// Not granted yet; asking shows the system prompt.
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

class PlatformPermissionService implements PermissionService {
  const PlatformPermissionService();

  static ph.Permission _of(AppPermission p) => switch (p) {
    AppPermission.location => ph.Permission.locationWhenInUse,
    AppPermission.camera => ph.Permission.camera,
    AppPermission.notifications => ph.Permission.notification,
  };

  static PermissionAccess _map(ph.PermissionStatus s) => switch (s) {
    ph.PermissionStatus.granted || ph.PermissionStatus.limited => PermissionAccess.granted,
    ph.PermissionStatus.permanentlyDenied || ph.PermissionStatus.restricted => PermissionAccess.blocked,
    _ => PermissionAccess.askable,
  };

  @override
  Future<PermissionAccess> status(AppPermission permission) async => _map(await _of(permission).status);

  @override
  Future<PermissionAccess> request(AppPermission permission) async => _map(await _of(permission).request());

  @override
  Future<bool> openSettings() => ph.openAppSettings();
}

final permissionServiceProvider = Provider<PermissionService>((ref) => const PlatformPermissionService());
