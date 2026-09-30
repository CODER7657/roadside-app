// #120: Crashlytics through LaneLog (no personal data) and Remote Config defaults.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanic_app/app/crash_reporting.dart';
import 'package:mechanic_app/app/firebase.dart';
import 'package:mechanic_app/app/flavor.dart';
import 'package:mechanic_app/app/remote_flags.dart';
import 'package:roadside_core/roadside_core.dart';

class _FakeReporter implements CrashReporter {
  final errors = <(String, String, bool)>[];
  final logs = <String>[];

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    required String reason,
    required bool fatal,
  }) async => errors.add((error.toString(), reason, fatal));

  @override
  Future<void> log(String message) async => logs.add(message);
}

void main() {
  late _FakeReporter reporter;
  late LogSink previousSink;
  late bool previousRedact;
  final local = <LogRecord>[];

  setUp(() {
    reporter = _FakeReporter();
    local.clear();
    previousSink = LaneLog.sink;
    previousRedact = LaneLog.redact;
    // Debug builds don't redact; the Crashlytics sink must anyway.
    LaneLog.redact = false;
    LaneLog.sink = crashReportingSink(reporter, next: local.add);
  });

  tearDown(() {
    LaneLog.sink = previousSink;
    LaneLog.redact = previousRedact;
  });

  group('crash reporting sink', () {
    test('errors become reports, redacted even when LaneLog.redact is off', () {
      LaneLog.e(
        'call to +91 98765 43210 failed',
        error: StateError('otp 123456 at 23.022505,72.571362'),
        stackTrace: StackTrace.current,
      );
      expect(reporter.errors, hasLength(1));
      final (error, reason, fatal) = reporter.errors.single;
      for (final text in [error, reason]) {
        expect(text, isNot(contains('98765')));
        expect(text, isNot(contains('123456')));
        expect(text, isNot(contains('72.571362')));
      }
      expect(reason, contains(LaneLog.redacted));
      expect(fatal, isFalse);
      expect(local, hasLength(1), reason: 'the local log still gets the record');
    });

    test('uncaught errors are fatal', () {
      LaneLog.e('uncaught error', error: StateError('boom'), fields: kFatal);
      expect(reporter.errors.single.$3, isTrue);
    });

    test('info and warnings are breadcrumbs, with sensitive fields replaced', () {
      LaneLog.i('presence written', {'bookingId': 'b-1', 'phone': '+919876543210', 'lat': 23.0225});
      LaneLog.w('slow fetch');
      expect(reporter.errors, isEmpty);
      expect(reporter.logs, hasLength(2));
      expect(reporter.logs.first, contains('b-1'));
      expect(reporter.logs.first, isNot(contains('9876543210')));
      expect(reporter.logs.first, isNot(contains('23.0225')));
      expect(reporter.logs.last, '[warning] slow fetch');
    });

    test('the reported error carries text only, never the original object', () {
      LaneLog.e('save failed', error: _Leaky());
      expect(reporter.errors.single.$1, isNot(contains('9876543210')));
    });
  });

  group('remote config', () {
    test('defaults: nobody forced to update, Live Update off', () {
      expect(RemoteFlags.defaults.minSupportedBuild, 0);
      expect(RemoteFlags.defaults.liveUpdateEnabled, isFalse);
      expect(RemoteFlags.defaultParameters, {'min_supported_build': 0, 'live_update_enabled': false});
    });

    test('fetches often in dev, rarely in prod', () {
      expect(remoteConfigInterval(AppFlavor.dev), lessThan(remoteConfigInterval(AppFlavor.prod)));
    });

    test('without Firebase, the providers fall back to fakes and defaults', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(firebaseServicesProvider), isNull);
      expect(container.read(remoteFlagsProvider), same(RemoteFlags.defaults));
    });
  });
}

class _Leaky {
  @override
  String toString() => 'customer +919876543210';
}
