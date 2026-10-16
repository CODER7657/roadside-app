import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roadside_core/roadside_core.dart';

import '../features/auth/application/auth.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/first_run/application/first_run.dart';
import '../features/first_run/presentation/consent_screen.dart';
import '../features/first_run/presentation/language_screen.dart';
import '../features/first_run/presentation/onboarding_screen.dart';
import '../features/first_run/presentation/privacy_notice_screen.dart';
import '../features/first_run/presentation/splash_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/help/presentation/help_screen.dart';
import '../features/job/presentation/complete_job_screen.dart';
import '../features/job/presentation/job_screen.dart';
import '../features/job/presentation/start_code_screen.dart';
import '../features/offers/presentation/offer_screen.dart';
import '../features/permissions/application/permission_service.dart';
import '../features/permissions/presentation/permission_explainer_screen.dart';
import '../features/registration/application/registration.dart';
import '../features/registration/presentation/pending_screen.dart';
import '../features/registration/presentation/registration_screen.dart';

/// Route paths. Screens are added per issue (M6 #31, …). Home is M3 Dashboard;
/// M4 is `/offer/:offerId` (offerRoute) and M5, the accepted job, `/job/:bookingId` (jobRoute).
abstract final class AppRoutes {
  static const splash = '/splash';
  static const home = '/';
  static const privacy = '/privacy';
  static const help = '/help';
  static const register = '/register';
  static const pending = '/pending';

  /// C5 Phone login, then C6 Enter OTP.
  static const login = '/login';
  static const loginCode = '/login/code';
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

/// After first run, before registration: C5–C6 until signed in (PLAN §10 Common: consent comes
/// before sign-up). Help, the privacy notice and permission explainers stay reachable. While
/// Auth is restoring the session ([user] not yet known), nothing moves.
String? authRedirect(AsyncValue<AuthUser?> user, String location) {
  const open = [AppRoutes.splash, AppRoutes.privacy, AppRoutes.help];
  if (open.contains(location) || location.startsWith('/permission/')) return null;
  if (!user.hasValue) return null;
  final onLogin = location == AppRoutes.login || location == AppRoutes.loginCode;
  if (user.value == null) return onLogin ? null : AppRoutes.login;
  return onLogin ? AppRoutes.home : null;
}

/// After first run and login: M1 until registered, M2 while pending or blocked, home once approved.
/// Help, the privacy notice and permission explainers stay reachable from M1 and M2.
/// While the profile is still loading ([status] not yet known), nothing moves.
String? registrationRedirect(AsyncValue<MechanicStatus?> status, String location) {
  const open = [AppRoutes.splash, AppRoutes.privacy, AppRoutes.help];
  if (open.contains(location) || location.startsWith('/permission/')) return null;
  if (!status.hasValue) return null;
  switch (status.value) {
    case null:
      return location == AppRoutes.register ? null : AppRoutes.register;
    case MechanicStatus.pending || MechanicStatus.blocked:
      return location == AppRoutes.pending ? null : AppRoutes.pending;
    case MechanicStatus.approved:
      // Everything else (home, offers, jobs) is theirs; only registration is behind them.
      return location == AppRoutes.register || location == AppRoutes.pending ? AppRoutes.home : null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run the redirects on sign-in / sign-out and when the profile changes (submitted,
  // approved, blocked).
  final refresh = ValueNotifier<int>(0);
  ref.listen(authUserProvider, (_, _) => refresh.value++);
  ref.listen(registrationStatusProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final firstRun = firstRunRedirect(ref.read(firstRunProvider), location);
      if (firstRun != null || ref.read(firstRunProvider).nextStep != null) return firstRun;
      final user = ref.read(authUserProvider);
      return authRedirect(user, location) ??
          (user.value != null ? registrationRedirect(ref.read(registrationStatusProvider), location) : null);
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: FirstRunStep.language, builder: (context, state) => const LanguageScreen()),
      GoRoute(path: FirstRunStep.onboarding, builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: FirstRunStep.consent, builder: (context, state) => const ConsentScreen()),
      GoRoute(path: AppRoutes.privacy, builder: (context, state) => const PrivacyNoticeScreen()),
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: AppRoutes.loginCode, builder: (context, state) => const OtpScreen()),
      GoRoute(path: AppRoutes.home, builder: (context, state) => const DashboardScreen()),
      GoRoute(path: AppRoutes.help, builder: (context, state) => const HelpScreen()),
      GoRoute(path: AppRoutes.register, builder: (context, state) => const RegistrationScreen()),
      GoRoute(path: AppRoutes.pending, builder: (context, state) => const PendingScreen()),
      GoRoute(
        path: '/offer/:offerId',
        builder: (context, state) => OfferScreen(offerId: state.pathParameters['offerId']!),
      ),
      GoRoute(
        path: '/job/:bookingId',
        builder: (context, state) => JobScreen(bookingId: state.pathParameters['bookingId']!),
        routes: [
          GoRoute(
            path: 'start',
            builder: (context, state) => StartCodeScreen(bookingId: state.pathParameters['bookingId']!),
          ),
          GoRoute(
            path: 'complete',
            builder: (context, state) => CompleteJobScreen(bookingId: state.pathParameters['bookingId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/permission/:kind',
        builder: (context, state) =>
            PermissionExplainerScreen(permission: AppPermission.values.byName(state.pathParameters['kind']!)),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
