import 'package:flutter_test/flutter_test.dart';
import 'package:roadside_core/roadside_core.dart';

void main() {
  late List<LogRecord> records;

  setUp(() {
    records = [];
    LaneLog.sink = records.add;
    LaneLog.minLevel = LogLevel.debug;
  });

  group('redacting (release)', () {
    setUp(() => LaneLog.redact = true);

    test('sensitive keys are replaced, ids are kept', () {
      LaneLog.i('booking created', {
        'bookingId': 'b123',
        'uid': 'u1',
        'phone': '+919876543210',
        'customerPhone': '+919876543210',
        'startCode': '4821',
        'otp': '4821',
        'pickup': {'lat': 23.0497, 'lng': 72.5117},
        'address': 'Near Thaltej Cross Roads',
        'upiId': 'kiran@oksbi',
        'fcmToken': 'abc',
        'amount': 450,
      });
      final f = records.single.fields;
      expect(f['bookingId'], 'b123');
      expect(f['uid'], 'u1');
      expect(f['amount'], 450);
      for (final k in [
        'phone',
        'customerPhone',
        'startCode',
        'otp',
        'pickup',
        'address',
        'upiId',
        'fcmToken',
      ]) {
        expect(f[k], LaneLog.redacted, reason: k);
      }
    });

    test('nested values and free text are scrubbed', () {
      LaneLog.w(
        'call to 98765 43210 failed',
        fields: {
          'context': {'note': 'customer at 23.04971, 72.51172'},
          'rating': 4.6,
          'heading': 23.04971,
        },
        error: Exception('OTP 4821 rejected for +91 98765 43210, upi kiran@oksbi'),
      );
      final r = records.single;
      expect(r.message, isNot(contains('98765')));
      expect((r.fields['context']! as Map)['note'], isNot(contains('23.04971')));
      expect(r.fields['rating'], 4.6);
      expect(r.fields['heading'], LaneLog.redacted);
      expect(r.error, isNot(anyOf(contains('4821'), contains('98765'), contains('kiran@oksbi'))));
    });

    test('ordinary numbers survive', () {
      expect(
        LaneLog.redactText('radius widened to 10 km after 30 s, ₹450, year 2026, rating 4.67, v3.13.4'),
        'radius widened to 10 km after 30 s, ₹450, year 2026, rating 4.67, v3.13.4',
      );
    });

    test('loosely typed maps are redacted by key (#90 review)', () {
      final Map<dynamic, dynamic> fromPlugin = {
        'booking': <dynamic, dynamic>{'landmark': 'opp. temple', 'status': 'enRoute', 1: 'x'},
      };
      LaneLog.i('platform event', {'event': fromPlugin});
      final booking = (records.single.fields['event']! as Map)['booking']! as Map;
      expect(booking['landmark'], LaneLog.redacted);
      expect(booking['status'], 'enRoute');
      expect(booking['1'], 'x');
    });

    test('3-decimal coordinates are redacted (#90 review)', () {
      LaneLog.i('mechanic at 23.022, 72.571', {
        'latLng': [23.022, 72.571],
        'point': [23.022, 72.571],
      });
      final r = records.single;
      expect(r.message, isNot(anyOf(contains('23.022'), contains('72.571'))));
      expect(r.fields['latLng'], LaneLog.redacted);
      expect(r.fields['point'], [LaneLog.redacted, LaneLog.redacted]);
    });

    test('names and registration numbers are redacted (#90 review)', () {
      LaneLog.i('assigned', {
        'name': 'Kiran Patel',
        'customerName': 'Kiran Patel',
        'mechanic_name': 'Ravi',
        'regNo': 'GJ01AB1234',
        'cityName': 'Ahmedabad',
        'fileName': 'before.jpg',
      });
      final f = records.single.fields;
      for (final k in ['name', 'customerName', 'mechanic_name', 'regNo']) {
        expect(f[k], LaneLog.redacted, reason: k);
      }
      expect(f['fileName'], 'before.jpg');
    });
  });

  group('crashReporterSink', () {
    late List<String> breadcrumbs;
    late List<(RedactedError, StackTrace?)> reported;
    late List<LogRecord> console;

    setUp(() {
      breadcrumbs = [];
      reported = [];
      console = [];
      LaneLog.redact = true;
      LaneLog.sink = LaneLog.crashReporterSink(
        log: breadcrumbs.add,
        recordError: (e, st) => reported.add((e, st)),
        alsoTo: console.add,
      );
    });

    test('every record is a breadcrumb; only errors are reported', () {
      LaneLog.i('booking created', {'bookingId': 'b1'});
      LaneLog.w('retrying', error: Exception('timeout'));
      expect(breadcrumbs, hasLength(2));
      expect(reported, isEmpty);
      expect(console, hasLength(2));
    });

    test('errors are reported redacted, never as the original object', () {
      final original = Exception('OTP 4821 rejected for +91 98765 43210');
      LaneLog.e('verifyStartOtp failed', error: original, stackTrace: StackTrace.current);
      final (error, stack) = reported.single;
      expect(error, isA<RedactedError>());
      expect(error.message, isNot(anyOf(contains('4821'), contains('98765'))));
      expect(stack, isNotNull);
      expect(breadcrumbs.single, contains('verifyStartOtp failed'));
    });

    test('an error without an error object reports its message', () {
      LaneLog.e('dispatch stalled for 98765 43210');
      final (error, stack) = reported.single;
      expect(error.message, 'dispatch stalled for ${LaneLog.redacted}');
      expect(stack, StackTrace.empty);
    });
  });

  test('debug builds log as-is', () {
    LaneLog.redact = false;
    LaneLog.d('pickup', {'phone': '+919876543210'});
    expect(records.single.fields['phone'], '+919876543210');
  });

  test('records below minLevel are dropped', () {
    LaneLog.minLevel = LogLevel.warning;
    LaneLog.d('noise');
    LaneLog.i('noise');
    LaneLog.e('boom');
    expect(records.map((r) => r.level), [LogLevel.error]);
  });

  test('isSensitiveKey', () {
    expect(LaneLog.isSensitiveKey('lat'), isTrue);
    expect(LaneLog.isSensitiveKey('mechanicGeopoint'), isTrue);
    expect(LaneLog.isSensitiveKey('plus_code'), isTrue);
    expect(LaneLog.isSensitiveKey('bookingId'), isFalse);
    expect(LaneLog.isSensitiveKey('status'), isFalse);
    expect(LaneLog.isSensitiveKey('lnglat'), isTrue);
    expect(LaneLog.isSensitiveKey('routeName'), isFalse);
  });
}
