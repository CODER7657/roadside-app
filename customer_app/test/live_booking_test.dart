// #125: U8 Searching, U9 Assigned, cancel, no mechanic found, and the booking store.
import 'dart:async';

import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/app/router.dart';
import 'package:customer_app/features/booking/application/booking_draft.dart';
import 'package:customer_app/features/booking/application/estimate.dart';
import 'package:customer_app/features/booking/data/booking_repository.dart';
import 'package:customer_app/features/booking/data/booking_service.dart';
import 'package:customer_app/features/booking/presentation/live_booking_screen.dart';
import 'package:customer_app/features/booking/presentation/price_screen.dart';
import 'package:customer_app/features/booking/presentation/problem_screen.dart';
import 'package:customer_app/features/booking/presentation/tracking_view.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
import 'package:customer_app/features/help/presentation/help_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:roadside_core/fakes.dart';
import 'package:roadside_core/roadside_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

const id = RoadsideFakes.bookingId;

/// The customer's booking from RoadsideFakes, owned by the fake service's customer.
Booking bookingAt(BookingStatus status, {bool independent = true, Actor? cancelledBy}) {
  final b = RoadsideFakes.booking(status: status, independent: independent);
  return b.copyWith(customerId: FakeBookingService.customerId, cancelledBy: cancelledBy ?? b.cancelledBy);
}

/// Records cancel calls; the answer is scripted.
class CancelRecorder implements BookingService {
  CancelRecorder(this.store);

  final InMemoryBookingStore store;
  final calls = <(String, CancelReason)>[];
  FutureOr<void> Function()? answer;

  @override
  Future<CreatedBooking> createBooking(BookingDraft draft) => throw UnimplementedError();

  @override
  Future<void> markPaid(String bookingId) => throw UnimplementedError();

  @override
  Future<void> disputePayment(String bookingId, String text) => throw UnimplementedError();

  @override
  Future<void> cancelBooking(String bookingId, CancelReason reason) async {
    calls.add((bookingId, reason));
    final a = answer;
    if (a != null) return a();
    final b = store[bookingId]!;
    store.put(
      bookingId,
      b.copyWith(status: BookingStatus.cancelled, cancelledBy: Actor.customer, cancelReason: reason),
    );
  }
}

void main() {
  group('InMemoryBookingStore', () {
    test('watch gives the current booking, then every change; other ids stay quiet', () async {
      final store = InMemoryBookingStore();
      final seen = <BookingStatus?>[];
      final sub = store.watch(id).listen((b) => seen.add(b?.status));
      await pumpEventQueue();
      store.put(id, bookingAt(BookingStatus.requested));
      store.put('other', bookingAt(BookingStatus.accepted));
      store.put(id, bookingAt(BookingStatus.accepted));
      store.remove(id);
      await pumpEventQueue();
      expect(seen, [null, BookingStatus.requested, BookingStatus.accepted, null]);
      await sub.cancel();
    });
  });

  group('FakeBookingService.cancelBooking follows §9 for the customer', () {
    late InMemoryBookingStore store;
    late FakeBookingService service;
    setUp(() {
      store = InMemoryBookingStore();
      service = FakeBookingService(InMemoryPriceCatalog(), (_) async => null, store: store);
    });

    for (final s in [
      BookingStatus.requested,
      BookingStatus.accepted,
      BookingStatus.arriving,
      BookingStatus.arrived,
    ]) {
      test('$s → cancelled with the reason', () async {
        store.put(id, bookingAt(s));
        await service.cancelBooking(id, const CancelReason(code: 'too_slow'));
        expect(store[id]!.status, BookingStatus.cancelled);
        expect(store[id]!.cancelReason?.code, 'too_slow');
        expect(store[id]!.cancelledBy, Actor.customer);
      });
    }

    for (final s in [
      BookingStatus.inProgress,
      BookingStatus.completed,
      BookingStatus.cancelled,
      BookingStatus.noMechanicFound,
    ]) {
      test('$s can\'t be cancelled', () async {
        store.put(id, bookingAt(s));
        await expectLater(
          service.cancelBooking(id, const CancelReason(code: 'too_slow')),
          throwsA(isA<BookingException>().having((e) => e.code, 'code', BookingException.invalidStatus)),
        );
      });
    }

    test("someone else's booking looks missing", () async {
      store.put(id, RoadsideFakes.booking(status: BookingStatus.requested));
      await expectLater(
        service.cancelBooking(id, const CancelReason(code: 'too_slow')),
        throwsA(isA<BookingException>().having((e) => e.code, 'code', BookingException.bookingNotFound)),
      );
    });
  });

  group('screens', () {
    late InMemoryBookingStore store;
    late CancelRecorder service;
    late ProviderContainer container;

    Future<void> open(WidgetTester tester, {String language = 'en', String bookingId = id}) async {
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
            bookingServiceProvider.overrideWithValue(service),
            laneBatterySourceProvider.overrideWithValue(_NoBattery()),
            laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 29, 6, 30)),
          ],
          child: const RoadsideApp(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
      container.read(routerProvider).go(AppRoutes.booking(bookingId));
      await pumpAWhile(tester);
      expect(find.byType(LiveBookingScreen), findsOneWidget);
    }

    void tall(WidgetTester tester) {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    setUp(() {
      store = InMemoryBookingStore();
      service = CancelRecorder(store);
    });

    testWidgets('U8 shows the real search radius and a Cancel', (tester) async {
      tall(tester);
      store.put(id, bookingAt(BookingStatus.requested).copyWith(searchRadiusKm: 5));
      await open(tester);
      expect(find.text('Finding a mechanic'), findsOneWidget);
      expect(find.text("We're asking mechanics within 5 km of you."), findsOneWidget);
      expect(find.byType(BreathingPulse), findsOneWidget);
      expect(find.text('Cancel booking'), findsOneWidget);
    });

    testWidgets('cancel needs a reason; keep does nothing; confirm cancels with the reason', (tester) async {
      tall(tester);
      store.put(id, bookingAt(BookingStatus.requested));
      await open(tester);

      await tester.tap(find.text('Cancel booking'));
      await pumpAWhile(tester);
      expect(find.text('Cancel this booking?'), findsOneWidget);
      expect(find.text('We stop looking for a mechanic straight away.'), findsOneWidget);
      await tester.tap(find.text('Keep booking'));
      await pumpAWhile(tester);
      expect(service.calls, isEmpty);

      await tester.tap(find.text('Cancel booking'));
      await pumpAWhile(tester);
      final confirm = find.widgetWithText(LaneButton, 'Cancel booking').last;
      expect(tester.widget<LaneButton>(confirm).onPressed, isNull, reason: 'no reason picked yet');
      await tester.tap(find.text('Something else'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), '  Car started  ');
      await tester.tap(confirm);
      await pumpAWhile(tester);

      expect(service.calls.single.$1, id);
      expect(service.calls.single.$2, const CancelReason(code: 'other', text: 'Car started'));
      expect(find.text('Booking cancelled'), findsOneWidget);
      expect(find.text('You cancelled this booking.'), findsOneWidget);
    });

    testWidgets('a mechanic accepting while watching: U9 with the pass, code and a haptic', (tester) async {
      tall(tester);
      final haptics = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') haptics.add('${call.arguments}');
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      store.put(id, bookingAt(BookingStatus.requested));
      await open(tester);
      expect(haptics, isEmpty);

      store.put(id, bookingAt(BookingStatus.accepted), otp: RoadsideFakes.otp);
      await pumpAWhile(tester);
      expect(haptics, isNotEmpty);
      expect(find.text('A mechanic is coming'), findsOneWidget);
      expect(find.byType(TrustPass), findsOneWidget);
      expect(find.bySemanticsLabel('4 8 2 1'), findsOneWidget, reason: 'the start code from private/otp');
      expect(find.textContaining('Verified independent mechanic'), findsOneWidget);
      expect(find.bySemanticsLabel('Step 2 of 6: Accepted'), findsOneWidget);
      // Still cancellable before work starts, with the "mechanic is told" wording.
      await tester.tap(find.text('Cancel booking'));
      await pumpAWhile(tester);
      expect(find.text('Your mechanic is told straight away. Please pick a reason.'), findsOneWidget);
    });

    testWidgets('a workshop mechanic gets the workshop pass', (tester) async {
      tall(tester);
      store.put(id, bookingAt(BookingStatus.accepted, independent: false), otp: RoadsideFakes.otp);
      await open(tester);
      expect(find.text('Verified workshop'), findsOneWidget);
      expect(find.byType(PlateChip), findsNothing, reason: 'no travel vehicle for a workshop');
    });

    testWidgets('arriving and arrived hand over to U10 tracking', (tester) async {
      tall(tester);
      store.put(id, bookingAt(BookingStatus.arrived), otp: RoadsideFakes.otp);
      await open(tester);
      expect(find.byType(TrackingView), findsOneWidget);
      expect(find.text('Kiran Patel has arrived'), findsOneWidget);
      expect(find.bySemanticsLabel('Step 4 of 6: Arrived'), findsOneWidget);
    });

    testWidgets('cancel fails because work started meanwhile: says so, stays put', (tester) async {
      tall(tester);
      store.put(id, bookingAt(BookingStatus.arrived), otp: RoadsideFakes.otp);
      service.answer = () => throw const BookingException(BookingException.invalidStatus);
      await open(tester);
      await tester.tap(find.text('Cancel booking'));
      await pumpAWhile(tester);
      await tester.tap(find.text('Taking too long'));
      await tester.pump();
      await tester.tap(find.widgetWithText(LaneButton, 'Cancel booking').last);
      await pumpAWhile(tester);
      expect(find.text("It can't be cancelled now: the work has started."), findsOneWidget);
      expect(find.text('Kiran Patel has arrived'), findsOneWidget);
      await tester.pump(LaneToast.visibleFor);
    });

    testWidgets('no Cancel once work has started', (tester) async {
      tall(tester);
      store.put(id, bookingAt(BookingStatus.inProgress));
      await open(tester);
      expect(find.text('Kiran Patel is working on it'), findsOneWidget);
      expect(find.text('Cancel booking'), findsNothing);
    });

    testWidgets('no mechanic found: Try again books the same draft with a new key', (tester) async {
      tall(tester);
      final b = bookingAt(BookingStatus.noMechanicFound);
      store.put(id, b);
      await open(tester);
      // The draft that made this booking.
      container.read(bookingDraftProvider.notifier).state = BookingDraft(
        draftId: 'd1',
        idempotencyKey: b.idempotencyKey,
        vehicleId: 'v1',
        problem: ProblemType.flatTyre,
        pickup: const PickupDraft(lat: 23.05, lng: 72.51, address: 'Thaltej', accuracyMeters: 10),
      );
      expect(find.text('No mechanic free right now'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await pumpAWhile(tester);
      expect(find.byType(PriceScreen), findsOneWidget);
      final draft = container.read(bookingDraftProvider);
      expect(draft.idempotencyKey, isNot(b.idempotencyKey));
      expect(draft.pickup?.address, 'Thaltej', reason: 'everything else kept');
      expect(container.read(routerProvider).canPop(), isTrue, reason: 'back goes Home');
    });

    testWidgets('no mechanic found after a restart (no draft): starts over at U4', (tester) async {
      tall(tester);
      store.put(id, bookingAt(BookingStatus.noMechanicFound));
      await open(tester);
      await tester.tap(find.text('Try again'));
      await pumpAWhile(tester);
      expect(find.byType(ProblemScreen), findsOneWidget);
    });

    testWidgets('no mechanic found: talk to support', (tester) async {
      tall(tester);
      store.put(id, bookingAt(BookingStatus.noMechanicFound));
      await open(tester);
      await tester.tap(find.text('GET SUPPORT'));
      await pumpAWhile(tester);
      expect(find.byType(HelpScreen), findsOneWidget);
    });

    for (final (who, text) in [
      (Actor.mechanic, 'The mechanic had to cancel. You were not charged.'),
      (Actor.admin, 'Our support team cancelled this booking.'),
      (Actor.system, 'Our support team cancelled this booking.'),
    ]) {
      testWidgets('cancelled by $who says so', (tester) async {
        tall(tester);
        store.put(id, bookingAt(BookingStatus.cancelled, cancelledBy: who));
        await open(tester);
        expect(find.text(text), findsOneWidget);
      });
    }

    testWidgets("a booking that doesn't exist says so", (tester) async {
      tall(tester);
      await open(tester, bookingId: 'nope');
      expect(find.text("We couldn't find this booking."), findsOneWidget);
    });

    for (final status in [BookingStatus.requested, BookingStatus.accepted, BookingStatus.noMechanicFound]) {
      testWidgets('$status fits at 320 px, 200% text, Hindi', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        store.put(id, bookingAt(status), otp: RoadsideFakes.otp);
        await open(tester, language: 'hi');
        expect(tester.takeException(), isNull);
      });
    }
  });
}

/// Searching breathes forever, so pump a while instead of settling.
Future<void> pumpAWhile(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
