// #134: U14 Rate & review and the review repositories.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/app/router.dart';
import 'package:customer_app/features/booking/application/estimate.dart';
import 'package:customer_app/features/booking/data/booking_repository.dart';
import 'package:customer_app/features/booking/data/booking_service.dart';
import 'package:customer_app/features/booking/data/review_repository.dart';
import 'package:customer_app/features/booking/presentation/review_screen.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
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

const id = RoadsideFakes.bookingId;

/// The key set `firestore.rules` (#99) accepts for reviews/{bookingId}.
const rulesKeys = {'customerId', 'mechanicId', 'stars', 'tags', 'comment', 'createdAt'};

Booking completed({PaymentStatus payment = PaymentStatus.confirmed}) => RoadsideFakes.booking(
  status: BookingStatus.completed,
  paymentStatus: payment,
).copyWith(customerId: FakeBookingService.customerId);

void main() {
  // fake_cloud_firestore swaps in its FieldValue factory when constructed; do that before any
  // FieldValue is made, or later fake writes reject the platform one.
  setUpAll(FakeFirebaseFirestore.new);

  group('reviewFields', () {
    test('exactly the rules keys, createdAt from the server', () {
      final f = reviewFields(
        customerId: 'c',
        mechanicId: 'm',
        review: const ReviewDraft(stars: 4, tags: ['on_time']),
      );
      expect(f.keys.toSet(), rulesKeys);
      expect(f['createdAt'], isA<FieldValue>());
      expect(f['stars'], 4);
    });

    test('clamps stars, trims and caps the comment, caps tags at 10', () {
      final f = reviewFields(
        customerId: 'c',
        mechanicId: 'm',
        review: ReviewDraft(stars: 9, tags: List.generate(15, (i) => 't$i'), comment: '  ${'x' * 600}  '),
      );
      expect(f['stars'], 5);
      expect((f['tags']! as List).length, 10);
      expect((f['comment']! as String).length, 500);
      expect(reviewFields(customerId: 'c', mechanicId: 'm', review: const ReviewDraft(stars: 0))['stars'], 1);
    });
  });

  group('FirestoreReviewRepository', () {
    test('writes the rules-shaped doc at reviews/{bookingId}; exists afterwards', () async {
      final db = FakeFirebaseFirestore();
      final repo = FirestoreReviewRepository(RoadsideRefs(db));
      expect(await repo.exists(id), isFalse);
      await repo.submit(
        bookingId: id,
        customerId: 'c',
        mechanicId: 'm',
        review: const ReviewDraft(stars: 5, comment: ' Great '),
      );
      final doc = await db.doc('reviews/$id').get();
      expect(doc.data()!.keys.toSet(), rulesKeys);
      expect(doc.data()!['comment'], 'Great');
      expect(await repo.exists(id), isTrue);
    });
  });

  group('InMemoryReviewRepository', () {
    test('one review per booking', () async {
      final repo = InMemoryReviewRepository();
      await repo.submit(bookingId: id, customerId: 'c', mechanicId: 'm', review: const ReviewDraft(stars: 3));
      await expectLater(
        repo.submit(bookingId: id, customerId: 'c', mechanicId: 'm', review: const ReviewDraft(stars: 5)),
        throwsA(isA<ReviewException>().having((e) => e.error, 'error', ReviewError.notAllowed)),
      );
      expect(repo.saved[id]!['stars'], 3);
    });
  });

  test('tags follow the stars', () {
    expect(ReviewTags.forStars(5), ReviewTags.good);
    expect(ReviewTags.forStars(4), ReviewTags.good);
    expect(ReviewTags.forStars(3), ReviewTags.bad);
    expect(ReviewTags.forStars(1), ReviewTags.bad);
  });

  group('U14 screen', () {
    late InMemoryBookingStore store;
    late InMemoryReviewRepository reviews;

    Future<ProviderContainer> open(
      WidgetTester tester, {
      String language = 'en',
      bool viaPayment = false,
    }) async {
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
            reviewRepositoryProvider.overrideWithValue(reviews),
            laneBatterySourceProvider.overrideWithValue(_NoBattery()),
            laneClockProvider.overrideWithValue(() => RoadsideFakes.now),
          ],
          child: const RoadsideApp(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      final c = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
      c.read(routerProvider).go(viaPayment ? AppRoutes.booking(id) : AppRoutes.review(id));
      await tester.pumpAndSettle();
      return c;
    }

    void tall(WidgetTester tester) {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    LaneButton send(WidgetTester tester) =>
        tester.widget<LaneButton>(find.widgetWithText(LaneButton, 'Send review'));

    setUp(() {
      store = InMemoryBookingStore();
      reviews = InMemoryReviewRepository();
    });

    testWidgets('payment confirmed → Rate → U14', (tester) async {
      tall(tester);
      store.put(id, completed());
      await open(tester, viaPayment: true);
      await tester.tap(find.text('Rate Kiran Patel'));
      await tester.pumpAndSettle();
      expect(find.byType(ReviewScreen), findsOneWidget);
      expect(find.text('How was Kiran Patel?'), findsOneWidget);
    });

    testWidgets('Send stays off until a star is picked; tags switch with the rating', (tester) async {
      tall(tester);
      store.put(id, completed());
      await open(tester);
      expect(send(tester).onPressed, isNull);
      expect(find.byType(LaneChip), findsNothing);

      await tester.tap(find.byKey(const ValueKey('star-5')));
      await tester.pumpAndSettle();
      expect(send(tester).onPressed, isNotNull);
      expect(find.text('What went well?'), findsOneWidget);
      await tester.tap(find.text('On time'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('star-2')));
      await tester.pumpAndSettle();
      expect(find.text('What went wrong?'), findsOneWidget);
      expect(find.text('On time'), findsNothing);
      await tester.tap(find.text('Came late'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '  Waited an hour  ');
      await tester.tap(find.text('Send review'));
      await tester.pumpAndSettle();

      final saved = reviews.saved[id]!;
      expect(saved['stars'], 2);
      expect(saved['tags'], ['late'], reason: 'the on_time tag was dropped when the rating fell');
      expect(saved['comment'], 'Waited an hour');
      expect(saved['customerId'], FakeBookingService.customerId);
      expect(saved['mechanicId'], completed().mechanicId);
      expect(find.text('Thanks for your review!'), findsOneWidget);
      await tester.pump(LaneToast.visibleFor);
    });

    testWidgets('already reviewed: says so, no form', (tester) async {
      tall(tester);
      store.put(id, completed());
      await reviews.submit(
        bookingId: id,
        customerId: 'c',
        mechanicId: 'm',
        review: const ReviewDraft(stars: 4),
      );
      await open(tester);
      expect(find.text('You have rated this booking. Thank you!'), findsOneWidget);
      expect(find.byType(StarRating), findsNothing);
    });

    testWidgets('not completed yet: cannot be reviewed', (tester) async {
      tall(tester);
      store.put(
        id,
        RoadsideFakes.booking(status: BookingStatus.arriving)
            .copyWith(customerId: FakeBookingService.customerId),
      );
      await open(tester);
      expect(find.text('This booking can’t be reviewed.'), findsOneWidget);
    });

    testWidgets('a failed send keeps the form so it can be sent again', (tester) async {
      tall(tester);
      store.put(id, completed());
      reviews.failNext = ReviewError.failed;
      await open(tester);
      await tester.tap(find.byKey(const ValueKey('star-4')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send review'));
      await tester.pumpAndSettle();
      expect(find.textContaining("Couldn't send your review"), findsOneWidget);
      expect(find.byType(ReviewScreen), findsOneWidget);
      await tester.pump(LaneToast.visibleFor);
      await tester.tap(find.text('Send review'));
      await tester.pumpAndSettle();
      expect(reviews.saved[id]!['stars'], 4);
      await tester.pump(LaneToast.visibleFor);
    });

    testWidgets('fits at 320 px, 200% text, Hindi', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      store.put(id, completed());
      await open(tester, language: 'hi');
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('star-5')),
        100,
        scrollable: find.descendant(of: find.byType(ReviewScreen), matching: find.byType(Scrollable)).first,
      );
      await tester.tap(find.byKey(const ValueKey('star-5')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
