import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/first_run/application/first_run.dart';
import 'app.dart';
import 'flavor.dart';

/// Starts the app for a flavour. Firebase (initializeApp, App Check, Crashlytics, Remote
/// Config) is wired here in #92 once the projects from #42 exist.
Future<void> bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Uncaught errors go through LaneLog, which redacts personal data in release builds.
  FlutterError.onError = (details) =>
      LaneLog.e('flutter error', error: details.exception, stackTrace: details.stack);
  PlatformDispatcher.instance.onError = (error, stack) {
    LaneLog.e('uncaught error', error: error, stackTrace: stack);
    return true;
  };

  // First-run state (language, onboarding, consent) is read before the first frame.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        flavorProvider.overrideWithValue(flavor),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const RoadsideApp(),
    ),
  );
}
