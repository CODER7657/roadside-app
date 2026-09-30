// #107: U6 Confirm location, the pickup state, bestFix and Plus Codes.
import 'dart:async';

import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/features/booking/application/booking_draft.dart';
import 'package:customer_app/features/booking/application/pickup.dart';
import 'package:customer_app/features/booking/data/location.dart';
import 'package:customer_app/features/booking/data/plus_code.dart';
import 'package:customer_app/features/booking/presentation/price_screen.dart';
import 'package:customer_app/features/booking/presentation/confirm_location_screen.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
import 'package:customer_app/features/permissions/application/permission_service.dart';
import 'package:customer_app/features/permissions/presentation/permission_explainer_screen.dart';
import 'package:customer_app/app/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_location.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

class FakePermissions implements PermissionService {
  PermissionAccess access = PermissionAccess.granted;

  @override
  Future<PermissionAccess> status(AppPermission permission) async => access;

  @override
  Future<PermissionAccess> request(AppPermission permission) async => access;

  @override
  Future<bool> openSettings() async => true;
}

class _SlowGeocoder implements ReverseGeocoder {
  final calls = <Completer<String?>>[];

  @override
  Future<String?> addressAt(LatLng point, {required String languageCode}) {
    final c = Completer<String?>();
    calls.add(c);
    return c.future;
  }
}

LocationFix fix(double lat, double lng, double accuracy) =>
    LocationFix(position: (lat: lat, lng: lng), accuracyMeters: accuracy);

/// Thaltej, Ahmedabad.
const home = (lat: 23.0504, lng: 72.5170);

void main() {
  group('encodePlusCode', () {
    test('matches the Open Location Code test vectors', () {
      expect(encodePlusCode(47.0000625, 8.0000625), '8FVC2222+22');
      expect(encodePlusCode(20.3700625, 2.7821875), '7FG49QCJ+2V');
    });

    test('clips the pole and wraps longitude', () {
      expect(encodePlusCode(90, 1), encodePlusCode(89.9999, 1));
      expect(encodePlusCode(10, 180), encodePlusCode(10, -180));
      expect(encodePlusCode(10, 370), encodePlusCode(10, 10));
    });

    test('a point in Ahmedabad', () {
      expect(
        encodePlusCode(home.lat, home.lng),
        matches(RegExp(r'^7JMJ[23456789CFGHJMPQRVWX]{4}\+[23456789CFGHJMPQRVWX]{2}$')),
      );
    });
  });

  group('bestFix', () {
    test('stops at the first reading within 20 m', () async {
      final c = StreamController<LocationFix>();
      final seen = <double>[];
      final result = bestFix(c.stream, onFix: (f) => seen.add(f.accuracyMeters));
      c
        ..add(fix(1, 1, 80))
        ..add(fix(1, 1, 18))
        ..add(fix(1, 1, 5));
      expect((await result)!.accuracyMeters, 18);
      expect(seen, [80, 18]);
      expect(c.hasListener, isFalse, reason: 'unsubscribed');
    });

    test('on timeout, the best reading so far', () async {
      final c = StreamController<LocationFix>();
      final result = bestFix(c.stream, timeout: const Duration(milliseconds: 50));
      c
        ..add(fix(1, 1, 90))
        ..add(fix(1, 1, 40))
        ..add(fix(1, 1, 60));
      expect((await result)!.accuracyMeters, 40);
    });

    test('null when nothing arrives; errors pass through', () async {
      expect(await bestFix(const Stream.empty()), isNull);
      expect(await bestFix(StreamController<LocationFix>().stream, timeout: Duration.zero), isNull);
      expect(bestFix(Stream.error(StateError('no gps'))), throwsStateError);
    });
  });

  group('PickupNotifier', () {
    late FakeLocationService location;
    late FakeGeocoder geocoder;
    late ProviderContainer container;

    PickupState state() => container.read(pickupProvider);
    PickupNotifier notifier() => container.read(pickupProvider.notifier);

    setUp(() {
      location = FakeLocationService();
      geocoder = FakeGeocoder();
      container = ProviderContainer(
        overrides: [
          locationServiceProvider.overrideWithValue(location),
          reverseGeocoderProvider.overrideWithValue(geocoder),
        ],
      );
      // Keep the auto-dispose provider alive for the test.
      container.listen(pickupProvider, (_, _) {});
      addTearDown(container.dispose);
    });

    test('follows readings, then is ready with the address at ≤ 20 m', () async {
      final locating = notifier().locate(permitted: true, languageCode: 'gu');
      await pumpEventQueue();
      expect(state().status, PickupStatus.locating);
      location.add(home.lat, home.lng, 60);
      await pumpEventQueue();
      expect(state().fix!.accuracyMeters, 60);
      expect(state().pin, home);
      location.add(home.lat + 0.0001, home.lng, 12);
      await locating;
      expect(state().status, PickupStatus.ready);
      expect(state().fix!.accuracyMeters, 12);
      expect(state().address, 'Near SG Highway, Thaltej');
      expect(geocoder.asked.last.$2, 'gu');
      expect(state().canConfirm, isTrue);
    });

    test('no permission: the pin starts in Ahmedabad and can still be confirmed', () async {
      await notifier().locate(permitted: false, languageCode: 'en');
      expect(state().status, PickupStatus.noPermission);
      expect(state().pin, fallbackCenter);
      expect(state().fix, isNull);
      expect(state().canConfirm, isTrue);
    });

    test('GPS off is reported without listening for readings', () async {
      location.enabled = false;
      await notifier().locate(permitted: true, languageCode: 'en');
      expect(state().status, PickupStatus.gpsOff);
      expect(location.readings.hasListener, isFalse);
    });

    test('a drag while locating keeps the customer\'s pin', () async {
      final locating = notifier().locate(permitted: true, languageCode: 'en');
      await pumpEventQueue();
      location.add(home.lat, home.lng, 70);
      await pumpEventQueue();
      notifier().dragStarted();
      expect(state().canConfirm, isFalse, reason: 'not while dragging');
      const moved = (lat: 23.0510, lng: 72.5180);
      await notifier().dragEnded(moved);
      location.add(home.lat, home.lng, 10);
      await locating;
      expect(state().pin, moved);
      expect(state().fix!.accuracyMeters, 10);
    });

    test('more than 2 km from the phone needs "booking for someone else"', () async {
      final locating = notifier().locate(permitted: true, languageCode: 'en');
      await pumpEventQueue();
      location.add(home.lat, home.lng, 8);
      await locating;
      await notifier().dragEnded((lat: home.lat + 0.03, lng: home.lng)); // ~3.3 km north
      expect(state().farFromFix, isTrue);
      expect(state().canConfirm, isFalse);
      notifier().setForSomeoneElse(true);
      expect(state().canConfirm, isTrue);
      await notifier().recenter();
      expect(state().farFromFix, isFalse);
    });

    test('no address: confirm uses the Plus Code; a failed lookup is not fatal', () async {
      geocoder.answer = (_) => null;
      await notifier().locate(permitted: false, languageCode: 'en');
      notifier().setLandmark('  Opposite the petrol pump  ');
      expect(notifier().confirm(), isTrue);
      final pickup = container.read(bookingDraftProvider).pickup!;
      expect(pickup.address, pickup.plusCode);
      expect(pickup.plusCode, encodePlusCode(fallbackCenter.lat, fallbackCenter.lng));
      expect(pickup.landmark, 'Opposite the petrol pump');
      expect(pickup.accuracyMeters, PickupNotifier.unknownAccuracyMeters);

      geocoder.error = Exception('offline');
      await notifier().dragEnded(home);
      expect(state().address, isNull);
      expect(state().addressLoading, isFalse);
    });

    test('closing U6 while locating switches GPS off at once', () async {
      unawaited(notifier().locate(permitted: true, languageCode: 'en'));
      await pumpEventQueue();
      expect(location.active, 1);
      container.dispose();
      await pumpEventQueue();
      expect(location.active, 0);
    });

    test('a second locate replaces the first: one GPS subscription, latest wins', () async {
      final first = notifier().locate(permitted: true, languageCode: 'en');
      await pumpEventQueue();
      final second = notifier().locate(permitted: true, languageCode: 'en');
      await pumpEventQueue();
      expect(location.active, 1);
      await first;
      expect(state().status, PickupStatus.locating, reason: 'the old run did not finish the new one');
      location.add(home.lat, home.lng, 9);
      await second;
      expect(state().status, PickupStatus.ready);
      expect(state().fix!.accuracyMeters, 9);
      await pumpEventQueue();
      expect(location.active, 0);
    });

    test('GPS stops once a good reading arrives', () async {
      final locating = notifier().locate(permitted: true, languageCode: 'en');
      await pumpEventQueue();
      location.add(home.lat, home.lng, 5);
      await locating;
      await pumpEventQueue();
      expect(location.active, 0);
    });

    test('an address for an old pin position is ignored', () async {
      final slow = _SlowGeocoder();
      container = ProviderContainer(
        overrides: [
          locationServiceProvider.overrideWithValue(location),
          reverseGeocoderProvider.overrideWithValue(slow),
        ],
      );
      container.listen(pickupProvider, (_, _) {});
      final first = notifier().locate(permitted: false, languageCode: 'en');
      await pumpEventQueue();
      final second = notifier().dragEnded(home);
      await pumpEventQueue();
      expect(slow.calls, hasLength(2));
      slow.calls[1].complete('New place');
      slow.calls[0].complete('Old place');
      await Future.wait([first, second]);
      expect(state().address, 'New place');
      container.dispose();
    });

    test('confirm saves the pickup in the booking draft', () async {
      final locating = notifier().locate(permitted: true, languageCode: 'en');
      await pumpEventQueue();
      location.add(home.lat, home.lng, 9);
      await locating;
      expect(notifier().confirm(), isTrue);
      final pickup = container.read(bookingDraftProvider).pickup!;
      expect((pickup.lat, pickup.lng), (home.lat, home.lng));
      expect(pickup.address, 'Near SG Highway, Thaltej');
      expect(pickup.accuracyMeters, 9);
      expect(pickup.plusCode, matches(RegExp(r'^7JMJ')));
    });
  });

  group('screen', () {
    late FakeLocationService location;
    late FakeGeocoder geocoder;
    late FakePermissions permissions;

    Future<Widget> app({String language = 'en'}) async {
      SharedPreferences.setMockInitialValues({
        'first_run.language': language,
        'first_run.onboarded': true,
        'first_run.consent_version': kConsentVersion,
        'first_run.consent_at': '2026-09-29T10:15:00.000Z',
      });
      final prefs = await SharedPreferences.getInstance();
      return ProviderScope(
        overrides: [
          flavorProvider.overrideWithValue(AppFlavor.dev),
          sharedPreferencesProvider.overrideWithValue(prefs),
          permissionServiceProvider.overrideWithValue(permissions),
          locationServiceProvider.overrideWithValue(location),
          reverseGeocoderProvider.overrideWithValue(geocoder),
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 29, 6, 30)),
        ],
        child: const RoadsideApp(),
      );
    }

    /// Opens U6 on its own (`go`), so Home's own GPS isn't running underneath; [overHome]
    /// pushes it on top of Home instead.
    Future<void> openU6(WidgetTester tester, {String language = 'en', bool overHome = false}) async {
      await tester.pumpWidget(await app(language: language));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      final router = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first))
          .read(routerProvider);
      if (overHome) {
        unawaited(router.push(AppRoutes.bookLocation));
      } else {
        router.go(AppRoutes.bookLocation);
      }
      await tester.pumpAndSettle();
    }

    void tall(WidgetTester tester) {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    setUp(() {
      location = FakeLocationService();
      geocoder = FakeGeocoder();
      permissions = FakePermissions();
    });

    testWidgets('locating → accurate: badge, address, Plus Code; confirm goes on to U7', (tester) async {
      tall(tester);
      await openU6(tester);
      expect(find.byType(ConfirmLocationScreen), findsOneWidget);
      expect(find.text('Finding your location'), findsOneWidget);
      expect(tester.widget<LaneButton>(find.widgetWithText(LaneButton, 'Confirm pickup')).onPressed, isNull);

      location.add(home.lat, home.lng, 12);
      await tester.pumpAndSettle();
      expect(find.text('±12 m'), findsOneWidget);
      expect(find.text('Near SG Highway, Thaltej', skipOffstage: false), findsOneWidget);
      expect(find.textContaining('Plus Code 7JMJ', skipOffstage: false), findsOneWidget);
      expect(find.byTooltip('Go to my location'), findsOneWidget);

      await tester.ensureVisible(find.byType(TextField, skipOffstage: false));
      await tester.enterText(find.byType(TextField), 'Opposite the petrol pump');
      await tester.tap(find.text('Confirm pickup'));
      await tester.pumpAndSettle();
      expect(find.byType(PriceScreen), findsOneWidget);
    });

    testWidgets('dragging the map lifts the pin and moves the pickup', (tester) async {
      tall(tester);
      await openU6(tester);
      location.add(home.lat, home.lng, 10);
      await tester.pumpAndSettle();
      geocoder.answer = (_) => 'Somewhere else';
      final gesture = await tester.startGesture(const Offset(200, 200));
      await gesture.moveBy(const Offset(0, 30));
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      expect(tester.widget<CenterPin>(find.byType(CenterPin)).lifted, isTrue);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.widget<CenterPin>(find.byType(CenterPin)).lifted, isFalse);
      expect(find.text('Somewhere else', skipOffstage: false), findsOneWidget);
    });

    testWidgets('no permission: explainer first, then "drag or allow" with a manual pin', (tester) async {
      tall(tester);
      permissions.access = PermissionAccess.askable;
      await openU6(tester);
      expect(find.byType(PermissionExplainerScreen), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Location is off for this app', skipOffstage: false), findsOneWidget);
      expect(find.text('ALLOW LOCATION', skipOffstage: false), findsOneWidget);
      expect(
        tester.widget<LaneButton>(find.widgetWithText(LaneButton, 'Confirm pickup')).onPressed,
        isNotNull,
      );
    });

    testWidgets('GPS off offers to turn it on', (tester) async {
      tall(tester);
      location.enabled = false;
      await openU6(tester);
      expect(find.text("Your phone's location is switched off.", skipOffstage: false), findsOneWidget);
      await tester.ensureVisible(find.text('TURN ON LOCATION', skipOffstage: false));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TURN ON LOCATION'));
      await tester.pump();
      expect(location.settingsOpened, 1);
      // Settings is open: nothing is re-checked until the customer comes back.
      expect(location.active, 0);

      // Back without switching it on: still off, no GPS.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text("Your phone's location is switched off.", skipOffstage: false), findsOneWidget);
      expect(location.active, 0);

      // Switched on in Settings, then back: locating starts by itself.
      location.enabled = true;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump();
      expect(location.active, 1);
      location.add(home.lat, home.lng, 15);
      await tester.pumpAndSettle();
      expect(find.text('±15 m'), findsOneWidget);
      expect(location.active, 0, reason: 'GPS off again once a good reading arrived');
    });

    testWidgets('permission granted in Settings is picked up on return, without asking again', (
      tester,
    ) async {
      tall(tester);
      permissions.access = PermissionAccess.askable;
      await openU6(tester);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Location is off for this app', skipOffstage: false), findsOneWidget);

      // Still not granted: coming back shows no prompt and starts no GPS.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.byType(PermissionExplainerScreen), findsNothing);
      expect(location.active, 0);

      permissions.access = PermissionAccess.granted;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump();
      expect(location.active, 1);
      location.add(home.lat, home.lng, 11);
      await tester.pumpAndSettle();
      expect(find.text('±11 m'), findsOneWidget);
    });

    testWidgets('resuming while already located does not start GPS again', (tester) async {
      tall(tester);
      await openU6(tester);
      location.add(home.lat, home.lng, 8);
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(location.active, 0);
      expect(find.text('±8 m'), findsOneWidget);
    });

    testWidgets('leaving U6 while it locates stops its GPS (Home keeps its own)', (tester) async {
      tall(tester);
      await openU6(tester, overHome: true);
      // Home is locating underneath too.
      expect(location.active, 2);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ConfirmLocationScreen), findsNothing);
      expect(location.active, 1, reason: "only Home's subscription is left");
      await tester.pump(const Duration(seconds: 16)); // Home's wait runs out
      expect(location.active, 0);
    });

    testWidgets('no reading in 15 s: drag the map to your spot, or try again', (tester) async {
      tall(tester);
      await openU6(tester);
      await tester.pump(const Duration(seconds: 16));
      await tester.pumpAndSettle();
      expect(
        find.text("We couldn't find you. Drag the map to your spot.", skipOffstage: false),
        findsOneWidget,
      );
      expect(location.active, 0);
      expect(
        tester.widget<LaneButton>(find.widgetWithText(LaneButton, 'Confirm pickup')).onPressed,
        isNotNull,
      );

      await tester.ensureVisible(find.text('TRY AGAIN', skipOffstage: false));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TRY AGAIN'));
      await tester.pump();
      await tester.pump();
      expect(location.active, 1);
      location.add(home.lat, home.lng, 14);
      await tester.pumpAndSettle();
      expect(find.text('±14 m'), findsOneWidget);
    });

    testWidgets('a good reading sets the sunset position; ☀ switches the map to Glare', (tester) async {
      tall(tester);
      await openU6(tester);
      location.add(home.lat, home.lng, 9);
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(tester.element(find.byType(ConfirmLocationScreen)));
      final position = container.read(ambientControllerProvider).position!;
      expect((position.lat, position.lng), (home.lat, home.lng));

      expect(find.byType(LaneGlareButton), findsOneWidget);
      await tester.tap(find.byType(LaneGlareButton));
      await tester.pumpAndSettle();
      expect(container.read(laneModeProvider), LaneMode.glare);
      await tester.tap(find.byType(LaneGlareButton));
      await tester.pumpAndSettle();
      expect(container.read(laneModeProvider), isNot(LaneMode.glare));
    });

    testWidgets('fits at 320 px, 200% text, Hindi', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openU6(tester, language: 'hi');
      location.add(home.lat, home.lng, 35);
      await tester.pumpAndSettle();
      expect(find.text('±35 मी'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 16)); // U6's GPS wait (35 m isn't good enough)
    });
  });
}
