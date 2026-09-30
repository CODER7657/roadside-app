import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';

import '../_local_ui/console_shell.dart';
import '../features/auth/application/admin_session.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/console/application/city_filter.dart';
import '../features/console/presentation/console_sections.dart';
import '../features/console/presentation/labels.dart';
import '../features/prices/presentation/prices_screen.dart';
import '../l10n/app_localizations.dart';

const signInPath = '/sign-in';

/// Routes: A0 sign-in outside the shell, A1–A6 inside ConsoleShell. Nothing but A0 is
/// reachable without an admin session (PLAN §12.11 layer 2).
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<AdminSession>(ref.read(adminSessionProvider));
  ref.listen(adminSessionProvider, (_, next) => refresh.value = next);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: ConsoleSection.dashboard.path,
    refreshListenable: refresh,
    redirect: (context, state) {
      final isAdmin = ref.read(adminSessionProvider) is SessionAdmin;
      final atSignIn = state.matchedLocation == signInPath;
      if (!isAdmin) return atSignIn ? null : signInPath;
      return atSignIn ? ConsoleSection.dashboard.path : null;
    },
    routes: [
      GoRoute(path: signInPath, builder: (_, _) => const SignInScreen()),
      ShellRoute(
        builder: (context, state, child) => _Console(location: state.matchedLocation, child: child),
        routes: [
          for (final section in ConsoleSection.values)
            GoRoute(
              path: section.path,
              pageBuilder: (_, _) => NoTransitionPage(
                child: switch (section) {
                  ConsoleSection.prices => const PricesScreen(),
                  _ => SectionPlaceholder(section: section),
                },
              ),
            ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class _Console extends ConsumerWidget {
  const _Console({required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final current = ConsoleSection.fromPath(location);
    final city = ref.watch(cityFilterProvider);
    final session = ref.watch(adminSessionProvider);
    final email = session is SessionAdmin ? session.user.email : null;

    return ConsoleShell(
      title: current.label(l10n),
      nav: [
        for (final s in ConsoleSection.values)
          ConsoleNavItem(
            label: s.label(l10n),
            icon: s.icon,
            selected: s == current,
            onTap: () => context.go(s.path),
          ),
      ],
      filters: Semantics(
        label: l10n.console_filter_label,
        container: true,
        child: Wrap(
          spacing: lane.space.s8,
          runSpacing: lane.space.s8,
          children: [
            for (final c in <CityId?>[null, ...CityId.values])
              LaneChip(
                label: cityLabel(l10n, c),
                selected: city == c,
                onSelected: (_) => ref.read(cityFilterProvider.notifier).select(c),
              ),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (email != null)
            Flexible(
              child: Text(
                email,
                style: lane.text.caption.copyWith(color: lane.color.inkMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Gap(lane.space.s12),
          LaneButton.ghost(
            label: l10n.console_sign_out,
            onPressed: () => ref.read(adminSessionProvider.notifier).signOut(),
          ),
        ],
      ),
      child: child,
    );
  }
}
