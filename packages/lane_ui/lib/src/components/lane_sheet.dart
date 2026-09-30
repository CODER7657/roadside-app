// LaneSheet and LaneConfirmSheet (PLAN.md §6.12, §6.5 ⑤): modal sheets, and the confirm
// sheet every destructive action uses (cancel booking, delete account), never a single tap.
import 'package:flutter/material.dart';

import '../theme/lane_theme.dart';
import 'lane_button.dart';
import 'lane_inputs.dart';

/// Shows [child] (usually a [LaneSheet]) as a modal bottom sheet in Lane style: `surface`,
/// `r24` top corners, a drag handle, and dismissible by drag or back.
Future<T?> showLaneSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  final lane = context.lane;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: lane.color.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: lane.radius.r24.topLeft)),
    builder: builder,
  );
}

/// The inside of a sheet: a title, content that scrolls when tall (200% text), and the
/// actions pinned underneath.
class LaneSheet extends StatelessWidget {
  const LaneSheet({super.key, required this.title, this.children = const [], this.primary, this.secondary});

  final String title;
  final List<Widget> children;
  final Widget? primary;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final inset = lane.space.s16;
    return Padding(
      // Lift above the keyboard when a field inside is focused.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(inset, 0, inset, inset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(header: true, child: Text(title, style: lane.text.title)),
                  SizedBox(height: lane.space.s12),
                  ...children,
                ],
              ),
            ),
          ),
          if (primary != null || secondary != null)
            Padding(
              padding: EdgeInsets.fromLTRB(inset, 0, inset, inset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ?primary,
                  if (primary != null && secondary != null) SizedBox(height: lane.space.s8),
                  ?secondary,
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A reason the user picks on a [LaneConfirmSheet].
@immutable
class LaneReason<T> {
  const LaneReason(this.value, this.label, {this.asksForText = false});

  final T value;
  final String label;

  /// "Something else": shows a short text field (optional, up to [LaneConfirmSheet.maxText]).
  final bool asksForText;
}

/// What the user confirmed.
typedef LaneConfirmResult<T> = ({T reason, String? text});

/// Confirm a destructive action with a **required** reason: the confirm button stays off
/// until a chip is chosen. Returns null when dismissed or kept. The confirm button is
/// [LaneButton.danger] (never amber); "keep" is the safe ghost option.
class LaneConfirmSheet<T> extends StatefulWidget {
  const LaneConfirmSheet({
    super.key,
    required this.title,
    required this.reasons,
    required this.confirmLabel,
    required this.keepLabel,
    this.message,
    this.textLabel,
  });

  /// Matches `cancelBooking`'s `reason.text` limit.
  static const maxText = 300;

  final String title;
  final String? message;
  final List<LaneReason<T>> reasons;
  final String confirmLabel;
  final String keepLabel;

  /// Label of the text field for a reason with `asksForText`.
  final String? textLabel;

  static Future<LaneConfirmResult<T>?> show<T>(
    BuildContext context, {
    required String title,
    required List<LaneReason<T>> reasons,
    required String confirmLabel,
    required String keepLabel,
    String? message,
    String? textLabel,
  }) => showLaneSheet<LaneConfirmResult<T>>(
    context,
    builder: (_) => LaneConfirmSheet<T>(
      title: title,
      message: message,
      reasons: reasons,
      confirmLabel: confirmLabel,
      keepLabel: keepLabel,
      textLabel: textLabel,
    ),
  );

  @override
  State<LaneConfirmSheet<T>> createState() => _LaneConfirmSheetState<T>();
}

class _LaneConfirmSheetState<T> extends State<LaneConfirmSheet<T>> {
  LaneReason<T>? _picked;
  String _text = '';

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final picked = _picked;
    return LaneSheet(
      title: widget.title,
      primary: LaneButton.danger(
        label: widget.confirmLabel,
        onPressed: picked == null
            ? null
            : () {
                final text = _text.trim();
                Navigator.of(context).pop<LaneConfirmResult<T>>((
                  reason: picked.value,
                  text: picked.asksForText && text.isNotEmpty ? text : null,
                ));
              },
      ),
      secondary: LaneButton.ghost(label: widget.keepLabel, onPressed: () => Navigator.of(context).pop()),
      children: [
        if (widget.message != null) ...[
          Text(widget.message!, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
          SizedBox(height: lane.space.s16),
        ],
        Wrap(
          spacing: lane.space.s8,
          runSpacing: lane.space.s8,
          children: [
            for (final r in widget.reasons)
              LaneChip(
                label: r.label,
                selected: identical(r, picked),
                onSelected: (_) => setState(() => _picked = r),
              ),
          ],
        ),
        if (picked != null && picked.asksForText) ...[
          SizedBox(height: lane.space.s16),
          LaneTextField(
            label: widget.textLabel ?? picked.label,
            maxLength: LaneConfirmSheet.maxText,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (v) => _text = v,
          ),
        ],
      ],
    );
  }
}
