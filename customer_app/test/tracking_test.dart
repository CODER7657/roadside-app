// #126: U10 Live tracking, the marker glide and the tracking map.
import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/app/router.dart';
import 'package:customer_app/features/booking/application/estimate.dart';
import 'package:customer_app/features/booking/application/marker_glide.dart';
import 'package:customer_app/features/booking/data/booking_repository.dart';
import 'package:customer_app/features/booking/data/booking_service.dart';
import 'package:customer_app/features/booking/presentation/tracking_map.dart';
import 'package:customer_app/features/booking/presentation/tracking_view.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
import 'package:customer_app/features/help/presentation/help_screen.dart';
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
const a = (lat: 23.00, lng: 72.50);
const b = (lat: 23.01, lng: 72.52);

Booking bookingAt(BookingStatus status) =>
    RoadsideFakes.booking(status: status).copyWith(customerId: FakeBookingService.customerId);

LiveLocation reading(double lat, double lng, {double heading = 0, int eta = 6, DateTime? at}) => LiveLocation(
  mechanicGeopoint: GeoPoint(lat, lng),
  heading: heading,
  speed: 7,
  etaMinutes: eta,
  updatedAt: at ?? RoadsideFakes.now,
  expireAt: RoadsideFakes.now.add(const Duration(hours: 24)),
);

void main() {
  group('MarkerGlide', () {
    test('moves in a straight line and never past the reading', () {
      const g = MarkerGlide(from: a, to: b, fromHeading: 0, toHeading: 0);
      expect(g.positionAt(0), a);
      expect(g.positionAt(1), b);
      final mid = g.positionAt(0.5);
      expect(mid.lat, closeTo(23.005, 1e-9));
      expect(mid.lng, closeTo(72.51, 1e-9));
      expect(g.positionAt(1.7), b, reason: 'no extrapolation');
      expect(g.positionAt(-1), a);
    });

    test('turns the short way round, across north both ways', () {
      expect(shortestTurn(350, 10), 20);
      expect(shortestTurn(10, 350), -20);
      expect(shortestTurn(0, 180), 180);
      expect(shortestTurn(90, 90), 0);
      expect(shortestTurn(-30, 30), 60);
      const g = MarkerGlide(from: a, to: b, fromHeading: 350, toHeading: 10);
      expect(g.headingAt(0.5), closeTo(0, 1e-9));
      expect(g.headingAt(0.25), closeTo(355, 1e-9));
      expect(normalizeHeading(-90), 270);
      expect(normalizeHeading(720), 0);
    });

    test('a reading that arrives mid-glide continues from where the marker is drawn', () {
      const g = MarkerGlide(from: a, to: b, fromHeading: 0, toHeading: 90);
      final n = g.next(0.5, a, 180);
      expect(n.from, g.positionAt(0.5), reason: 'no jump back to the old reading');
      expect(n.fromHeading, closeTo(45, 1e-9));
      expect(n.to, a);
      expect(n.toHeading, 180);
    });
  });

  group('GridTrackingMap', () {
    test('metres from the pickup: east and north are positive', () {
      final east = GridTrackingMap.metresFrom(a, (lat: a.lat, lng: a.lng + 0.001));
      expect(east.dx, greaterThan(90));
      expect(east.dy, closeTo(0, 1e-6));
      final north = GridTrackingMap.metresFrom(a, (lat: a.lat + 0.001, lng: a.lng));
      expect(north.dy, closeTo(111.32, 0.01));
    });
  });

  group('U10 screen', () {
    late InMemoryBookingStore store;
    late List<Uri> launched;
    late bool launchOk;
    late DateTime clock;

    Future<ProviderContainer> open(WidgetTester tester, {String language = 'en'}) async {
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
            launchLinkProvider.overrideWithValue((uri) async {
              launched.add(uri);
              return launchOk;
            }),
            laneBatterySourceProvider.overrideWithValue(_NoBattery()),
            laneClockProvider.overrideWithValue(() => clock),
          ],
          child: const RoadsideApp(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
      container.read(routerProvider).go(AppRoutes.booking(id));
      await tester.pumpAndSettle();
      return container;
    }

    void tall(WidgetTester tester) {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    Offset markerAt(WidgetTester tester) => tester.getCenter(find.byKey(const ValueKey('mechanic-marker')));

    setUp(() {
      store = InMemoryBookingStore();
      launched = [];
      launchOk = true;
      clock = RoadsideFakes.now.add(const Duration(seconds: 5));
    });

    testWidgets('arriving: the map, rolling ETA, plate, Call and the start code', (tester) async {
      tall(tester);
      store.put(id, bookingAt(BookingStatus.arriving), otp: RoadsideFakes.otp);
      store.putLive(id, reading(23.0395, 72.5066, eta: 6));
      await open(tester);
      expect(find.byType(TrackingView), findsOneWidget);
      expect(find.text('Kiran Patel is on the way'), findsOneWidget);
      expect(tester.widget<LaneRollingNumber>(find.byType(LaneRollingNumber)).value, '6 min');
      expect(find.byType(PlateChip), findsOneWidget);
      expect(find.byKey(const ValueKey('mechanic-marker')), findsOneWidget);
      expect(find.bySemanticsLabel('4 8 2 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Step 3 of 6: On the way'), findsOneWidget);
      expect(find.text('Cancel booking'), findsOneWidget);

      await tester.ensureVisible(find.text('CALL KIRAN PATEL'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CALL KIRAN PATEL'));
      await tester.pump();
      expect(launched.single.scheme, 'tel');
      expect(launched.single.path, bookingAt(BookingStatus.arriving).mechanicCard!.phone);
    });

    testWidgets('the marker glides to a new reading over 5 s instead of jumping', (tester) async {
      tall(tester);
      store.put(id, bookingAt(BookingStatus.arriving));
      // ~110 m and ~45 m south of the pickup: close enough for the map's 1 px per metre.
      store.putLive(id, reading(23.0487, 72.5117));
      await open(tester);
      final start = markerAt(tester);

      store.putLive(id, reading(23.0493, 72.5117, eta: 5));
      // The reading lands, then the glide's first frame starts its clock.
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2500));
      final half = markerAt(tester);
      await tester.pump(const Duration(milliseconds: 2600));
      final end = markerAt(tester);
      expect(half.dy, lessThan(start.dy), reason: 'moving north');
      expect(half.dy, greaterThan(end.dy), reason: 'still on its way at half time');
      expect(tester.widget<LaneRollingNumber>(find.byType(LaneRollingNumber)).value, '5 min');
    });

    testWidgets('reduced motion: the marker jumps to each reading', (tester) async {
      tall(tester);
      store.put(id, bookingAt(BookingStatus.arriving));
      store.putLive(id, reading(23.0487, 72.5117));
      await open(tester);
      final c = ProviderScope.containerOf(tester.element(find.byType(TrackingView)));
      c.read(ambientControllerProvider.notifier).setManual(LaneMode.saver);
      await tester.pumpAndSettle();
      final before = markerAt(tester);
      store.putLive(id, reading(23.0493, 72.5117));
      await tester.pump();
      await tester.pump();
      final jumped = markerAt(tester);
      expect(jumped.dy, lessThan(before.dy), reason: 'already at the new reading');
      await tester.pump(const Duration(seconds: 5));
      expect(markerAt(tester), jumped);
    });

    testWidgets('no reading yet: says so, no ETA, no marker', (tester) async {
      tall(tester);
      store.put(id, bookingAt(BookingStatus.arriving));
      await open(tester);
      expect(find.text("Waiting for Kiran Patel's location…"), findsOneWidget);
      expect(find.byType(LaneRollingNumber), findsNothing);
      expect(find.byKey(const ValueKey('mechanic-marker')), findsNothing);
    });

    testWidgets('a stale reading is shown as stale, not as a live ETA', (tester) async {
      tall(tester);
      store.put(id, bookingAt(BookingStatus.arriving));
      store.putLive(id, reading(23.04, 72.51, at: RoadsideFakes.now));
      clock = RoadsideFakes.now.add(const Duration(minutes: 3));
      await open(tester);
      expect(find.text('Location last updated 3 min ago. It may be out of signal.'), findsOneWidget);
      expect(find.byType(LaneRollingNumber), findsNothing);
    });

    testWidgets('arrived: says so, hides the moving marker, keeps the code', (tester) async {
      tall(tester);
      store.put(id, bookingAt(BookingStatus.arrived), otp: RoadsideFakes.otp);
      store.putLive(id, reading(23.0497, 72.5117));
      await open(tester);
      expect(find.text('Kiran Patel has arrived'), findsOneWidget);
      expect(find.byKey(const ValueKey('mechanic-marker')), findsNothing);
      expect(find.bySemanticsLabel('4 8 2 1'), findsOneWidget);
    });

    testWidgets("the dialer doesn't open: a toast", (tester) async {
      tall(tester);
      launchOk = false;
      store.put(id, bookingAt(BookingStatus.arriving));
      await open(tester);
      await tester.ensureVisible(find.text('CALL KIRAN PATEL'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CALL KIRAN PATEL'));
      await tester.pump();
      expect(find.text("Couldn't open the phone app."), findsOneWidget);
      await tester.pump(LaneToast.visibleFor);
    });

    testWidgets('fits at 320 px, 200% text, Hindi', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      store.put(id, bookingAt(BookingStatus.arriving), otp: RoadsideFakes.otp);
      store.putLive(id, reading(23.04, 72.51));
      await open(tester, language: 'hi');
      expect(tester.takeException(), isNull);
    });
  });
}
