import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:lane_ui/lane_ui.dart';

import '../l10n/app_localizations.dart';
import 'router.dart';

/// The admin panel root (PLAN §7.1): LaneApp owns theme, ambient modes and Lane's strings.
class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => LaneApp.router(
    routerConfig: ref.watch(routerProvider),
    onGenerateTitle: (context) => AppLocalizations.of(context).app_title,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

/// The provider container the panel runs in: Night "control room" by default
/// (PLAN §6.13 ConsoleShell).
ProviderContainer createAdminContainer({List<Override> overrides = const []}) {
  final container = ProviderContainer(overrides: overrides);
  container.read(ambientControllerProvider.notifier).setManual(LaneMode.night);
  return container;
}
