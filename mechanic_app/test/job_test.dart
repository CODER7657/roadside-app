// #30: M5 Navigate + foreground location service.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:mechanic_app/app/app.dart';
import 'package:mechanic_app/app/flavor.dart';
import 'package:mechanic_app/features/dashboard/application/online.dart';
import 'package:mechanic_app/features/dashboard/data/location_service.dart';
import 'package:mechanic_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:mechanic_app/features/first_run/application/first_run.dart';
import 'package:mechanic_app/features/help/presentation/help_screen.dart';
import 'package:mechanic_app/features/job/application/job.dart';
import 'package:mechanic_app/features/job/data/job_repository.dart';
import 'package:mechanic_app/features/job/presentation/job_screen.dart';
import 'package:mechanic_app/features/offers/application/offers.dart';
import 'package:mechanic_app/features/permissions/application/permission_service.dart';
import 'package:mechanic_app/features/permissions/presentation/permission_explainer_screen.dart';
import 'package:mechanic_app/features/registration/application/registration.dart';
import 'package:roadside_core/roadside_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

class FakeLocation implements LocationService {
  int? distance;
  Duration? interval;
  ForegroundTracking? foreground;
  StreamController<LocationFix>? _c;
  int streams = 0;

  bool get listening => _c != null && _c!.hasListener;

  void move(double lat, double lng) =>
      _c!.add(LocationFix(lat: lat, lng: lng, accuracyMeters: 5, heading: 90, speed: 6));

  /// The phone's location switch.
  bool gpsOn = true;

  @override
  Future<bool> serviceEnabled() async => gpsOn;

  @override
  Future<bool> openSettings() async => true;

  @override
  Stream<LocationFix> fixes({
    required int distanceFilterMeters,
    Duration? interval,
    ForegroundTracking? foreground,
  }) {
    distance = distanceFilterMeters;
    this.interval = interval;
    this.foreground = foreground;
    streams++;
    _c = StreamController<LocationFix>();
    return _c!.stream;
  }
}

/// Location permission as the phone has it; asking grants it.
class FakePermissions implements PermissionService {
  FakePermissions([this.location = PermissionAccess.granted]);

  PermissionAccess location;
  final requested = <AppPermission>[];

  @override
  Future<PermissionAccess> status(AppPermission permission) async =>
      permission == AppPermission.location ? location : PermissionAccess.granted;

  @override
  Future<PermissionAccess> request(AppPermission permission) async {
    requested.add(permission);
    if (permission == AppPermission.location) location = PermissionAccess.granted;
    return PermissionAccess.granted;
  }

  @override
  Future<bool> openSettings() async => true;
}

const pickup = GeoPoint(23.0225, 72.5714);

Booking booking(BookingStatus status) => Booking.fromJson({
  'customerId': 'c-1',
  'mechanicId': 'mech-1',
  'cityId': 'ahmedabad',
  'vehicle': {'type': 'car', 'brand': 'Maruti', 'model': 'Swift', 'regNo': 'GJ01AB1234'},
  'problemType': 'flat_tyre',
  'pickup': {
    'geopoint': pickup,
    'geohash': encodeGeohash(pickup.latitude, pickup.longitude),
    'address': '12 CG Road, Navrangpura',
    'landmark': 'Near the temple',
    'accuracyMeters': 10,
  },
  'status': status.value,
  'statusHistory': <Object>[],
  'triedMechanicIds': <Object>[],
  'searchRadiusKm': 3,
  'priceEstimate': {'min': 350, 'max': 600},
  'paymentStatus': 'pending',
  'customerCard': {'name': 'Priya Shah', 'phone': '+919812345678'},
  'idempotencyKey': 'k-1',
});

void main() {
  group('M5 logic', () {
    test('callable error keys map to outcomes', () {
      expect(tripOutcomeForError('error_not_at_pickup'), TripOutcome.notAtPickup);
      expect(tripOutcomeForError('error_location_unavailable'), TripOutcome.locationUnavailable);
      expect(tripOutcomeForError('error_invalid_status'), TripOutcome.invalidStatus);
      expect(tripOutcomeForError('error_booking_not_found'), TripOutcome.invalidStatus);
      expect(tripOutcomeForError(null), TripOutcome.failed);
    });

    test('ETA: 0 at the pickup, straight line at 20 km/h, within the rules', () {
      LocationFix at(double northKm) =>
          LocationFix(lat: pickup.latitude + northKm / 111.2, lng: pickup.longitude, accuracyMeters: 5);
      expect(etaMinutes(at(0.01), pickup), 0);
      expect(etaMinutes(at(2), pickup), 6);
      expect(etaMinutes(at(0.2), pickup), 1);
      expect(etaMinutes(at(900), pickup), 600);
    });

    test('Open in Maps gives driving directions to the pickup', () {
      final uri = directionsTo(pickup);
      expect(uri.host, 'www.google.com');
      expect(uri.queryParameters, {'api': '1', 'destination': '23.0225,72.5714', 'travelmode': 'driving'});
    });
  });

  group('JobTrackingController', () {
    late FakeLocation location;
    late InMemoryLiveLocationRepository live;
    late FakePermissions permissions;
    late ProviderContainer c;

    setUp(() {
      location = FakeLocation();
      live = InMemoryLiveLocationRepository();
      permissions = FakePermissions();
      c = ProviderContainer(
        overrides: [
          locationServiceProvider.overrideWithValue(location),
          liveLocationRepositoryProvider.overrideWithValue(live),
          permissionServiceProvider.overrideWithValue(permissions),
        ],
      );
      addTearDown(c.dispose);
    });

    const note = ForegroundTracking(title: 'Sharing your location', text: 'With your customer');

    test('every 5 s / 10 m as a foreground service; each fix written with an ETA', () async {
      await c.read(jobTrackingProvider.notifier).start(bookingId: 'b-1', pickup: pickup, notification: note);
      expect(location.distance, 10);
      expect(location.interval, const Duration(seconds: 5));
      expect(location.foreground?.title, 'Sharing your location', reason: 'keeps going with the screen off');

      location.move(pickup.latitude + 2 / 111.2, pickup.longitude);
      await pumpEventQueue();
      expect(live.writes.single.$1, 'b-1');
      expect(live.writes.single.$3, 6);
      expect(c.read(jobTrackingProvider).lastFix, isNotNull);
    });

    test('starting the same job again keeps the one stream; stop ends it', () async {
      final t = c.read(jobTrackingProvider.notifier);
      // The second start comes while the first is still checking: still one stream.
      final first = t.start(bookingId: 'b-1', pickup: pickup, notification: note);
      final second = t.start(bookingId: 'b-1', pickup: pickup, notification: note);
      await (first, second).wait;
      expect(location.streams, 1);
      t.stop();
      await pumpEventQueue();
      expect(location.listening, isFalse);
      expect(c.read(jobTrackingProvider).isTracking, isFalse);
    });

    test('no location permission: no foreground service, says why; retry after allowing', () async {
      permissions.location = PermissionAccess.askable;
      final t = c.read(jobTrackingProvider.notifier);
      await t.start(bookingId: 'b-1', pickup: pickup, notification: note);
      expect(location.streams, 0);
      expect(c.read(jobTrackingProvider).problem, JobLocationProblem.permission);
      expect(c.read(jobTrackingProvider).isTracking, isTrue, reason: 'still the active job');

      permissions.location = PermissionAccess.granted;
      await t.retry();
      expect(location.streams, 1);
      expect(c.read(jobTrackingProvider).problem, isNull);
    });

    test("phone's location off: says so; retry once it's on", () async {
      location.gpsOn = false;
      final t = c.read(jobTrackingProvider.notifier);
      await t.start(bookingId: 'b-1', pickup: pickup, notification: note);
      expect(c.read(jobTrackingProvider).problem, JobLocationProblem.gpsOff);
      expect(location.streams, 0);
      await t.retry();
      expect(location.streams, 0, reason: 'still off');
      location.gpsOn = true;
      await t.retry();
      expect(location.streams, 1);
      expect(c.read(jobTrackingProvider).problem, isNull);
    });
  });

  group('FirestoreLiveLocationRepository', () {
    test('writes exactly the rules’ six fields, expiring ~24 h out, in range', () async {
      final db = FakeFirebaseFirestore();
      final now = DateTime(2026, 9, 30, 12);
      await FirestoreLiveLocationRepository(db, clock: () => now).write(
        'b-1',
        const LocationFix(lat: 23.02, lng: 72.57, accuracyMeters: 5, heading: 400, speed: 150),
        etaMinutes: 7,
      );
      final doc = (await db.doc('liveLocations/b-1').get()).data()!;
      expect(doc.keys.toSet(), {
        'mechanicGeopoint',
        'heading',
        'speed',
        'etaMinutes',
        'updatedAt',
        'expireAt',
      });
      expect(doc['mechanicGeopoint'], const GeoPoint(23.02, 72.57));
      expect(doc['etaMinutes'], 7);
      expect(doc['heading'], 360);
      expect(doc['speed'], 100);
      expect((doc['expireAt'] as Timestamp).toDate(), now.add(const Duration(hours: 24)));
    });
  });

  group('M5 screen', () {
    late InMemoryJobRepository jobs;
    late FakeLocation location;
    late InMemoryLiveLocationRepository live;
    late FakePermissions permissions;
    final launched = <Uri>[];

    Future<Widget> app(BookingStatus status, {String language = 'en'}) async {
      SharedPreferences.setMockInitialValues({
        'first_run.language': language,
        'first_run.onboarded': true,
        'first_run.consent_version': kConsentVersion,
        'first_run.consent_at': '2026-09-30T10:15:00.000Z',
      });
      final prefs = await SharedPreferences.getInstance();
      jobs = InMemoryJobRepository({'b-1': booking(status)});
      return ProviderScope(
        overrides: [
          flavorProvider.overrideWithValue(AppFlavor.dev),
          sharedPreferencesProvider.overrideWithValue(prefs),
          registrationRepositoryProvider.overrideWithValue(approvedMechanic()),
          jobRepositoryProvider.overrideWithValue(jobs),
          locationServiceProvider.overrideWithValue(location),
          liveLocationRepositoryProvider.overrideWithValue(live),
          permissionServiceProvider.overrideWithValue(permissions),
          launchLinkProvider.overrideWithValue((uri) async {
            launched.add(uri);
            return true;
          }),
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 30, 6, 30)),
        ],
        child: const MechanicApp(),
      );
    }

    Future<void> openJob(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      GoRouter.of(tester.element(find.byType(DashboardScreen))).go(jobRoute('b-1'));
      await tester.pumpAndSettle();
    }

    Future<void> tapText(WidgetTester tester, String text) async {
      await tester.ensureVisible(find.text(text).first);
      // In a LaneDock, bringing a row into view can grow the sheet (animated): let it settle
      // before tapping, or the tap lands where the row used to be.
      await tester.pumpAndSettle();
      await tester.tap(find.text(text).first);
      await tester.pumpAndSettle();
    }

    setUp(() {
      location = FakeLocation();
      live = InMemoryLiveLocationRepository();
      permissions = FakePermissions();
      launched.clear();
    });

    testWidgets('no location permission: the banner explains, Allow → C7 explainer → sharing starts', (
      tester,
    ) async {
      permissions.location = PermissionAccess.askable;
      await tester.pumpWidget(await app(BookingStatus.accepted));
      await openJob(tester);
      expect(find.textContaining("can't see you coming"), findsOneWidget);
      expect(location.streams, 0);

      await tapText(tester, 'ALLOW LOCATION');
      expect(find.byType(PermissionExplainerScreen), findsOneWidget, reason: 'explainer before the prompt');
      await tester.tap(find.widgetWithText(LaneButton, 'Allow'));
      await tester.pumpAndSettle();
      expect(permissions.requested, [AppPermission.location]);
      expect(find.byType(JobScreen), findsOneWidget);
      expect(find.textContaining("can't see you coming"), findsNothing);
      expect(location.streams, 1);
    });

    testWidgets("phone's location off: the banner offers to turn it on", (tester) async {
      location.gpsOn = false;
      await tester.pumpWidget(await app(BookingStatus.arriving));
      await openJob(tester);
      expect(find.textContaining('location is switched off'), findsOneWidget);
      expect(find.text('TURN ON LOCATION'), findsOneWidget);
    });

    testWidgets('accepted: address, customer, plate; Start trip → on the way; tracking runs', (tester) async {
      await tester.pumpWidget(await app(BookingStatus.accepted));
      await openJob(tester);
      expect(find.byType(JobScreen), findsOneWidget);
      expect(find.text('Priya · Near the temple'), findsOneWidget);
      expect(find.text('12 CG Road, Navrangpura'), findsOneWidget);
      expect(find.byType(PlateChip), findsOneWidget);
      expect(find.byType(JourneyRail), findsOneWidget);
      expect(location.foreground, isNotNull, reason: 'foreground service from the start');

      location.move(pickup.latitude + 2 / 111.2, pickup.longitude);
      await tester.pumpAndSettle();
      expect(live.writes, hasLength(1));
      expect(find.text('About 6 min away'), findsOneWidget);

      // Within ~50 m: no "About 0 min away".
      location.move(pickup.latitude, pickup.longitude);
      await tester.pumpAndSettle();
      expect(find.text("You're at the pickup"), findsOneWidget);
      expect(find.textContaining('0 min'), findsNothing);

      await tapText(tester, 'Start trip');
      expect(jobs.calls, ['startTrip:b-1']);
      expect(find.text('On your way to the customer'), findsOneWidget);
      expect(find.text("I've arrived"), findsOneWidget);
    });

    testWidgets("I've arrived: too far shows why; at the pickup → ask for the start code", (tester) async {
      await tester.pumpWidget(await app(BookingStatus.arriving));
      await openJob(tester);
      jobs.nextOutcome = TripOutcome.notAtPickup;
      await tapText(tester, "I've arrived");
      expect(find.textContaining('not at the pickup yet'), findsOneWidget);
      await tester.pump(LaneToast.visibleFor);

      jobs.nextOutcome = TripOutcome.locationUnavailable;
      await tapText(tester, "I've arrived");
      expect(find.textContaining("can't see your location"), findsOneWidget);
      await tester.pump(LaneToast.visibleFor);

      await tapText(tester, "I've arrived");
      expect(find.text("You're at the customer"), findsOneWidget);
      expect(find.textContaining('4-digit start code'), findsOneWidget);
      expect(find.widgetWithText(LaneButton, 'Enter start code'), findsOneWidget, reason: 'M6 next');
      expect(find.text("I've arrived"), findsNothing);
    });

    testWidgets('Open in Maps and Call hand off to the phone', (tester) async {
      await tester.pumpWidget(await app(BookingStatus.arriving));
      await openJob(tester);
      // The floating map button (top right) and the dock both hand off; the dock also has Call.
      expect(find.widgetWithText(LaneButton, 'OPEN IN MAPS'), findsOneWidget);
      await tester.tap(find.byTooltip('Open in Maps'));
      await tester.pumpAndSettle();
      await tapText(tester, 'CALL');
      expect(launched, [directionsTo(pickup), Uri(scheme: 'tel', path: '+919812345678')]);
    });

    testWidgets('the customer cancels: says so, and location sharing stops', (tester) async {
      await tester.pumpWidget(await app(BookingStatus.arriving));
      await openJob(tester);
      expect(location.listening, isTrue);
      jobs.setStatus('b-1', BookingStatus.cancelled);
      await tester.pumpAndSettle();
      expect(find.text('This job was cancelled'), findsOneWidget);
      expect(location.listening, isFalse);
      await tapText(tester, 'Back to dashboard');
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('fits at 320 px and 200% text in Gujarati', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(await app(BookingStatus.arriving, language: 'gu'));
      await openJob(tester);
      expect(find.text('હું પહોંચી ગયો'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
