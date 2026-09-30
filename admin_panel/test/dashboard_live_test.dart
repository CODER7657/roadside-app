// A1 Dashboard + A3 Live bookings (#53). "Done when: admin sees the day-10 demo booking live."

import 'package:admin_panel/app/firebase_providers.dart';
import 'package:admin_panel/app/router.dart';
import 'package:admin_panel/features/bookings/data/bookings_repository.dart';
import 'package:admin_panel/features/dashboard/application/dashboard.dart';
import 'package:admin_panel/features/live/application/live_bookings.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart' hide JourneyStop;
import 'package:roadside_core/fakes.dart';
import 'package:roadside_core/roadside_core.dart';

import 'support.dart';

/// 29 Sep 2026, 10:30 IST.
final now = RoadsideFakes.now;

String idFor(BookingStatus s) => 'bk${s.index}${s.value.replaceAll('_', '')}'.padRight(8, 'x');

BookingEntry entry(BookingStatus s) => (id: idFor(s), booking: RoadsideFakes.booking(status: s));

Presence presence({required Duration ago, bool online = true, CityId city = CityId.ahmedabad}) =>
    RoadsideFakes.presence(isOnline: online).copyWith(updatedAt: now.subtract(ago), cityId: city);

class FakeBookingAdminApi implements BookingAdminApi {
  final calls = <String>[];

  @override
  Future<void> cancel(String bookingId, {required String reason}) async => calls.add('$bookingId: $reason');
}

void main() {
  group('IST days', () {
    test('a day starts at 00:00 IST, i.e. 18:30 UTC the day before', () {
      expect(
        istDayStart(DateTime.utc(2026, 9, 29, 20)),
        DateTime.utc(2026, 9, 29, 18, 30),
      ); // 30 Sep 01:30 IST
      expect(
        istDayStart(DateTime.utc(2026, 9, 29, 5)),
        DateTime.utc(2026, 9, 28, 18, 30),
      ); // 29 Sep 10:30 IST
    });
  });

  group('DashboardStats', () {
    test('counts, completion and median arrival', () {
      final day = [for (final s in BookingStatus.values) entry(s)];
      final stats = DashboardStats.from(
        day: day,
        online: [
          presence(ago: const Duration(seconds: 30)),
          presence(ago: const Duration(minutes: 5)),
        ],
        now: now,
      );
      expect(stats.bookings, 8);
      expect(stats.activeMechanics, 1); // the 5-minute-old presence is stale
      expect(stats.completionRate, closeTo(1 / 3, 1e-9)); // completed / (completed, cancelled, no mechanic)
      expect(stats.medianArrival, const Duration(minutes: 12)); // accepted +6 min → arrived +18 min
    });

    test('empty day: nothing to divide', () {
      final stats = DashboardStats.from(day: const [], online: const [], now: now);
      expect(stats.bookings, 0);
      expect(stats.completionRate, isNull);
      expect(stats.medianArrival, isNull);
    });

    test('median of an even count is the mean of the middle two', () {
      Booking arrivedAfter(int minutes) => RoadsideFakes.booking(status: BookingStatus.arrived).copyWith(
        timestamps: BookingTimestamps(
          accepted: now,
          arrived: now.add(Duration(minutes: minutes)),
        ),
      );
      final stats = DashboardStats.from(
        day: [
          for (final (i, m) in [10, 20, 30, 40].indexed) (id: 'b$i', booking: arrivedAfter(m)),
        ],
        online: const [],
        now: now,
      );
      expect(stats.medianArrival, const Duration(minutes: 25));
    });
  });

  group('screens', () {
    late FakeFirebaseFirestore db;
    late FakeBookingAdminApi api;

    Future<void> open(WidgetTester tester, String path) async {
      db = FakeFirebaseFirestore();
      for (final s in BookingStatus.values) {
        await db.doc('bookings/${idFor(s)}').set(RoadsideFakes.booking(status: s).toJson());
      }
      await db.doc('presence/m1').set(presence(ago: const Duration(seconds: 20)).toJson());
      await db
          .doc('presence/m2')
          .set(presence(ago: const Duration(seconds: 20), city: CityId.bharuch).toJson());
      await db.doc('presence/m3').set(presence(ago: const Duration(minutes: 9)).toJson()); // stale
      for (final MapEntry(:key, :value) in RoadsideFakes.serviceAreas.entries) {
        await db.doc('serviceAreas/${key.value}').set(value.toJson());
      }
      api = FakeBookingAdminApi();
      await pumpPanel(
        tester,
        overrides: [
          firestoreProvider.overrideWithValue(db),
          bookingAdminApiProvider.overrideWithValue(api),
          laneClockProvider.overrideWithValue(() => now),
        ],
      );
      auth.emit(admin);
      await settle(tester);
      container.read(routerProvider).go(path);
      await settle(tester);
    }

    Future<void> tap(WidgetTester tester, Finder f) async {
      await tester.ensureVisible(f.first);
      await tester.tap(f.first);
      await settle(tester);
    }

    Finder statValue(String label) => find.bySemanticsLabel(RegExp('^$label: '));

    testPanel('A1: today\'s stats and bookings', (tester) async {
      await open(tester, '/dashboard');
      expect(find.textContaining('Today, '), findsOneWidget);
      expect(statValue('Bookings'), findsOneWidget);
      expect(find.bySemanticsLabel('Bookings: 8'), findsOneWidget);
      expect(find.bySemanticsLabel('Mechanics online: 2'), findsOneWidget);
      expect(find.bySemanticsLabel('Completion: 33%'), findsOneWidget);
      expect(find.bySemanticsLabel('Median arrival: 12 min'), findsOneWidget);
      expect(find.bySemanticsLabel('SMS success: —'), findsOneWidget);
      expect(find.text('Kiran Patel'), findsWidgets); // mechanic column
      expect(find.text('₹450'), findsOneWidget); // completed booking's amount
    });

    testPanel('A1: the city filter applies to stats and table', (tester) async {
      await open(tester, '/dashboard');
      await tap(tester, find.text('Bharuch'));
      expect(find.bySemanticsLabel('Bookings: 0'), findsOneWidget);
      expect(find.bySemanticsLabel('Mechanics online: 1'), findsOneWidget);
      expect(find.text('No bookings this day.'), findsOneWidget);
    });

    testPanel('A1: previous day, and no going past today', (tester) async {
      await open(tester, '/dashboard');
      final day = container.read(dashboardDayProvider);
      await tap(tester, find.bySemanticsLabel('Next day'));
      expect(container.read(dashboardDayProvider), day);
      await tap(tester, find.bySemanticsLabel('Previous day'));
      expect(container.read(dashboardDayProvider), day.subtract(const Duration(days: 1)));
      expect(find.bySemanticsLabel('Bookings: 0'), findsOneWidget);
    });

    testPanel('A3: only active bookings, with the selected one\'s rail', (tester) async {
      await open(tester, '/live');
      expect(container.read(liveBookingsProvider).value, hasLength(kActiveStatuses.length));
      expect(find.bySemanticsLabel(RegExp('Map with 5 active bookings')), findsOneWidget);
      expect(find.text('Cancelled'), findsNothing);

      await tap(tester, find.text('On the way'));
      expect(container.read(liveBookingsProvider).value!.single.booking.status, BookingStatus.arriving);
      expect(tester.widget<PlateChip>(find.byType(PlateChip)).regNo, 'GJ01AB1234'); // plate in the detail
      expect(find.byType(JourneyRail), findsOneWidget);
      expect(find.textContaining('Mechanic: Kiran Patel'), findsOneWidget);
    });

    testPanel('A3: admin cancel needs a reason', (tester) async {
      await open(tester, '/live');
      await tap(tester, find.text('On the way'));
      await tap(tester, find.bySemanticsLabel('Cancel as admin'));
      await tap(tester, find.bySemanticsLabel('Cancel booking'));
      expect(api.calls, isEmpty);
      await tester.enterText(
        find.descendant(
          of: find.byWidgetPredicate((w) => w is LaneTextField && w.label == 'Why are you cancelling?'),
          matching: find.byType(EditableText),
        ),
        'Customer asked by phone',
      );
      await settle(tester);
      await tap(tester, find.bySemanticsLabel('Cancel booking'));
      expect(api.calls, ['${idFor(BookingStatus.arriving)}: Customer asked by phone']);
      expect(find.text('Booking cancelled.'), findsOneWidget);
    });

    testPanel('A3: no admin cancel once the job has started (PLAN §9)', (tester) async {
      await open(tester, '/live');
      await tap(tester, find.text('Working'));
      expect(find.bySemanticsLabel('Cancel as admin'), findsNothing);
    });

    testPanel('A3: a new booking appears live', (tester) async {
      await open(tester, '/live');
      await db
          .doc('bookings/demo0001')
          .set(
            RoadsideFakes.booking(status: BookingStatus.requested).copyWith(cityId: CityId.bharuch).toJson(),
          );
      await settle(tester);
      expect(container.read(liveBookingsProvider).value, hasLength(kActiveStatuses.length + 1));
      await tap(tester, find.text('Bharuch'));
      expect(container.read(liveBookingsProvider).value!.single.id, 'demo0001');
    });
  });
}
