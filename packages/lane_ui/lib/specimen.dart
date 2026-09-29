/// A living type and colour specimen for the example app and Widgetbook. Not for app screens.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
            Gap(lane.space.s8),
            chips<String>(
              const [
                ('Map', 'map'),
                ('Flow', 'flow'),
                ('Status', 'status'),
                ('List', 'list'),
                ('Form', 'form'),
              ],
              '',
              (t) => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LaneTemplateSample(template: t, sample: address),
                ),
              ),
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

/// A sample screen for each PLAN §6.13 template, for the example app and Widgetbook.
class LaneTemplateSample extends StatelessWidget {
  const LaneTemplateSample({super.key, required this.template, required this.sample});

  /// `map`, `flow`, `status`, `list` or `form`.
  final String template;

  /// Sample text in the active script.
  final String sample;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    Widget primary(String label) => FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: lane.color.beacon,
        foregroundColor: lane.color.onBeacon,
        shape: RoundedRectangleBorder(borderRadius: lane.radius.r12),
      ),
      onPressed: () {},
      // Lane text styles carry `ink`; on a Beacon fill the label must be `onBeacon`.
      child: Text(label, style: lane.text.label.copyWith(color: lane.color.onBeacon)),
    );
    final lines = [for (var i = 1; i <= 8; i++) Text('$i · $sample', style: lane.text.body)];

    return switch (template) {
      'map' => LaneMapScaffold(
        map: CustomPaint(painter: _GridMap(lane), child: const SizedBox.expand()),
        overlay: Icon(Icons.location_on, size: lane.space.s48, color: lane.color.ink),
        actions: [
          IconButton.filled(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(backgroundColor: lane.color.surface, foregroundColor: lane.color.ink),
          ),
        ],
        dock: LaneDock(
          header: Text('PICKUP', style: lane.text.caps),
          primary: primary('GET HELP'),
          children: [
            Text(sample, style: lane.text.title),
            ...lines,
          ],
        ),
      ),
      'flow' => LaneFlowScaffold(
        step: 2,
        totalSteps: 4,
        stepLabel: 'STEP 2 OF 4',
        title: sample,
        primary: primary('Continue'),
        children: lines,
      ),
      'status' => LaneStatusScaffold(
        top: const Align(alignment: Alignment.centerLeft, child: LaneBackButton()),
        visual: Icon(Icons.radar, size: lane.space.s64 * 1.5, color: lane.color.signal.wait),
        title: "We're finding the nearest mechanic",
        message: sample,
        primary: primary('Cancel request'),
      ),
      'list' => LaneListScaffold(
        showBack: true,
        title: 'Booking history',
        filters: [
          for (final f in ['All', 'Ahmedabad', 'Ankleshwar', 'Bharuch']) Chip(label: Text(f)),
        ],
        itemCount: 12,
        itemBuilder: (_, i) => Container(
          padding: EdgeInsets.all(lane.space.s16),
          decoration: BoxDecoration(
            color: lane.color.surface,
            borderRadius: lane.radius.r16,
            border: Border.all(color: lane.color.line, width: lane.stroke.hairline),
          ),
          child: Text('#${1000 + i} · $sample', style: lane.text.body),
        ),
        empty: Text('No bookings yet', style: lane.text.body),
      ),
      _ => LaneFormScaffold(
        title: 'Profile & settings',
        primary: primary('Save'),
        children: [
          for (final label in ['Name', 'Phone', 'Emergency contact'])
            TextField(
              decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
            ),
        ],
      ),
    };
  }
}

/// A plain street grid standing in for the map.
class _GridMap extends CustomPainter {
  _GridMap(this.lane);

  final LaneTheme lane;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = lane.color.surfaceSunken);
    final road = Paint()
      ..color = lane.color.surface
      ..strokeWidth = lane.space.s12;
    for (var x = 0.0; x < size.width; x += lane.space.s64 * 1.5) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), road);
    }
    for (var y = 0.0; y < size.height; y += lane.space.s64 * 1.5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
    }
  }

  @override
  bool shouldRepaint(_GridMap old) => old.lane.color.bg != lane.color.bg;
}

/// Renders [child] as one phone screen in a given mode, language and text scale, without
/// `LaneApp` or providers. Golden tests and Widgetbook use it so they match exactly.
class LanePreview extends StatelessWidget {
  const LanePreview({
    super.key,
    required this.mode,
    required this.child,
    this.locale = const Locale('en'),
    this.textScale = 1.0,
    this.size = const Size(360, 800),
  });

  final LaneMode mode;
  final Locale locale;
  final double textScale;

  /// PLAN §6.14: designs are done at 360 × 800.
  final Size size;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LaneThemeData.build(mode, script: LaneScript.of(locale));
    return Localizations.override(
      context: context,
      locale: locale,
      delegates: GlobalMaterialLocalizations.delegates,
      child: Theme(
        data: theme,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: size,
            textScaler: TextScaler.linear(textScale.clamp(1.0, LaneApp.maxTextScale)),
            padding: EdgeInsets.zero,
            viewPadding: EdgeInsets.zero,
          ),
          child: SizedBox.fromSize(
            size: size,
            child: DefaultTextStyle(
              style: theme.extension<LaneTheme>()!.text.body,
              child: Navigator(onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => child)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Every button and gesture component in its states, for goldens and Widgetbook (#7).
class LaneButtonsSample extends StatelessWidget {
  const LaneButtonsSample({super.key, this.label = 'Get help'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    void noop() {}
    Widget gap() => SizedBox(height: lane.space.s12);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(lane.space.s16),
        children: [
          LaneButton.primary(label: label, onPressed: noop, critical: true),
          gap(),
          LaneButton.primary(label: label, onPressed: noop, loading: true),
          gap(),
          Row(
            children: [
              Expanded(
                child: LaneButton.secondary(label: 'Call', onPressed: noop, icon: const Icon(Icons.call)),
              ),
              SizedBox(width: lane.space.s8),
              Expanded(
                child: LaneButton.secondary(label: 'Chat', onPressed: noop, loading: true),
              ),
            ],
          ),
          gap(),
          LaneButton.pill(label: label, onPressed: noop),
          gap(),
          Row(
            children: [
              Expanded(
                child: LaneButton.danger(label: 'Cancel booking', onPressed: noop),
              ),
              SizedBox(width: lane.space.s8),
              Expanded(
                child: LaneButton.ghost(label: 'Skip', onPressed: noop),
              ),
            ],
          ),
          gap(),
          LaneButton.primary(label: label, onPressed: null),
          gap(),
          LaneSlideToConfirm(label: 'Slide to accept', onConfirmed: noop),
          gap(),
          Center(
            child: LaneHoldButton(label: 'SOS', semanticsHint: 'Hold to send SOS', onConfirmed: noop),
          ),
        ],
      ),
    );
  }
}

/// Inputs, chips and badges in their states, for goldens and Widgetbook (#84).
class LaneInputsSample extends StatelessWidget {
  const LaneInputsSample({super.key, this.sample = 'Near SG Highway, Thaltej'});

  final String sample;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    Widget gap() => SizedBox(height: lane.space.s16);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(lane.space.s16),
        children: [
          LaneTextField(label: 'Landmark', hint: sample, helper: 'Helps the mechanic find you'),
          gap(),
          const LaneTextField(
            label: 'Registration number',
            initialValue: 'GJ01AB',
            errorText: 'Check the number',
          ),
          gap(),
          Wrap(
            spacing: lane.space.s8,
            runSpacing: lane.space.s8,
            children: [
              LaneChip(label: 'All', selected: true, onSelected: (_) {}),
              LaneChip(label: 'Ahmedabad', selected: false, onSelected: (_) {}),
              const LaneChip(label: 'Bharuch', selected: false),
            ],
          ),
          gap(),
          LaneSwitch(
            label: 'Online',
            subtitle: 'You get new jobs',
            value: true,
            onChanged: (_) {},
            big: true,
          ),
          LaneSwitch(label: 'Arrival chime', value: false, onChanged: (_) {}),
          LaneListTile(
            leading: const Icon(Icons.directions_car_rounded),
            title: sample,
            subtitle: 'Petrol · default',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          gap(),
          Wrap(
            spacing: lane.space.s8,
            runSpacing: lane.space.s8,
            children: [
              for (final (signal, label) in [
                (LaneSignal.wait, 'Requested'),
                (LaneSignal.route, 'On the way'),
                (LaneSignal.go, 'Arrived'),
                (LaneSignal.work, 'Working'),
                (LaneSignal.stop, 'SOS'),
                (LaneSignal.neutral, 'Cancelled'),
              ])
                SignalBadge(signal: signal, label: label),
            ],
          ),
          gap(),
          Wrap(
            spacing: lane.space.s8,
            runSpacing: lane.space.s8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const [
              PlateChip(regNo: 'GJ01AB1234'),
              PlateChip(regNo: '22BH1234AA', large: true),
            ],
          ),
        ],
      ),
    );
  }
}
