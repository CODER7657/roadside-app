import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/first_run/application/first_run.dart';
import '../features/first_run/presentation/consent_screen.dart';
import '../features/first_run/presentation/language_screen.dart';
import '../features/first_run/presentation/onboarding_screen.dart';
import '../features/first_run/presentation/privacy_notice_screen.dart';
import '../features/first_run/presentation/splash_screen.dart';
import '../features/help/presentation/help_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/permissions/application/permission_service.dart';
import '../features/permissions/presentation/permission_explainer_screen.dart';
import '../features/vehicles/presentation/add_vehicle_screen.dart';
import '../features/vehicles/presentation/my_vehicles_screen.dart';

/// Route paths. Screens are added per issue (C7/C9 #95, login #96, U1 #12, …).
abstract final class AppRoutes {
  static const splash = '/splash';
  static const home = '/';
  static const privacy = '/privacy';
  static const help = '/help';
  static const vehicles = '/vehicles';
  static const addVehicle = '/vehicles/add';
}

/// Keeps first run in order: home (and later everything else) waits until language,
/// onboarding and consent are done. Splash and the privacy notice are always reachable.
String? firstRunRedirect(FirstRunState firstRun, String location) {
  if (location == AppRoutes.splash || location == AppRoutes.privacy) return null;
  // Asking for a permission is never blocked by first run.
  if (location.startsWith('/permission/')) return null;
  final next = firstRun.nextStep;
  const steps = [FirstRunStep.language, FirstRunStep.onboarding, FirstRunStep.consent];
  if (next == null) return steps.contains(location) ? AppRoutes.home : null;
  // Going back to an earlier step (e.g. to change the language) is fine; skipping ahead isn't.
  final at = steps.indexOf(location);
  return at != -1 && at <= steps.indexOf(next) ? null : next;
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) => firstRunRedirect(ref.read(firstRunProvider), state.matchedLocation),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: FirstRunStep.language, builder: (context, state) => const LanguageScreen()),
      GoRoute(path: FirstRunStep.onboarding, builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: FirstRunStep.consent, builder: (context, state) => const ConsentScreen()),
      GoRoute(path: AppRoutes.privacy, builder: (context, state) => const PrivacyNoticeScreen()),
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.help, builder: (context, state) => const HelpScreen()),
      GoRoute(path: AppRoutes.vehicles, builder: (context, state) => const MyVehiclesScreen()),
      GoRoute(path: AppRoutes.addVehicle, builder: (context, state) => const AddVehicleScreen()),
      GoRoute(
        path: '/permission/:kind',
        builder: (context, state) =>
            PermissionExplainerScreen(permission: AppPermission.values.byName(state.pathParameters['kind']!)),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
