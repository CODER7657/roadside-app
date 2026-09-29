/// A living type and colour specimen for the example app and Widgetbook. Not for app screens.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lane_ui.dart';

/// Sample copy per script: the brand line, an address and the numbers that matter.
const _samples = {
  LaneScript.latin: ('Help on the road, in minutes', 'Near SG Highway, Thaltej', 'PICKUP'),
  LaneScript.devanagari: ('सड़क पर मदद, मिनटों में', 'एसजी हाईवे के पास, थलतेज', 'पिकअप स्थान'),
  LaneScript.gujarati: ('રસ્તા પર મદદ, મિનિટોમાં', 'એસજી હાઇવે પાસે, થલતેજ', 'પિકઅપ સ્થળ'),
};

/// Shows the active mode and every Lane type style and signal in the active script.
/// Switch modes with the chips; switch language with [onLocale].
class LaneSpecimen extends ConsumerWidget {
  const LaneSpecimen({super.key, required this.locale, required this.onLocale});

  final Locale locale;
  final ValueChanged<Locale> onLocale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    final ambient = ref.watch(ambientControllerProvider);
    final ctrl = ref.read(ambientControllerProvider.notifier);
    final (hero, address, caps) = _samples[lane.script]!;
    final s = lane.color.signal;

    Widget chips<T>(List<(String, T)> options, T selected, ValueChanged<T> onSelect) => Wrap(
      spacing: lane.space.s8,
      runSpacing: lane.space.s8,
      children: [
        for (final (label, value) in options)
          ChoiceChip(label: Text(label), selected: value == selected, onSelected: (_) => onSelect(value)),
      ],
    );

    Widget row(String name, TextStyle style, String text) => Padding(
      padding: EdgeInsets.only(bottom: lane.space.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$name · ${style.fontSize!.toStringAsFixed(0)} sp',
            style: lane.text.caption.copyWith(color: lane.color.inkSubtle),
          ),
          Text(text, style: style),
        ],
      ),
    );

    Widget badge(String label, Color color, Color tint) => Container(
      padding: EdgeInsets.symmetric(horizontal: lane.space.s12, vertical: lane.space.s4),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: lane.radius.pill,
        border: lane.mode == LaneMode.glare ? Border.all(color: color, width: lane.stroke.hairline) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: lane.space.s8, color: color),
          Gap(lane.space.s8),
          Text(label, style: lane.text.label),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(lane.space.s16),
          children: [
            Text('LANE ${lane.mode.name.toUpperCase()}', style: lane.text.caps),
            Gap(lane.space.s8),
            chips<LaneMode?>(
              [('Auto', null), for (final m in LaneMode.values) (m.name, m)],
              ambient.manual,
              ctrl.setManual,
            ),
            Gap(lane.space.s8),
            chips<String>(
              const [('English', 'en'), ('हिन्दी', 'hi'), ('ગુજરાતી', 'gu')],
              locale.languageCode,
              (code) => onLocale(Locale(code)),
            ),
            Gap(lane.space.s8),
            Text(
              'Auto now: ${resolveLaneMode(glare: ambient.glare, systemDark: ambient.systemDark, battery: ambient.battery, night: isNightAt(ambient.now, ambient.position ?? LanePosition.fallback))}'
              ' · battery ${ambient.battery.level ?? '?'}%',
              style: lane.text.caption.copyWith(color: lane.color.inkMuted),
            ),
            Gap(lane.space.s24),
            row('hero', lane.text.hero, hero),
            row('display', lane.text.display, '₹1,25,000'),
            row('otp', lane.text.otp, '4 8 2 7'),
            row('headline', lane.text.headline, hero),
            row('title', lane.text.title, address),
            row('bodyLarge', lane.text.bodyLarge, address),
            row('body', lane.text.body, '$hero. $address.'),
            row('label', lane.text.label, address),
            row('caps', lane.text.caps, caps),
            row('caption', lane.text.caption, address),
            Gap(lane.space.s8),
            Wrap(
              spacing: lane.space.s8,
              runSpacing: lane.space.s8,
              children: [
                badge('Requested', s.wait, s.waitTint),
                badge('On the way', s.route, s.routeTint),
                badge('Arrived', s.go, s.goTint),
                badge('Working', s.work, s.workTint),
                badge('SOS', s.stop, s.stopTint),
                badge('Cancelled', s.neutral, s.neutralTint),
              ],
            ),
            Gap(lane.space.s24),
            Container(
              height: lane.touch.critical,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: lane.color.beacon, borderRadius: lane.radius.r12),
              child: Text('GET HELP', style: lane.text.label.copyWith(color: lane.color.onBeacon)),
            ),
          ],
        ),
      ),
    );
  }
}
