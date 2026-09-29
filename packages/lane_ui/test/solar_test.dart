import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';

const ahmedabad = LanePosition(23.0225, 72.5714);
const bharuch = LanePosition(21.7051, 72.9959);
const ist = Duration(hours: 5, minutes: 30);

/// "HH:MM" in IST for a UTC instant.
String istTime(DateTime utc) {
  final t = utc.add(ist);
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

int minutesOf(String hhmm) => int.parse(hhmm.split(':')[0]) * 60 + int.parse(hhmm.split(':')[1]);

/// Instant for an IST wall-clock time.
DateTime istAt(int y, int m, int d, int h, int min) => DateTime.utc(y, m, d, h, min).subtract(ist);

void main() {
  // Reference times from an independent algorithm (the Wikipedia sunrise equation),
  // which agrees with published tables to a few minutes.
  final cases = <(String, LanePosition, DateTime, String, String)>[
    ('Ahmedabad June solstice', ahmedabad, DateTime(2026, 6, 21), '05:54', '19:27'),
    ('Ahmedabad December solstice', ahmedabad, DateTime(2026, 12, 21), '07:16', '17:59'),
    ('Ahmedabad equinox', ahmedabad, DateTime(2027, 3, 20), '06:44', '18:50'),
    ('Bharuch today', bharuch, DateTime(2026, 9, 29), '06:28', '18:28'),
  ];

  for (final (name, at, date, rise, set) in cases) {
    test('$name: sunrise ≈ $rise, sunset ≈ $set IST (±5 min)', () {
      final day = SolarDay.of(date, at);
      expect(day.polar, isNull);
      expect(
        (minutesOf(istTime(day.sunrise!)) - minutesOf(rise)).abs(),
        lessThanOrEqualTo(5),
        reason: 'sunrise was ${istTime(day.sunrise!)}',
      );
      expect(
        (minutesOf(istTime(day.sunset!)) - minutesOf(set)).abs(),
        lessThanOrEqualTo(5),
        reason: 'sunset was ${istTime(day.sunset!)}',
      );
    });
  }

  group('isNightAt (Ahmedabad, 29 Sep 2026, sunset ≈ 18:29 IST)', () {
    test('midday and just before sunset are day', () {
      expect(isNightAt(istAt(2026, 9, 29, 12, 0), ahmedabad), isFalse);
      expect(isNightAt(istAt(2026, 9, 29, 18, 15), ahmedabad), isFalse);
    });

    test('after sunset, before midnight and before sunrise are night', () {
      expect(isNightAt(istAt(2026, 9, 29, 18, 45), ahmedabad), isTrue);
      expect(isNightAt(istAt(2026, 9, 29, 23, 59), ahmedabad), isTrue);
      expect(isNightAt(istAt(2026, 9, 30, 0, 30), ahmedabad), isTrue);
      expect(isNightAt(istAt(2026, 9, 30, 5, 45), ahmedabad), isTrue);
    });

    test('after sunrise is day again', () {
      expect(isNightAt(istAt(2026, 9, 30, 6, 45), ahmedabad), isFalse);
    });

    test('the UTC date change (05:30 IST) does not flip the answer', () {
      // 00:00 UTC = 05:30 IST: still before sunrise on the local date.
      expect(isNightAt(DateTime.utc(2026, 9, 30), ahmedabad), isTrue);
      // 18:59 UTC on the 29th = 00:29 IST on the 30th.
      expect(isNightAt(DateTime.utc(2026, 9, 29, 18, 59), ahmedabad), isTrue);
    });

    test('works the same for local and UTC DateTimes', () {
      final utc = istAt(2026, 9, 29, 19, 0);
      expect(isNightAt(utc.toLocal(), ahmedabad), isNightAt(utc, ahmedabad));
    });
  });

  test('polar day and night are handled without a sunrise', () {
    const tromso = LanePosition(69.65, 18.96);
    expect(SolarDay.of(DateTime(2026, 6, 21), tromso).polar, PolarDay.day);
    expect(SolarDay.of(DateTime(2026, 12, 21), tromso).polar, PolarDay.night);
    expect(isNightAt(DateTime.utc(2026, 6, 21, 23), tromso), isFalse);
    expect(isNightAt(DateTime.utc(2026, 12, 21, 12), tromso), isTrue);
  });
}
