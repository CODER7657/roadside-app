/// Build-time configuration from `--dart-define-from-file=env/dev.json` (PLAN §12.8).
/// The JSON files are git-ignored; `env/example.json` lists the keys.
abstract final class AppEnv {
  /// Ola Maps key for M5 Navigate, restricted to this app's package + SHA-1. Empty in CI and tests.
  static const olaMapsApiKey = String.fromEnvironment('OLA_MAPS_API_KEY');

  static bool get hasMapsKey => olaMapsApiKey.isNotEmpty;

  /// Support line in E.164 (e.g. +9179…), until `appConfig.supportPhone` is read from
  /// Firestore (#120). Empty hides the call and WhatsApp buttons.
  static const supportPhone = String.fromEnvironment('SUPPORT_PHONE');

  /// The DPDP grievance officer's address (PLAN §12.12), named in the policy (#55).
  static const grievanceEmail = String.fromEnvironment('GRIEVANCE_EMAIL');

  /// Dev only: use the local Emulator Suite instead of the dev project.
  static const useEmulators = bool.fromEnvironment('USE_EMULATORS');

  /// Where the emulators run, seen from the phone. `localhost` works on a USB phone or an
  /// emulator after `adb reverse tcp:8080 tcp:8080` (and 5001, 9099, 9199).
  static const emulatorHost = String.fromEnvironment('EMULATOR_HOST', defaultValue: 'localhost');

  /// Dev App Check debug token, registered in the dev project console (PLAN §12.3). Empty: the
  /// app prints a new one to logcat on first start. Never in git.
  static const appCheckDebugToken = String.fromEnvironment('APP_CHECK_DEBUG_TOKEN');

  /// Dev only: sends one test report on start, to check Crashlytics (#120).
  static const crashlyticsTest = bool.fromEnvironment('CRASHLYTICS_TEST');
}
