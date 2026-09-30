import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';

/// Route paths. Screens are added per issue (C1–C10, then M1 #26, M3 #27, …).
abstract final class AppRoutes {
  static const home = '/';
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen())],
  );
  ref.onDispose(router.dispose);
  return router;
});
