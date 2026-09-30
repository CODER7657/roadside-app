import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:lane_ui/lane_ui.dart';

import '../features/first_run/application/first_run.dart';
import '../features/profile/application/settings.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

/// The customer app root (PLAN §7.1): LaneApp owns theme, ambient modes, hi/gu type,
/// text scaling, transitions and Lane's own strings.
class RoadsideApp extends ConsumerWidget {
  const RoadsideApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => LaneApp.router(
    routerConfig: ref.watch(routerProvider),
    // The language chosen on C2; null follows the phone.
    locale: ref.watch(firstRunProvider.select((s) => s.locale)),
    onGenerateTitle: (context) => AppLocalizations.of(context).app_title,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

/// The provider container the app runs in, with the display mode chosen on U18 applied
/// before the first frame (so the app doesn't open in Day and then fade to Night).
ProviderContainer createAppContainer({List<Override> overrides = const []}) {
  final container = ProviderContainer(overrides: overrides);
  container.read(settingsProvider.notifier).applyDisplayMode();
  return container;
}
