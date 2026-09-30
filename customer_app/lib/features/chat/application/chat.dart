import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lane_ui/lane_ui.dart' show ChatDelivery, laneClockProvider;
import 'package:roadside_core/roadside_core.dart';

import '../../booking/application/booking_draft.dart'
    show newDraftToken, photoCompressorProvider, photoPickerProvider;
import '../../booking/application/estimate.dart' show customerIdProvider;
import '../../booking/data/photo_pipeline.dart';
import '../data/chat_repository.dart';

// Seams: in memory until #92 wires Firebase (then FirestoreChatRepository + a Storage store).
final chatRepositoryProvider = Provider<ChatRepository>((ref) => InMemoryChatRepository());
final chatPhotoStoreProvider = Provider<ChatPhotoStore>((ref) => InMemoryChatPhotoStore());

final chatMessagesProvider = StreamProvider.autoDispose.family<List<ChatEntry>, String>(
  (ref, bookingId) => ref.watch(chatRepositoryProvider).watch(bookingId),
);

/// A chat photo's bytes, by Storage path (the rules let only the two participants read it).
final chatPhotoProvider = FutureProvider.autoDispose.family<Uint8List, String>(
  (ref, path) => ref.watch(chatPhotoStoreProvider).download(path),
);

/// One of my messages that isn't on the server yet.
@immutable
class OutboxItem {
  const OutboxItem({
    required this.id,
    required this.text,
    required this.createdAt,
    this.photo,
    this.imagePath,
    this.failed = false,
  });

  final String id;
  final String text;
  final DateTime createdAt;

  /// The prepared JPEG, until it is uploaded.
  final Uint8List? photo;

  /// Set once the photo is in Storage, so a retry only resends the message (the chat path is
  /// write-once; uploading again would be refused).
  final String? imagePath;
  final bool failed;

  OutboxItem copyWith({String? imagePath, bool? failed}) => OutboxItem(
    id: id,
    text: text,
    createdAt: createdAt,
    photo: photo,
    imagePath: imagePath ?? this.imagePath,
    failed: failed ?? this.failed,
  );
}

/// A line in U11, from the server or from my outbox.
@immutable
class ChatLine {
  const ChatLine({
    required this.id,
    required this.mine,
    required this.text,
    required this.delivery,
    this.createdAt,
    this.imagePath,
    this.photo,
  });

  final String id;
  final bool mine;
  final String text;
  final ChatDelivery delivery;
  final DateTime? createdAt;
  final String? imagePath;

  /// Local bytes for a photo I just sent (shown before it reaches Storage).
  final Uint8List? photo;
}

/// Why a photo couldn't be added.
enum ChatPhotoError { tooLarge, failed }

/// My unsent messages for one booking, and the sending itself.
class ChatOutbox extends Notifier<List<OutboxItem>> {
  ChatOutbox(this.bookingId);

  final String bookingId;

  @override
  List<OutboxItem> build() => const [];

  ChatRepository get _repo => ref.read(chatRepositoryProvider);

  void _replace(OutboxItem item) => state = [
    for (final i in state)
      if (i.id == item.id) item else i,
  ];

  OutboxItem _add({String text = '', Uint8List? photo}) {
    final item = OutboxItem(
      id: newDraftToken(),
      text: text.trim(),
      photo: photo,
      createdAt: ref.read(laneClockProvider)(),
    );
    state = [...state, item];
    return item;
  }

  /// Sends a text message (the composer has trimmed it and kept it ≤ 500 characters).
  Future<void> sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await _deliver(_add(text: trimmed.characters.take(kMaxChatLength).toString()));
  }

  /// Picks, compresses (≤ 1600 px, ≤ 500 KB, no EXIF location) and sends a photo.
  Future<ChatPhotoError?> sendPhoto(PhotoSource source) async {
    final Uint8List bytes;
    try {
      final picked = await ref.read(photoPickerProvider).pick(source);
      if (picked == null) return null;
      bytes = await ref.read(photoCompressorProvider).compress(picked);
    } on PhotoTooLargeException {
      return ChatPhotoError.tooLarge;
    } catch (e, s) {
      LaneLog.w('chat photo pick failed', error: e, stackTrace: s);
      return ChatPhotoError.failed;
    }
    if (!ref.mounted) return null;
    await _deliver(_add(photo: bytes));
    return null;
  }

  Future<void> retry(String id) async {
    final item = state.where((i) => i.id == id && i.failed).firstOrNull;
    if (item == null) return;
    final again = item.copyWith(failed: false);
    _replace(again);
    await _deliver(again);
  }

  Future<void> _deliver(OutboxItem item) async {
    var current = item;
    try {
      if (current.photo != null && current.imagePath == null) {
        final path = await ref
            .read(chatPhotoStoreProvider)
            // A new name per attempt: if an upload reached Storage but the reply got lost, retrying
            // the same name would hit the write-once rule forever.
            .upload(
              bookingId,
              fileName: '${current.id}-${ref.read(laneClockProvider)().millisecondsSinceEpoch}.jpg',
              bytes: current.photo!,
            );
        current = current.copyWith(imagePath: path);
        if (ref.mounted) _replace(current);
      }
      await _repo.send(
        bookingId,
        id: current.id,
        message: ChatMessage(
          senderId: ref.read(customerIdProvider),
          text: current.text,
          imagePath: current.imagePath,
        ),
      );
      if (ref.mounted) {
        state = [
          for (final i in state)
            if (i.id != current.id) i,
        ];
      }
    } catch (e, s) {
      // Ids only: the text or photo never goes to the logs.
      LaneLog.w('chat send failed', error: e, stackTrace: s, fields: {'bookingId': bookingId});
      if (ref.mounted) _replace(current.copyWith(failed: true));
    }
  }
}

final chatOutboxProvider = NotifierProvider.family<ChatOutbox, List<OutboxItem>, String>(ChatOutbox.new);

/// U11's lines, oldest first: the server's messages plus my outbox. A message already on the
/// server (by id) is shown once, from the server; pending server writes read "Sending…".
final chatLinesProvider = Provider.autoDispose.family<AsyncValue<List<ChatLine>>, String>((ref, bookingId) {
  final me = ref.watch(customerIdProvider);
  final outbox = ref.watch(chatOutboxProvider(bookingId));
  return ref.watch(chatMessagesProvider(bookingId)).whenData((server) {
    final serverIds = {for (final e in server) e.id};
    final local = {for (final o in outbox) o.id: o};
    final lines = [
      for (final e in server)
        ChatLine(
          id: e.id,
          mine: e.message.senderId == me,
          text: e.message.text,
          imagePath: e.message.imagePath,
          photo: local[e.id]?.photo,
          createdAt: e.message.createdAt,
          delivery: e.pending ? ChatDelivery.sending : ChatDelivery.sent,
        ),
      for (final o in outbox)
        if (!serverIds.contains(o.id))
          ChatLine(
            id: o.id,
            mine: true,
            text: o.text,
            imagePath: o.imagePath,
            photo: o.photo,
            createdAt: o.createdAt,
            delivery: o.failed ? ChatDelivery.failed : ChatDelivery.sending,
          ),
    ];
    return lines;
  });
});
