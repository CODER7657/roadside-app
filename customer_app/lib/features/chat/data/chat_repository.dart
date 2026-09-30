import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:roadside_core/roadside_core.dart';

/// A message as U11 shows it. [pending] = written on this phone, not yet on the server.
@immutable
class ChatEntry {
  const ChatEntry({required this.id, required this.message, this.pending = false});

  final String id;
  final ChatMessage message;
  final bool pending;
}

/// `bookings/{bookingId}/messages` (PLAN §8). The rules (#99) let the two participants write
/// while the booking is active: sender = self, text ≤ 500, text or a photo, server time.
abstract interface class ChatRepository {
  /// Oldest first.
  Stream<List<ChatEntry>> watch(String bookingId);

  /// Writes message [id] (chosen by the app, so a retry can't post it twice) and completes
  /// once the server has it. Offline, Firestore shows it at once as pending and sends it later.
  Future<void> send(String bookingId, {required String id, required ChatMessage message});
}

/// Chat photos in Storage: `bookings/{bookingId}/chat/{fileName}` (storage rules #102:
/// participants, active booking, images < 5 MB, write-once). The Firebase implementation
/// comes with #92 and must set `contentType: image/jpeg`.
abstract interface class ChatPhotoStore {
  /// Uploads a prepared JPEG and returns its Storage path (never a URL).
  Future<String> upload(String bookingId, {required String fileName, required Uint8List bytes});

  Future<Uint8List> download(String path);
}

class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository(this._refs);

  final RoadsideRefs _refs;

  @override
  Stream<List<ChatEntry>> watch(String bookingId) => _refs
      .messages(bookingId)
      .orderBy('createdAt')
      .snapshots(includeMetadataChanges: true)
      .map(
        (q) => [
          for (final d in q.docs)
            ChatEntry(id: d.id, message: d.data(), pending: d.metadata.hasPendingWrites),
        ],
      );

  @override
  Future<void> send(String bookingId, {required String id, required ChatMessage message}) =>
      _refs.raw(_refs.messages(bookingId).doc(id)).set(stampCreated(message.toJson()));
}

/// Messages kept in memory until #92 wires Firebase. Tests can [receive] the mechanic's
/// messages, make sends [failNext] or hang ([holdSends]), and read what was sent.
class InMemoryChatRepository implements ChatRepository {
  InMemoryChatRepository({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final _messages = <String, List<ChatEntry>>{};
  final _changes = StreamController<String>.broadcast();

  /// How many of the next sends fail.
  int failNext = 0;

  /// While set, sends wait for it (to see the pending state).
  Completer<void>? holdSends;

  List<ChatEntry> messagesOf(String bookingId) => List.unmodifiable(_messages[bookingId] ?? const []);

  /// A message from the other side.
  void receive(String bookingId, ChatMessage message, {String? id}) {
    final list = _messages.putIfAbsent(bookingId, () => []);
    list.add(
      ChatEntry(
        id: id ?? 'in-${list.length}',
        message: message.copyWith(createdAt: message.createdAt ?? _clock()),
      ),
    );
    _changes.add(bookingId);
  }

  @override
  Stream<List<ChatEntry>> watch(String bookingId) {
    late final StreamController<List<ChatEntry>> out;
    StreamSubscription<String>? sub;
    out = StreamController<List<ChatEntry>>(
      onListen: () {
        out.add(messagesOf(bookingId));
        sub = _changes.stream.where((b) => b == bookingId).listen((_) => out.add(messagesOf(bookingId)));
      },
      onCancel: () => sub?.cancel(),
    );
    return out.stream;
  }

  @override
  Future<void> send(String bookingId, {required String id, required ChatMessage message}) async {
    final list = _messages.putIfAbsent(bookingId, () => []);
    if (list.any((e) => e.id == id)) return; // already there: a retry of a send that worked
    final entry = ChatEntry(
      id: id,
      message: message.copyWith(createdAt: _clock()),
      pending: true,
    );
    list.add(entry);
    _changes.add(bookingId);
    await holdSends?.future;
    if (failNext > 0) {
      failNext--;
      list.remove(entry); // the server refused it, like Firestore dropping a rejected write
      _changes.add(bookingId);
      throw Exception('send failed');
    }
    list[list.indexOf(entry)] = ChatEntry(id: id, message: entry.message);
    _changes.add(bookingId);
  }
}

/// Photos kept in memory until #92.
class InMemoryChatPhotoStore implements ChatPhotoStore {
  final _files = <String, Uint8List>{};

  /// How many of the next uploads fail (no network, too large…).
  int failNext = 0;

  Iterable<String> get paths => _files.keys;

  @override
  Future<String> upload(String bookingId, {required String fileName, required Uint8List bytes}) async {
    if (failNext > 0) {
      failNext--;
      throw Exception('upload failed');
    }
    final path = 'bookings/$bookingId/chat/$fileName';
    if (_files.containsKey(path)) throw StateError('write-once: $path exists');
    _files[path] = bytes;
    return path;
  }

  @override
  Future<Uint8List> download(String path) async => _files[path] ?? (throw StateError('no photo at $path'));
}
