import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

/// Whether the phone has a network (PLAN §6.5 ⑩ honest offline).
abstract interface class ConnectivitySource {
  /// True while there is no network at all; the current state first, then changes.
  Stream<bool> watchOffline();
}

/// `connectivity_plus`: offline when every interface reports none. It knows about networks,
/// not the internet, so a captive Wi-Fi still counts as online; requests then fail and show
/// their own error states.
class PlusConnectivitySource implements ConnectivitySource {
  PlusConnectivitySource([Connectivity? connectivity]) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _offline(List<ConnectivityResult> r) => r.every((c) => c == ConnectivityResult.none);

  @override
  Stream<bool> watchOffline() async* {
    // Never errors: if the plugin can't answer, the app behaves as online (and requests say
    // so themselves) rather than blocking everything behind a strip that may be wrong.
    try {
      yield _offline(await _connectivity.checkConnectivity());
      yield* _connectivity.onConnectivityChanged.map(_offline).handleError((Object e, StackTrace s) {
        LaneLog.w('connectivity stream failed', error: e, stackTrace: s);
      });
    } on Object catch (e, s) {
      LaneLog.w('connectivity unavailable', error: e, stackTrace: s);
      yield false;
    }
  }
}

final connectivitySourceProvider = Provider<ConnectivitySource>((ref) => PlusConnectivitySource());

/// Offline now? False until the first answer, so nothing is disabled on a guess.
final offlineProvider = StreamProvider<bool>(
  (ref) => ref.watch(connectivitySourceProvider).watchOffline().distinct(),
);

/// Synchronous form for widgets.
final isOfflineProvider = Provider<bool>((ref) => ref.watch(offlineProvider).value ?? false);
