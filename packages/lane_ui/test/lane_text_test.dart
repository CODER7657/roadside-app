import 'package:flutter/painting.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';

const ink = Color(0xFF14161B);
String pkg(String family) => 'packages/lane_ui/$family';
double? weightOf(TextStyle s) => s.fontVariations?.singleWhere((FontVariation v) => v.axis == 'wght').value;

void main() {
  final latin = LaneText.build(script: LaneScript.latin, ink: ink);
  final hindi = LaneText.build(script: LaneScript.devanagari, ink: ink);
  final gujarati = LaneText.build(script: LaneScript.gujarati, ink: ink);
  final glare = LaneText.build(script: LaneScript.latin, ink: ink, glare: true);

  test('locales map to scripts', () {
    expect(LaneScript.of(const Locale('en')), LaneScript.latin);
    expect(LaneScript.of(const Locale('en', 'IN')), LaneScript.latin);
    expect(LaneScript.of(const Locale('hi')), LaneScript.devanagari);
    expect(LaneScript.of(const Locale('gu', 'IN')), LaneScript.gujarati);
  });

  test('Latin body is Onest 17/24 at weight 450 (PLAN §6.8)', () {
    expect(latin.body.fontFamily, pkg('Onest'));
    expect(latin.body.fontSize, 17);
    expect(latin.body.height! * latin.body.fontSize!, closeTo(24, 1e-9));
    expect(weightOf(latin.body), 450);
    expect(latin.body.color, ink);
  });

  test('hi/gu use Anek at +1 sp and ×1.18 line height (scriptMetrics)', () {
    for (final (t, family) in [(hindi, 'AnekDevanagari'), (gujarati, 'AnekGujarati')]) {
      expect(t.body.fontFamily, pkg(family));
      expect(t.body.fontSize, 18);
      expect(t.body.height! * t.body.fontSize!, closeTo(24 * 1.18, 1e-9));
      expect(t.title.fontSize, 23);
      expect(t.caption.fontSize, 14);
    }
  });

  test('hero is Instrument Serif in Latin and Anek 600 in hi/gu', () {
    expect(latin.hero.fontFamily, pkg('InstrumentSerif'));
    expect(hindi.hero.fontFamily, pkg('AnekDevanagari'));
    expect(weightOf(hindi.hero), 600);
    expect(gujarati.hero.fontFamily, pkg('AnekGujarati'));
  });

  test('numbers stay JetBrains Mono with Latin metrics in every script', () {
    for (final t in [latin, hindi, gujarati]) {
      expect(t.display.fontFamily, pkg('JetBrainsMono'));
      expect(t.display.fontSize, 48);
      expect(t.otp.fontSize, 56);
    }
  });

  test('caps: mono with +8% tracking in Latin; no tracking in hi/gu', () {
    expect(latin.caps.fontFamily, pkg('JetBrainsMono'));
    expect(latin.caps.letterSpacing, closeTo(0.96, 1e-9));
    expect(hindi.caps.fontFamily, pkg('AnekDevanagari'));
    expect(hindi.caps.letterSpacing, 0);
  });

  test('Glare: +100 weight and a 19 sp body', () {
    expect(glare.body.fontSize, 19);
    expect(weightOf(glare.body), 550);
    expect(weightOf(glare.label), 700);
    expect(weightOf(glare.display), 800);
  });

  test('nothing is smaller than caption (13 sp) except the 12 sp caps label; all have fallbacks', () {
    // PLAN §6.8 sets caps at 12 sp (short uppercase signage) while calling caption the
    // minimum; caps is the one exception.
    for (final t in [latin, hindi, gujarati, glare]) {
      for (final MapEntry(key: name, value: s) in t.all.entries) {
        expect(s.fontSize, greaterThanOrEqualTo(name == 'caps' ? 12 : 13), reason: '${t.script}.$name');
        expect(s.fontFamilyFallback, isNotEmpty, reason: '${t.script}.$name');
        expect(s.fontFamilyFallback, isNot(contains(s.fontFamily)), reason: '${t.script}.$name');
      }
    }
  });

  test('a Hindi screen falls back to Devanagari first for text inside mono styles', () {
    expect(hindi.display.fontFamilyFallback!.first, pkg('AnekDevanagari'));
  });
}
