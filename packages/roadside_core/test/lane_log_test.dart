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
        LaneLog.redactText('radius widened to 10 km after 30 s, ₹450, year 2026'),
        'radius widened to 10 km after 30 s, ₹450, year 2026',
      );
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
  });
}
