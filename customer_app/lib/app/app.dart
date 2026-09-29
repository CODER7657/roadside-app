import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart';

import '../l10n/app_localizations.dart';
import 'router.dart';

/// The customer app root (PLAN §7.1): LaneApp owns theme, ambient modes, hi/gu type,
/// text scaling, transitions and Lane's own strings.
class RoadsideApp extends ConsumerWidget {
  const RoadsideApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => LaneApp.router(
    routerConfig: ref.watch(routerProvider),
    onGenerateTitle: (context) => AppLocalizations.of(context).app_title,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}
