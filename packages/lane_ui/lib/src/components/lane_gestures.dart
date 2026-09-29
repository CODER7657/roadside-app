// Deliberate gestures for high-stakes actions (PLAN.md §6.5 ⑤): they stop pocket taps and
// panic taps without adding dialogs.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/lane_theme.dart';
import '../tokens/lane_haptics.dart';

/// Hold to confirm (SOS). A red ThreeUI Gradient Beam ring fills while held; completing
/// the hold fires [onConfirmed] once with the alert haptic. Letting go early cancels with
/// no side effect.
///
/// TalkBack users can't see the ring, so the semantic long-press action confirms directly.
class LaneHoldButton extends StatefulWidget {
  const LaneHoldButton({
    super.key,
    required this.label,
    required this.semanticsHint,
    required this.onConfirmed,
    this.size,
  });

  /// PLAN §6.5 ⑤.
  static const holdDuration = Duration(milliseconds: 1500);

  /// Shown inside the ring (e.g. "SOS").
  final String label;

  /// Localised "Hold for 1.5 seconds to send SOS" for screen readers.
  final String semanticsHint;

  final VoidCallback? onConfirmed;

  /// Diameter. Defaults to the critical touch target (64 dp).
  final double? size;

  @override
  State<LaneHoldButton> createState() => _LaneHoldButtonState();
}

class _LaneHoldButtonState extends State<LaneHoldButton> with SingleTickerProviderStateMixin {
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: LaneHoldButton.holdDuration,
  )..addStatusListener(_onStatus);

  bool get _enabled => widget.onConfirmed != null;

  void _onStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed) {
      LaneHaptics.alert();
      widget.onConfirmed?.call();
      _hold.value = 0;
    }
  }

  void _start() {
    if (!_enabled) return;
    LaneHaptics.select();
    _hold.forward(from: 0);
  }

  void _cancel() {
    if (!mounted) return;
    if (_hold.isAnimating) _hold.animateBack(0, duration: context.lane.motion.quick);
  }

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final size = widget.size ?? lane.touch.critical;
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      hint: widget.semanticsHint,
      excludeSemantics: true,
      onLongPress: _enabled ? widget.onConfirmed : null,
      child: GestureDetector(
        onTapDown: (_) => _start(),
        onTapUp: (_) => _cancel(),
        onTapCancel: _cancel,
        child: Opacity(
          opacity: _enabled ? 1 : 0.4,
          child: SizedBox.square(
            dimension: size,
            child: AnimatedBuilder(
              animation: _hold,
              builder: (context, _) => CustomPaint(
                painter: _BeamRingPainter(
                  progress: _hold.value,
                  track: lane.color.line,
                  beam: lane.color.signal.stop,
                  stroke: lane.space.s4,
                ),
                child: Padding(
                  padding: EdgeInsets.all(lane.space.s8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: lane.color.signal.stop, shape: BoxShape.circle),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: EdgeInsets.all(lane.space.s4),
                          child: Text(
                            widget.label,
                            style: lane.text.caps.copyWith(color: lane.color.onSignal),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ThreeUI Gradient Beam as a progress ring: a conic sweep in [beam] over a [track].
class _BeamRingPainter extends CustomPainter {
  _BeamRingPainter({required this.progress, required this.track, required this.beam, required this.stroke});

  final double progress;
  final Color track;
  final Color beam;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    if (progress <= 0) return;
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: sweep,
          transform: const GradientRotation(-math.pi / 2),
          colors: [beam.withValues(alpha: 0.35), beam],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_BeamRingPainter old) =>
      old.progress != progress || old.track != track || old.beam != beam || old.stroke != stroke;
}

/// Slide to accept or finish (mechanic offers, job complete). Works with gloves: a 64 dp
/// track and a big thumb. Sliding past [threshold] confirms; anything less springs back
/// without overshoot. Screen readers confirm with a double tap.
class LaneSlideToConfirm extends StatefulWidget {
  const LaneSlideToConfirm({super.key, required this.label, required this.onConfirmed});

  /// Fraction of the track the thumb must travel.
  static const threshold = 0.85;

  final String label;
  final VoidCallback? onConfirmed;

  @override
  State<LaneSlideToConfirm> createState() => _LaneSlideToConfirmState();
}

class _LaneSlideToConfirmState extends State<LaneSlideToConfirm> with SingleTickerProviderStateMixin {
  late final AnimationController _pos = AnimationController(vsync: this);
  bool _done = false;

  bool get _enabled => widget.onConfirmed != null && !_done;

  @override
  void dispose() {
    _pos.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_enabled) return;
    setState(() => _done = true);
    LaneHaptics.alert();
    widget.onConfirmed!();
  }

  void _release() {
    final motion = context.lane.motion;
    if (_pos.value >= LaneSlideToConfirm.threshold) {
      _pos.animateTo(1, duration: motion.quick, curve: motion.enter);
      _confirm();
    } else {
      _pos.animateBack(0, duration: motion.standard, curve: motion.exit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    final height = lane.touch.critical;
    final inset = lane.space.s4;
    final thumb = height - 2 * inset;

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      excludeSemantics: true,
      onTap: _enabled ? _confirm : null,
      child: Opacity(
        opacity: widget.onConfirmed == null ? 0.4 : 1,
        child: LayoutBuilder(
          builder: (context, box) {
            final travel = math.max(1.0, box.maxWidth - thumb - 2 * inset);
            return GestureDetector(
              onHorizontalDragUpdate: _enabled
                  ? (d) => _pos.value = (_pos.value + d.delta.dx / travel).clamp(0.0, 1.0)
                  : null,
              onHorizontalDragEnd: _enabled ? (_) => _release() : null,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: c.surfaceSunken,
                  borderRadius: lane.radius.pill,
                  border: Border.all(color: c.line, width: lane.stroke.hairline),
                ),
                child: AnimatedBuilder(
                  animation: _pos,
                  builder: (context, _) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.only(left: thumb + lane.space.s12, right: lane.space.s16),
                          child: Center(
                            child: Opacity(
                              opacity: (1 - _pos.value * 1.6).clamp(0.0, 1.0),
                              child: Text(
                                widget.label,
                                style: lane.text.label.copyWith(color: c.ink),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: inset + _pos.value * travel,
                        child: Container(
                          width: thumb,
                          height: thumb,
                          decoration: BoxDecoration(color: c.beacon, shape: BoxShape.circle),
                          child: Icon(
                            _done ? Icons.check_rounded : Icons.keyboard_double_arrow_right_rounded,
                            color: c.onBeacon,
                            size: lane.space.s32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
