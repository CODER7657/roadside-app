import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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

  /// App Check provider (PLAN §12.3): `v3` (reCAPTCHA v3, free: dev), `enterprise` (reCAPTCHA
  /// Enterprise: prod), `debug` (a local run against a real project; register the token the
  /// browser console prints, and never commit it) or empty for off. Off with the emulators.
  static const appCheck = String.fromEnvironment('APP_CHECK');
  static const recaptchaSiteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');
  static const appCheckDebugToken = String.fromEnvironment('APP_CHECK_DEBUG_TOKEN');

  /// The web provider for [appCheck], or null when App Check is off or its site key is missing.
  static WebProvider? get appCheckProvider => appCheckProviderFor(
    useEmulators: useEmulators,
    mode: appCheck,
    siteKey: recaptchaSiteKey,
    debugToken: appCheckDebugToken,
  );

  @visibleForTesting
  static WebProvider? appCheckProviderFor({
    required bool useEmulators,
    required String mode,
    required String siteKey,
    required String debugToken,
  }) {
    if (useEmulators) return null;
    return switch (mode) {
      'v3' when siteKey.isNotEmpty => ReCaptchaV3Provider(siteKey),
      'enterprise' when siteKey.isNotEmpty => ReCaptchaEnterpriseProvider(siteKey),
      'debug' => WebDebugProvider(debugToken: debugToken.isEmpty ? null : debugToken),
      _ => null,
    };
  }

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
