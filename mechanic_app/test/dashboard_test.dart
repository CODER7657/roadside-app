// #27: M3 Dashboard, online toggle and presence.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:mechanic_app/app/app.dart';
import 'package:mechanic_app/app/flavor.dart';
import 'package:mechanic_app/features/dashboard/application/online.dart';
import 'package:mechanic_app/features/dashboard/data/jobs_repository.dart';
import 'package:mechanic_app/features/dashboard/data/location_service.dart';
import 'package:mechanic_app/features/dashboard/data/presence_repository.dart';
import 'package:mechanic_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:mechanic_app/features/first_run/application/first_run.dart';
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

/// A phone whose GPS the test drives.
class FakeLocation implements LocationService {
  FakeLocation({this.enabled = true});

  bool enabled;
  int settingsOpened = 0;
  int? lastDistanceFilter;
  StreamController<LocationFix>? _fixes;

  bool get listening => _fixes != null && _fixes!.hasListener;

  void move(double lat, double lng) => _fixes!.add(LocationFix(lat: lat, lng: lng, accuracyMeters: 8));

  @override
  Future<bool> serviceEnabled() async => enabled;

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }

  @override
  Stream<LocationFix> fixes({required int distanceFilterMeters}) {
    lastDistanceFilter = distanceFilterMeters;
    _fixes = StreamController<LocationFix>();
    return _fixes!.stream;
  }
}

class GrantAll implements PermissionService {
  final requested = <AppPermission>[];

  @override
  Future<PermissionAccess> status(AppPermission permission) async => PermissionAccess.granted;

  @override
  Future<PermissionAccess> request(AppPermission permission) async {
    requested.add(permission);
    return PermissionAccess.granted;
  }

  @override
  Future<bool> openSettings() async => true;
}

final start = DateTime(2026, 9, 30, 9);

void main() {
  group('OnlineController', () {
    late FakeLocation location;
    late InMemoryPresenceRepository presence;
    late DateTime now;
    late ProviderContainer container;

    setUp(() {
      location = FakeLocation();
      presence = InMemoryPresenceRepository();
      now = start;
      container = ProviderContainer(
        overrides: [
          locationServiceProvider.overrideWithValue(location),
          presenceRepositoryProvider.overrideWithValue(presence),
          registrationRepositoryProvider.overrideWithValue(approvedMechanic()),
          dashboardClockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);
    });

    Future<void> ready() async {
      // The profile (for cityId) is a stream: let it deliver.
      container.listen(mechanicProfileProvider, (_, _) {});
      await container.read(mechanicProfileProvider.future);
    }

    OnlineController ctrl() => container.read(onlineProvider.notifier);
    OnlineState state() => container.read(onlineProvider);

    test('going online writes presence with the profile city on the first fix, every 100 m', () async {
      await ready();
      await ctrl().goOnline();
      expect(state().phase, OnlinePhase.goingOnline);
      expect(location.lastDistanceFilter, PresenceTiming.moveMeters);
      expect(presence.writes, isEmpty, reason: 'nothing until there is a fix');

      location.move(21.7051, 72.9959);
      await pumpEventQueue();
      expect(state().phase, OnlinePhase.online);
      expect(presence.writes.single.online, isTrue);
      expect(presence.writes.single.cityId, CityId.bharuch);

      location.move(21.7061, 72.9959);
      await pumpEventQueue();
      expect(presence.writes, hasLength(2));
    });

    // testWidgets runs on fake time: tester.pump(d) fires the heartbeat timers.
    testWidgets('a heartbeat every 60 s keeps updatedAt fresh while standing still', (tester) async {
      await ready();
      await ctrl().goOnline();
      location.move(21.7051, 72.9959);
      await tester.pump();
      expect(presence.writes, hasLength(1));

      for (var i = 1; i <= 3; i++) {
        now = start.add(PresenceTiming.heartbeat * i);
        await tester.pump(PresenceTiming.heartbeat);
      }
      expect(presence.writes, hasLength(4));
      expect(presence.writes.every((w) => w.online), isTrue);
      container.dispose(); // stops the timer before the test ends
    });

    testWidgets('2 minutes without a working write: stale, so the app goes offline and says so', (
      tester,
    ) async {
      await ready();
      await ctrl().goOnline();
      location.move(21.7051, 72.9959);
      await tester.pump();
      expect(state().phase, OnlinePhase.online);

      presence.failNext = 100; // network gone
      now = start.add(PresenceTiming.heartbeat);
      await tester.pump(PresenceTiming.heartbeat);
      expect(state().isOnline, isTrue, reason: '60 s is not stale yet');

      now = start.add(PresenceTiming.stale);
      await tester.pump(PresenceTiming.heartbeat);
      expect(state().phase, OnlinePhase.offline);
      expect(state().problem, OnlineProblem.lostConnection);
      expect(location.listening, isFalse, reason: 'GPS stops');
    });

    testWidgets('no fix at all for 2 minutes also counts as stale', (tester) async {
      await ready();
      await ctrl().goOnline();
      now = start.add(PresenceTiming.stale);
      await tester.pump(PresenceTiming.heartbeat);
      await tester.pump(PresenceTiming.heartbeat);
      expect(state().problem, OnlineProblem.lostConnection);
    });

    test('going offline writes isOnline false at the last position and stops GPS', () async {
      await ready();
      await ctrl().goOnline();
      location.move(21.7051, 72.9959);
      await pumpEventQueue();
      await ctrl().goOffline();
      expect(presence.writes.last.online, isFalse);
      expect(presence.writes.last.at.lat, 21.7051);
      expect(state().isOnline, isFalse);
      expect(location.listening, isFalse);
    });

    test('GPS switched off: stays offline and says why', () async {
      await ready();
      location.enabled = false;
      await ctrl().goOnline();
      expect(state().phase, OnlinePhase.offline);
      expect(state().problem, OnlineProblem.gpsOff);
      expect(presence.writes, isEmpty);
    });
  });

  group('TodaySummary', () {
    CompletedJob job(DateTime at, int amount) => CompletedJob(
      problemType: ProblemType.flatTyre,
      vehicleType: VehicleType.car,
      completedAt: at,
      amount: amount,
    );

    test('counts and sums only today, newest first', () {
      final s = TodaySummary.of([
        job(DateTime(2026, 9, 30, 8, 12), 600),
        job(DateTime(2026, 9, 29, 23, 50), 999),
        job(DateTime(2026, 9, 30, 10, 51), 450),
      ], DateTime(2026, 9, 30, 12));
      expect(s.count, 2);
      expect(s.earned, 1050);
      expect(s.jobs.first.amount, 450);
    });

    test('rupees use Indian grouping', () {
      expect(formatRupees(1850), '₹1,850');
      expect(formatRupees(125000), '₹1,25,000');
    });
  });

  group('Firestore repositories', () {
    test('presence: first write creates with city and no booking, later ones only update', () async {
      final db = FakeFirebaseFirestore();
      final repo = FirestorePresenceRepository(db, 'mech-1');
      const at = LocationFix(lat: 21.7051, lng: 72.9959, accuracyMeters: 8);

      await repo.write(online: true, at: at, cityId: CityId.bharuch);
      var doc = (await db.doc('presence/mech-1').get()).data()!;
      expect(doc['isOnline'], isTrue);
      expect(doc['cityId'], 'bharuch');
      expect(doc.containsKey('activeBookingId'), isTrue);
      expect(doc['activeBookingId'], isNull);
      expect((doc['location'] as Map)['geohash'], encodeGeohash(21.7051, 72.9959));
      expect((doc['location'] as Map)['geopoint'], const GeoPoint(21.7051, 72.9959));
      expect(doc['updatedAt'], isNotNull);

      // Functions assign a booking meanwhile; the app's updates must never touch it.
      await db.doc('presence/mech-1').update({'activeBookingId': 'b-1'});
      await repo.write(online: false, at: at, cityId: CityId.ahmedabad);
      doc = (await db.doc('presence/mech-1').get()).data()!;
      expect(doc['isOnline'], isFalse);
      expect(doc['cityId'], 'bharuch', reason: 'city is only set on create');
      expect(doc['activeBookingId'], 'b-1');
    });

    test('jobs: today’s completed bookings of this mechanic only', () async {
      final db = FakeFirebaseFirestore();
      final today = DateTime(2026, 9, 30, 10, 51);
      Future<void> booking(
        String id, {
        String mechanicId = 'mech-1',
        String status = 'completed',
        DateTime? done,
      }) => db.doc('bookings/$id').set({
        'customerId': 'c-1',
        'mechanicId': mechanicId,
        'cityId': 'bharuch',
        'vehicle': {'type': 'car', 'brand': 'Maruti', 'model': 'Swift', 'regNo': 'GJ16AB1234'},
        'problemType': 'flat_tyre',
        'pickup': {
          'geopoint': const GeoPoint(21.7, 72.99),
          'geohash': 'tsm',
          'address': 'x',
          'accuracyMeters': 10,
        },
        'status': status,
        'statusHistory': <Object>[],
        'triedMechanicIds': <Object>[],
        'searchRadiusKm': 3,
        'paymentStatus': 'pending',
        'priceEstimate': {'min': 300, 'max': 600},
        'finalAmount': 450,
        'timestamps': {if (done != null) 'completed': Timestamp.fromDate(done)},
        'idempotencyKey': 'k-$id',
        'createdAt': Timestamp.fromDate(done ?? today),
      });
      await booking('b1', done: today);
      await booking('b2', done: today.subtract(const Duration(days: 1)));
      await booking('b3', status: 'in_progress');
      await booking('b4', mechanicId: 'someone-else', done: today);
      // A malformed doc is skipped, not fatal.
      await db.doc('bookings/broken').set({'mechanicId': 'mech-1', 'createdAt': Timestamp.fromDate(today)});

      final summary = await FirestoreJobsRepository(db, 'mech-1').watchToday(() => today).first;
      expect(summary.count, 1);
      expect(summary.earned, 450);
    });
  });

  group('M3 screen', () {
    late FakeLocation location;
    late InMemoryPresenceRepository presence;
    late PermissionService permissions;

    Future<Widget> app({List<CompletedJob> jobs = const [], String language = 'en'}) async {
      SharedPreferences.setMockInitialValues({
        'first_run.language': language,
        'first_run.onboarded': true,
        'first_run.consent_version': kConsentVersion,
        'first_run.consent_at': '2026-09-30T10:15:00.000Z',
      });
      final prefs = await SharedPreferences.getInstance();
      return ProviderScope(
        overrides: [
          flavorProvider.overrideWithValue(AppFlavor.dev),
          sharedPreferencesProvider.overrideWithValue(prefs),
          registrationRepositoryProvider.overrideWithValue(approvedMechanic()),
          locationServiceProvider.overrideWithValue(location),
          presenceRepositoryProvider.overrideWithValue(presence),
          permissionServiceProvider.overrideWithValue(permissions),
          jobsRepositoryProvider.overrideWithValue(InMemoryJobsRepository(jobs)),
          dashboardClockProvider.overrideWithValue(() => DateTime(2026, 9, 30, 12)),
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 30, 6, 30)),
        ],
        child: const MechanicApp(),
      );
    }

    Future<void> pastSplash(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }

    setUp(() {
      location = FakeLocation();
      presence = InMemoryPresenceRepository();
      permissions = GrantAll();
    });

    testWidgets('an approved mechanic lands on M3, offline, with today’s numbers', (tester) async {
      await tester.pumpWidget(
        await app(
          jobs: [
            CompletedJob(
              problemType: ProblemType.battery,
              vehicleType: VehicleType.scooter,
              completedAt: DateTime(2026, 9, 30, 9, 30),
              amount: 300,
            ),
            CompletedJob(
              problemType: ProblemType.flatTyre,
              vehicleType: VehicleType.car,
              completedAt: DateTime(2026, 9, 30, 10, 51),
              amount: 1550,
            ),
          ],
        ),
      );
      await pastSplash(tester);
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text("You're offline"), findsOneWidget);
      Finder rolling(String v) => find.byWidgetPredicate((w) => w is LaneRollingNumber && w.value == v);
      expect(rolling('2'), findsOneWidget);
      expect(rolling('₹1,850'), findsOneWidget);
      expect(find.text('Flat tyre · Car'), findsOneWidget);
      expect(find.text('₹1,550'), findsOneWidget);
    });

    testWidgets('no jobs yet shows the empty line', (tester) async {
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      expect(find.textContaining('No jobs yet today'), findsOneWidget);
    });

    testWidgets('the toggle goes online (location permission first) and back offline', (tester) async {
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      await tester.tap(find.byType(LaneSwitch));
      await tester.pumpAndSettle();
      expect(find.text('Finding your location…'), findsOneWidget);

      location.move(21.7051, 72.9959);
      await tester.pumpAndSettle();
      expect(find.text("You're online"), findsOneWidget);
      expect(find.text("We'll send you jobs nearby."), findsOneWidget);
      expect(presence.isOnline, isTrue);

      await tester.tap(find.byType(LaneSwitch));
      await tester.pumpAndSettle();
      expect(find.text("You're offline"), findsOneWidget);
      expect(presence.isOnline, isFalse);
    });

    testWidgets('location not granted: the C7 explainer comes first; Not now stays offline', (tester) async {
      permissions = _AskFirst();
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      await tester.tap(find.byType(LaneSwitch));
      await tester.pumpAndSettle();
      expect(find.byType(PermissionExplainerScreen), findsOneWidget);
      expect(find.text('Allow location'), findsOneWidget);

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text("You're offline"), findsOneWidget);
      expect(location.lastDistanceFilter, isNull, reason: 'GPS never started');
      expect(presence.writes, isEmpty);
    });

    testWidgets('GPS off shows why and a button to switch it on', (tester) async {
      location.enabled = false;
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      await tester.tap(find.byType(LaneSwitch));
      await tester.pumpAndSettle();
      expect(find.textContaining('location is switched off'), findsOneWidget);
      await tester.tap(find.widgetWithText(LaneButton, 'TURN ON LOCATION'));
      expect(location.settingsOpened, 1);
    });

    testWidgets('fits at 320 px and 200% text in Gujarati, online', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        await app(
          language: 'gu',
          jobs: [
            CompletedJob(
              problemType: ProblemType.wontStart,
              vehicleType: VehicleType.bike,
              completedAt: DateTime(2026, 9, 30, 8, 12),
              amount: 125000,
            ),
          ],
        ),
      );
      await pastSplash(tester);
      await tester.tap(find.byType(LaneSwitch));
      await tester.pumpAndSettle();
      location.move(21.7051, 72.9959);
      await tester.pumpAndSettle();
      expect(find.text('તમે ઓનલાઇન છો'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

class _AskFirst implements PermissionService {
  @override
  Future<PermissionAccess> status(AppPermission permission) async => PermissionAccess.askable;

  @override
  Future<PermissionAccess> request(AppPermission permission) async => PermissionAccess.askable;

  @override
  Future<bool> openSettings() async => true;
}
