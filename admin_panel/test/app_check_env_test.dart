import 'package:admin_panel/app/env.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WebProvider? provider({
    bool emulators = false,
    String mode = '',
    String key = '',
    String token = '',
    bool release = false,
  }) => AppEnv.appCheckProviderFor(
    useEmulators: emulators,
    mode: mode,
    siteKey: key,
    debugToken: token,
    release: release,
  );

  test('reCAPTCHA v3 in dev, Enterprise in prod', () {
    expect(
      provider(mode: 'v3', key: 'site'),
      isA<ReCaptchaV3Provider>().having((p) => p.siteKey, 'siteKey', 'site'),
    );
    expect(provider(mode: 'enterprise', key: 'site'), isA<ReCaptchaEnterpriseProvider>());
  });

  test('off without a site key, with an unknown mode, or on the emulators', () {
    expect(provider(mode: 'v3'), isNull);
    expect(provider(mode: 'enterprise'), isNull);
    expect(provider(), isNull);
    expect(provider(mode: 'recaptcha', key: 'site'), isNull);
    expect(provider(emulators: true, mode: 'v3', key: 'site'), isNull);
  });

  test('debug uses the given token, or lets the SDK make one', () {
    expect(
      provider(mode: 'debug', token: 't'),
      isA<WebDebugProvider>().having((p) => p.debugToken, 'token', 't'),
    );
    expect(provider(mode: 'debug'), isA<WebDebugProvider>().having((p) => p.debugToken, 'token', isNull));
  });

  test('release builds never use the debug provider (the env is in the public JS)', () {
    expect(provider(mode: 'debug', token: 't', release: true), isNull);
    expect(provider(mode: 'debug', release: true), isNull);
    expect(provider(mode: 'enterprise', key: 'site', release: true), isA<ReCaptchaEnterpriseProvider>());
  });
}
