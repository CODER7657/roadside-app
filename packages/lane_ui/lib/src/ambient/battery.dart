// Battery input for Saver mode. Behind an interface so tests and Widgetbook can fake it.
import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';

/// Battery level (0–100, null if unknown) and whether system battery saver is on.
@immutable
class LaneBatteryStatus {
  const LaneBatteryStatus({this.level, this.powerSave = false});

  static const unknown = LaneBatteryStatus();

  final int? level;
  final bool powerSave;

  @override
  bool operator ==(Object other) =>
      other is LaneBatteryStatus && other.level == level && other.powerSave == powerSave;

  @override
  int get hashCode => Object.hash(level, powerSave);
}

abstract interface class LaneBatterySource {
  /// Emits the current status on listen, then whenever it may have changed.
  Stream<LaneBatteryStatus> watch();
}

/// Reads the device battery with `battery_plus`: on listen, on every charging-state
/// change and every [pollEvery]. Platforms that can't report a value give
/// [LaneBatteryStatus.unknown] instead of an error.
class PlusBatterySource implements LaneBatterySource {
  PlusBatterySource({Battery? battery, this.pollEvery = const Duration(minutes: 1)})
    : _battery = battery ?? Battery();

  final Battery _battery;
  final Duration pollEvery;

  @override
  Stream<LaneBatteryStatus> watch() {
    late final StreamController<LaneBatteryStatus> out;
    StreamSubscription<BatteryState>? changes;
    Timer? poll;

    Future<void> emit() async {
      final status = await _read();
      if (!out.isClosed) out.add(status);
    }

    out = StreamController<LaneBatteryStatus>(
      onListen: () {
        emit();
        poll = Timer.periodic(pollEvery, (_) => emit());
        try {
          changes = _battery.onBatteryStateChanged.listen((_) => emit(), onError: (Object _) {});
        } catch (_) {
          // No charging-state events on this platform; polling still runs.
        }
      },
      onCancel: () async {
        poll?.cancel();
        await changes?.cancel();
      },
    );
    return out.stream;
  }

  Future<LaneBatteryStatus> _read() async {
    int? level;
    var powerSave = false;
    try {
      level = await _battery.batteryLevel;
    } catch (_) {}
    try {
      powerSave = await _battery.isInBatterySaveMode;
    } catch (_) {}
    return LaneBatteryStatus(level: level, powerSave: powerSave);
  }
}
