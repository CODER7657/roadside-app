import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart' show LaneMode, ambientControllerProvider;
import 'package:roadside_core/roadside_core.dart';

import '../../first_run/application/first_run.dart';
import '../data/profile_repository.dart';

// Seam: in memory until #92 wires Firebase and #96 signs in (then FirestoreProfileRepository).
final profileRepositoryProvider = Provider<ProfileRepository>((ref) => InMemoryProfileRepository());

final profileProvider = StreamProvider.autoDispose<AppUser?>(
  (ref) => ref.watch(profileRepositoryProvider).watch(),
);

/// The display modes U18 offers. Saver isn't one: it follows the battery (PLAN §6.5 ③).
const kDisplayModes = [null, LaneMode.day, LaneMode.night, LaneMode.glare];

/// U18 settings kept on the phone.
@immutable
class AppSettings {
  const AppSettings({this.displayMode, this.arrivalChime = true});

  /// The user's manual mode; null is Auto (Day / Night by sunset, Saver on a low battery).
  final LaneMode? displayMode;

  /// The one sound the customer app plays (PLAN §6.11).
  final bool arrivalChime;
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  static const _kDisplayMode = 'settings.display_mode';
  static const _kArrivalChime = 'settings.arrival_chime';

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final mode = prefs.getString(_kDisplayMode);
    return AppSettings(
      displayMode: kDisplayModes.firstWhere((m) => m?.name == mode, orElse: () => null),
      arrivalChime: prefs.getBool(_kArrivalChime) ?? true,
    );
  }

  /// Applies the saved display mode. Call once before the first frame (`createAppContainer`).
  void applyDisplayMode() => ref.read(ambientControllerProvider.notifier).setManual(state.displayMode);

  Future<void> setDisplayMode(LaneMode? mode) async {
    assert(kDisplayModes.contains(mode));
    state = AppSettings(displayMode: mode, arrivalChime: state.arrivalChime);
    applyDisplayMode();
    final prefs = ref.read(sharedPreferencesProvider);
    await (mode == null ? prefs.remove(_kDisplayMode) : prefs.setString(_kDisplayMode, mode.name));
  }

  Future<void> setArrivalChime(bool on) async {
    state = AppSettings(displayMode: state.displayMode, arrivalChime: on);
    await ref.read(sharedPreferencesProvider).setBool(_kArrivalChime, on);
  }

  /// Switches the app language at once and, when signed in, the language notifications are
  /// sent in. The account update is queued offline by Firestore, so it isn't awaited.
  Future<void> setLanguage(String code) async {
    await ref.read(firstRunProvider.notifier).setLanguage(code);
    if (ref.read(profileProvider).value == null) return;
    unawaited(
      ref
          .read(profileRepositoryProvider)
          .setLanguage(Language.fromValue(code))
          .catchError(
            (Object e, StackTrace s) => LaneLog.w('profile language not saved', error: e, stackTrace: s),
          ),
    );
  }
}
