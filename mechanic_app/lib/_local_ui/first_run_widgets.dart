// Temporary widgets for C2 and C4 until they move into lane_ui (PLAN §2: build locally,
// then a `lane:request` issue). Same as customer_app/lib/_local_ui; move both together.
// Tokens only; no raw values.
import 'package:flutter/material.dart';
import 'package:lane_ui/lane_ui.dart';

/// A big selectable tile for one language, written in its own script (C2).
class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key, required this.nativeName, required this.selected, required this.onTap});

  /// "English", "हिन्दी", "ગુજરાતી".
  final String nativeName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    void tap() {
      LaneHaptics.select();
      onTap();
    }

    return Semantics(
      button: true,
      selected: selected,
      label: nativeName,
      excludeSemantics: true,
      onTap: tap,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: lane.radius.r16,
          side: BorderSide(color: selected ? c.ink : c.line, width: selected ? 2 : lane.stroke.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: tap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: lane.touch.critical),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: lane.space.s20, vertical: lane.space.s16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(nativeName, style: lane.text.title.copyWith(color: c.ink)),
                  ),
                  if (selected) LaneIcon(LaneIcons.checkCircle, color: c.ink, size: lane.space.s24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A checkbox row where the whole row is the touch target (C4 consent).
class ConsentCheck extends StatelessWidget {
  const ConsentCheck({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    void toggle() {
      LaneHaptics.select();
      onChanged(!value);
    }

    return Semantics(
      checked: value,
      label: label,
      excludeSemantics: true,
      onTap: toggle,
      child: InkWell(
        onTap: toggle,
        borderRadius: lane.radius.r12,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: lane.touch.min),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: lane.space.s8),
            child: Row(
              children: [
                Checkbox(
                  value: value,
                  onChanged: (_) => toggle(),
                  activeColor: c.ink,
                  checkColor: c.surface,
                  side: BorderSide(color: c.ink, width: 2),
                ),
                SizedBox(width: lane.space.s8),
                Expanded(
                  child: Text(label, style: lane.text.body.copyWith(color: c.ink)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A plain bullet line for the privacy notice.
class NoticeBullet extends StatelessWidget {
  const NoticeBullet(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    return Padding(
      padding: EdgeInsets.only(bottom: lane.space.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: lane.space.s4),
            child: LaneIcon(LaneIcons.check, size: lane.space.s16, color: lane.color.inkMuted),
          ),
          SizedBox(width: lane.space.s12),
          Expanded(
            child: Text(text, style: lane.text.body.copyWith(color: lane.color.inkMuted)),
          ),
        ],
      ),
    );
  }
}
