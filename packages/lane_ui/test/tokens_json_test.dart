// design/tokens.json mirrors the Dart tokens for Figma (PLAN.md §6.14). This fails when
// one side changes without the other.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/painting.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';

Color hex(Object? v) => Color(int.parse('FF${(v! as String).substring(1)}', radix: 16));

void main() {
  final json = jsonDecode(File('../../design/tokens.json').readAsStringSync()) as Map<String, dynamic>;
  final color = json['color'] as Map<String, dynamic>;

  void neutrals(String name, LaneColors c) {
    final j = color[name] as Map<String, dynamic>;
    final dart = {
      'bg': c.bg,
      'surface': c.surface,
      'surfaceSunken': c.surfaceSunken,
      'line': c.line,
      'ink': c.ink,
      'inkMuted': c.inkMuted,
      'inkSubtle': c.inkSubtle,
    };
    for (final key in j.keys) {
      expect(dart[key], hex(j[key]), reason: 'color.$name.$key');
    }
  }

  test('neutral colours match', () {
    neutrals('day', LaneColors.day);
    neutrals('night', LaneColors.night);
    neutrals('glare', LaneColors.glare);
  });

  test('signal and brand colours match', () {
    final signal = color['signal'] as Map<String, dynamic>;
    for (final (name, c) in [('day', LaneColors.day), ('night', LaneColors.night)]) {
      final j = signal[name] as Map<String, dynamic>;
      final s = c.signal;
      expect(
        [s.wait, s.route, s.go, s.work, s.stop],
        [
          for (final k in ['wait', 'route', 'go', 'work', 'stop']) hex(j[k]),
        ],
        reason: 'signal.$name',
      );
    }
    final brand = color['brand'] as Map<String, dynamic>;
    expect(LaneBrand.beacon, hex(brand['beacon']));
    expect(LaneBrand.onBeacon, hex(brand['onBeacon']));
  });

  test('ThreeUI button colours match', () {
    final b = color['button'] as Map<String, dynamic>;
    List<Color> list(Object? v) => [for (final x in v! as List<dynamic>) hex(x)];
    expect(LaneBrand.launchGradient, list(b['launchGradient']));
    expect(LaneBrand.launchText, hex(b['launchText']));
    expect(LaneBrand.launchRing, hex(b['launchRing']));
    expect(LaneBrand.launchLedge, hex(b['launchLedge']));
    expect(LaneBrand.quietGradient, list(b['quietGradient']));
    expect(LaneBrand.quietText, hex(b['quietText']));
    expect(LaneBrand.pillGradient, list(b['pillGradient']));
    expect(LaneBrand.pillText, hex(b['pillText']));
  });

  test('type scale matches (Latin)', () {
    final t = LaneText.build(script: LaneScript.latin, ink: LaneColors.day.ink).all;
    final type = Map<String, dynamic>.of(json['type'] as Map<String, dynamic>)..remove('_format');
    for (final MapEntry(key: name, value: spec) in type.entries) {
      final [size, lineHeight, weight] = [for (final v in spec as List<dynamic>) (v as num).toDouble()];
      final s = t[name]!;
      expect(s.fontSize, size, reason: '$name size');
      expect(s.height! * s.fontSize!, closeTo(lineHeight, 1e-9), reason: '$name line height');
      expect(s.fontVariations!.single.value, weight, reason: '$name weight');
    }
  });

  test('space, radius, touch and motion match', () {
    const space = LaneSpace();
    expect(
      [space.s4, space.s8, space.s12, space.s16, space.s20, space.s24, space.s32, space.s48, space.s64],
      [for (final v in json['space'] as List<dynamic>) (v as num).toDouble()],
    );

    const r = LaneRadius();
    final radius = json['radius'] as Map<String, dynamic>;
    for (final (k, v) in [('r6', r.r6), ('r12', r.r12), ('r16', r.r16), ('r24', r.r24), ('pill', r.pill)]) {
      expect(v.topLeft.x, (radius[k] as num).toDouble(), reason: 'radius.$k');
    }

    const touch = LaneTouch();
    final tj = json['touch'] as Map<String, dynamic>;
    expect([touch.min, touch.primary, touch.critical], [tj['min'], tj['primary'], tj['critical']]);

    final m = json['motion'] as Map<String, dynamic>;
    const full = LaneMotion.full;
    expect([full.instant, full.quick, full.standard, full.calm, full.breath].map((d) => d.inMilliseconds), [
      m['instantMs'],
      m['quickMs'],
      m['standardMs'],
      m['calmMs'],
      m['breathMs'],
    ]);
  });

  test('float shadow matches', () {
    final f = (json['shadow'] as Map<String, dynamic>)['float'] as Map<String, dynamic>;
    for (final (shadows, opacity) in [
      (LaneShadows.day, f['dayOpacity']),
      (LaneShadows.night, f['nightOpacity']),
    ]) {
      final s = shadows.float.single;
      expect(s.offset.dy, f['y']);
      expect(s.blurRadius, f['blur']);
      expect(s.color.a, closeTo((opacity as num).toDouble(), 0.01));
    }
  });
}
