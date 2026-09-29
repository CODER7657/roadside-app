/// Build-time configuration from `--dart-define-from-file=env/dev.json` (PLAN §12.8).
/// The JSON files are git-ignored; `env/example.json` lists the keys.
abstract final class AppEnv {
  /// Ola Maps key, restricted to this app's package + SHA-1. Empty in CI and tests.
  static const olaMapsApiKey = String.fromEnvironment('OLA_MAPS_API_KEY');

  static bool get hasMapsKey => olaMapsApiKey.isNotEmpty;
}
