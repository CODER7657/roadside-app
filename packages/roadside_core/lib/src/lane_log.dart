// LaneLog: the only logger the apps use (PLAN.md §12.7). `print` is banned by lint.
//
// In release builds it redacts phone numbers, OTPs/start codes, addresses, coordinates, UPI IDs,
// emails and tokens, both in structured fields (by key) and in free text (by pattern).
// Still: log ids (uid, bookingId), not personal data.
//
//   LaneLog.i('booking created', {'bookingId': id});
//   LaneLog.e('createBooking failed', error: e, stackTrace: st, fields: {'bookingId': id});
//
// Apps route records to Crashlytics once at start-up (roadside_core doesn't depend on Crashlytics,
// which has no web support, so the app passes the two calls in):
//
//   final crashlytics = FirebaseCrashlytics.instance;
//   LaneLog.sink = LaneLog.crashReporterSink(
//     log: crashlytics.log,
//     recordError: (error, stack) => crashlytics.recordError(error, stack),
//   );

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

/// One log call, already redacted when [LaneLog.redact] is on.
@immutable
class LogRecord {
  const LogRecord({
    required this.level,
    required this.message,
    required this.fields,
    required this.time,
    this.error,
    this.stackTrace,
  });

  final LogLevel level;
  final String message;
  final Map<String, Object?> fields;
  final DateTime time;

  /// The error's text (redacted), not the object, so nothing sensitive leaks through `toString`.
  final String? error;
  final StackTrace? stackTrace;

  String format() {
    final b = StringBuffer('[${level.name}] $message');
    if (fields.isNotEmpty) b.write(' $fields');
    if (error != null) b.write(' error=$error');
    return b.toString();
  }

  @override
  String toString() => format();
}

typedef LogSink = void Function(LogRecord record);

/// What a crash reporter receives instead of the original error: its redacted text. The original
/// object never leaves the phone, because its `toString` or fields could hold personal data.
@immutable
class RedactedError implements Exception {
  const RedactedError(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract final class LaneLog {
  /// Redaction is on in release builds. Tests may flip it.
  static bool redact = kReleaseMode;

  /// Records below this level are dropped.
  static LogLevel minLevel = kReleaseMode ? LogLevel.info : LogLevel.debug;

  /// Where records go. Defaults to `dart:developer` (silent in release).
  static LogSink sink = _developerSink;

  static const String redacted = '‹redacted›';

  /// A sink for a crash reporter such as Crashlytics. Every record is added to the breadcrumb
  /// [log]; error-level records are also reported as non-fatal issues through [recordError], as a
  /// [RedactedError]. Records are redacted before they get here, so turn on [redact] in any build
  /// that reports (it is on in release); while it is off, nothing is reported. [alsoTo] keeps a
  /// second sink, e.g. the developer console.
  static LogSink crashReporterSink({
    required void Function(String message) log,
    required void Function(RedactedError error, StackTrace? stackTrace) recordError,
    LogSink? alsoTo,
  }) => (r) {
    alsoTo?.call(r);
    // With redaction off (debug, or a profile build that forgot to turn it on), the record still
    // holds personal data: it stays on the phone.
    if (!redact) return;
    log(r.format());
    if (r.level == LogLevel.error) {
      recordError(RedactedError(r.error ?? r.message), r.stackTrace ?? StackTrace.empty);
    }
  };

  static void d(String message, [Map<String, Object?> fields = const {}]) =>
      _log(LogLevel.debug, message, fields);

  static void i(String message, [Map<String, Object?> fields = const {}]) =>
      _log(LogLevel.info, message, fields);

  static void w(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> fields = const {},
  }) => _log(LogLevel.warning, message, fields, error, stackTrace);

  static void e(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> fields = const {},
  }) => _log(LogLevel.error, message, fields, error, stackTrace);

  static void _log(
    LogLevel level,
    String message,
    Map<String, Object?> fields, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (level.index < minLevel.index) return;
    final errorText = error?.toString();
    sink(
      LogRecord(
        level: level,
        message: redact ? redactText(message) : message,
        fields: redact ? redactFields(fields) : Map.unmodifiable(fields),
        time: DateTime.now().toUtc(),
        error: errorText == null ? null : (redact ? redactText(errorText) : errorText),
        stackTrace: stackTrace,
      ),
    );
  }

  static void _developerSink(LogRecord r) => developer.log(
    r.format(),
    name: 'lane',
    level: switch (r.level) {
      LogLevel.debug => 500,
      LogLevel.info => 800,
      LogLevel.warning => 900,
      LogLevel.error => 1000,
    },
    stackTrace: r.stackTrace,
  );

  static const List<String> _sensitiveKeyParts = [
    'phone', 'otp', 'startcode', 'address', 'landmark', 'pluscode', 'latitude', 'longitude', //
    'latlng', 'lnglat', 'geopoint', 'geohash', 'location', 'pickup', 'coord', 'upi', 'email', //
    'token', 'password', 'customername', 'mechanicname', 'displayname', 'fullname', 'regno',
  ];
  static const Set<String> _sensitiveKeys = {'lat', 'lng', 'lon', 'code', 'pin', 'name'};

  /// Whether a field named [key] holds personal data.
  static bool isSensitiveKey(String key) {
    final k = key.toLowerCase().replaceAll('_', '');
    return _sensitiveKeys.contains(k) || _sensitiveKeyParts.any(k.contains);
  }

  /// Replaces the values of sensitive keys (recursively) and redacts the text of the rest.
  static Map<String, Object?> redactFields(Map<String, Object?> fields) => Map.unmodifiable({
    for (final MapEntry(:key, :value) in fields.entries)
      key: isSensitiveKey(key) ? redacted : _redactValue(value),
  });

  static Object? _redactValue(Object? value) => switch (value) {
    null || bool() || int() => value,
    final double d => _coordinateLike.hasMatch(d.toString()) ? redacted : d,
    final String s => redactText(s),
    // Maps from platform channels and plugins are often Map<dynamic, dynamic>: redact them by key too.
    final Map<Object?, Object?> m => redactFields({
      for (final MapEntry(:key, :value) in m.entries) key.toString(): value,
    }),
    final Iterable<Object?> l => l.map(_redactValue).toList(growable: false),
    _ => redactText(value.toString()),
  };

  /// A number with ≥ 3 decimals: precise enough to be a coordinate (3 decimals is about 100 m).
  static final RegExp _coordinateLike = RegExp(r'\.\d{3,}');

  static final List<RegExp> _patterns = [
    RegExp(r'[\w.\-]+@[\w.\-]+'), // email and UPI IDs
    RegExp(r'\+\d[\d\s-]{7,16}\d'), // E.164 with separators
    RegExp(r'(?<!\d)(?:0|91[\s-]?)?[6-9]\d{4}[\s-]?\d{5}(?!\d)'), // Indian mobile, e.g. 98765 43210
    RegExp(r'-?\d{1,3}\.\d{3,}'), // coordinates (≥ 3 decimals, about 100 m)
  ];
  static final RegExp _codeAfterKeyword = RegExp(r'((?:otp|code|pin)\D{0,12})\d{4,6}', caseSensitive: false);

  /// Redacts phone numbers, emails/UPI IDs, coordinates and codes after "otp"/"code"/"pin".
  static String redactText(String text) {
    var out = text.replaceAllMapped(_codeAfterKeyword, (m) => '${m[1]}$redacted');
    for (final p in _patterns) {
      out = out.replaceAll(p, redacted);
    }
    return out;
  }
}
