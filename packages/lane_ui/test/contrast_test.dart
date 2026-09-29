// Re-checks the WCAG contrast promises in PLAN.md §6.7 and §6.16 for every mode.
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void expectContrast(Color fg, Color bg, double min, String what) {
  final r = contrast(fg, bg);
  expect(r, greaterThanOrEqualTo(min), reason: '$what is ${r.toStringAsFixed(2)}:1, needs $min:1');
}

void main() {
  final modes = {
    'day': LaneColors.day,
    'night': LaneColors.night,
    'glare': LaneColors.glare,
    'saver': LaneColors.saver,
  };

  for (final MapEntry(key: name, value: c) in modes.entries) {
    group('$name palette', () {
      test('key text (ink) is at least 7:1 on bg and surface (OTP, ETA, price)', () {
        expectContrast(c.ink, c.bg, 7, 'ink on bg');
        expectContrast(c.ink, c.surface, 7, 'ink on surface');
      });

      test('body text is at least 4.5:1 on bg, surface and sunken wells', () {
        for (final (label, fg) in [('inkMuted', c.inkMuted), ('inkSubtle', c.inkSubtle)]) {
          expectContrast(fg, c.bg, 4.5, '$label on bg');
          expectContrast(fg, c.surface, 4.5, '$label on surface');
          expectContrast(fg, c.surfaceSunken, 4.5, '$label on surfaceSunken');
        }
      });

      test('signal colours are readable as text on surface', () {
        final s = c.signal;
        for (final (label, fg) in [
          ('wait', s.wait),
          ('route', s.route),
          ('go', s.go),
          ('work', s.work),
          ('stop', s.stop),
          ('neutral', s.neutral),
        ]) {
          expectContrast(fg, c.surface, 4.5, '$label on surface');
        }
      });

      // Badge rule: label in ink on the tint, signal colour for the icon and dot only.
      // (Day route blue is 4.4:1 on its own tint, so it can't be the label colour.)
      test('badges: ink labels on every tint, signal icons at 3:1 or more', () {
        final s = c.signal;
        for (final (label, fg, tint) in [
          ('wait', s.wait, s.waitTint),
          ('route', s.route, s.routeTint),
          ('go', s.go, s.goTint),
          ('work', s.work, s.workTint),
          ('stop', s.stop, s.stopTint),
          ('neutral', s.neutral, s.neutralTint),
        ]) {
          expectContrast(c.ink, tint, 7, 'ink label on $label tint');
          expectContrast(fg, tint, 3, '$label icon on its tint');
        }
      });

      test('onSignal text is readable on every solid signal fill', () {
        final s = c.signal;
        for (final (label, fill) in [
          ('wait', s.wait),
          ('route', s.route),
          ('go', s.go),
          ('work', s.work),
          ('stop', s.stop),
        ]) {
          expectContrast(c.onSignal, fill, 4.5, 'onSignal on $label');
        }
      });

      test('onBeacon on the Beacon fill is at least 7:1', () {
        expectContrast(c.onBeacon, c.beacon, 7, 'onBeacon on beacon');
      });
    });
  }

  test('Beacon is never readable as text on light backgrounds (why it stays a fill)', () {
    expect(contrast(LaneBrand.beacon, LaneColors.day.surface), lessThan(3));
  });

  test('Glare is pure black on white (21:1)', () {
    expect(contrast(LaneColors.glare.ink, LaneColors.glare.bg), closeTo(21, 0.01));
  });

  test('Night text on Night signal fills uses Day ink at 6.5:1 or more', () {
    final s = LaneColors.night.signal;
    for (final fill in [s.wait, s.route, s.go, s.work, s.stop]) {
      expectContrast(LaneColors.day.ink, fill, 6.5, 'Day ink on a Night signal');
    }
  });

  test('ThreeUI button labels are readable on every gradient stop', () {
    for (final stop in LaneBrand.launchGradient) {
      expectContrast(LaneBrand.launchText, stop, 4.5, 'Launch label');
    }
    for (final stop in LaneBrand.quietGradient) {
      expectContrast(LaneBrand.quietText, stop, 4.5, 'Spinning Border label');
    }
    for (final stop in LaneBrand.pillGradient) {
      expectContrast(LaneBrand.pillText, stop, 4.5, 'Gradient CTA label');
    }
  });
}
