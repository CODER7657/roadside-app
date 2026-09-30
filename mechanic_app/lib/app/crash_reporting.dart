import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:roadside_core/roadside_core.dart';

/// Where crash reports go. Crashlytics in the app; a fake in tests.
abstract interface class CrashReporter {
  Future<void> recordError(Object error, StackTrace? stack, {required String reason, required bool fatal});

  /// A breadcrumb shown with the next report.
  Future<void> log(String message);
}

class CrashlyticsReporter implements CrashReporter {
  CrashlyticsReporter(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordError(Object error, StackTrace? stack, {required String reason, required bool fatal}) =>
      _crashlytics.recordError(error, stack, reason: reason, fatal: fatal);

  @override
  Future<void> log(String message) => _crashlytics.log(message);
}

/// The error a report carries: only LaneLog's redacted text, never the original object, whose
/// `toString` could hold personal data.
class LoggedError {
  const LoggedError(this.text);

  final String text;

  @override
  String toString() => text;
}

/// Marks a LaneLog error as an uncaught crash: `LaneLog.e(..., fields: kFatal)`.
const kFatal = <String, Object?>{'fatal': true};

/// Routes LaneLog to [reporter] (PLAN §12.7, §12.13): errors become reports, everything else a
/// breadcrumb. Redacts again here, whatever [LaneLog.redact] says, so no phone number, OTP,
/// address or coordinate reaches Crashlytics. [next] still gets every record (the local log).
LogSink crashReportingSink(CrashReporter reporter, {LogSink? next}) => (r) {
  next?.call(r);
  final message = LaneLog.redactText(r.message);
  if (r.level == LogLevel.error) {
    unawaited(
      reporter.recordError(
        LoggedError(LaneLog.redactText(r.error ?? r.message)),
        r.stackTrace,
        reason: message,
        fatal: r.fields['fatal'] == true,
      ),
    );
    return;
  }
  final fields = LaneLog.redactFields(r.fields);
  unawaited(reporter.log('[${r.level.name}] $message${fields.isEmpty ? '' : ' $fields'}'));
};
