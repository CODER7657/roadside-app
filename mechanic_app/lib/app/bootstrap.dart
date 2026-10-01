import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/application/auth.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/first_run/application/first_run.dart';
import 'app.dart';
import 'crash_reporting.dart';
import 'env.dart';
import 'firebase.dart';
import 'flavor.dart';
import 'remote_flags.dart';

/// Starts the app for a flavour: Firebase (the flavour's project or the emulators), App Check,
/// Crashlytics and Remote Config. Without a Firebase config it still starts, on the fakes.
Future<void> bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Uncaught errors go through LaneLog, which redacts personal data in release builds.
  FlutterError.onError = (details) =>
      LaneLog.e('flutter error', error: details.exception, stackTrace: details.stack, fields: kFatal);
  PlatformDispatcher.instance.onError = (error, stack) {
    LaneLog.e('uncaught error', error: error, stackTrace: stack, fields: kFatal);
    return true;
  };

  final firebase = await connectFirebase(flavor);
  RemoteFlags Function()? remoteFlags;
  if (firebase?.mode == FirebaseMode.project) {
    // Each of these is optional for the app to work: a failure is logged, never fatal at launch.
    await _guarded('app check', () async {
      // PLAN §12.3: Play Integrity in prod; the debug provider in dev.
      await FirebaseAppCheck.instance.activate(
        providerAndroid: flavor == AppFlavor.prod
            ? const AndroidPlayIntegrityProvider()
            : AndroidDebugProvider(
                debugToken: AppEnv.appCheckDebugToken.isEmpty ? null : AppEnv.appCheckDebugToken,
              ),
      );
    });

    await _guarded('crashlytics', () async {
      // Reports only from release builds; LaneLog records reach Crashlytics redacted.
      final crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCrashlyticsCollectionEnabled(kReleaseMode);
      await crashlytics.setCustomKey('flavor', flavor.name);
      LaneLog.sink = crashReportingSink(CrashlyticsReporter(crashlytics), next: LaneLog.sink);
    });

    await _guarded('remote config', () async {
      final config = await setUpRemoteConfig(FirebaseRemoteConfig.instance, flavor);
      remoteFlags = () => RemoteFlags.fromConfig(config);
    });
  }
  LaneLog.i('firebase', {'mode': (firebase?.mode ?? FirebaseMode.none).name, 'flavor': flavor.name});

  // First-run state (language, onboarding, consent) is read before the first frame.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        flavorProvider.overrideWithValue(flavor),
        sharedPreferencesProvider.overrideWithValue(prefs),
        firebaseServicesProvider.overrideWithValue(firebase),
        if (firebase != null) authRepositoryProvider.overrideWithValue(FirebaseAuthRepository(firebase.auth)),
        if (remoteFlags != null) remoteFlagsProvider.overrideWith((ref) => remoteFlags!()),
      ],
      child: const MechanicApp(),
    ),
  );

  if (flavor == AppFlavor.dev && AppEnv.crashlyticsTest) {
    LaneLog.e('crashlytics test report', error: StateError('Test report from the dev build (#120)'));
  }
}

Future<void> _guarded(String what, Future<void> Function() setUp) async {
  try {
    await setUp();
  } catch (e) {
    LaneLog.w('$what setup failed', error: e);
  }
}
