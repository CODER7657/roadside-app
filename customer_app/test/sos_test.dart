// #19: SOS hold, share live trip, SMS fallback when offline.
import 'dart:async';

import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/app/router.dart';
import 'package:customer_app/features/booking/application/estimate.dart';
import 'package:customer_app/features/booking/application/pickup.dart';
import 'package:customer_app/features/booking/data/booking_repository.dart';
import 'package:customer_app/features/booking/data/booking_service.dart';
import 'package:customer_app/features/booking/presentation/live_booking_screen.dart';
import 'package:customer_app/features/connectivity/connectivity.dart';
import 'package:customer_app/features/contacts/application/contacts.dart';
import 'package:customer_app/features/contacts/data/contacts_repository.dart';
import 'package:customer_app/features/contacts/presentation/contacts_screen.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
import 'package:customer_app/features/help/presentation/help_screen.dart';
import 'package:customer_app/features/home/presentation/home_screen.dart';
import 'package:customer_app/features/permissions/application/permission_service.dart';
import 'package:customer_app/features/sos/application/sos.dart';
import 'package:customer_app/features/sos/data/share_links.dart';
import 'package:customer_app/features/sos/presentation/sos_sheet.dart';
import 'package:customer_app/l10n/app_localizations_en.dart';
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

class _Permissions implements PermissionService {
  @override
  Future<PermissionAccess> status(AppPermission permission) async => PermissionAccess.granted;

  @override
  Future<PermissionAccess> request(AppPermission permission) async => PermissionAccess.granted;

  @override
  Future<bool> openSettings() async => true;
}

class _Network implements ConnectivitySource {
  final _c = StreamController<bool>.broadcast();
  bool offline = false;

  void set(bool value) {
    offline = value;
    _c.add(value);
  }

  @override
  Stream<bool> watchOffline() async* {
    yield offline;
    yield* _c.stream;
  }
}

class _Links implements ShareLinkService {
  Uri? next = Uri.parse('https://roadside-33282.web.app/t/abc123');
  Duration delay = Duration.zero;
  final asked = <String>[];

  @override
  Future<Uri?> create(String bookingId) async {
    asked.add(bookingId);
    await Future<void>.delayed(delay);
    return next;
  }
}

const mom = Contact(name: 'Mom', phone: '+919876500021');
const rahul = Contact(name: 'Rahul', phone: '+919876543088');

void main() {
  final l10n = AppLocalizationsEn();

  group('message', () {
    test('location, Plus Code and the trip link; or says the location is missing', () {
      final m = sosMessage(
        l10n,
        place: (lat: 23.0504, lng: 72.517),
        tripLink: Uri.parse('https://x.web.app/t/abc'),
      );
      expect(m, contains('https://maps.google.com/?q=23.050400,72.517000'));
      expect(m, contains('Plus Code'));
      expect(m, endsWith('Follow my live trip: https://x.web.app/t/abc'));
      expect(sosMessage(l10n), "SOS: I need help. My location isn't available right now.");
    });

    test('sms: to every contact, body encoded', () {
      final uri = smsUri([mom.phone, rahul.phone], 'SOS & help?');
      expect(uri.toString(), 'sms:+919876500021,+919876543088?body=SOS%20%26%20help%3F');
      expect(smsUri([], 'x').toString(), 'sms:?body=x');
    });
  });

  group('U1·SOS', () {
    late FakeLocationService location;
    late InMemoryBookingStore store;
    late InMemoryEmergencyContactsRepository contacts;
    late _Network network;
    late _Links links;
    late List<Uri> launched;
    late List<String> shared;
    late bool launchWorks;
    late String supportPhone;

    Future<ProviderContainer> open(
      WidgetTester tester, {
      String language = 'en',
      Size size = const Size(400, 1000),
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
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flavorProvider.overrideWithValue(AppFlavor.dev),
            sharedPreferencesProvider.overrideWithValue(prefs),
            permissionServiceProvider.overrideWithValue(_Permissions()),
            locationServiceProvider.overrideWithValue(location),
            reverseGeocoderProvider.overrideWithValue(FakeGeocoder()),
            bookingStoreProvider.overrideWithValue(store),
            emergencyContactsRepositoryProvider.overrideWithValue(contacts),
            connectivitySourceProvider.overrideWithValue(network),
            shareLinkServiceProvider.overrideWithValue(links),
            shareTextProvider.overrideWithValue((text) async => shared.add(text)),
            launchLinkProvider.overrideWithValue((uri) async {
              launched.add(uri);
              return launchWorks;
            }),
            supportContactsProvider.overrideWithValue((
              phone: supportPhone,
              grievanceEmail: 'g@example.test',
            )),
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

    Future<void> openSheet(WidgetTester tester) async {
      await tester.tap(find.byType(LaneSosButton));
      await tester.pumpAndSettle();
      expect(find.byType(SosSheet), findsOneWidget);
    }

    /// Holds the ring past 1.5 s, the way a finger would.
    Future<void> hold(WidgetTester tester) async {
      final g = await tester.startGesture(tester.getCenter(find.byType(LaneHoldButton)));
      for (var t = 0; t < 1800; t += 100) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pump(LaneHaptics.alertGap);
      await g.up();
      await tester.pumpAndSettle();
    }

    setUp(() {
      location = FakeLocationService();
      store = InMemoryBookingStore();
      contacts = InMemoryEmergencyContactsRepository(const [mom, rahul]);
      network = _Network();
      links = _Links();
      launched = [];
      shared = [];
      launchWorks = true;
      supportPhone = '+919800000000';
    });

    testWidgets('the red SOS button opens the sheet; a tap alone sends nothing', (tester) async {
      await open(tester);
      expect(find.bySemanticsLabel('Emergency SOS'), findsOneWidget);
      expect(tester.getSize(find.byType(LaneSosButton)).width, 64, reason: 'critical target');
      await openSheet(tester);
      expect(find.text('Hold to alert your 2 emergency contacts with your location.'), findsOneWidget);
      await tester.tap(find.byType(LaneHoldButton));
      await tester.pumpAndSettle();
      expect(launched, isEmpty);
      expect(find.text('SHARE TRIP'), findsNothing, reason: 'no booking, no trip to share');
    });

    testWidgets('hold: SMS to both contacts with the location; no booking, no trip link', (tester) async {
      await open(tester);
      location.add(23.0504, 72.5170, 9);
      await tester.pumpAndSettle();
      await openSheet(tester);
      await hold(tester);
      final sms = launched.single;
      expect(sms.scheme, 'sms');
      expect(sms.path, '+919876500021,+919876543088');
      expect(sms.queryParameters['body'], contains('https://maps.google.com/?q=23.050400,72.517000'));
      expect(sms.queryParameters['body'], isNot(contains('/t/')));
      expect(links.asked, isEmpty);
      expect(find.byType(SosSheet), findsNothing);
      expect(find.text('Your messages app has the SOS ready. Press send.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5)); // let the toast go
    });

    testWidgets('during a booking: the live trip link goes in the SMS, and Share trip shares it', (
      tester,
    ) async {
      final c = await open(tester);
      store.put(
        RoadsideFakes.bookingId,
        RoadsideFakes.booking(status: BookingStatus.arriving)
            .copyWith(customerId: FakeBookingService.customerId),
      );
      c
          .read(activeBookingProvider.notifier)
          .set(
            const CreatedBooking(
              bookingId: RoadsideFakes.bookingId,
              cityId: CityId.ahmedabad,
              min: 350,
              max: 600,
            ),
          );
      await tester.pumpAndSettle();
      await openSheet(tester);
      await tester.tap(find.text('SHARE TRIP'));
      await tester.pumpAndSettle();
      expect(shared.single, 'Follow my roadside help trip live: https://roadside-33282.web.app/t/abc123');

      await hold(tester);
      final body = launched.single.queryParameters['body']!;
      expect(body, contains('Follow my live trip: https://roadside-33282.web.app/t/abc123'));
      expect(body, contains('https://maps.google.com/?q='), reason: 'the pickup, without a fresh fix');
      expect(links.asked, [RoadsideFakes.bookingId, RoadsideFakes.bookingId]);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('a slow trip link never holds the SOS back', (tester) async {
      final c = await open(tester);
      store.put(
        RoadsideFakes.bookingId,
        RoadsideFakes.booking(status: BookingStatus.arriving)
            .copyWith(customerId: FakeBookingService.customerId),
      );
      c
          .read(activeBookingProvider.notifier)
          .set(
            const CreatedBooking(
              bookingId: RoadsideFakes.bookingId,
              cityId: CityId.ahmedabad,
              min: 350,
              max: 600,
            ),
          );
      links.delay = const Duration(seconds: 30);
      await tester.pumpAndSettle();
      await openSheet(tester);
      await hold(tester);
      expect(launched, isEmpty, reason: 'still waiting for the link');
      expect(find.text('Opening your messages…'), findsOneWidget);
      await tester.pump(kShareLinkWait);
      await tester.pumpAndSettle();
      expect(launched.single.queryParameters['body'], isNot(contains('/t/')));
      await tester.pump(const Duration(seconds: 30));
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('offline: no link is asked for; the SMS still goes', (tester) async {
      final c = await open(tester);
      store.put(
        RoadsideFakes.bookingId,
        RoadsideFakes.booking(status: BookingStatus.arriving)
            .copyWith(customerId: FakeBookingService.customerId),
      );
      c
          .read(activeBookingProvider.notifier)
          .set(
            const CreatedBooking(
              bookingId: RoadsideFakes.bookingId,
              cityId: CityId.ahmedabad,
              min: 350,
              max: 600,
            ),
          );
      network.set(true);
      await tester.pumpAndSettle();
      await openSheet(tester);
      await hold(tester);
      expect(links.asked, isEmpty);
      expect(launched.single.scheme, 'sms');
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('no contacts: holding still opens messages (to choose), and Add contacts goes to U17', (
      tester,
    ) async {
      contacts = InMemoryEmergencyContactsRepository();
      await open(tester);
      await openSheet(tester);
      expect(
        find.text('No emergency contacts saved. Holding opens your messages so you can choose who to alert.'),
        findsOneWidget,
      );
      await hold(tester);
      expect(launched.single.path, isEmpty);
      await tester.pump(const Duration(seconds: 5));

      await openSheet(tester);
      await tester.tap(find.text('Add emergency contacts'));
      await tester.pumpAndSettle();
      expect(find.byType(EmergencyContactsScreen), findsOneWidget);
    });

    testWidgets('no SMS app: says so and keeps the sheet; Call 112 dials', (tester) async {
      launchWorks = false;
      await open(tester);
      await openSheet(tester);
      await hold(tester);
      expect(find.text("Couldn't open your messages. Call 112."), findsOneWidget);
      expect(find.byType(SosSheet), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      launchWorks = true;
      await tester.tap(find.text('CALL 112'));
      await tester.pumpAndSettle();
      expect(launched.last, Uri(scheme: 'tel', path: '112'));
    });

    testWidgets('tracking has ☀ Glare and SOS on the map', (tester) async {
      final c = await open(tester);
      store.put(
        RoadsideFakes.bookingId,
        RoadsideFakes.booking(status: BookingStatus.arriving)
            .copyWith(customerId: FakeBookingService.customerId),
      );
      unawaited(c.read(routerProvider).push('/booking/${RoadsideFakes.bookingId}'));
      await tester.pumpAndSettle();
      expect(find.byType(LiveBookingScreen), findsOneWidget);
      expect(find.byType(LaneGlareButton), findsOneWidget);
      await tester.tap(find.byType(LaneSosButton));
      await tester.pumpAndSettle();
      expect(find.byType(SosSheet), findsOneWidget);
    });

    testWidgets('fits at 320 px, 200% text, in hi and gu', (tester) async {
      for (final language in ['hi', 'gu']) {
        await open(tester, language: language, size: const Size(320, 800), textScale: 2);
        await openSheet(tester);
        expect(tester.takeException(), isNull, reason: language);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });
  });

  group('offline on Home (SMS fallback)', () {
    late FakeLocationService location;
    late _Network network;
    late List<Uri> launched;
    late String supportPhone;

    Future<void> open(WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({
        'first_run.language': 'en',
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
            permissionServiceProvider.overrideWithValue(_Permissions()),
            locationServiceProvider.overrideWithValue(location),
            reverseGeocoderProvider.overrideWithValue(FakeGeocoder()),
            connectivitySourceProvider.overrideWithValue(network),
            launchLinkProvider.overrideWithValue((uri) async {
              launched.add(uri);
              return true;
            }),
            supportContactsProvider.overrideWithValue((
              phone: supportPhone,
              grievanceEmail: 'g@example.test',
            )),
            laneBatterySourceProvider.overrideWithValue(_NoBattery()),
            laneClockProvider.overrideWithValue(() => RoadsideFakes.now),
          ],
          child: const RoadsideApp(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }

    setUp(() {
      location = FakeLocationService();
      network = _Network();
      launched = [];
      supportPhone = '+919800000000';
    });

    testWidgets('the strip shows, and the big button sends the location by SMS', (tester) async {
      await open(tester);
      location.add(23.0504, 72.5170, 9);
      await tester.pumpAndSettle();
      network.set(true);
      await tester.pumpAndSettle();
      expect(find.byType(OfflineStrip), findsOneWidget);
      expect(
        find.text("You're offline. You can still send your location to our helpline by SMS."),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(LaneButton, 'Send my location by SMS'));
      await tester.pumpAndSettle();
      expect(launched.single.toString(), startsWith('sms:+919800000000?body='));

      network.set(false);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(LaneButton, 'Get help'), findsOneWidget);
    });

    testWidgets('no helpline set: Get help is off and says why', (tester) async {
      supportPhone = '';
      network.offline = true;
      await open(tester);
      location.add(23.0504, 72.5170, 9);
      await tester.pumpAndSettle();
      expect(find.text("You're offline. Getting help needs the internet."), findsOneWidget);
      expect(tester.widget<LaneButton>(find.widgetWithText(LaneButton, 'Get help')).onPressed, isNull);
    });

    testWidgets('no GPS fix yet: never sends the map centre as a location', (tester) async {
      network.offline = true;
      await open(tester);
      expect(find.widgetWithText(LaneButton, 'Send my location by SMS'), findsNothing);
      expect(find.text("You're offline. Getting help needs the internet."), findsOneWidget);
    });
  });
}
