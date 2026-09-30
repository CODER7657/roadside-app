import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import 'flavor.dart';

/// Remote Config (PLAN §3): force update and feature flags. The in-app defaults hold until the
/// first fetch, and whenever Remote Config can't be reached.
@immutable
class RemoteFlags {
  const RemoteFlags({this.minSupportedBuild = 0, this.liveUpdateEnabled = false});

  factory RemoteFlags.fromConfig(FirebaseRemoteConfig config) => RemoteFlags(
    minSupportedBuild: config.getInt(keyMinSupportedBuild),
    liveUpdateEnabled: config.getBool(keyLiveUpdateEnabled),
  );

  static const keyMinSupportedBuild = 'min_supported_build';
  static const keyLiveUpdateEnabled = 'live_update_enabled';

  static const defaults = RemoteFlags();

  /// What Remote Config starts from (`setDefaults`).
  static Map<String, Object> get defaultParameters => {
    keyMinSupportedBuild: defaults.minSupportedBuild,
    keyLiveUpdateEnabled: defaults.liveUpdateEnabled,
  };

  /// Builds below this must update before going on (the blocking screen comes with the force
  /// update check, PLAN §12.7). 0 = nobody is forced.
  final int minSupportedBuild;

  /// Android 16 Live Update for the active job (mechanic_app CLAUDE.md). Off until it ships.
  final bool liveUpdateEnabled;
}

/// Overridden in `bootstrap` once Remote Config is set up.
final remoteFlagsProvider = Provider<RemoteFlags>((ref) => RemoteFlags.defaults);

/// How often a fetch may hit the server: often in dev, to try flags; rarely in prod.
Duration remoteConfigInterval(AppFlavor flavor) =>
    flavor == AppFlavor.dev ? const Duration(minutes: 5) : const Duration(hours: 12);

/// Sets the defaults and starts a fetch that doesn't hold up the first frame. If the fetch
/// fails, the defaults (or the last fetched values) stay in use.
Future<FirebaseRemoteConfig> setUpRemoteConfig(FirebaseRemoteConfig config, AppFlavor flavor) async {
  await config.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: remoteConfigInterval(flavor),
    ),
  );
  await config.setDefaults(RemoteFlags.defaultParameters);
  unawaited(
    config.fetchAndActivate().then<void>(
      (_) {},
      onError: (Object e) => LaneLog.w('remote config fetch failed', error: e),
    ),
  );
  return config;
}
