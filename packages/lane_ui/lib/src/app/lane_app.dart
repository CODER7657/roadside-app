// LaneApp: the one root widget every app uses (PLAN.md §7.1).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ambient/ambient_controller.dart';
import '../components/lane_feedback.dart';
import '../l10n/lane_localizations.dart';
import '../tokens/lane_text.dart';
import '../theme/lane_theme.dart';
import 'lane_licenses.dart';

/// Wraps [MaterialApp] with everything Lane owns:
/// - the theme for the ambient mode picked by `AmbientController`, cross-faded over
///   `motion.standard` when the mode changes (the map and routes are not rebuilt)
/// - the hi/gu type scale when the locale is Hindi or Gujarati
/// - text scaling clamped to 200% (layouts must reflow up to there)
/// - shared-axis page transitions (a fade with reduced motion)
/// - the OfflineStrip above every screen ([offline]), and Lane's own strings (en/hi/gu)
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
    this.offline,
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
    this.offline,
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

  /// Whether the device is offline (from the app's connectivity provider). When set,
  /// LaneApp shows an [OfflineStrip] above every screen and moves the top safe area to it.
  final bool? offline;

  /// A custom banner instead of [offline]'s `OfflineStrip`. It must own the top safe area
  /// itself while shown.
  final Widget? offlineStrip;

  /// Lane's component strings first, then the app's.
  Iterable<LocalizationsDelegate<dynamic>> get _delegates => [
    LaneLocalizations.delegate,
    ...?localizationsDelegates,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LaneLicenses.register();
    final mode = ref.watch(laneModeProvider);
    final theme = LaneThemeData.build(mode);
    // The cross-fade itself counts as motion: in Saver it's a quick fade.
    final fade = LaneTheme.of(mode).motion;

    Widget shell(BuildContext context, Widget? child) =>
        _LaneShell(offline: offline, offlineStrip: offlineStrip, child: child ?? const SizedBox.shrink());

    if (routerConfig != null) {
      return MaterialApp.router(
        routerConfig: routerConfig,
        title: title,
        onGenerateTitle: onGenerateTitle,
        locale: locale,
        localizationsDelegates: _delegates,
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
      localizationsDelegates: _delegates,
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
  const _LaneShell({required this.offline, required this.offlineStrip, required this.child});

  final bool? offline;
  final Widget? offlineStrip;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Runs inside Localizations and the animated theme, so the script follows the locale
    // and the colours are mid-cross-fade.
    final base = Theme.of(context);
    final lane = base.extension<LaneTheme>()!.withScript(LaneScript.of(Localizations.localeOf(context)));

    Widget screen = child;
    final strip = offlineStrip ?? (offline == null ? null : OfflineStrip(offline: offline!));
    if (strip != null) {
      screen = Column(
        children: [
          strip,
          Expanded(
            // While the strip is shown it owns the status-bar area, so the screen mustn't
            // pad for it again. Its own semantics container stops the route's BlockSemantics
            // from hiding the strip from TalkBack.
            child: Semantics(
              container: true,
              child: MediaQuery.removePadding(context: context, removeTop: offline ?? false, child: screen),
            ),
          ),
        ],
      );
    }

    // The strip sits inside the theme so it gets the hi/gu type and the cross-fade.
    return Theme(
      data: base.copyWith(textTheme: LaneThemeData.textThemeOf(lane.text), extensions: [lane]),
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: LaneApp.maxTextScale,
        child: DefaultTextStyle(style: lane.text.body, child: screen),
      ),
    );
  }
}
