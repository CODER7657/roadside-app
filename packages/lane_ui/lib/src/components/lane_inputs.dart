// Inputs and list parts (PLAN.md §6.12): LaneTextField, LaneChip, LaneSwitch, LaneListTile.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/lane_theme.dart';
import '../tokens/lane_haptics.dart';

/// A labelled text field: label above, 56 dp field on a sunken well, helper or error below.
///
/// Focus is a 2 px `ink` border (Beacon is too faint on light backgrounds for a focus
/// ring); errors use `signal.stop` and replace the helper.
class LaneTextField extends StatelessWidget {
  const LaneTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hint,
    this.helper,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hint;
  final String? helper;

  /// Replaces [helper] when set.
  final String? errorText;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final int? maxLines;
  final bool enabled;
  final bool obscureText;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: lane.radius.r12,
      borderSide: BorderSide(color: color, width: width),
    );
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: lane.text.label.copyWith(color: c.ink)),
        SizedBox(height: lane.space.s8),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          maxLength: maxLength,
          maxLines: obscureText ? 1 : maxLines,
          enabled: enabled,
          obscureText: obscureText,
          textCapitalization: textCapitalization,
          style: lane.text.body.copyWith(color: c.ink),
          cursorColor: c.ink,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: lane.text.body.copyWith(color: c.inkSubtle),
            filled: true,
            fillColor: c.surfaceSunken,
            isDense: false,
            counterText: '',
            constraints: BoxConstraints(minHeight: lane.touch.primary),
            contentPadding: EdgeInsets.symmetric(horizontal: lane.space.s16, vertical: lane.space.s16),
            enabledBorder: border(hasError ? c.signal.stop : c.line, lane.stroke.hairline),
            disabledBorder: border(c.line, lane.stroke.hairline),
            focusedBorder: border(hasError ? c.signal.stop : c.ink, 2),
            errorBorder: border(c.signal.stop, lane.stroke.hairline),
            focusedErrorBorder: border(c.signal.stop, 2),
          ),
        ),
        if (hasError || helper != null) ...[
          SizedBox(height: lane.space.s8),
          Semantics(
            liveRegion: hasError,
            child: Text(
              errorText ?? helper!,
              style: lane.text.caption.copyWith(color: hasError ? c.signal.stop : c.inkMuted),
            ),
          ),
        ],
      ],
    );
  }
}

/// A filter or choice chip. Selected chips are solid `ink` (Swiss: meaning by weight, not
/// colour); unselected ones are outlined. At least 48 dp tall.
class LaneChip extends StatelessWidget {
  const LaneChip({super.key, required this.label, required this.selected, this.onSelected, this.icon});

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    final fg = selected ? c.surface : c.ink;
    final enabled = onSelected != null;
    void toggle() {
      LaneHaptics.select();
      onSelected!(!selected);
    }

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      // excludeSemantics drops the InkWell's own action, so TalkBack needs this one.
      onTap: enabled ? toggle : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: InkWell(
          borderRadius: lane.radius.pill,
          onTap: enabled ? toggle : null,
          child: AnimatedContainer(
            duration: lane.motion.quick,
            constraints: BoxConstraints(minHeight: lane.touch.min),
            padding: EdgeInsets.symmetric(horizontal: lane.space.s16, vertical: lane.space.s8),
            decoration: BoxDecoration(
              color: selected ? c.ink : c.surface,
              borderRadius: lane.radius.pill,
              border: Border.all(color: selected ? c.ink : c.line, width: lane.stroke.hairline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  IconTheme.merge(
                    data: IconThemeData(color: fg, size: lane.space.s20),
                    child: icon!,
                  ),
                  SizedBox(width: lane.space.s8),
                ],
                Flexible(
                  child: Text(label, style: lane.text.label.copyWith(color: fg)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A labelled on/off switch; the whole row is the touch target. [big] makes it the 64 dp
/// mechanic online toggle (M3).
class LaneSwitch extends StatelessWidget {
  const LaneSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.big = false,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    final enabled = onChanged != null;
    void toggle() {
      LaneHaptics.select();
      onChanged!(!value);
    }

    return Semantics(
      toggled: value,
      enabled: enabled,
      label: label,
      hint: subtitle,
      excludeSemantics: true,
      onTap: enabled ? toggle : null,
      child: InkWell(
        onTap: enabled ? toggle : null,
        borderRadius: lane.radius.r12,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: big ? lane.touch.critical : lane.touch.min),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: lane.space.s8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, style: (big ? lane.text.title : lane.text.body).copyWith(color: c.ink)),
                      if (subtitle != null)
                        Text(subtitle!, style: lane.text.caption.copyWith(color: c.inkMuted)),
                    ],
                  ),
                ),
                SizedBox(width: lane.space.s12),
                Transform.scale(
                  scale: big ? 1.3 : 1,
                  child: Switch(
                    value: value,
                    onChanged: enabled ? (_) => toggle() : null,
                    activeTrackColor: c.beacon,
                    activeThumbColor: c.onBeacon,
                    inactiveTrackColor: c.surfaceSunken,
                    inactiveThumbColor: c.inkMuted,
                    trackOutlineColor: WidgetStateProperty.resolveWith(
                      (s) => s.contains(WidgetState.selected) ? c.beacon : c.line,
                    ),
                    trackOutlineWidth: WidgetStatePropertyAll(lane.stroke.hairline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A row in a list: optional leading, a title that may wrap to two lines, an optional
/// subtitle and trailing. At least 56 dp.
class LaneListTile extends StatelessWidget {
  const LaneListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    return InkWell(
      onTap: onTap,
      borderRadius: lane.radius.r12,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: lane.touch.primary),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: lane.space.s4, vertical: lane.space.s12),
          child: Row(
            children: [
              if (leading != null) ...[
                IconTheme.merge(
                  data: IconThemeData(color: c.ink, size: lane.space.s24),
                  child: leading!,
                ),
                SizedBox(width: lane.space.s16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: lane.text.body.copyWith(color: c.ink),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: lane.space.s4),
                      Text(subtitle!, style: lane.text.caption.copyWith(color: c.inkMuted)),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: lane.space.s12),
                IconTheme.merge(
                  data: IconThemeData(color: c.inkMuted),
                  child: trailing!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
