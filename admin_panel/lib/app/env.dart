import 'package:firebase_core/firebase_core.dart';

/// Build-time configuration from `--dart-define-from-file=env/dev.json` (PLAN §12.8).
/// The JSON files are git-ignored; `env/example.json` lists the keys. The web config
/// identifies the project (it isn't secret), but the browser key must be restricted to the
/// admin domain (PLAN §12.8).
abstract final class AppEnv {
  /// Talk to the local Emulator Suite (`firebase emulators:start` in `firebase/`).
  static const useEmulators = bool.fromEnvironment('USE_EMULATORS');

  static const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const apiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
  static const appId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');

  /// Project the emulators run as (see `firebase/README.md`).
  static const emulatorProjectId = 'demo-roadside';

  /// Options for the real project, or for the emulators' demo project. Null when neither is
  /// configured, so the panel can say so instead of crashing.
  static FirebaseOptions? get firebaseOptions {
    if (useEmulators) {
      return const FirebaseOptions(
        apiKey: 'demo-key',
        appId: '1:0:web:0',
        messagingSenderId: '0',
        projectId: emulatorProjectId,
        authDomain: 'localhost',
      );
    }
    if (projectId.isEmpty || apiKey.isEmpty || appId.isEmpty) return null;
    return const FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain,
    );
  }
}
