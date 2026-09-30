// A photo slot for M1 (profile, shop, toolkit, ID documents) until lane_ui has one
// (PLAN §2: build locally, then a `lane:request` issue). Tokens only; no raw values.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lane_ui/lane_ui.dart';

/// A square slot: the photo if there is one, otherwise an "add" tile. The whole slot is the
/// touch target (at least `lane.touch.min`).
class PhotoSlot extends StatelessWidget {
  const PhotoSlot({
    super.key,
    required this.label,
    required this.addLabel,
    required this.onTap,
    this.bytes,
    this.onRemove,
    this.removeLabel,
    this.hasError = false,
  });

  final String label;

  /// Shown in an empty slot ("Add photo"): lane_ui has no plus or camera glyph yet.
  final String addLabel;
  final Uint8List? bytes;
  final VoidCallback onTap;

  /// Shown as a small close button on a filled slot (toolkit photos).
  final VoidCallback? onRemove;
  final String? removeLabel;

  /// Draws the border in the stop colour (the error text sits under the group).
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    final size = lane.touch.critical * 1.5;
    final filled = bytes != null;
    return Semantics(
      button: true,
      label: label,
      image: filled,
      // The label is part of the target too: tapping "Shop photo" opens the picker.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: size,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Material(
                    color: c.surfaceSunken,
                    shape: RoundedRectangleBorder(
                      borderRadius: lane.radius.r12,
                      side: BorderSide(
                        color: hasError ? c.signal.stop : c.line,
                        width: lane.stroke.hairline * 2,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onTap,
                      child: SizedBox.square(
                        dimension: size,
                        child: filled
                            ? Image.memory(bytes!, fit: BoxFit.cover, gaplessPlayback: true)
                            : Center(
                                child: Padding(
                                  padding: EdgeInsets.all(lane.space.s8),
                                  child: Text(
                                    addLabel,
                                    textAlign: TextAlign.center,
                                    style: lane.text.label.copyWith(color: c.ink),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (filled && onRemove != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        tooltip: removeLabel,
                        onPressed: onRemove,
                        icon: LaneIcon(LaneIcons.close, size: lane.space.s20, color: c.ink),
                      ),
                    ),
                ],
              ),
              SizedBox(height: lane.space.s4),
              Text(label, style: lane.text.caption.copyWith(color: c.inkMuted), maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }
}

/// A line of error text under a group that isn't a text field (chips, photos).
class FieldError extends StatelessWidget {
  const FieldError(this.text, {super.key});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: lane.space.s4),
      child: Text(text!, style: lane.text.caption.copyWith(color: lane.color.signal.stop)),
    );
  }
}
