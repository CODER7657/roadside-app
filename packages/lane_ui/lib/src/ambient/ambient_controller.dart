// AmbientController: picks Day / Night / Glare / Saver (PLAN.md §6.5 ③).
//
// Priority: user's manual choice > Saver > Glare > Night > Day.
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/lane_theme.dart';
import 'battery.dart';
import 'solar.dart';

/// Battery at or below this level turns on Saver mode.
const saverBatteryThreshold = 15;

/// Everything the mode depends on.
@immutable
class AmbientState {
  const AmbientState({
    required this.now,
    this.manual,
    this.glare = false,
    this.systemDark = false,
    this.battery = LaneBatteryStatus.unknown,
    this.position,
  });

  /// The user's explicit choice (Profile & settings). Null means automatic.
  final LaneMode? manual;

  /// The ☀ Glare button in the dock is on.
  final bool glare;

  /// The system asks for dark mode.
  final bool systemDark;

  final LaneBatteryStatus battery;

  /// Last known position for local sunset. Null until the app shares a fix.
  final LanePosition? position;

  /// When the mode was last evaluated.
  final DateTime now;

  LaneMode get mode => resolveLaneMode(
    manual: manual,
    glare: glare,
    systemDark: systemDark,
    battery: battery,
    night: isNightAt(now, position ?? LanePosition.fallback),
  );

  AmbientState copyWith({
    LaneMode? Function()? manual,
    bool? glare,
    bool? systemDark,
    LaneBatteryStatus? battery,
    LanePosition? position,
    DateTime? now,
  }) => AmbientState(
    manual: manual != null ? manual() : this.manual,
    glare: glare ?? this.glare,
    systemDark: systemDark ?? this.systemDark,
    battery: battery ?? this.battery,
    position: position ?? this.position,
    now: now ?? this.now,
  );
}

/// The priority rule on its own, so it can be tested exhaustively.
LaneMode resolveLaneMode({
  LaneMode? manual,
  bool glare = false,
  bool systemDark = false,
  LaneBatteryStatus battery = LaneBatteryStatus.unknown,
  bool night = false,
}) {
  if (manual != null) return manual;
  final lowBattery = battery.level != null && battery.level! <= saverBatteryThreshold;
  if (lowBattery || battery.powerSave) return LaneMode.saver;
  if (glare) return LaneMode.glare;
  if (night || systemDark) return LaneMode.night;
  return LaneMode.day;
}

/// The clock the controller reads. Override in tests.
final laneClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Battery input for Saver. Override in tests and Widgetbook.
final laneBatterySourceProvider = Provider<LaneBatterySource>((ref) => PlusBatterySource());

/// How often the controller re-checks the time for sunrise and sunset.
const ambientTick = Duration(minutes: 1);

final ambientControllerProvider = NotifierProvider<AmbientController, AmbientState>(AmbientController.new);

/// The active mode. `LaneApp` watches this.
final laneModeProvider = Provider<LaneMode>(
  (ref) => ref.watch(ambientControllerProvider.select((s) => s.mode)),
);

class AmbientController extends Notifier<AmbientState> {
  @override
  AmbientState build() {
    final clock = ref.watch(laneClockProvider);
    final binding = WidgetsFlutterBinding.ensureInitialized();

    final observer = _AmbientObserver(
      onBrightness: () => state = state.copyWith(systemDark: _systemDark(binding)),
      onResume: () => state = state.copyWith(now: clock()),
    );
    binding.addObserver(observer);

    final tick = Timer.periodic(ambientTick, (_) => state = state.copyWith(now: clock()));

    final battery = ref
        .watch(laneBatterySourceProvider)
        .watch()
        .listen((b) => state = state.copyWith(battery: b), onError: (Object _) {});

    ref.onDispose(() {
      binding.removeObserver(observer);
      tick.cancel();
      battery.cancel();
    });

    return AmbientState(now: clock(), systemDark: _systemDark(binding));
  }

  /// Sets or clears (null) the user's manual mode.
  void setManual(LaneMode? mode) => state = state.copyWith(manual: () => mode);

  void setGlare(bool on) => state = state.copyWith(glare: on);

  void toggleGlare() => setGlare(!state.glare);

  /// Call with each location fix (or occasionally); only the position for sunset is used.
  void updatePosition(double lat, double lng) =>
      state = state.copyWith(position: LanePosition(lat, lng), now: ref.read(laneClockProvider)());

  static bool _systemDark(WidgetsBinding b) => b.platformDispatcher.platformBrightness == Brightness.dark;
}

class _AmbientObserver with WidgetsBindingObserver {
  _AmbientObserver({required this.onBrightness, required this.onResume});

  final VoidCallback onBrightness;
  final VoidCallback onResume;

  @override
  void didChangePlatformBrightness() => onBrightness();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResume();
  }
}
