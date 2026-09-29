// The numbers that matter, at arm's length, and calm motion (PLAN.md §6.5 ⑥⑦, §6.12):
// LaneOtpDisplay, LaneOtpInput, LaneRollingNumber, BreathingPulse, CountdownRing.
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../theme/lane_theme.dart';
import 'lane_button.dart';
import 'lane_feedback.dart';

/// Screen brightness for the full-screen start code. Tests and Widgetbook swap it.
abstract interface class LaneBrightness {
  Future<void> setMax();
  Future<void> reset();
}

class _PluginBrightness implements LaneBrightness {
  const _PluginBrightness();

  @override
  Future<void> setMax() async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(1);
    } catch (_) {
      // Not available (web, tests): the code is still big and high-contrast.
    }
  }

  @override
  Future<void> reset() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (_) {}
  }
}

/// Digits spaced so TalkBack reads "4 8 2 7", not "four thousand…".
String _spoken(String code) => code.split('').join(' ');

/// The start code at arm's length: 56 sp JetBrains Mono, digits 16 dp apart. Tap it to show
/// it full screen at maximum brightness for the mechanic to read (PLAN §6.5 ⑦).
class LaneOtpDisplay extends StatelessWidget {
  const LaneOtpDisplay({super.key, required this.code, this.fullscreenOnTap = true});

  /// Swap in tests or Widgetbook.
  static LaneBrightness brightness = const _PluginBrightness();

  final String code;
  final bool fullscreenOnTap;

  static Widget _digits(BuildContext context, String code, TextStyle style) {
    final lane = context.lane;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, d) in code.split('').indexed) ...[
          if (i > 0) SizedBox(width: lane.space.s16),
          Text(d, style: style),
        ],
      ],
    );
  }

  void _open(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: context.lane.motion.standard,
        pageBuilder: (_, _, _) => _OtpFullscreen(code: code),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final digits = FittedBox(
      fit: BoxFit.scaleDown,
      child: _digits(context, code, lane.text.otp.copyWith(color: lane.color.ink)),
    );
    return Semantics(
      label: _spoken(code),
      button: fullscreenOnTap,
      hint: fullscreenOnTap ? laneStrings(context).otp_show_big : null,
      excludeSemantics: true,
      onTap: fullscreenOnTap ? () => _open(context) : null,
      child: fullscreenOnTap ? GestureDetector(onTap: () => _open(context), child: digits) : digits,
    );
  }
}

class _OtpFullscreen extends StatefulWidget {
  const _OtpFullscreen({required this.code});

  final String code;

  @override
  State<_OtpFullscreen> createState() => _OtpFullscreenState();
}

class _OtpFullscreenState extends State<_OtpFullscreen> {
  @override
  void initState() {
    super.initState();
    LaneOtpDisplay.brightness.setMax();
  }

  @override
  void dispose() {
    LaneOtpDisplay.brightness.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final strings = laneStrings(context);
    return Scaffold(
      backgroundColor: lane.color.surface,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).maybePop(),
          child: Column(
            children: [
              Expanded(
                child: Semantics(
                  label: _spoken(widget.code),
                  excludeSemantics: true,
                  child: Padding(
                    padding: EdgeInsets.all(lane.space.s24),
                    // Fills the width: readable from a metre or two away.
                    child: SizedBox.expand(
                      child: FittedBox(
                        child: LaneOtpDisplay._digits(
                          context,
                          widget.code,
                          lane.text.otp.copyWith(color: lane.color.ink),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(lane.space.s16),
                child: LaneButton.ghost(
                  label: strings.otp_close,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Code entry as big boxes (mechanic start code: 4; phone OTP: 6). Accepts a pasted code
/// and SMS auto-fill (`oneTimeCode`); calls [onCompleted] once all digits are in.
class LaneOtpInput extends StatefulWidget {
  const LaneOtpInput({
    super.key,
    this.length = 4,
    this.onChanged,
    this.onCompleted,
    this.autofocus = false,
    this.errorText,
    this.enabled = true,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;

  /// Shown under the boxes; also outlines them in `signal.stop`.
  final String? errorText;
  final bool enabled;

  @override
  State<LaneOtpInput> createState() => _LaneOtpInputState();
}

class _LaneOtpInputState extends State<LaneOtpInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _changed(String v) {
    setState(() {});
    widget.onChanged?.call(v);
    if (v.length == widget.length) widget.onCompleted?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    final text = _controller.text;
    final hasError = widget.errorText != null;

    Widget box(int i) {
      final active =
          _focus.hasFocus && (i == text.length || (i == widget.length - 1 && text.length == widget.length));
      return Expanded(
        child: AspectRatio(
          aspectRatio: 0.85,
          child: Container(
            constraints: BoxConstraints(minHeight: lane.touch.primary),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.surfaceSunken,
              borderRadius: lane.radius.r12,
              border: Border.all(
                color: hasError ? c.signal.stop : (active ? c.ink : c.line),
                width: active || hasError ? 2 : lane.stroke.hairline,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(lane.space.s4),
              child: FittedBox(
                child: Text(i < text.length ? text[i] : '', style: lane.text.display.copyWith(color: c.ink)),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            // The real field: invisible, full size, so taps focus it and paste works.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  showCursor: false,
                  enableInteractiveSelection: true,
                  decoration: InputDecoration(
                    labelText: laneStrings(context).otp_input_label,
                    border: InputBorder.none,
                  ),
                  onChanged: _changed,
                ),
              ),
            ),
            IgnorePointer(
              child: Row(
                children: [
                  for (var i = 0; i < widget.length; i++) ...[
                    if (i > 0) SizedBox(width: lane.space.s8),
                    box(i),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (hasError) ...[
          SizedBox(height: lane.space.s8),
          Semantics(
            container: true,
            liveRegion: true,
            child: Text(widget.errorText!, style: lane.text.caption.copyWith(color: c.signal.stop)),
          ),
        ],
      ],
    );
  }
}

/// A number that rolls digit by digit when it changes (ETA, price, earnings), instead of
/// jumping. Non-digits (₹, spaces, "min") stay put. Reads as the whole value.
class LaneRollingNumber extends StatelessWidget {
  const LaneRollingNumber({super.key, required this.value, this.style});

  /// Already formatted, e.g. "7 min" or "₹1,250".
  final String value;

  /// Defaults to `lane.text.display` (JetBrains Mono).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final s = style ?? lane.text.display.copyWith(color: lane.color.ink);
    final motion = lane.motion;
    return Semantics(
      label: value,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, ch) in value.split('').indexed)
            ClipRect(
              child: AnimatedSwitcher(
                duration: motion.enabled ? motion.standard : Duration.zero,
                switchInCurve: motion.enter,
                switchOutCurve: motion.exit,
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Text(ch, key: ValueKey('$i:$ch'), style: s),
              ),
            ),
        ],
      ),
    );
  }
}

/// A soft ring breathing on a 10-second cycle (5 s out, 5 s in) behind [child], for the
/// Searching screen: something slow and steady to follow instead of a spinner. With reduced
/// motion it holds still. (A calming choice; make no medical claims in copy.)
class BreathingPulse extends StatefulWidget {
  const BreathingPulse({super.key, required this.child, this.size});

  final Widget child;

  /// Diameter of the ring at rest. Defaults to 3 × the critical touch size.
  final double? size;

  @override
  State<BreathingPulse> createState() => _BreathingPulseState();
}

class _BreathingPulseState extends State<BreathingPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(vsync: this);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final breath = context.lane.motion.breath;
    if (breath == Duration.zero) {
      _breath.stop();
      _breath.value = 0.5;
    } else if (!_breath.isAnimating) {
      // Half the cycle out, half back in.
      _breath
        ..duration = breath ~/ 2
        ..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final size = widget.size ?? lane.touch.critical * 3;
    final tint = lane.color.signal.waitTint;
    final ring = lane.color.signal.wait;
    return SizedBox.square(
      dimension: size * 1.25,
      child: AnimatedBuilder(
        animation: _breath,
        builder: (context, child) {
          final t = Curves.easeInOutSine.transform(_breath.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 0.85 + 0.3 * t,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tint,
                    border: Border.all(
                      color: ring.withValues(alpha: 0.35 + 0.35 * (1 - t)),
                      width: lane.space.s4 / 2,
                    ),
                  ),
                ),
              ),
              child!,
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// A countdown drawn as a border that drains around [child] (the mechanic's 30 s offer
/// wraps `LaneSlideToConfirm`). Calls [onExpired] once at zero. Pill-shaped by default, so it
/// fits both a slider and a round child.
class CountdownRing extends StatefulWidget {
  const CountdownRing({
    super.key,
    required this.child,
    this.duration = defaultDuration,
    this.elapsed = Duration.zero,
    this.onExpired,
  });

  /// PLAN §11: offers expire after 30 s.
  static const defaultDuration = Duration(seconds: 30);

  final Widget child;
  final Duration duration;

  /// Time already gone (e.g. the push arrived late): the ring starts part-drained.
  final Duration elapsed;
  final VoidCallback? onExpired;

  @override
  State<CountdownRing> createState() => _CountdownRingState();
}

class _CountdownRingState extends State<CountdownRing> with SingleTickerProviderStateMixin {
  late final AnimationController _left;
  int _lastSecond = -1;

  @override
  void initState() {
    super.initState();
    final start = 1 - (widget.elapsed.inMilliseconds / widget.duration.inMilliseconds).clamp(0.0, 1.0);
    _left = AnimationController(vsync: this, duration: widget.duration, value: start)
      ..addListener(_tick)
      ..addStatusListener((s) {
        if (s == AnimationStatus.dismissed) widget.onExpired?.call();
      });
    if (start > 0) {
      _left.reverse();
    } else {
      scheduleMicrotask(() => widget.onExpired?.call());
    }
  }

  // Whole seconds, rounded up; via milliseconds so 20.000001 s doesn't read as 21.
  int get _secondsLeft {
    final ms = (_left.value * widget.duration.inMilliseconds).round();
    return (ms + 999) ~/ 1000;
  }

  // Rebuild the semantics label once a second, not every frame.
  void _tick() {
    final s = _secondsLeft;
    if (s != _lastSecond) setState(() => _lastSecond = s);
  }

  @override
  void dispose() {
    _left.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final seconds = _secondsLeft;
    return Semantics(
      label: laneStrings(context).countdown_seconds_left(seconds),
      child: CustomPaint(
        foregroundPainter: _DrainPainter(
          left: _left,
          track: lane.color.line,
          // Calm: route blue, turning to wait amber for the last third.
          color: _left.value > 1 / 3 ? lane.color.signal.route : lane.color.signal.wait,
          stroke: lane.space.s4,
        ),
        child: Padding(padding: EdgeInsets.all(lane.space.s8), child: widget.child),
      ),
    );
  }
}

class _DrainPainter extends CustomPainter {
  _DrainPainter({required this.left, required this.track, required this.color, required this.stroke})
    : super(repaint: left);

  final Animation<double> left;
  final Color track;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final radius = Radius.circular(math.min(rect.width, rect.height) / 2);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, radius));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint..color = track);
    final PathMetric metric = path.computeMetrics().first;
    // Start at the top centre and drain clockwise.
    final start = metric.length * 0.125;
    final remaining = metric.length * left.value;
    final end = start + remaining;
    final visible = Path()..addPath(metric.extractPath(start, math.min(end, metric.length)), Offset.zero);
    if (end > metric.length) visible.addPath(metric.extractPath(0, end - metric.length), Offset.zero);
    canvas.drawPath(visible, paint..color = color);
  }

  @override
  bool shouldRepaint(_DrainPainter old) => old.color != color || old.track != track || old.stroke != stroke;
}
