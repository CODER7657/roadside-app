// LaneApp: the one root widget every app uses (PLAN.md §7.1).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ambient/ambient_controller.dart';
import '../tokens/lane_text.dart';
import '../theme/lane_theme.dart';
import 'lane_licenses.dart';

/// Wraps [MaterialApp] with everything Lane owns:
/// - the theme for the ambient mode picked by `AmbientController`, cross-faded over
///   `motion.standard` when the mode changes (the map and routes are not rebuilt)
/// - the hi/gu type scale when the locale is Hindi or Gujarati
/// - text scaling clamped to 200% (layouts must reflow up to there)
/// - shared-axis page transitions (a fade with reduced motion)
/// - the OfflineStrip slot above every screen
/// - third-party notices on the licenses screen
///
/// Needs a `ProviderScope` above it.
class LaneApp extends ConsumerWidget {
  /// For apps that use `go_router` (every Lane app). See PLAN §7.1.
  const LaneApp.router({
    super.key,
    required RouterConfig<Object> this.routerConfig,
    this.title = '',
    this.onGenerateTitle,
    this.locale,
    this.localizationsDelegates,
    this.supportedLocales = const [Locale('en')],
    this.offlineStrip,
  }) : home = null;

  /// A single screen with no router: Widgetbook, tests, the lane_ui example.
  const LaneApp({
    super.key,
    required Widget this.home,
    this.title = '',
    this.onGenerateTitle,
    this.locale,
    this.localizationsDelegates,
    this.supportedLocales = const [Locale('en')],
    this.offlineStrip,
  }) : routerConfig = null;

  /// Largest text scale Lane lays out for (PLAN §6.8).
  static const maxTextScale = 2.0;

  final RouterConfig<Object>? routerConfig;
  final Widget? home;
  final String title;
  final GenerateAppTitle? onGenerateTitle;
  final Locale? locale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Iterable<Locale> supportedLocales;

  /// The connectivity banner (`OfflineStrip`). It sits above the screen, owns the top safe
  /// area while shown and takes no space when online.
  final Widget? offlineStrip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LaneLicenses.register();
    final mode = ref.watch(laneModeProvider);
    final theme = LaneThemeData.build(mode);
    // The cross-fade itself counts as motion: in Saver it's a quick fade.
    final fade = LaneTheme.of(mode).motion;

    Widget shell(BuildContext context, Widget? child) =>
        _LaneShell(offlineStrip: offlineStrip, child: child ?? const SizedBox.shrink());

    if (routerConfig != null) {
      return MaterialApp.router(
        routerConfig: routerConfig,
        title: title,
        onGenerateTitle: onGenerateTitle,
        locale: locale,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        theme: theme,
        themeAnimationDuration: fade.standard,
        themeAnimationCurve: fade.move,
        debugShowCheckedModeBanner: false,
        builder: shell,
      );
    }
    return MaterialApp(
      home: home,
      title: title,
      onGenerateTitle: onGenerateTitle,
      locale: locale,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales,
      theme: theme,
      themeAnimationDuration: fade.standard,
      themeAnimationCurve: fade.move,
      debugShowCheckedModeBanner: false,
      builder: shell,
    );
  }
}

class _LaneShell extends StatelessWidget {
  const _LaneShell({required this.offlineStrip, required this.child});

  final Widget? offlineStrip;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Runs inside Localizations and the animated theme, so the script follows the locale
    // and the colours are mid-cross-fade.
    final base = Theme.of(context);
    final lane = base.extension<LaneTheme>()!.withScript(LaneScript.of(Localizations.localeOf(context)));

    Widget screen = child;
    if (offlineStrip != null) {
      screen = Column(
        children: [
          offlineStrip!,
          Expanded(child: screen),
        ],
      );
    }

    return Theme(
      data: base.copyWith(textTheme: LaneThemeData.textThemeOf(lane.text), extensions: [lane]),
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: LaneApp.maxTextScale,
        child: DefaultTextStyle(style: lane.text.body, child: screen),
      ),
    );
  }
}
