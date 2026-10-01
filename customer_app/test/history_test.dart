// #18: U15 Booking history and U16 Booking detail.
import 'dart:async';

import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/app/router.dart';
import 'package:customer_app/features/booking/application/estimate.dart';
import 'package:customer_app/features/booking/data/booking_repository.dart';
import 'package:customer_app/features/booking/data/booking_service.dart';
import 'package:customer_app/features/booking/presentation/live_booking_screen.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
import 'package:customer_app/features/help/presentation/help_screen.dart';
import 'package:customer_app/features/history/presentation/booking_detail_screen.dart';
import 'package:customer_app/features/history/presentation/history_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:roadside_core/fakes.dart';
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;
import 'package:shared_preferences/shared_preferences.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

const me = FakeBookingService.customerId;

/// RoadsideFakes' booking at [status], owned by the fake customer, created [ago] before now.
Booking mine(BookingStatus status, {Duration ago = Duration.zero, PaymentStatus? payment}) {
  final b = RoadsideFakes.booking(status: status, paymentStatus: payment);
  return b.copyWith(customerId: me, createdAt: b.createdAt!.subtract(ago));
}

String hm(DateTime t) => DateFormat.Hm('en').format(t.toLocal());

Future<void> flush() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> settle(WidgetTester tester, {int frames = 6}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

void main() {
  setUpAll(FakeFirebaseFirestore.new);

  test('railStop: where the booking is, or the last stop reached before it ended', () {
    expect(railStop(RoadsideFakes.booking(status: BookingStatus.completed)), 5);
    expect(railStop(RoadsideFakes.booking(status: BookingStatus.arrived)), 3);
    expect(railStop(RoadsideFakes.booking(status: BookingStatus.cancelled)), 2, reason: 'on the way');
    expect(railStop(RoadsideFakes.booking(status: BookingStatus.noMechanicFound)), 0);
  });

  group('watchHistory', () {
    test('Firestore: only mine, newest first, capped', () async {
      final db = FakeFirebaseFirestore();
      final refs = RoadsideRefs(db);
      await refs.booking('old').set(mine(BookingStatus.completed, ago: const Duration(days: 3)));
      await refs.booking('new').set(mine(BookingStatus.cancelled));
      await refs.booking('theirs').set(RoadsideFakes.booking(status: BookingStatus.completed));
      final list = await FirestoreBookingRepository(refs).watchHistory(me).first;
      expect(list.map((e) => e.id), ['new', 'old']);
      expect(list.first.booking.status, BookingStatus.cancelled);
      expect(list.first.booking.createdAt, isA<DateTime>());
    });

    test('in memory: follows changes; newest first', () async {
      final store = InMemoryBookingStore()
        ..put('a', mine(BookingStatus.completed, ago: const Duration(days: 1)))
        ..put('b', mine(BookingStatus.requested));
      final seen = <List<String>>[];
      final sub = store.watchHistory(me).listen((l) => seen.add([for (final e in l) e.id]));
      await flush();
      store.put('c', mine(BookingStatus.cancelled, ago: const Duration(days: 2)));
      await flush();
      await sub.cancel();
      expect(seen, [
        ['b', 'a'],
        ['b', 'a', 'c'],
      ]);
    });
  });

  group('U15 / U16', () {
    late InMemoryBookingStore store;
    ProviderContainer? live;

    /// Disposes the container inside the test (its ambient timer must be gone before the
    /// binding checks for pending timers).
    void screenTest(String description, Future<void> Function(WidgetTester tester) body) =>
        testWidgets(description, (tester) async {
          await body(tester);
          await tester.pumpWidget(const SizedBox.shrink());
          live?.dispose();
          live = null;
        });

    Future<ProviderContainer> open(
      WidgetTester tester, {
      String at = AppRoutes.history,
      String language = 'en',
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
      final c = createAppContainer(
        overrides: [
          flavorProvider.overrideWithValue(AppFlavor.dev),
          sharedPreferencesProvider.overrideWithValue(prefs),
          bookingStoreProvider.overrideWithValue(store),
          historyClockProvider.overrideWithValue(() => RoadsideFakes.now),
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => RoadsideFakes.now),
        ],
      );
      live = c;
      await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const RoadsideApp()));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      unawaited(c.read(routerProvider).push(at));
      await settle(tester);
      return c;
    }

    setUp(() {
      store = InMemoryBookingStore()
        ..put('done', mine(BookingStatus.completed, payment: PaymentStatus.confirmed))
        ..put('going', mine(BookingStatus.arriving, ago: const Duration(minutes: -5)))
        ..put('cancelled', mine(BookingStatus.cancelled, ago: const Duration(days: 1)))
        ..put('none', mine(BookingStatus.noMechanicFound, ago: const Duration(days: 20)))
        ..put('theirs', RoadsideFakes.booking(status: BookingStatus.completed));
    });

    screenTest('U15: newest first, each with its day, amount and badge; filters', (tester) async {
      await open(tester);
      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Flat tyre · Swift'), findsNWidgets(4));
      final details = tester.widgetList<Text>(find.textContaining(RegExp(r'^(Today|Yesterday|\d+ \w+)')));
      expect(details.map((t) => t.data), ['Today', 'Today · ₹450', 'Yesterday', '9 Sep']);
      expect(tester.widgetList<SignalBadge>(find.byType(SignalBadge)).map((b) => (b.label, b.signal)), [
        ('On the way', LaneSignal.route),
        ('Done', LaneSignal.go),
        ('Cancelled', LaneSignal.neutral),
        ('No mechanic', LaneSignal.neutral),
      ], reason: "someone else's booking isn't listed; cancelled is grey, not red");

      await tester.tap(find.text('Active'));
      await settle(tester);
      expect(find.byType(SignalBadge), findsOneWidget);
      await tester.tap(find.text('Past'));
      await settle(tester);
      expect(find.byType(SignalBadge), findsNWidgets(3));
    });

    screenTest('U15: an active booking opens its live screen', (tester) async {
      await open(tester);
      await tester.tap(find.text('On the way'));
      await settle(tester);
      expect(find.byType(LiveBookingScreen), findsOneWidget);
    });

    screenTest('U15: empty, then an empty filter offers "Show all"', (tester) async {
      store = InMemoryBookingStore();
      await open(tester);
      expect(find.text('No bookings yet'), findsOneWidget);
      expect(find.text('Active'), findsNothing, reason: 'no filters on an empty list');

      store.put('done', mine(BookingStatus.completed));
      await settle(tester);
      await tester.tap(find.text('Active'));
      await settle(tester);
      expect(find.text('Nothing going on right now'), findsOneWidget);
      await tester.tap(find.text('Show all'));
      await settle(tester);
      expect(find.byType(SignalBadge), findsOneWidget);
    });

    screenTest('U15: a load error offers a retry', (tester) async {
      store.failHistory = Exception('offline');
      await open(tester);
      expect(find.text("Couldn't load your bookings. Check your connection."), findsOneWidget);
      store.failHistory = null;
      await tester.tap(find.text('Try again'));
      await settle(tester);
      expect(find.byType(SignalBadge), findsNWidgets(4));
    });

    screenTest('U16 (done): rail with every time, and the receipt', (tester) async {
      final b = store['done']!;
      await open(tester);
      await tester.tap(find.text('Today · ₹450'));
      await settle(tester);
      expect(find.byType(BookingDetailScreen), findsOneWidget);
      expect(find.text('Flat tyre · Swift'), findsOneWidget);
      expect(find.byType(PlateChip), findsOneWidget);
      final rail = tester.widget<JourneyRail>(find.byType(JourneyRail));
      expect(rail.direction, Axis.vertical);
      expect(rail.current, 5);
      expect(rail.ended, isFalse);
      expect(rail.stops.map((s) => s.time), [
        hm(b.timestamps.requested!),
        hm(b.timestamps.accepted!),
        hm(b.timestamps.arriving!),
        hm(b.timestamps.arrived!),
        hm(b.timestamps.started!),
        hm(b.timestamps.completed!),
      ]);
      expect(find.text(b.mechanicCard!.name), findsOneWidget);
      expect(find.text('₹450'), findsOneWidget);
      expect(find.text('UPI to ${b.mechanicCard!.upiName}'), findsOneWidget);
      expect(find.text('Paid, confirmed by the mechanic'), findsOneWidget);

      await tester.tap(find.text('REPORT AN ISSUE'));
      await settle(tester);
      expect(find.byType(HelpScreen), findsOneWidget);
    });

    screenTest('U16 (cancelled): a grey rail up to where it stopped, who cancelled, nothing to pay', (
      tester,
    ) async {
      final b = store['cancelled']!;
      await open(tester, at: AppRoutes.bookingDetail('cancelled'));
      final rail = tester.widget<JourneyRail>(find.byType(JourneyRail));
      expect(rail.ended, isTrue);
      expect(rail.current, 2);
      expect(rail.stops.map((s) => s.time).whereType<String>(), hasLength(3));
      expect(find.text('You cancelled at ${hm(b.timestamps.cancelled!)}.'), findsOneWidget);
      expect(find.text('Nothing to pay'), findsOneWidget);
      expect(find.text('₹450'), findsNothing);
    });

    screenTest('U16 (no mechanic): says so, nothing charged', (tester) async {
      await open(tester, at: AppRoutes.bookingDetail('none'));
      expect(find.text('No mechanic was free nearby. Nothing was charged.'), findsOneWidget);
      expect(find.text('Nothing to pay'), findsOneWidget);
    });

    screenTest("U16: a booking that isn't there (or isn't mine) says so", (tester) async {
      await open(tester, at: AppRoutes.bookingDetail('missing'));
      expect(find.text("This booking isn't available."), findsOneWidget);
      await tester.tap(find.text('Back to bookings'));
      await settle(tester);
      expect(find.byType(BookingDetailScreen), findsNothing);
    });

    for (final language in ['hi', 'gu']) {
      screenTest('fits at 320 px, 200% text, in $language', (tester) async {
        await open(tester, language: language, size: const Size(320, 800), textScale: 2);
        expect(tester.takeException(), isNull);
        final done = find.textContaining('₹450');
        await tester.ensureVisible(done);
        await settle(tester);
        await tester.tap(done);
        await settle(tester);
        expect(find.byType(BookingDetailScreen), findsOneWidget);
        await tester.scrollUntilVisible(find.text('₹450'), 100);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
