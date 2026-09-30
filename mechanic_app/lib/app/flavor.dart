import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which Firebase project and build the app runs against (PLAN §5 Environments).
enum AppFlavor {
  /// `roadside-33282` (dev) or the emulators. Test phone numbers, debug App Check.
  dev,

  /// `roadside-prod` (client-owned).
  prod,
}

/// Set once in `bootstrap` from `main_dev.dart` / `main_prod.dart`.
final flavorProvider = Provider<AppFlavor>((ref) => throw UnimplementedError('Overridden in bootstrap()'));
