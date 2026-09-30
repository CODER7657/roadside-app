// A compact "₹ min – max" cell for admin tables (A4 prices). Lives here until lane_ui has a
// LaneDataTable (PLAN §6.12); like ConsoleShell it takes no app strings or providers.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lane_ui/lane_ui.dart';

class PriceRangeField extends StatelessWidget {
  const PriceRangeField({
    super.key,
    required this.min,
    required this.max,
    required this.minLabel,
    required this.maxLabel,
    required this.onChanged,
    this.minHint,
    this.maxHint,
    this.errorText,
    this.changed = false,
    this.enabled = true,
  });

  final String min;
  final String max;

  /// Screen-reader labels, e.g. "Car, flat tyre: minimum".
  final String minLabel;
  final String maxLabel;

  /// Shown in empty fields, e.g. the default a city override falls back to.
  final String? minHint;
  final String? maxHint;
  final String? errorText;

  /// Marks an unsaved edit with a Beacon outline.
  final bool changed;
  final bool enabled;
  final void Function(String min, String max) onChanged;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    final hasError = errorText != null;
    final borderColor = hasError ? c.signal.stop : (changed ? c.beacon : c.line);

    Widget field(String value, String label, String? hint, void Function(String) onValue) => Expanded(
      child: Semantics(
        label: label,
        textField: true,
        child: TextFormField(
          initialValue: value,
          enabled: enabled,
          onChanged: onValue,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
          textAlign: TextAlign.end,
          style: lane.text.body.copyWith(color: c.ink, fontFeatures: const [FontFeature.tabularFigures()]),
          cursorColor: c.ink,
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: lane.text.body.copyWith(color: c.inkSubtle),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: lane.space.s12),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(minHeight: lane.touch.min),
          padding: EdgeInsets.symmetric(horizontal: lane.space.s12),
          decoration: BoxDecoration(
            color: c.surfaceSunken,
            borderRadius: lane.radius.r12,
            border: Border.all(color: borderColor, width: hasError || changed ? 2 : lane.stroke.hairline),
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Text('₹', style: lane.text.body.copyWith(color: c.inkMuted)),
              ),
              field(min, minLabel, minHint, (v) => onChanged(v, max)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: lane.space.s8),
                child: ExcludeSemantics(
                  child: Text('–', style: lane.text.body.copyWith(color: c.inkMuted)),
                ),
              ),
              field(max, maxLabel, maxHint, (v) => onChanged(min, v)),
            ],
          ),
        ),
        if (hasError) ...[
          Gap(lane.space.s4),
          Semantics(
            liveRegion: true,
            child: Text(errorText!, style: lane.text.caption.copyWith(color: c.signal.stop)),
          ),
        ],
      ],
    );
  }
}
