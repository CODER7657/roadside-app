import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../features/auth/application/admin_session.dart';
import '../features/auth/data/admin_auth.dart';
import 'app.dart';
import 'env.dart';
import 'flavor.dart';

/// Starts the panel for a flavour. Firebase comes from `env/*.json`, or the local emulators when
/// `USE_EMULATORS=true`. Without either, A0 says the console isn't connected.
/// App Check (reCAPTCHA Enterprise) and Crashlytics are wired in #48 once the projects (#42) exist.
Future<void> bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Uncaught errors go through LaneLog, which redacts personal data in release builds.
  FlutterError.onError = (details) =>
      LaneLog.e('flutter error', error: details.exception, stackTrace: details.stack);
  PlatformDispatcher.instance.onError = (error, stack) {
    LaneLog.e('uncaught error', error: error, stackTrace: stack);
    return true;
  };

  AdminAuth? auth;
  final options = AppEnv.firebaseOptions;
  if (options != null) {
    await Firebase.initializeApp(options: options);
    if (AppEnv.useEmulators) {
      assert(flavor == AppFlavor.dev, 'Emulators are for the dev flavour only');
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    }
    auth = FirebaseAdminAuth(FirebaseAuth.instance);
  }

  runApp(
    UncontrolledProviderScope(
      container: createAdminContainer(
        overrides: [flavorProvider.overrideWithValue(flavor), adminAuthProvider.overrideWithValue(auth)],
      ),
      child: const AdminApp(),
    ),
  );
}
