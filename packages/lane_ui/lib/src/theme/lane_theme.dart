// LaneTheme: every token behind `context.lane` (PLAN.md §6, §7.2).
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../tokens/lane_colors.dart';
import '../tokens/lane_layout.dart';
import '../tokens/lane_motion.dart';
import '../tokens/lane_text.dart';

/// The four ambient modes (PLAN §6.5 ③). Picked by `AmbientController`.
enum LaneMode {
  /// Default between local sunrise and sunset. Warm "Chalk" background.
  day,

  /// After local sunset or with system dark mode. "Asphalt" palette.
  night,

  /// Harsh sun: pure black on white, heavier and bigger text, 2 px borders.
  glare,

  /// Low battery: Night palette with non-essential motion off.
  saver;

  bool get isDark => this == night || this == saver;
}

/// All Lane tokens for one mode and script. Read with `context.lane`.
@immutable
class LaneTheme extends ThemeExtension<LaneTheme> {
  const LaneTheme._({
    required this.mode,
    required this.color,
    required this.text,
    required this.motion,
    required this.shadow,
    required this.stroke,
  });

  factory LaneTheme.of(LaneMode mode, {LaneScript script = LaneScript.latin}) {
    final color = switch (mode) {
      LaneMode.day => LaneColors.day,
      LaneMode.night => LaneColors.night,
      LaneMode.glare => LaneColors.glare,
      LaneMode.saver => LaneColors.saver,
    };
    return LaneTheme._(
      mode: mode,
      color: color,
      text: LaneText.build(script: script, ink: color.ink, glare: mode == LaneMode.glare),
      motion: mode == LaneMode.saver ? LaneMotion.reduced : LaneMotion.full,
      shadow: mode.isDark ? LaneShadows.night : LaneShadows.day,
      stroke: mode == LaneMode.glare ? LaneStroke.glare : LaneStroke.normal,
    );
  }

  final LaneMode mode;
  final LaneColors color;
  final LaneText text;
  final LaneMotion motion;
  final LaneShadows shadow;
  final LaneStroke stroke;

  final LaneSpace space = const LaneSpace();
  final LaneRadius radius = const LaneRadius();
  final LaneTouch touch = const LaneTouch();

  LaneScript get script => text.script;

  /// The same tokens with the type scale for [script] (hi/gu switch family and metrics).
  LaneTheme withScript(LaneScript script) => script == this.script
      ? this
      : copyWith(
          text: LaneText.build(script: script, ink: color.ink, glare: mode == LaneMode.glare),
        );

  @override
  LaneTheme copyWith({
    LaneMode? mode,
    LaneColors? color,
    LaneText? text,
    LaneMotion? motion,
    LaneShadows? shadow,
    LaneStroke? stroke,
  }) => LaneTheme._(
    mode: mode ?? this.mode,
    color: color ?? this.color,
    text: text ?? this.text,
    motion: motion ?? this.motion,
    shadow: shadow ?? this.shadow,
    stroke: stroke ?? this.stroke,
  );

  /// Colours cross-fade between modes; everything else switches halfway.
  @override
  LaneTheme lerp(covariant LaneTheme? other, double t) {
    if (other == null) return this;
    final end = t < 0.5 ? this : other;
    final color = LaneColors.lerp(this.color, other.color, t);
    return LaneTheme._(
      mode: end.mode,
      color: color,
      text: LaneText.build(script: end.script, ink: color.ink, glare: end.mode == LaneMode.glare),
      motion: end.motion,
      shadow: end.shadow,
      stroke: end.stroke,
    );
  }
}

extension LaneContext on BuildContext {
  /// Lane tokens: `context.lane.color`, `.text`, `.space`, `.radius`, `.motion`, `.touch`.
  ///
  /// Motion is reduced automatically when the system asks for it.
  LaneTheme get lane {
    final lane = Theme.of(this).extension<LaneTheme>();
    if (lane == null) {
      throw FlutterError('No LaneTheme found. Wrap the app in LaneApp (package:lane_ui).');
    }
    if (lane.motion.enabled && (MediaQuery.maybeDisableAnimationsOf(this) ?? false)) {
      return lane.copyWith(motion: LaneMotion.reduced);
    }
    return lane;
  }
}

/// Builds the Material [ThemeData] for a mode, so Material internals match Lane too.
abstract final class LaneThemeData {
  static ThemeData build(LaneMode mode, {LaneScript script = LaneScript.latin}) {
    final lane = LaneTheme.of(mode, script: script);
    final c = lane.color;
    final brightness = mode.isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.beacon,
        onPrimary: c.onBeacon,
        secondary: c.signal.route,
        onSecondary: c.onSignal,
        error: c.signal.stop,
        onError: c.onSignal,
        surface: c.surface,
        onSurface: c.ink,
        onSurfaceVariant: c.inkMuted,
        surfaceContainerHighest: c.surfaceSunken,
        outline: c.line,
        outlineVariant: c.line,
      ),
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      dividerTheme: DividerThemeData(
        color: c.line,
        thickness: lane.stroke.hairline,
        space: lane.stroke.hairline,
      ),
      iconTheme: IconThemeData(color: c.ink),
      package: LaneFonts.package,
      fontFamily: script.family,
      textTheme: textThemeOf(lane.text),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: LanePageTransitionsBuilder(),
          TargetPlatform.iOS: LanePageTransitionsBuilder(),
          TargetPlatform.linux: LanePageTransitionsBuilder(),
          TargetPlatform.macOS: LanePageTransitionsBuilder(),
          TargetPlatform.windows: LanePageTransitionsBuilder(),
          TargetPlatform.fuchsia: LanePageTransitionsBuilder(),
        },
      ),
      extensions: [lane],
    );
  }

  /// Maps the Lane scale onto Material's, for widgets that read `Theme.textTheme`.
  static TextTheme textThemeOf(LaneText t) => TextTheme(
    displayLarge: t.display,
    displayMedium: t.hero,
    headlineMedium: t.headline,
    titleLarge: t.title,
    titleMedium: t.label,
    bodyLarge: t.bodyLarge,
    bodyMedium: t.body,
    bodySmall: t.caption,
    labelLarge: t.label,
    labelSmall: t.caps,
  );
}

/// Flow steps slide on a shared horizontal axis (PLAN §6.10). With reduced motion, a fade.
class LanePageTransitionsBuilder extends PageTransitionsBuilder {
  const LanePageTransitionsBuilder();

  static const _sharedAxis = SharedAxisPageTransitionsBuilder(
    transitionType: SharedAxisTransitionType.horizontal,
  );

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (!context.lane.motion.enabled) {
      return FadeTransition(opacity: animation, child: child);
    }
    return _sharedAxis.buildTransitions(route, context, animation, secondaryAnimation, child);
  }
}
