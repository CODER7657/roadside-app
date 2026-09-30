// #31: M6 Start code.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:mechanic_app/app/app.dart';
import 'package:mechanic_app/app/flavor.dart';
import 'package:mechanic_app/app/secure_window.dart';
import 'package:mechanic_app/features/dashboard/application/online.dart';
import 'package:mechanic_app/features/dashboard/data/location_service.dart';
import 'package:mechanic_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:mechanic_app/features/first_run/application/first_run.dart';
import 'package:mechanic_app/features/job/application/job.dart';
import 'package:mechanic_app/features/job/data/job_repository.dart';
import 'package:mechanic_app/features/job/presentation/job_screen.dart';
import 'package:mechanic_app/features/job/presentation/start_code_screen.dart';
import 'package:mechanic_app/features/offers/application/offers.dart';
import 'package:mechanic_app/features/permissions/application/permission_service.dart';
import 'package:mechanic_app/features/registration/application/registration.dart';
import 'package:roadside_core/roadside_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

class _NoLocation implements LocationService {
  @override
  Future<bool> serviceEnabled() async => true;

  @override
  Future<bool> openSettings() async => true;

  @override
  Stream<LocationFix> fixes({
    required int distanceFilterMeters,
    Duration? interval,
    ForegroundTracking? foreground,
  }) => StreamController<LocationFix>().stream;
}

class _GrantAll implements PermissionService {
  @override
  Future<PermissionAccess> status(AppPermission permission) async => PermissionAccess.granted;

  @override
  Future<PermissionAccess> request(AppPermission permission) async => PermissionAccess.granted;

  @override
  Future<bool> openSettings() async => true;
}

class _FakeSecureWindow implements SecureWindow {
  final calls = <bool>[];

  @override
  Future<void> setSecure(bool secure) async => calls.add(secure);
}

const pickup = GeoPoint(23.0225, 72.5714);

Booking booking(BookingStatus status) => Booking.fromJson({
  'customerId': 'c-1',
  'mechanicId': 'me',
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
  group('start code logic', () {
    test('verifyStartOtp errors map to outcomes', () {
      expect(
        startCodeResultForError('error_code_wrong', {'attemptsLeft': 3}),
        isA<StartCodeWrong>().having((r) => r.attemptsLeft, 'attemptsLeft', 3),
      );
      final locked = startCodeResultForError('error_code_locked', {
        'lockedUntil': '2026-09-30T12:10:00.000Z',
      });
      expect(locked, isA<StartCodeLocked>());
      expect((locked as StartCodeLocked).until.toUtc(), DateTime.utc(2026, 9, 30, 12, 10));
      expect(startCodeResultForError('error_code_locked', {}), isA<StartCodeFailed>(), reason: 'no time');
      expect(startCodeResultForError('error_invalid_status', null), isA<StartCodeInvalidStatus>());
      expect(startCodeResultForError('error_booking_not_found', null), isA<StartCodeInvalidStatus>());
      expect(startCodeResultForError('error_internal', null), isA<StartCodeFailed>());
    });

    test('lock minutes round up, and are 0 once it has run out', () {
      final now = DateTime(2026, 9, 30, 12);
      expect(lockMinutesLeft(now.add(const Duration(minutes: 10)), now), 10);
      expect(lockMinutesLeft(now.add(const Duration(seconds: 61)), now), 2);
      expect(lockMinutesLeft(now.add(const Duration(seconds: 5)), now), 1);
      expect(lockMinutesLeft(now, now), 0);
    });

    test('the fake follows the server: 5 wrong codes lock it for 10 minutes', () async {
      var now = DateTime(2026, 9, 30, 12);
      final jobs = InMemoryJobRepository({'b-1': booking(BookingStatus.arrived)})..clock = () => now;
      for (var left = 4; left >= 1; left--) {
        expect(
          await jobs.verifyStartCode('b-1', '0000'),
          isA<StartCodeWrong>().having((r) => r.attemptsLeft, 'left', left),
        );
      }
      expect(await jobs.verifyStartCode('b-1', '0000'), isA<StartCodeLocked>());
      expect(
        await jobs.verifyStartCode('b-1', '1234'),
        isA<StartCodeLocked>(),
        reason: 'even the right code',
      );
      now = now.add(const Duration(minutes: 11));
      expect(await jobs.verifyStartCode('b-1', '1234'), isA<StartCodeAccepted>());
    });
  });

  group('M6 screen', () {
    late InMemoryJobRepository jobs;
    late _FakeSecureWindow secure;
    late DateTime now;

    Future<Widget> app({String language = 'en'}) async {
      SharedPreferences.setMockInitialValues({
        'first_run.language': language,
        'first_run.onboarded': true,
        'first_run.consent_version': kConsentVersion,
        'first_run.consent_at': '2026-09-30T10:15:00.000Z',
      });
      final prefs = await SharedPreferences.getInstance();
      jobs = InMemoryJobRepository({'b-1': booking(BookingStatus.arrived)})..clock = () => now;
      return ProviderScope(
        overrides: [
          flavorProvider.overrideWithValue(AppFlavor.dev),
          sharedPreferencesProvider.overrideWithValue(prefs),
          registrationRepositoryProvider.overrideWithValue(approvedMechanic()),
          jobRepositoryProvider.overrideWithValue(jobs),
          locationServiceProvider.overrideWithValue(_NoLocation()),
          permissionServiceProvider.overrideWithValue(_GrantAll()),
          secureWindowProvider.overrideWithValue(secure),
          startCodeClockProvider.overrideWithValue(() => now),
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 30, 6, 30)),
        ],
        child: const MechanicApp(),
      );
    }

    /// From M5 (arrived) to M6, the way the mechanic gets there.
    Future<void> openStartCode(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      GoRouter.of(tester.element(find.byType(DashboardScreen))).go(jobRoute('b-1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enter start code'));
      await tester.pumpAndSettle();
    }

    Future<void> enterCode(WidgetTester tester, String code) async {
      await tester.enterText(
        find.descendant(of: find.byType(LaneOtpInput), matching: find.byType(TextField)),
        code,
      );
      await tester.pumpAndSettle();
    }

    setUp(() {
      secure = _FakeSecureWindow();
      now = DateTime(2026, 9, 30, 12);
    });

    testWidgets('M5 at arrival → M6, kept out of screenshots', (tester) async {
      await tester.pumpWidget(await app());
      await openStartCode(tester);
      expect(find.byType(StartCodeScreen), findsOneWidget);
      expect(find.text('Ask the customer for the 4-digit code on their screen.'), findsOneWidget);
      expect(find.text('5 tries, then a 10-minute lock.'), findsOneWidget);
      expect(secure.calls, [true]);
    });

    testWidgets('a wrong code says how many tries are left', (tester) async {
      await tester.pumpWidget(await app());
      await openStartCode(tester);
      await enterCode(tester, '0000');
      expect(find.text("That code isn't right. 4 tries left."), findsOneWidget);
      expect(find.byType(StartCodeScreen), findsOneWidget);
    });

    testWidgets('the right code → back on M5, job in progress', (tester) async {
      await tester.pumpWidget(await app());
      await openStartCode(tester);
      await enterCode(tester, '1234');
      expect(jobs.calls, ['verifyStartCode:b-1']);
      expect(find.byType(JobScreen), findsOneWidget);
      expect(find.text('Job in progress'), findsOneWidget);
      expect(secure.calls.last, isFalse, reason: 'secure only on M6');
    });

    testWidgets('5 wrong codes lock it; after 10 minutes it works again', (tester) async {
      await tester.pumpWidget(await app());
      await openStartCode(tester);
      for (var i = 0; i < 5; i++) {
        await enterCode(tester, '0000');
      }
      expect(find.text('Too many wrong codes. Try again in 10 minutes.'), findsOneWidget);
      final input = tester.widget<LaneOtpInput>(find.byType(LaneOtpInput));
      expect(input.enabled, isFalse);

      now = now.add(const Duration(minutes: 11));
      await tester.pump(const Duration(seconds: 15));
      expect(tester.widget<LaneOtpInput>(find.byType(LaneOtpInput)).enabled, isTrue);
      await enterCode(tester, '1234');
      expect(find.text('Job in progress'), findsOneWidget);
    });

    testWidgets('Back returns to M5', (tester) async {
      await tester.pumpWidget(await app());
      await openStartCode(tester);
      await tester.tap(find.byType(LaneBackButton));
      await tester.pumpAndSettle();
      expect(find.byType(JobScreen), findsOneWidget);
    });

    for (final language in ['gu', 'hi']) {
      testWidgets('fits at 320 px and 200% text in $language', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(await app(language: language));
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        GoRouter.of(tester.element(find.byType(DashboardScreen))).go(startCodeRoute('b-1'));
        await tester.pumpAndSettle();
        expect(find.byType(StartCodeScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
