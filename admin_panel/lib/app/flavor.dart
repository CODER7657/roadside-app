import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which Firebase project the panel runs against (PLAN §5 Environments).
enum AppFlavor {
  /// `roadside-dev`, or the local emulators when `USE_EMULATORS=true`.
  dev,

  /// `roadside-prod` (client-owned).
  prod,
}

/// Set once in `bootstrap` from `main_dev.dart` / `main_prod.dart`.
final flavorProvider = Provider<AppFlavor>((ref) => throw UnimplementedError('Overridden in bootstrap()'));
