// #12: U1 Home, the city chip and U1·Area.
import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/features/booking/application/estimate.dart';
import 'package:customer_app/features/booking/application/pickup.dart';
import 'package:customer_app/features/booking/data/booking_repository.dart';
import 'package:customer_app/features/booking/data/booking_service.dart';
import 'package:customer_app/features/booking/presentation/live_booking_screen.dart';
import 'package:customer_app/features/booking/presentation/problem_screen.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
import 'package:customer_app/features/help/presentation/help_screen.dart';
import 'package:customer_app/features/history/presentation/history_screen.dart';
import 'package:customer_app/features/home/presentation/home_screen.dart';
import 'package:customer_app/features/profile/presentation/profile_screen.dart';
import 'package:customer_app/features/permissions/application/permission_service.dart';
import 'package:customer_app/features/permissions/presentation/permission_explainer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:roadside_core/fakes.dart';
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_location.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

class FakePermissions implements PermissionService {
  PermissionAccess access = PermissionAccess.granted;
  bool throws = false;

  @override
  Future<PermissionAccess> status(AppPermission permission) async {
    if (throws) throw StateError('no plugin');
    return access;
  }

  @override
  Future<PermissionAccess> request(AppPermission permission) async => access;

  @override
  Future<bool> openSettings() async => true;
}

void main() {
  late FakeLocationService location;
  late FakeGeocoder geocoder;
  late FakePermissions permissions;
  late InMemoryBookingStore store;
  late List<Uri> launched;
  late String supportPhone;

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
          permissionServiceProvider.overrideWithValue(permissions),
          locationServiceProvider.overrideWithValue(location),
          reverseGeocoderProvider.overrideWithValue(geocoder),
          bookingStoreProvider.overrideWithValue(store),
          launchLinkProvider.overrideWithValue((uri) async {
            launched.add(uri);
            return true;
          }),
          supportContactsProvider.overrideWithValue((phone: supportPhone, grievanceEmail: 'g@example.test')),
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => RoadsideFakes.now),
        ],
        child: const RoadsideApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    return ProviderScope.containerOf(tester.element(find.byType(HomeScreen)));
  }

  void tall(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Finder text(String t) => find.text(t, skipOffstage: false);

  setUp(() {
    location = FakeLocationService();
    geocoder = FakeGeocoder();
    permissions = FakePermissions();
    store = InMemoryBookingStore();
    launched = [];
    supportPhone = '+919800000000';
  });

  testWidgets('allowed: locates, shows the city and address; Get help starts a booking', (tester) async {
    tall(tester);
    await open(tester);
    expect(location.active, 1);
    location.add(23.0504, 72.5170, 9); // Thaltej
    await tester.pumpAndSettle();
    expect(text('Ahmedabad'), findsOneWidget);
    expect(text('Near SG Highway, Thaltej'), findsOneWidget);
    expect(location.active, 0, reason: 'GPS off once located');
    await tester.tap(find.widgetWithText(LaneButton, 'Get help'));
    await tester.pumpAndSettle();
    expect(find.byType(ProblemScreen), findsOneWidget);
  });

  testWidgets('where Ankleshwar and Bharuch overlap, the nearer city wins', (tester) async {
    tall(tester);
    await open(tester);
    location.add(21.6200, 73.0100, 12); // GIDC Ankleshwar
    await tester.pumpAndSettle();
    expect(text('Ankleshwar'), findsOneWidget);
    expect(text('Bharuch'), findsNothing);
  });

  testWidgets('the city name follows the app language', (tester) async {
    tall(tester);
    await open(tester, language: 'gu');
    location.add(21.7051, 72.9959, 10); // Bharuch centre
    await tester.pumpAndSettle();
    expect(text('ભરૂચ'), findsOneWidget);
  });

  testWidgets('outside every city: U1·Area and "Send my location by SMS"', (tester) async {
    tall(tester);
    await open(tester);
    location.add(19.0760, 72.8777, 10); // Mumbai
    await tester.pumpAndSettle();
    expect(text('Outside our area'), findsOneWidget);
    expect(text("We're not in your area yet"), findsOneWidget);
    expect(find.widgetWithText(LaneButton, 'Get help'), findsNothing);
    await tester.tap(find.widgetWithText(LaneButton, 'Send my location by SMS'));
    await tester.pump();
    final sms = launched.single;
    expect(sms.scheme, 'sms');
    expect(sms.path, supportPhone);
    final body = Uri.decodeComponent(sms.query.replaceFirst('body=', ''));
    expect(body, contains('https://maps.google.com/?q=19.076000,72.877700'));
    expect(body, contains('Plus Code 7JFJ'));
  });

  testWidgets('outside, with no helpline configured: Get help stays (no dead SMS button)', (tester) async {
    tall(tester);
    supportPhone = '';
    await open(tester);
    location.add(19.0760, 72.8777, 10);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(LaneButton, 'Get help'), findsOneWidget);
    expect(find.widgetWithText(LaneButton, 'Send my location by SMS'), findsNothing);
  });

  testWidgets('not allowed yet: no prompt on open; Show my location goes through C7', (tester) async {
    tall(tester);
    permissions.access = PermissionAccess.askable;
    await open(tester);
    expect(find.byType(PermissionExplainerScreen), findsNothing, reason: 'Home never prompts by itself');
    expect(location.active, 0);
    expect(
      text('Share your location to see help near you. You can still get help without it.'),
      findsOneWidget,
    );
    await tester.ensureVisible(text('SHOW MY LOCATION'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SHOW MY LOCATION'));
    await tester.pumpAndSettle();
    expect(find.byType(PermissionExplainerScreen), findsOneWidget);
  });

  testWidgets('a permission check that throws is treated as not allowed', (tester) async {
    tall(tester);
    permissions.throws = true;
    await open(tester);
    expect(tester.takeException(), isNull);
    expect(text('SHOW MY LOCATION'), findsOneWidget);
  });

  testWidgets('GPS off: Turn on location; no reading: try again', (tester) async {
    tall(tester);
    location.enabled = false;
    await open(tester);
    expect(text("Your phone's location is switched off."), findsOneWidget);
    expect(text('TURN ON LOCATION'), findsOneWidget);
  });

  testWidgets('no reading in 15 s: says so, Get help still works', (tester) async {
    tall(tester);
    await open(tester);
    await tester.pump(const Duration(seconds: 16));
    await tester.pumpAndSettle();
    expect(
      text("We couldn't find your location. You can still get help and place the pin yourself."),
      findsOneWidget,
    );
    expect(find.widgetWithText(LaneButton, 'Get help'), findsOneWidget);
    expect(location.active, 0);
  });

  testWidgets('a booking still in progress is one tap away', (tester) async {
    tall(tester);
    const id = RoadsideFakes.bookingId;
    store.put(
      id,
      RoadsideFakes.booking(status: BookingStatus.arriving)
          .copyWith(customerId: FakeBookingService.customerId),
    );
    final c = await open(tester);
    c
        .read(activeBookingProvider.notifier)
        .set(const CreatedBooking(bookingId: id, cityId: CityId.ahmedabad, min: 350, max: 600));
    await tester.pumpAndSettle();
    expect(text('Your booking is in progress'), findsOneWidget);
    await tester.tap(find.text('Your booking is in progress'));
    await tester.pumpAndSettle();
    expect(find.byType(LiveBookingScreen), findsOneWidget);
  });

  testWidgets('a finished booking is not offered again', (tester) async {
    tall(tester);
    const id = RoadsideFakes.bookingId;
    store.put(
      id,
      RoadsideFakes.booking(status: BookingStatus.completed)
          .copyWith(customerId: FakeBookingService.customerId),
    );
    final c = await open(tester);
    c
        .read(activeBookingProvider.notifier)
        .set(const CreatedBooking(bookingId: id, cityId: CityId.ahmedabad, min: 350, max: 600));
    await tester.pumpAndSettle();
    expect(text('Your booking is in progress'), findsNothing);
  });

  testWidgets('"Your bookings" opens U15', (tester) async {
    tall(tester);
    await open(tester);
    await tester.tap(find.text('Your bookings'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsOneWidget);
  });

  testWidgets('the map button opens Profile & settings (U18)', (tester) async {
    tall(tester);
    await open(tester);
    await tester.tap(find.byTooltip('Profile & settings'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('☀ Glare is on the map', (tester) async {
    tall(tester);
    await open(tester);
    expect(find.byType(LaneGlareButton), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing, reason: 'Home is the root');
  });

  testWidgets('fits at 320 px, 200% text, Hindi (located and outside)', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await open(tester, language: 'hi');
    location.add(19.0760, 72.8777, 10);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
