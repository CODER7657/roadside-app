import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `FLAG_SECURE` (PLAN §12.7): no screenshots, screen recording or recents preview while a
/// screen with a code or ID on it is open. Set in `MainActivity` (`roadside/secure`).
abstract interface class SecureWindow {
  Future<void> setSecure(bool secure);
}

class PlatformSecureWindow implements SecureWindow {
  const PlatformSecureWindow();

  static const _channel = MethodChannel('roadside/secure');

  @override
  Future<void> setSecure(bool secure) async {
    try {
      await _channel.invokeMethod<void>('setSecure', secure);
    } on MissingPluginException {
      // Tests and non-Android hosts: nothing to protect.
    } on PlatformException {
      // Best effort; the screen still works.
    }
  }
}

final secureWindowProvider = Provider<SecureWindow>((ref) => const PlatformSecureWindow());

/// How many [SecureScreen]s are mounted. Going from one secure screen to another (C5 -> C6) mounts
/// the new one before the old one is disposed, so the flag goes off only when the last one goes.
int _secureScreens = 0;

/// Keeps the window secure while [child] is on screen.
class SecureScreen extends ConsumerStatefulWidget {
  const SecureScreen({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends ConsumerState<SecureScreen> {
  /// Read once: `ref` can't be used in dispose().
  late final SecureWindow _window;

  @override
  void initState() {
    super.initState();
    _window = ref.read(secureWindowProvider);
    if (_secureScreens++ == 0) unawaited(_window.setSecure(true));
  }

  @override
  void dispose() {
    if (--_secureScreens == 0) unawaited(_window.setSecure(false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
