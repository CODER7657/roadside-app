// ChatBubble and ChatComposer: the parts of the booking chat (PLAN.md §6.12, U11).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/lane_theme.dart';
import 'lane_feedback.dart';
import 'lane_icons.dart';

/// Where one of my messages is. The other person's messages are always [sent].
enum ChatDelivery { sending, sent, failed }

/// One chat message: mine on the right in ink, theirs on the left on the sunken surface.
/// Text, a photo, or both. Under it, the time, and for my messages whether it is still
/// sending or failed; a failed message retries on tap.
///
/// TalkBack reads one node per message: [semanticLabel] (e.g. "Kiran: I'm near the pump"),
/// the photo, and the delivery state.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.mine,
    this.text,
    this.image,
    this.time,
    this.semanticLabel,
    this.delivery = ChatDelivery.sent,
    this.onRetry,
    this.onImageTap,
  }) : assert(text != null || image != null, 'A message has text, a photo, or both');

  final bool mine;
  final String? text;

  /// The photo, e.g. `Image.memory` or `Image.network`. The bubble crops and sizes it.
  final Widget? image;

  /// Already formatted by the app ("10:24").
  final String? time;

  /// Who said what, for TalkBack. Defaults to [text].
  final String? semanticLabel;

  final ChatDelivery delivery;

  /// Called when a [ChatDelivery.failed] message is tapped.
  final VoidCallback? onRetry;
  final VoidCallback? onImageTap;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    final strings = laneStrings(context);
    final failed = mine && delivery == ChatDelivery.failed;
    final sending = mine && delivery == ChatDelivery.sending;
    final fg = mine ? c.bg : c.ink;
    final radius = lane.radius.r16;

    final bubble = DecoratedBox(
      decoration: BoxDecoration(
        color: mine ? c.ink : c.surfaceSunken,
        borderRadius: radius,
        border: mine ? null : Border.all(color: c.line, width: lane.stroke.hairline),
      ),
      child: Padding(
        padding: EdgeInsets.all(image != null && text == null ? lane.space.s4 : lane.space.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (image != null)
              GestureDetector(
                onTap: onImageTap,
                child: ClipRRect(
                  borderRadius: lane.radius.r12,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: lane.space.s64 * 4),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: FittedBox(fit: BoxFit.cover, child: image),
                    ),
                  ),
                ),
              ),
            if (image != null && text != null) SizedBox(height: lane.space.s8),
            if (text != null) Text(text!, style: lane.text.body.copyWith(color: fg)),
          ],
        ),
      ),
    );

    final meta = <Widget>[
      if (sending) ...[
        LaneIcon(LaneIcons.hourglass, size: lane.space.s16, color: c.inkMuted),
        SizedBox(width: lane.space.s4),
        Text(strings.chat_sending, style: lane.text.caption.copyWith(color: c.inkMuted)),
      ] else if (failed) ...[
        LaneIcon(LaneIcons.warning, size: lane.space.s16, color: c.signal.stop),
        SizedBox(width: lane.space.s4),
        Flexible(
          child: Text(strings.chat_failed, style: lane.text.caption.copyWith(color: c.signal.stop)),
        ),
      ] else if (time != null)
        Text(time!, style: lane.text.caption.copyWith(color: c.inkMuted)),
    ];

    final column = Column(
      crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(opacity: sending ? 0.6 : 1, child: bubble),
        if (meta.isNotEmpty) ...[
          SizedBox(height: lane.space.s4),
          Row(mainAxisSize: MainAxisSize.min, children: meta),
        ],
      ],
    );

    final state = sending
        ? strings.chat_sending
        : failed
        ? strings.chat_failed
        : time;
    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: 0.8,
        alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        child: Align(
          alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
          child: Semantics(
            container: true,
            button: failed,
            label: [
              semanticLabel ?? text,
              if (image != null) strings.chat_photo,
            ].whereType<String>().join(', '),
            value: state,
            onTap: failed ? onRetry : null,
            child: ExcludeSemantics(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: failed ? onRetry : null,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: failed ? lane.touch.min : 0),
                  child: column,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The chat input: an optional camera button, a text field that grows to four lines, and a
/// round Beacon send button that stays disabled until there is something to send. Text is
/// capped at [maxLength] characters (PLAN §8: 500); the count shows near the limit.
///
/// [onSend] gets the trimmed text; the composer then clears itself.
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAttach,
    this.hint,
    this.maxLength = 500,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSend;

  /// Shows the camera button when set.
  final VoidCallback? onAttach;

  /// Defaults to "Message".
  final String? hint;
  final int maxLength;
  final bool enabled;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(ChatComposer old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  String get _text => widget.controller.text.trim();

  void _send() {
    final text = _text;
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    widget.controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    final strings = laneStrings(context);
    final canSend = widget.enabled && _text.isNotEmpty;
    final left = widget.maxLength - widget.controller.text.characters.length;
    final size = lane.touch.min;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (left <= widget.maxLength ~/ 10)
          Padding(
            padding: EdgeInsets.only(bottom: lane.space.s4),
            child: Semantics(
              liveRegion: true,
              child: Text(
                strings.chat_chars_left(left),
                textAlign: TextAlign.end,
                style: lane.text.caption.copyWith(color: left <= 0 ? c.signal.stop : c.inkMuted),
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.onAttach != null) ...[
              IconButton(
                tooltip: strings.chat_add_photo,
                onPressed: widget.enabled ? widget.onAttach : null,
                constraints: BoxConstraints.tightFor(width: size, height: size),
                icon: LaneIcon(LaneIcons.camera, color: widget.enabled ? c.ink : c.inkSubtle),
              ),
              SizedBox(width: lane.space.s4),
            ],
            Expanded(
              child: TextField(
                controller: widget.controller,
                enabled: widget.enabled,
                minLines: 1,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [LengthLimitingTextInputFormatter(widget.maxLength)],
                style: lane.text.body.copyWith(color: c.ink),
                cursorColor: c.ink,
                decoration: InputDecoration(
                  hintText: widget.hint ?? strings.chat_hint,
                  hintStyle: lane.text.body.copyWith(color: c.inkSubtle),
                  filled: true,
                  fillColor: c.surfaceSunken,
                  constraints: BoxConstraints(minHeight: size),
                  contentPadding: EdgeInsets.symmetric(horizontal: lane.space.s16, vertical: lane.space.s12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: lane.radius.r12,
                    borderSide: BorderSide(color: c.line, width: lane.stroke.hairline),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: lane.radius.r12,
                    borderSide: BorderSide(color: c.line, width: lane.stroke.hairline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: lane.radius.r12,
                    borderSide: BorderSide(color: c.ink, width: lane.stroke.hairline * 2),
                  ),
                ),
              ),
            ),
            SizedBox(width: lane.space.s8),
            Semantics(
              button: true,
              enabled: canSend,
              label: strings.chat_send,
              onTap: canSend ? _send : null,
              child: ExcludeSemantics(
                child: Material(
                  color: canSend ? c.beacon : c.surfaceSunken,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    key: const ValueKey('chat-send'),
                    onTap: canSend ? _send : null,
                    child: SizedBox.square(
                      dimension: size,
                      child: Center(
                        child: LaneIcon(
                          LaneIcons.send,
                          size: lane.space.s24,
                          color: canSend ? c.onBeacon : c.inkSubtle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
