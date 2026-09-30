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
                const SignalBadge(signal: LaneSignal.wait, label: 'Requested'),
                const SignalBadge(signal: LaneSignal.route, label: 'On the way'),
                const SignalBadge(signal: LaneSignal.go, label: 'Arrived'),
                const SignalBadge(signal: LaneSignal.work, label: 'Working'),
                const SignalBadge(signal: LaneSignal.stop, label: 'SOS'),
                const SignalBadge(signal: LaneSignal.neutral, label: 'Cancelled'),
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
        overlay: LaneIcon(LaneIcons.location, size: lane.space.s48),
        actions: [
          IconButton.filled(
            onPressed: () => Navigator.maybePop(context),
            icon: const LaneIcon(LaneIcons.close),
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
        visual: LaneIcon(LaneIcons.hourglass, size: lane.space.s64 * 1.5, color: lane.color.signal.wait),
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
      delegates: [LaneLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
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
              // The route reads the child through [_PreviewScreen], so a rebuild with a new
              // child (Widgetbook knobs, a test re-pumping) shows it instead of the first one.
              child: _PreviewScreen(
                screen: child,
                child: Navigator(onGenerateRoute: (_) => MaterialPageRoute<void>(builder: _PreviewScreen.of)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewScreen extends InheritedWidget {
  const _PreviewScreen({required this.screen, required super.child});

  final Widget screen;

  static Widget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PreviewScreen>()!.screen;

  @override
  bool updateShouldNotify(_PreviewScreen old) => screen != old.screen;
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
                child: LaneButton.secondary(
                  label: 'Call',
                  onPressed: noop,
                  icon: const LaneIcon(LaneIcons.call),
                ),
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
            leading: const LaneIcon(LaneIcons.car),
            title: sample,
            subtitle: 'Petrol · default',
            trailing: const LaneIcon(LaneIcons.caretRight),
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

/// Loading, empty, error and offline states, for goldens and Widgetbook (#85).
class LaneFeedbackSample extends StatelessWidget {
  const LaneFeedbackSample({super.key});

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return Scaffold(
      body: Column(
        children: [
          const OfflineStrip(offline: true),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(lane.space.s16),
              children: [
                SkeletonGroup.lines(),
                SizedBox(height: lane.space.s16),
                ErrorState(onRetry: () {}, alternativeLabel: 'Send location by SMS', onAlternative: () {}),
                EmptyState(
                  title: 'No bookings yet',
                  message: 'Your trips will show here.',
                  actionLabel: 'Get help',
                  onAction: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Every Lane icon, the problem grid and vehicle tiles, for goldens and Widgetbook (#86).
class LaneIconsSample extends StatelessWidget {
  const LaneIconsSample({super.key, this.problemLabels = const {}});

  /// Localised problem names keyed by PLAN §8 `problemType`; English names otherwise.
  final Map<String, String> problemLabels;

  static const problems = ['flat_tyre', 'battery', 'wont_start', 'overheating', 'accident', 'fuel', 'other'];

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final inset = lane.space.s16;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(inset),
        children: [
          Wrap(
            spacing: lane.space.s12,
            runSpacing: lane.space.s12,
            children: [for (final i in LaneIcons.values) LaneIcon(i, size: lane.space.s32)],
          ),
          SizedBox(height: lane.space.s24),
          LaneTileGrid(
            children: [
              for (final p in problems)
                ProblemTile(
                  icon: LaneIcons.forProblem(p),
                  label: problemLabels[p] ?? p.replaceAll('_', ' '),
                  selected: p == 'battery',
                  onTap: () {},
                ),
            ],
          ),
          SizedBox(height: lane.space.s24),
          VehicleTile(
            icon: LaneIcons.forVehicle('car'),
            name: 'Maruti Swift',
            regNo: 'GJ01AB1234',
            detail: 'Petrol · default',
            selected: true,
            onTap: () {},
          ),
          SizedBox(height: lane.space.s12),
          VehicleTile(
            icon: LaneIcons.forVehicle('scooter'),
            name: 'Honda Activa',
            regNo: 'GJ05CD5678',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// The signature components (#15): JourneyRail, TrustPass (both variants), the start code,
/// code entry, a rolling number, the countdown ring and the breathing pulse.
class LaneSignatureSample extends StatelessWidget {
  const LaneSignatureSample({
    super.key,
    this.page = 0,
    this.stops = defaultStops,
    this.name = 'Ramesh Patel',
  });

  /// PLAN §9 order: requested · accepted · on the way · arrived · working · done.
  static const defaultStops = ['Requested', 'Accepted', 'On the way', 'Arrived', 'Working', 'Done'];
  static const signals = [
    LaneSignal.wait,
    LaneSignal.route,
    LaneSignal.route,
    LaneSignal.go,
    LaneSignal.work,
    LaneSignal.go,
  ];

  /// 0: the rails and the workshop pass. 1: the independent pass and the number parts.
  /// (Two pages so each fits a 360 × 800 golden.)
  final int page;

  final List<String> stops;
  final String name;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final journey = [
      for (final (i, label) in stops.indexed)
        JourneyStop(label: label, signal: signals[i], time: i <= 2 ? '10:4${i * 2}' : null),
    ];
    final gap = SizedBox(height: lane.space.s24);
    final inset = lane.space.s16;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(inset),
        children: [
          if (page == 0) ...[
            JourneyRail(stops: journey, current: 2),
            gap,
            JourneyRail(stops: journey, current: 2, direction: Axis.vertical),
            gap,
            TrustPass.workshop(
              name: name,
              shopName: 'Shree Auto Garage',
              rating: 4.8,
              jobs: 126,
              vehicleTypes: const ['bike', 'car'],
              startCode: '4827',
            ),
          ] else ...[
            TrustPass.independent(name: name, years: 6, travelRegNo: 'GJ01AB1234', rating: 4.6, jobs: 38),
            gap,
            const LaneOtpInput(),
            gap,
            const Center(child: LaneRollingNumber(value: '₹1,250')),
            gap,
            CountdownRing(
              elapsed: const Duration(seconds: 10),
              child: LaneButton.primary(label: 'Accept', onPressed: () {}),
            ),
            gap,
            Center(
              child: BreathingPulse(child: LaneIcon(LaneIcons.mechanic, size: lane.space.s48)),
            ),
          ],
        ],
      ),
    );
  }
}

/// CenterPin (resting and lifted), every AccuracyBadge state and PriceRange, for goldens and
/// Widgetbook (#107, #108).
class LaneMapPartsSample extends StatelessWidget {
  const LaneMapPartsSample({super.key});

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final gap = SizedBox(height: lane.space.s16);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(lane.space.s24),
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [CenterPin(), CenterPin(lifted: true)],
          ),
          gap,
          const PriceRange(min: 350, max: 600, includes: 'Puncture repair or spare fitting'),
          gap,
          const PriceRange(min: 125000, max: 125000),
          gap,
          const Center(
            child: LaneQrCode(
              data: 'upi://pay?pa=kiran@okaxis&pn=Kiran%20Patel&am=450.00&cu=INR',
              semanticLabel: 'QR',
              size: 160,
            ),
          ),
          gap,
          for (final m in const [null, 8.0, 35.0, 120.0]) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: AccuracyBadge(meters: m),
            ),
            gap,
          ],
        ],
      ),
    );
  }
}

/// LaneConfirmSheet as it looks open, for goldens and Widgetbook (#125).
class LaneSheetSample extends StatelessWidget {
  const LaneSheetSample({
    super.key,
    this.reasons = const ['Found help elsewhere', 'Taking too long', 'Something else'],
  });

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return Scaffold(
      backgroundColor: lane.color.bg,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: lane.color.surface,
            borderRadius: BorderRadius.vertical(top: lane.radius.r24.topLeft),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: lane.space.s24),
            child: LaneConfirmSheet<int>(
              title: 'Cancel this booking?',
              message: 'The mechanic will be told straight away.',
              reasons: [
                for (final (i, r) in reasons.indexed) LaneReason(i, r, asksForText: i == reasons.length - 1),
              ],
              confirmLabel: 'Cancel booking',
              keepLabel: 'Keep booking',
            ),
          ),
        ),
      ),
    );
  }
}
