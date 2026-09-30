import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../l10n/app_localizations.dart';
import '../../booking/application/live_booking.dart';
import '../../booking/data/photo_pipeline.dart';
import '../../help/presentation/help_screen.dart' show launchLinkProvider;
import '../../permissions/application/permission_service.dart';
import '../../permissions/presentation/permission_explainer_screen.dart';
import '../application/chat.dart';

/// U11 Chat (PLAN §10 Customer 11, wireframe U11): text (≤ 500) and photos with the assigned
/// mechanic, only while the booking is active; afterwards it stays readable for 30 days.
/// Sends show right away as "Sending…", and a failed one retries on tap.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  int _shown = 0;

  ChatOutbox get _outbox => ref.read(chatOutboxProvider(widget.bookingId).notifier);

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Keeps the newest message in view when one arrives, unless the customer scrolled up to
  /// read older ones (then a message of their own still brings them down).
  void _follow(List<ChatLine> lines) {
    if (lines.length == _shown) return;
    final first = _shown == 0;
    final mineLast = lines.isNotEmpty && lines.last.mine;
    _shown = lines.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final position = _scroll.position;
      final nearBottom = position.maxScrollExtent - position.pixels < context.lane.space.s64 * 3;
      if (first || !context.lane.motion.enabled) {
        _scroll.jumpTo(position.maxScrollExtent);
      } else if (nearBottom || mineLast) {
        unawaited(
          _scroll.animateTo(
            position.maxScrollExtent,
            duration: context.lane.motion.quick,
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  Future<void> _attach() async {
    final l10n = AppLocalizations.of(context);
    final source = await showLaneSheet<PhotoSource>(
      context,
      builder: (context) => LaneSheet(
        title: l10n.chat_photo_title,
        children: [
          LaneButton.secondary(
            label: l10n.chat_photo_take,
            onPressed: () => Navigator.pop(context, PhotoSource.camera),
          ),
          SizedBox(height: context.lane.space.s8),
          LaneButton.secondary(
            label: l10n.chat_photo_gallery,
            onPressed: () => Navigator.pop(context, PhotoSource.gallery),
          ),
        ],
      ),
    );
    if (source == null || !mounted) return;
    // The camera goes through the C7 explainer first; the gallery uses the system picker.
    if (source == PhotoSource.camera && !await ensurePermission(context, ref, AppPermission.camera)) return;
    final error = await _outbox.sendPhoto(source);
    if (error == null || !mounted) return;
    unawaited(LaneHaptics.error());
    LaneToast.show(context, switch (error) {
      ChatPhotoError.tooLarge => l10n.chat_photo_too_large,
      ChatPhotoError.failed => l10n.chat_photo_failed,
    });
  }

  Future<void> _call(String phone) async {
    final l10n = AppLocalizations.of(context);
    final ok = await ref.read(launchLinkProvider)(Uri(scheme: 'tel', path: phone));
    if (!ok && mounted) LaneToast.show(context, l10n.tracking_call_failed);
  }

  String? _subtitle(AppLocalizations l10n, Booking b, String name) => switch (b.status) {
    BookingStatus.accepted || BookingStatus.arriving => l10n.tracking_on_the_way(name),
    BookingStatus.arrived => l10n.tracking_arrived(name),
    BookingStatus.inProgress => l10n.working_title(name),
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final booking = ref.watch(liveBookingProvider(widget.bookingId)).value;
    final card = booking?.mechanicCard;
    final name = card?.name ?? '';
    final active = booking != null && booking.status.isActive;
    final linesAsync = ref.watch(chatLinesProvider(widget.bookingId));
    final lines = linesAsync.value ?? const <ChatLine>[];
    // Skeleton rows while the first messages load (the empty slot is for a real empty chat).
    final loading = !linesAsync.hasValue && !linesAsync.hasError;
    _follow(lines);
    final time = DateFormat.Hm(Localizations.localeOf(context).toLanguageTag());

    final Widget empty = linesAsync.hasError
        ? EmptyState(
            title: l10n.chat_error,
            actionLabel: l10n.chat_error_retry,
            onAction: () => ref.invalidate(chatMessagesProvider(widget.bookingId)),
          )
        : EmptyState(
            title: l10n.chat_empty_title,
            message: name.isEmpty ? null : l10n.chat_empty_body(name),
            actionLabel: l10n.tracking_call(name),
            onAction: card == null || card.phone.isEmpty ? null : () => _call(card.phone),
          );

    return LaneListScaffold(
      title: name.isEmpty ? l10n.chat_title : name,
      subtitle: booking == null ? null : _subtitle(l10n, booking, name) ?? l10n.chat_closed,
      showBack: true,
      controller: _scroll,
      itemCount: loading ? 2 : lines.length,
      empty: empty,
      itemBuilder: (context, i) {
        if (loading) return SkeletonGroup.lines(lines: 2);
        final line = lines[i];
        final hasPhoto = line.photo != null || line.imagePath != null;
        return ChatBubble(
          key: ValueKey(line.id),
          mine: line.mine,
          text: line.text.isEmpty ? null : line.text,
          image: hasPhoto ? _ChatPhoto(line: line) : null,
          time: line.createdAt == null ? null : time.format(line.createdAt!.toLocal()),
          semanticLabel: line.text.isEmpty
              ? null
              : line.mine
              ? l10n.chat_you(line.text)
              : l10n.chat_from(name, line.text),
          delivery: line.delivery,
          onRetry: () => _outbox.retry(line.id),
        );
      },
      primary: active
          ? ChatComposer(
              controller: _text,
              onSend: (text) => unawaited(_outbox.sendText(text)),
              onAttach: _attach,
            )
          : Padding(
              padding: EdgeInsets.symmetric(vertical: lane.space.s8),
              child: Text(
                l10n.chat_closed,
                textAlign: TextAlign.center,
                style: lane.text.body.copyWith(color: lane.color.inkMuted),
              ),
            ),
    );
  }
}

/// A chat photo: my local copy while it uploads, otherwise the file from Storage.
class _ChatPhoto extends ConsumerWidget {
  const _ChatPhoto({required this.line});

  final ChatLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lane = context.lane;
    // 4:3; the bubble scales it to its width.
    Widget frame(Widget child) =>
        SizedBox(width: lane.space.s64 * 4, height: lane.space.s64 * 3, child: child);
    final Uint8List? bytes =
        line.photo ?? (line.imagePath == null ? null : ref.watch(chatPhotoProvider(line.imagePath!)).value);
    if (bytes == null) {
      return frame(ColoredBox(color: lane.color.surfaceSunken));
    }
    return frame(
      Image.memory(
        bytes,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        // A photo that can't be decoded shows as the empty frame instead of an error.
        errorBuilder: (_, _, _) => ColoredBox(color: lane.color.surfaceSunken),
      ),
    );
  }
}
