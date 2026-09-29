// LaneButton: the ThreeUI button styles re-implemented in Flutter (PLAN.md §6.12, §6.17).
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/lane_theme.dart';
import '../tokens/lane_colors.dart';
import '../tokens/lane_haptics.dart';

enum _Variant { primary, secondary, pill, ghost, danger }

/// Every button in the apps. One primary per screen (PLAN §6.3 ③).
///
/// - [LaneButton.primary]: ThreeUI **Launch** (amber gradient, ring, ledge). Get Help,
///   Confirm, Pay, every flow's main action.
/// - [LaneButton.secondary]: ThreeUI **Spinning Border** (zinc pill, mono caps label; the
///   border beam spins only while [loading]). Call, Chat.
/// - [LaneButton.pill]: ThreeUI **Gradient CTA**. Onboarding and empty states only.
/// - [LaneButton.ghost]: text only. Skip, Cancel.
/// - [LaneButton.danger]: flat `signal.stop`. Delete, cancel booking. Never amber.
///
/// Set [critical] for Get Help, Accept, SOS and Pay (64 dp instead of 56 dp). A null
/// [onPressed] disables the button; [loading] shows progress and ignores taps.
class LaneButton extends StatefulWidget {
  const LaneButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.critical = false,
  }) : _variant = _Variant.primary;

  const LaneButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.critical = false,
  }) : _variant = _Variant.secondary;

  const LaneButton.pill({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.critical = false,
  }) : _variant = _Variant.pill;

  const LaneButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  }) : critical = false,
       _variant = _Variant.ghost;

  const LaneButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.critical = false,
  }) : _variant = _Variant.danger;

  /// Height of the Launch ledge; the face drops [pressDepth] of it when pressed.
  static const ledgeHeight = 4.0;
  static const pressDepth = 2.0;

  /// One turn of the Spinning Border beam while loading.
  static const beamPeriod = Duration(milliseconds: 1600);

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool loading;
  final bool critical;
  final _Variant _variant;

  @override
  State<LaneButton> createState() => _LaneButtonState();
}

class _LaneButtonState extends State<LaneButton> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _beam = AnimationController(vsync: this, duration: LaneButton.beamPeriod);

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBeam();
  }

  @override
  void didUpdateWidget(LaneButton old) {
    super.didUpdateWidget(old);
    _syncBeam();
  }

  void _syncBeam() {
    final spin = widget._variant == _Variant.secondary && widget.loading && context.lane.motion.enabled;
    if (spin && !_beam.isAnimating) {
      _beam.repeat();
    } else if (!spin && _beam.isAnimating) {
      _beam.stop();
    }
  }

  @override
  void dispose() {
    _beam.dispose();
    super.dispose();
  }

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  void _tap() {
    LaneHaptics.press();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    final minHeight = widget.critical ? lane.touch.critical : lane.touch.primary;
    final pressed = _pressed && _enabled;

    final (Color fg, TextStyle labelStyle) = switch (widget._variant) {
      // Lane text styles carry `ink`; every variant sets its own label colour.
      _Variant.primary => (LaneBrand.launchText, lane.text.label.copyWith(color: LaneBrand.launchText)),
      _Variant.secondary => (LaneBrand.quietText, lane.text.caps.copyWith(color: LaneBrand.quietText)),
      _Variant.pill => (LaneBrand.pillText, lane.text.label.copyWith(color: LaneBrand.pillText)),
      _Variant.ghost => (c.ink, lane.text.label.copyWith(color: c.ink)),
      _Variant.danger => (c.onSignal, lane.text.label.copyWith(color: c.onSignal)),
    };
    final text = widget._variant == _Variant.secondary ? widget.label.toUpperCase() : widget.label;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          IconTheme.merge(
            data: IconThemeData(color: fg, size: lane.space.s24),
            child: widget.icon!,
          ),
          SizedBox(width: lane.space.s8),
        ],
        Flexible(
          child: Text(text, style: labelStyle, textAlign: TextAlign.center),
        ),
      ],
    );
    if (widget.loading && widget._variant != _Variant.secondary) {
      // Spinners only ever appear inside buttons (PLAN §6.12 loading rule). The label keeps
      // its space so the button doesn't jump.
      content = Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0, child: content),
          SizedBox.square(
            dimension: lane.space.s20,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
          ),
        ],
      );
    }

    final padding = EdgeInsets.symmetric(horizontal: lane.space.s20, vertical: lane.space.s12);
    final face = switch (widget._variant) {
      _Variant.primary => _LaunchFace(
        pressed: pressed,
        lane: lane,
        padding: padding,
        minHeight: minHeight,
        child: content,
      ),
      _Variant.secondary => _BeamFace(
        beam: _beam,
        loading: widget.loading,
        lane: lane,
        padding: padding,
        minHeight: minHeight,
        child: content,
      ),
      _Variant.pill => _Face(
        minHeight: minHeight,
        padding: padding,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: LaneBrand.pillGradient),
          borderRadius: lane.radius.pill,
          border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 1),
        ),
        child: content,
      ),
      _Variant.ghost => _Face(minHeight: lane.touch.min, padding: padding, child: content),
      _Variant.danger => _Face(
        minHeight: minHeight,
        padding: padding,
        decoration: BoxDecoration(color: c.signal.stop, borderRadius: lane.radius.r12),
        child: content,
      ),
    };

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      excludeSemantics: true,
      onTap: _enabled ? _tap : null,
      child: Opacity(
        opacity: widget.onPressed == null ? 0.4 : 1,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => _setPressed(true) : null,
          onTapUp: _enabled ? (_) => _setPressed(false) : null,
          onTapCancel: () => _setPressed(false),
          onTap: _enabled ? _tap : null,
          child: AnimatedScale(
            scale: pressed && widget._variant != _Variant.primary && lane.motion.enabled ? 0.98 : 1,
            duration: lane.motion.instant,
            child: face,
          ),
        ),
      ),
    );
  }
}

class _Face extends StatelessWidget {
  const _Face({required this.minHeight, required this.padding, required this.child, this.decoration});

  final double minHeight;
  final EdgeInsets padding;
  final Decoration? decoration;
  final Widget child;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: minHeight),
    child: DecoratedBox(
      decoration: decoration ?? const BoxDecoration(),
      child: Padding(
        padding: padding,
        child: Center(widthFactor: 1, child: child),
      ),
    ),
  );
}

/// ThreeUI Launch: vertical amber gradient, 1 px ring, a hard ledge underneath and a soft
/// glow. Pressing drops the face by [LaneButton.pressDepth] and the ledge shrinks, like a
/// physical key.
class _LaunchFace extends StatelessWidget {
  const _LaunchFace({
    required this.pressed,
    required this.lane,
    required this.padding,
    required this.minHeight,
    required this.child,
  });

  final bool pressed;
  final LaneTheme lane;
  final EdgeInsets padding;
  final double minHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final drop = pressed ? LaneButton.pressDepth : 0.0;
    final ledge = LaneButton.ledgeHeight - drop;
    // The footprint includes the full ledge so pressing never shifts the layout.
    return Padding(
      padding: const EdgeInsets.only(bottom: LaneButton.ledgeHeight),
      child: AnimatedContainer(
        duration: lane.motion.instant,
        curve: lane.motion.move,
        transform: Matrix4.translationValues(0, drop, 0),
        constraints: BoxConstraints(minHeight: minHeight - LaneButton.ledgeHeight),
        padding: padding,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: LaneBrand.launchGradient,
          ),
          borderRadius: lane.radius.r12,
          border: Border.all(color: LaneBrand.launchRing, width: 1),
          boxShadow: [
            BoxShadow(color: LaneBrand.launchLedge, offset: Offset(0, ledge)),
            BoxShadow(
              color: LaneBrand.launchGradient.last.withValues(alpha: pressed ? 0.2 : 0.35),
              offset: Offset(0, lane.space.s4 + ledge),
              blurRadius: lane.space.s16,
            ),
          ],
        ),
        child: Center(widthFactor: 1, child: child),
      ),
    );
  }
}

/// ThreeUI Spinning Border: zinc gradient pill with a 1 px highlight edge. While loading, a
/// Beacon beam runs round the border.
class _BeamFace extends StatelessWidget {
  const _BeamFace({
    required this.beam,
    required this.loading,
    required this.lane,
    required this.padding,
    required this.minHeight,
    required this.child,
  });

  final Animation<double> beam;

  /// Shows the Beacon beam; it only spins when motion is on.
  final bool loading;
  final LaneTheme lane;
  final EdgeInsets padding;
  final double minHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: beam,
    builder: (context, face) => DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: lane.radius.pill,
        gradient: SweepGradient(
          transform: GradientRotation(beam.value * 2 * math.pi),
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.18),
            loading ? LaneBrand.beacon : Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.18),
          ],
          stops: const [0, 0.7, 0.85, 1],
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(1), child: face),
    ),
    child: _Face(
      minHeight: minHeight - 2,
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: LaneBrand.quietGradient,
        ),
        borderRadius: lane.radius.pill,
      ),
      child: child,
    ),
  );
}
