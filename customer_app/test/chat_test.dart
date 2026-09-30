// #127: U11 Chat: repository, outbox (send, fail, retry, photos) and the screen.
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/app/router.dart';
import 'package:customer_app/features/booking/application/booking_draft.dart';
import 'package:customer_app/features/booking/application/estimate.dart';
import 'package:customer_app/features/booking/data/booking_repository.dart';
import 'package:customer_app/features/booking/data/booking_service.dart';
import 'package:customer_app/features/booking/data/photo_pipeline.dart';
import 'package:customer_app/features/chat/application/chat.dart';
import 'package:customer_app/features/chat/data/chat_repository.dart';
import 'package:customer_app/features/chat/presentation/chat_screen.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
import 'package:customer_app/features/permissions/application/permission_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:roadside_core/fakes.dart';
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;
import 'package:shared_preferences/shared_preferences.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

class _Picker implements PhotoPicker {
  /// A real 1×1 PNG, so the photo bubble can decode it.
  Uint8List? next = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
  );
  final sources = <PhotoSource>[];

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    sources.add(source);
    return next;
  }
}

class _Permissions implements PermissionService {
  @override
  Future<PermissionAccess> status(AppPermission permission) async => PermissionAccess.granted;

  @override
  Future<PermissionAccess> request(AppPermission permission) async => PermissionAccess.granted;

  @override
  Future<bool> openSettings() async => true;
}

const id = RoadsideFakes.bookingId;
const me = FakeBookingService.customerId;
const mechanicId = 'mech-1';

/// The key set `firestore.rules` (#99) accepts for bookings/{id}/messages/{messageId}.
const rulesKeys = {'senderId', 'text', 'imagePath', 'createdAt'};

Booking booking(BookingStatus status) =>
    RoadsideFakes.booking(status: status).copyWith(customerId: me, mechanicId: mechanicId);

/// Lets stream events reach the providers (they take a few event-loop turns).
Future<void> flush() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  setUpAll(FakeFirebaseFirestore.new);

  group('FirestoreChatRepository', () {
    test('writes the rules-shaped message under the id the app chose; watch is oldest first', () async {
      final db = FakeFirebaseFirestore();
      final repo = FirestoreChatRepository(RoadsideRefs(db));
      await repo.send(
        id,
        id: 'm1',
        message: const ChatMessage(senderId: me, text: 'first'),
      );
      await repo.send(
        id,
        id: 'm2',
        message: const ChatMessage(senderId: me, text: '', imagePath: 'bookings/b/chat/x.jpg'),
      );
      final doc = await db.doc('bookings/$id/messages/m1').get();
      expect(doc.data()!.keys.toSet(), rulesKeys);
      expect(doc.data()!['createdAt'], isA<Timestamp>());
      final list = await repo.watch(id).first;
      expect([for (final e in list) e.id], ['m1', 'm2']);
      expect(list.last.message.imagePath, 'bookings/b/chat/x.jpg');
    });
  });

  group('outbox', () {
    late InMemoryChatRepository repo;
    late InMemoryChatPhotoStore photos;
    late _Picker picker;
    late ProviderContainer c;

    setUp(() {
      repo = InMemoryChatRepository(clock: () => RoadsideFakes.now);
      photos = InMemoryChatPhotoStore();
      picker = _Picker();
      c = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(repo),
          chatPhotoStoreProvider.overrideWithValue(photos),
          photoPickerProvider.overrideWithValue(picker),
          photoCompressorProvider.overrideWithValue(PhotoCompressor(encode: (b, q) async => b)),
          laneClockProvider.overrideWithValue(() => RoadsideFakes.now),
        ],
      );
      addTearDown(c.dispose);
      c.listen(chatLinesProvider(id), (_, _) {});
    });

    ChatOutbox outbox() => c.read(chatOutboxProvider(id).notifier);
    List<ChatLine> lines() => c.read(chatLinesProvider(id)).value ?? const [];

    test('text is trimmed and capped at 500 characters; blank is ignored', () async {
      await outbox().sendText('   ');
      await outbox().sendText('  hello  ');
      await outbox().sendText('x' * 600);
      final sent = repo.messagesOf(id);
      expect([for (final e in sent) e.message.text.length], [5, 500]);
      expect(sent.first.message.text, 'hello');
      expect(sent.first.message.senderId, me);
      expect(c.read(chatOutboxProvider(id)), isEmpty);
    });

    test('a failed send shows as failed, once; retry sends it once', () async {
      repo.failNext = 1;
      await outbox().sendText('lost');
      await flush();
      expect([for (final l in lines()) (l.text, l.delivery)], [('lost', ChatDelivery.failed)]);
      await outbox().retry(lines().single.id);
      await flush();
      expect([for (final l in lines()) (l.text, l.delivery)], [('lost', ChatDelivery.sent)]);
      expect(repo.messagesOf(id), hasLength(1));
    });

    test('while the server has it pending it reads Sending…, and is never shown twice', () async {
      repo.holdSends = Completer<void>();
      final sending = outbox().sendText('on its way');
      await flush();
      expect([for (final l in lines()) (l.text, l.delivery)], [('on its way', ChatDelivery.sending)]);
      repo.holdSends!.complete();
      await sending;
      await flush();
      expect([for (final l in lines()) (l.text, l.delivery)], [('on its way', ChatDelivery.sent)]);
    });

    test("the mechanic's messages are theirs; mine are mine", () async {
      repo.receive(id, const ChatMessage(senderId: mechanicId, text: 'coming'));
      await outbox().sendText('ok');
      await flush();
      expect([for (final l in lines()) (l.text, l.mine)], [('coming', false), ('ok', true)]);
    });

    test('a photo is uploaded under bookings/{id}/chat/ and sent as a path, never a URL', () async {
      expect(await outbox().sendPhoto(PhotoSource.gallery), isNull);
      final path = repo.messagesOf(id).single.message.imagePath!;
      expect(path, startsWith('bookings/$id/chat/'));
      expect(path, endsWith('.jpg'));
      expect(photos.paths, [path]);
    });

    test('photo upload fails → failed; retry uploads under a new name', () async {
      photos.failNext = 1;
      await outbox().sendPhoto(PhotoSource.gallery);
      await flush();
      expect(lines().single.delivery, ChatDelivery.failed);
      expect(lines().single.photo, isNotNull); // still shown from the local copy
      await outbox().retry(lines().single.id);
      expect(photos.paths, hasLength(1));
      expect(repo.messagesOf(id), hasLength(1));
    });

    test('upload worked but the send failed → retry only resends (write-once path)', () async {
      repo.failNext = 1;
      await outbox().sendPhoto(PhotoSource.gallery);
      await flush();
      expect(lines().single.delivery, ChatDelivery.failed);
      await outbox().retry(lines().single.id);
      expect(photos.paths, hasLength(1));
      expect(repo.messagesOf(id).single.message.imagePath, photos.paths.single);
    });

    test('a photo that cannot be made small enough is refused; cancelling the picker is fine', () async {
      c.updateOverrides([
        chatRepositoryProvider.overrideWithValue(repo),
        chatPhotoStoreProvider.overrideWithValue(photos),
        photoPickerProvider.overrideWithValue(picker),
        photoCompressorProvider.overrideWithValue(
          PhotoCompressor(encode: (b, q) async => Uint8List(PhotoLimits.maxBytes + 1)),
        ),
        laneClockProvider.overrideWithValue(() => RoadsideFakes.now),
      ]);
      expect(await outbox().sendPhoto(PhotoSource.gallery), ChatPhotoError.tooLarge);
      picker.next = null;
      expect(await outbox().sendPhoto(PhotoSource.gallery), isNull);
      expect(repo.messagesOf(id), isEmpty);
    });
  });

  group('U11 screen', () {
    late InMemoryBookingStore store;
    late InMemoryChatRepository chat;
    late InMemoryChatPhotoStore photos;
    late _Picker picker;

    Future<ProviderContainer> open(
      WidgetTester tester, {
      String language = 'en',
      String? route,
      Size size = const Size(400, 900),
      double textScale = 1,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      SharedPreferences.setMockInitialValues({
        'first_run.language': language,
        'first_run.onboarded': true,
        'first_run.consent_version': kConsentVersion,
        'first_run.consent_at': '2026-09-29T10:15:00.000Z',
      });
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flavorProvider.overrideWithValue(AppFlavor.dev),
            sharedPreferencesProvider.overrideWithValue(prefs),
            bookingStoreProvider.overrideWithValue(store),
            chatRepositoryProvider.overrideWithValue(chat),
            chatPhotoStoreProvider.overrideWithValue(photos),
            photoPickerProvider.overrideWithValue(picker),
            photoCompressorProvider.overrideWithValue(PhotoCompressor(encode: (b, q) async => b)),
            permissionServiceProvider.overrideWithValue(_Permissions()),
            laneBatterySourceProvider.overrideWithValue(_NoBattery()),
            laneClockProvider.overrideWithValue(() => RoadsideFakes.now),
          ],
          child: const RoadsideApp(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      final c = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
      c.read(routerProvider).go(route ?? AppRoutes.chat(id));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(); // the jump to the newest message happens after the first data frame
      return c;
    }

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    setUp(() {
      store = InMemoryBookingStore();
      chat = InMemoryChatRepository(clock: () => RoadsideFakes.now);
      photos = InMemoryChatPhotoStore();
      picker = _Picker();
    });

    testWidgets('U10 has Call and Chat side by side; Chat opens U11', (tester) async {
      store.put(id, booking(BookingStatus.arriving));
      await open(tester, route: AppRoutes.booking(id));
      await tester.ensureVisible(find.widgetWithText(LaneButton, 'CHAT'));
      await tester.pump();
      final callRect = tester.getRect(find.widgetWithText(LaneButton, 'CALL KIRAN PATEL'));
      final chatRect = tester.getRect(find.widgetWithText(LaneButton, 'CHAT'));
      expect((callRect.top - chatRect.top).abs(), lessThan(1));
      expect(chatRect.left, greaterThan(callRect.right));
      await tester.tap(find.widgetWithText(LaneButton, 'CHAT'));
      await settle(tester);
      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('U12 also offers Call and Chat', (tester) async {
      store.put(id, booking(BookingStatus.inProgress));
      await open(tester, route: AppRoutes.booking(id));
      expect(find.widgetWithText(LaneButton, 'CALL KIRAN PATEL'), findsOneWidget);
      expect(find.widgetWithText(LaneButton, 'CHAT'), findsOneWidget);
    });

    testWidgets('empty: who and where, and the next action is a call', (tester) async {
      store.put(id, booking(BookingStatus.arriving));
      await open(tester);
      expect(find.text('Kiran Patel'), findsOneWidget);
      expect(find.text('Kiran Patel is on the way'), findsOneWidget);
      expect(find.text('No messages yet'), findsOneWidget);
      expect(find.widgetWithText(LaneButton, 'Call Kiran Patel'), findsOneWidget);
    });

    testWidgets('type and send; the mechanic answers on the other side', (tester) async {
      store.put(id, booking(BookingStatus.arriving));
      await open(tester);
      await tester.enterText(find.byType(TextField), "  I'm by the white Swift  ");
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('chat-send')));
      await settle(tester);
      expect(chat.messagesOf(id).single.message.text, "I'm by the white Swift");
      expect(find.text("I'm by the white Swift"), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);

      chat.receive(id, const ChatMessage(senderId: mechanicId, text: 'Coming in 2 min'));
      await settle(tester);
      final theirs = tester.getRect(find.text('Coming in 2 min'));
      final mine = tester.getRect(find.text("I'm by the white Swift"));
      expect(theirs.left, lessThan(mine.left));
    });

    testWidgets('a failed send says so; tapping it sends it once', (tester) async {
      store.put(id, booking(BookingStatus.arriving));
      chat.failNext = 1;
      await open(tester);
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('chat-send')));
      await settle(tester);
      expect(find.text('Not sent. Tap to try again.'), findsOneWidget);
      await tester.tap(find.text('hello'));
      await settle(tester);
      expect(find.text('Not sent. Tap to try again.'), findsNothing);
      expect(chat.messagesOf(id), hasLength(1));
    });

    testWidgets('send a photo from the gallery: shown right away, stored as a path', (tester) async {
      store.put(id, booking(BookingStatus.arrived));
      await open(tester);
      await tester.tap(find.byTooltip('Add a photo'));
      await settle(tester);
      await tester.tap(find.text('CHOOSE FROM GALLERY'));
      await settle(tester);
      expect(picker.sources, [PhotoSource.gallery]);
      expect(find.byType(Image), findsOneWidget);
      expect(chat.messagesOf(id).single.message.imagePath, startsWith('bookings/$id/chat/'));
    });

    testWidgets('after the job the chat is read-only, with a note instead of the composer', (tester) async {
      store.put(id, booking(BookingStatus.completed));
      chat.receive(id, const ChatMessage(senderId: mechanicId, text: 'Thanks!'));
      await open(tester);
      expect(find.text('Thanks!'), findsOneWidget);
      expect(find.byType(ChatComposer), findsNothing);
      expect(find.text('This chat has closed. You can still read it for 30 days.'), findsWidgets);
    });

    testWidgets('fits at 320 px, 200% text, in Hindi', (tester) async {
      store.put(id, booking(BookingStatus.arriving));
      chat.receive(id, const ChatMessage(senderId: mechanicId, text: 'मैं 2 मिनट में पहुँच रहा हूँ।'));
      await open(tester, language: 'hi', size: const Size(320, 800), textScale: 2);
      expect(tester.takeException(), isNull);
      expect(find.text('मैं 2 मिनट में पहुँच रहा हूँ।'), findsOneWidget);
      expect(find.byType(ChatComposer), findsOneWidget);
    });
  });
}
