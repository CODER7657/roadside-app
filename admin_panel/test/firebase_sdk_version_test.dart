// web/firebase_sdk.js loads the Firebase JS SDK itself (the CSP forbids FlutterFire's inline
// loader). Its version must match what the FlutterFire plugins are built against.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `supportedFirebaseJsSdkVersion` from the resolved firebase_core_web package (web-only, so it's
/// read from source rather than imported).
String flutterFireSdkVersion() {
  final config =
      jsonDecode(File('.dart_tool/package_config.json').readAsStringSync()) as Map<String, dynamic>;
  final package = (config['packages'] as List<dynamic>).cast<Map<String, dynamic>>().firstWhere(
    (p) => p['name'] == 'firebase_core_web',
  );
  final rootUri = package['rootUri'] as String;
  final root = Uri.parse('.dart_tool/').resolve(rootUri.endsWith('/') ? rootUri : '$rootUri/');
  final source = File.fromUri(root.resolve('lib/src/firebase_sdk_version.dart')).readAsStringSync();
  return RegExp(r"supportedFirebaseJsSdkVersion = '([0-9.]+)'").firstMatch(source)![1]!;
}

void main() {
  test('web/firebase_sdk.js loads the Firebase JS SDK version FlutterFire expects', () {
    final loader = File('web/firebase_sdk.js').readAsStringSync();
    final version = RegExp(r"const FIREBASE_JS_SDK = '([0-9.]+)';").firstMatch(loader)?[1];
    expect(
      version,
      flutterFireSdkVersion(),
      reason: 'Update FIREBASE_JS_SDK in web/firebase_sdk.js after upgrading the Firebase plugins.',
    );
  });

  test('index.html has no inline scripts (the CSP blocks them)', () {
    final html = File('web/index.html').readAsStringSync();
    final inline = RegExp(r'<script(?![^>]*\bsrc=)[^>]*>').allMatches(html);
    expect(inline, isEmpty);
  });
}
