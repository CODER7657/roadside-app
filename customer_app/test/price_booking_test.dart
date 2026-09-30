// #108: U7 Price estimate, the createBooking payload and error mapping, and the fakes.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/app/router.dart';
import 'package:customer_app/features/booking/application/booking_draft.dart';
import 'package:customer_app/features/booking/application/estimate.dart';
import 'package:customer_app/features/booking/data/booking_service.dart';
import 'package:customer_app/features/booking/presentation/price_screen.dart';
import 'package:customer_app/features/booking/presentation/searching_pending_screen.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
import 'package:customer_app/features/help/presentation/help_screen.dart';
import 'package:customer_app/features/vehicles/application/vehicles.dart';
import 'package:customer_app/features/vehicles/data/vehicle_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:roadside_core/roadside_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

const swift = VehicleDraft(
  type: VehicleType.car,
  brand: 'Maruti Suzuki',
  model: 'Swift',
  regNo: 'GJ01AB1234',
  fuel: Fuel.petrol,
);

/// `firebase/seed/data/prices.json` `car_flat_tyre`.
const carFlatTyre = Price(
  vehicleType: VehicleType.car,
  problemType: ProblemType.flatTyre,
  min: 350,
  max: 600,
  includes: 'Puncture repair or spare fitting',
  cityOverrides: {
    CityId.ankleshwar: PriceRange(min: 400, max: 700),
    CityId.bharuch: PriceRange(min: 400, max: 700),
  },
);

const thaltej = PickupDraft(
  lat: 23.0504,
  lng: 72.5170,
  address: 'Near SG Highway, Thaltej',
  accuracyMeters: 9,
  landmark: 'Opposite the petrol pump',
  plusCode: '7JMJ3G28+5R',
);

/// Ankleshwar GIDC: inside both the Ankleshwar and Bharuch circles, nearer Ankleshwar.
const gidc = PickupDraft(lat: 21.6200, lng: 73.0100, address: 'GIDC', accuracyMeters: 12);

/// Mumbai: no service area.
const mumbai = PickupDraft(lat: 19.0760, lng: 72.8777, address: 'Mumbai', accuracyMeters: 10);

BookingDraft draftWith({
  PickupDraft pickup = thaltej,
  String vehicleId = 'v1',
  List<DraftPhoto> photos = const [],
}) => BookingDraft(
  draftId: 'draft-1',
  idempotencyKey: 'AbCdEfGhIjKlMnOpQrStUv',
  vehicleId: vehicleId,
  problem: ProblemType.flatTyre,
  description: '  Rear tyre flat  ',
  photos: photos,
  pickup: pickup,
);

/// Records calls; each answer is set by the test.
class ScriptedBookingService implements BookingService {
  final keys = <String>[];
  final answers = <FutureOr<CreatedBooking> Function()>[];

  @override
  Future<CreatedBooking> createBooking(BookingDraft draft) async {
    keys.add(draft.idempotencyKey);
    return answers.removeAt(0)();
  }
}

const created = CreatedBooking(bookingId: 'b1', cityId: CityId.ahmedabad, min: 350, max: 600);

void main() {
  group('createBookingPayload', () {
    test('is exactly the shape the createBooking zod schema accepts', () {
      final draft = draftWith(
        photos: [
          DraftPhoto(
            id: 'p1',
            bytes: Uint8List(1),
            state: PhotoUploadState.done,
            url: 'https://firebasestorage.googleapis.com/a',
          ),
          DraftPhoto(id: 'p2', bytes: Uint8List(1), state: PhotoUploadState.failed),
        ],
      );
      final payload = createBookingPayload(draft);
      expect(payload.keys.toSet(), {
        'idempotencyKey',
        'vehicleId',
        'problemType',
        'description',
        'photoUrls',
        'pickup',
        'pinConfirmed',
      });
      expect(payload['idempotencyKey'], matches(RegExp(r'^[A-Za-z0-9_-]{16,64}$')));
      expect(payload['problemType'], 'flat_tyre');
      expect(payload['description'], 'Rear tyre flat', reason: 'trimmed');
      expect(payload['photoUrls'], [
        'https://firebasestorage.googleapis.com/a',
      ], reason: 'only uploaded photos');
      expect(payload['pinConfirmed'], isTrue);
      final pickup = payload['pickup']! as Map<String, Object?>;
      // zod strictObject: no extra keys.
      expect(pickup.keys.toSet(), {'lat', 'lng', 'address', 'landmark', 'plusCode', 'accuracyMeters'});
      expect(pickup['accuracyMeters'], 9);
      // Round-trips through JSON (what the callable sends).
      expect(jsonDecode(jsonEncode(payload)), payload);
    });
  });

  group('bookingExceptionFrom', () {
    test('maps every createBooking / secureCall error', () {
      expect(
        bookingExceptionFrom('failed-precondition', 'error_out_of_area', null).code,
        BookingException.outOfArea,
      );
      final active = bookingExceptionFrom('failed-precondition', 'error_active_booking_exists', {
        'bookingId': 'b9',
      });
      expect(active.code, BookingException.activeBookingExists);
      expect(active.activeBookingId, 'b9');
      expect(
        bookingExceptionFrom('unavailable', 'error_service_paused', null).code,
        BookingException.servicePaused,
      );
      expect(
        bookingExceptionFrom('resource-exhausted', 'error_rate_limited', null).code,
        BookingException.rateLimited,
      );
      expect(
        bookingExceptionFrom('not-found', 'error_vehicle_not_found', null).code,
        BookingException.vehicleNotFound,
      );
    });

    test('transport failures are network errors; anything unexpected is unknown', () {
      expect(bookingExceptionFrom('unavailable', null, null).code, BookingException.network);
      expect(bookingExceptionFrom('unavailable', 'Service Unavailable', null).code, BookingException.network);
      expect(bookingExceptionFrom('deadline-exceeded', null, null).code, BookingException.network);
      expect(bookingExceptionFrom('internal', 'INTERNAL', null).code, BookingException.unknown);
      expect(
        bookingExceptionFrom(
          'failed-precondition',
          'error_active_booking_exists',
          'not a map',
        ).activeBookingId,
        isNull,
      );
    });
  });

  group('InMemoryPriceCatalog', () {
    test('launch areas match firebase/seed/data/serviceAreas.json', () {
      final seed = jsonDecode(
        File('../firebase/seed/data/serviceAreas.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      expect(seed.keys.toSet(), {for (final c in InMemoryPriceCatalog.launchAreas.keys) c.value});
      for (final MapEntry(key: city, value: area) in InMemoryPriceCatalog.launchAreas.entries) {
        final s = seed[city.value] as Map<String, dynamic>;
        expect([area.center.latitude, area.center.longitude], s['center'], reason: city.value);
        expect(area.radiusKm, (s['radiusKm'] as num).toDouble(), reason: city.value);
        expect(area.name.en, (s['name'] as Map)['en']);
      }
    });

    test('the price fixture matches the seed', () {
      final seed =
          jsonDecode(File('../firebase/seed/data/prices.json').readAsStringSync()) as Map<String, dynamic>;
      final s = seed[Price.idFor(VehicleType.car, ProblemType.flatTyre)] as Map<String, dynamic>;
      expect((carFlatTyre.min, carFlatTyre.max, carFlatTyre.includes), (s['min'], s['max'], s['includes']));
    });
  });

  group('FakeBookingService', () {
    late FakeBookingService service;
    setUp(() {
      service = FakeBookingService(
        InMemoryPriceCatalog(prices: {Price.idFor(VehicleType.car, ProblemType.flatTyre): carFlatTyre}),
        (id) async => id == 'v1' ? VehicleType.car : null,
      );
    });

    test('the same key returns the same booking; a new key a new one', () async {
      final a = await service.createBooking(draftWith());
      final b = await service.createBooking(draftWith());
      expect(b.bookingId, a.bookingId);
      const other = BookingDraft(
        draftId: 'd2',
        idempotencyKey: 'ZZZZZZZZZZZZZZZZZZZZZZ',
        vehicleId: 'v1',
        problem: ProblemType.flatTyre,
        pickup: thaltej,
      );
      expect((await service.createBooking(other)).bookingId, isNot(a.bookingId));
    });

    test('city override where the circles overlap goes to the nearer city', () async {
      final b = await service.createBooking(draftWith(pickup: gidc));
      expect(b.cityId, CityId.ankleshwar);
      expect((b.min, b.max), (400, 700));
    });

    test('out of area, unknown vehicle and missing price', () async {
      await expectLater(
        service.createBooking(draftWith(pickup: mumbai)),
        throwsA(isA<BookingException>().having((e) => e.code, 'code', BookingException.outOfArea)),
      );
      await expectLater(
        service.createBooking(draftWith(vehicleId: 'gone')),
        throwsA(isA<BookingException>().having((e) => e.code, 'code', BookingException.vehicleNotFound)),
      );
      final noPrices = FakeBookingService(InMemoryPriceCatalog(), (id) async => VehicleType.car);
      await expectLater(
        noPrices.createBooking(draftWith()),
        throwsA(isA<BookingException>().having((e) => e.code, 'code', BookingException.priceUnavailable)),
      );
    });
  });

  group('U7 screen', () {
    late InMemoryVehicleRepository vehicles;
    late ScriptedBookingService service;
    late String vehicleId;
    late ProviderContainer container;

    Future<void> openU7(WidgetTester tester, {PickupDraft pickup = thaltej, String language = 'en'}) async {
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
            vehicleRepositoryProvider.overrideWithValue(vehicles),
            priceCatalogProvider.overrideWithValue(
              InMemoryPriceCatalog(prices: {Price.idFor(VehicleType.car, ProblemType.flatTyre): carFlatTyre}),
            ),
            bookingServiceProvider.overrideWithValue(service),
            laneBatterySourceProvider.overrideWithValue(_NoBattery()),
            laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 29, 6, 30)),
          ],
          child: const RoadsideApp(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
      container.read(bookingDraftProvider.notifier)
        ..start(vehicleId: vehicleId)
        ..setProblem(ProblemType.flatTyre)
        ..setPickup(pickup);
      unawaited(container.read(routerProvider).push(AppRoutes.bookPrice));
      await tester.pumpAndSettle();
      expect(find.byType(PriceScreen), findsOneWidget);
    }

    /// Searching breathes forever, so pump a while instead of settling.
    Future<void> pumpAWhile(WidgetTester tester) async {
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    LaneButton book(WidgetTester tester) =>
        tester.widget<LaneButton>(find.widgetWithText(LaneButton, 'Book mechanic'));

    void tall(WidgetTester tester) {
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    setUp(() async {
      vehicles = InMemoryVehicleRepository();
      vehicleId = await vehicles.add(swift);
      service = ScriptedBookingService();
    });

    testWidgets('shows what, where and the range; Book goes to Searching and replaces the flow', (
      tester,
    ) async {
      tall(tester);
      service.answers.add(() => created);
      await openU7(tester);
      expect(find.text('Step 4 of 4'), findsOneWidget);
      expect(find.text('Maruti Suzuki Swift · Flat tyre'), findsOneWidget);
      expect(find.text('Near SG Highway, Thaltej'), findsOneWidget);
      expect(find.text('₹350–₹600'), findsOneWidget);
      expect(find.text('Puncture repair or spare fitting'), findsOneWidget);

      await tester.tap(find.text('Book mechanic'));
      await pumpAWhile(tester);
      expect(find.byType(SearchingPendingScreen), findsOneWidget);
      expect(container.read(activeBookingProvider)?.bookingId, 'b1');
      expect(
        container.read(routerProvider).canPop(),
        isFalse,
        reason: 'back from Searching never returns to U7',
      );
    });

    testWidgets('the city override is shown for Ankleshwar', (tester) async {
      tall(tester);
      await openU7(tester, pickup: gidc);
      expect(find.text('₹400–₹700'), findsOneWidget);
    });

    testWidgets('a double tap books once', (tester) async {
      tall(tester);
      final slow = Completer<CreatedBooking>();
      service.answers.add(() => slow.future);
      await openU7(tester);
      await tester.tap(find.text('Book mechanic'));
      await tester.pump();
      expect(book(tester).loading, isTrue);
      await tester.tap(find.text('Book mechanic'), warnIfMissed: false);
      await tester.pump();
      expect(service.keys, hasLength(1));
      slow.complete(created);
      await pumpAWhile(tester);
      expect(find.byType(SearchingPendingScreen), findsOneWidget);
    });

    testWidgets('a network error keeps the key: the retry is the same booking', (tester) async {
      tall(tester);
      service.answers
        ..add(() => throw const BookingException(BookingException.network))
        ..add(() => created);
      await openU7(tester);
      await tester.tap(find.text('Book mechanic'));
      await pumpAWhile(tester);
      expect(find.text("Couldn't book. Check your connection and try again."), findsOneWidget);
      expect(book(tester).onPressed, isNotNull);
      await tester.tap(find.text('Book mechanic'));
      await pumpAWhile(tester);
      expect(service.keys, hasLength(2));
      expect(service.keys.toSet(), hasLength(1), reason: 'same idempotencyKey both times');
      expect(find.byType(SearchingPendingScreen), findsOneWidget);
    });

    testWidgets('out of area: said up front, Book is off, Change pickup goes back', (tester) async {
      tall(tester);
      await openU7(tester, pickup: mumbai);
      expect(find.textContaining("We're not in this area yet"), findsOneWidget);
      expect(book(tester).onPressed, isNull);
      expect(service.keys, isEmpty);
      await tester.tap(find.text('CHANGE PICKUP'));
      await tester.pumpAndSettle();
      expect(find.byType(PriceScreen), findsNothing);
    });

    testWidgets('an active booking elsewhere: Open my booking', (tester) async {
      tall(tester);
      service.answers.add(
        () => throw const BookingException(BookingException.activeBookingExists, activeBookingId: 'b0'),
      );
      await openU7(tester);
      await tester.tap(find.text('Book mechanic'));
      await pumpAWhile(tester);
      expect(find.text('You already have a booking in progress.'), findsOneWidget);
      await tester.tap(find.text('OPEN MY BOOKING'));
      await pumpAWhile(tester);
      expect(find.byType(SearchingPendingScreen), findsOneWidget);
    });

    testWidgets('paused, then retried successfully; rate limited says wait', (tester) async {
      tall(tester);
      service.answers
        ..add(() => throw const BookingException(BookingException.servicePaused))
        ..add(() => throw const BookingException(BookingException.rateLimited))
        ..add(() => created);
      await openU7(tester);
      await tester.tap(find.text('Book mechanic'));
      await pumpAWhile(tester);
      expect(find.textContaining('Bookings are paused'), findsOneWidget);
      await tester.tap(find.text('Book mechanic'));
      await pumpAWhile(tester);
      expect(find.textContaining('Too many tries'), findsOneWidget);
      expect(find.textContaining('Bookings are paused'), findsNothing, reason: 'old error cleared');
      await tester.tap(find.text('Book mechanic'));
      await pumpAWhile(tester);
      expect(find.byType(SearchingPendingScreen), findsOneWidget);
    });

    testWidgets('no price for this problem: Get support opens Help', (tester) async {
      tall(tester);
      await openU7(tester);
      container.read(bookingDraftProvider.notifier).setProblem(ProblemType.other);
      await tester.pumpAndSettle();
      expect(find.textContaining("We can't price this problem yet"), findsOneWidget);
      expect(book(tester).onPressed, isNull);
      await tester.tap(find.text('GET SUPPORT'));
      await tester.pumpAndSettle();
      expect(find.byType(HelpScreen), findsOneWidget);
    });

    testWidgets('a vehicle deleted meanwhile: Choose vehicle', (tester) async {
      tall(tester);
      await openU7(tester);
      await vehicles.delete(vehicleId);
      await tester.pumpAndSettle();
      expect(find.text('This vehicle was removed. Choose another one.'), findsOneWidget);
      expect(book(tester).onPressed, isNull);
    });

    testWidgets('fits at 320 px, 200% text, Hindi', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openU7(tester, language: 'hi');
      expect(find.text('आपका अनुमान'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
