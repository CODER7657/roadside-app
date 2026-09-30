// #133: U12 Job in progress, U13 Payment, the UPI link and the payment fakes.
import 'dart:async';

import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/app/router.dart';
import 'package:customer_app/features/booking/application/estimate.dart';
import 'package:customer_app/features/booking/data/booking_repository.dart';
import 'package:customer_app/features/booking/data/booking_service.dart';
import 'package:customer_app/features/booking/data/upi.dart';
import 'package:customer_app/features/booking/presentation/finish_views.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
import 'package:customer_app/features/help/presentation/help_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

Booking done({PaymentStatus payment = PaymentStatus.pending, int? amount = 450, String? upiId}) {
  final b = RoadsideFakes.booking(status: BookingStatus.completed, paymentStatus: payment);
  return b.copyWith(
    customerId: FakeBookingService.customerId,
    finalAmount: amount,
    mechanicCard: upiId == null ? b.mechanicCard : b.mechanicCard!.copyWith(upiId: upiId),
  );
}

void main() {
  group('upiPayUri', () {
    test('the NPCI fields, amount fixed with 2 decimals, spaces as %20 not +', () {
      final uri = upiPayUri(
        upiId: 'kiran.patel@okaxis',
        payeeName: 'Kiran Patel',
        amount: 450,
        bookingId: 'aB3-x9Qz12pq',
      )!;
      expect(
        uri.toString(),
        'upi://pay?pa=kiran.patel@okaxis&pn=Kiran%20Patel&am=450.00&cu=INR&tn=Booking%20AB3X9QZ1',
      );
      expect(uri.scheme, 'upi');
      expect(uri.host, 'pay');
      expect(uri.queryParameters['pn'], 'Kiran Patel');
      expect(uri.queryParameters['am'], '450.00');
    });

    test('names with & or = cannot inject parameters', () {
      final uri = upiPayUri(upiId: 'a.b@okicici', payeeName: 'A&am=1&B', amount: 999, bookingId: 'x')!;
      expect(uri.queryParameters['am'], '999.00');
      expect(uri.queryParameters['pn'], 'A&am=1&B');
      expect(uri.queryParametersAll['am'], ['999.00']);
    });

    test('no link for a malformed UPI ID or a non-positive amount', () {
      for (final bad in [
        '',
        'kiran',
        '@okaxis',
        'kiran@',
        'kiran@@okaxis',
        'ki ran@okaxis',
        'kiran@ok axis',
        'a@1bank',
        'x&pa=evil@ybl',
      ]) {
        expect(
          upiPayUri(upiId: bad, payeeName: 'K', amount: 100, bookingId: 'b'),
          isNull,
          reason: bad,
        );
      }
      expect(upiPayUri(upiId: 'kiran@okaxis', payeeName: 'K', amount: 0, bookingId: 'b'), isNull);
      expect(upiPayUri(upiId: 'kiran@okaxis', payeeName: 'K', amount: -5, bookingId: 'b'), isNull);
      expect(
        upiPayUri(upiId: '  kiran@okaxis ', payeeName: 'K', amount: 5, bookingId: 'b')!.queryParameters['pa'],
        'kiran@okaxis',
      );
    });

    test('the booking note is short and safe', () {
      expect(bookingNote('fakeBooking00000001'), 'Booking FAKEBOOK');
      expect(bookingNote('ab'), 'Booking AB');
      expect(bookingNote('--__'), 'Booking ');
    });
  });

  group('FakeBookingService payments follow the #128 table', () {
    late InMemoryBookingStore store;
    late FakeBookingService service;
    setUp(() {
      store = InMemoryBookingStore();
      service = FakeBookingService(InMemoryPriceCatalog(), (_) async => null, store: store);
    });

    test('pending → marked paid; then no second markPaid', () async {
      store.put(id, done());
      await service.markPaid(id);
      expect(store[id]!.paymentStatus, PaymentStatus.customerMarkedPaid);
      await expectLater(
        service.markPaid(id),
        throwsA(isA<BookingException>().having((e) => e.code, 'code', BookingException.invalidPaymentStatus)),
      );
    });

    test('dispute from pending or marked paid; never after confirmed', () async {
      store.put(id, done());
      await service.disputePayment(id, 'asked for more');
      expect(store[id]!.paymentStatus, PaymentStatus.disputed);
      store.put(id, done(payment: PaymentStatus.customerMarkedPaid));
      await service.disputePayment(id, 'not received');
      expect(store[id]!.paymentStatus, PaymentStatus.disputed);
      store.put(id, done(payment: PaymentStatus.confirmed));
      await expectLater(service.disputePayment(id, 'late'), throwsA(isA<BookingException>()));
    });

    test('only on a completed booking of the customer', () async {
      store.put(
        id,
        RoadsideFakes.booking(status: BookingStatus.inProgress)
            .copyWith(customerId: FakeBookingService.customerId),
      );
      await expectLater(
        service.markPaid(id),
        throwsA(isA<BookingException>().having((e) => e.code, 'code', BookingException.invalidStatus)),
      );
      store.put(id, RoadsideFakes.booking(status: BookingStatus.completed));
      await expectLater(
        service.markPaid(id),
        throwsA(isA<BookingException>().having((e) => e.code, 'code', BookingException.bookingNotFound)),
      );
    });
  });

  group('screens', () {
    late InMemoryBookingStore store;
    late FakeBookingService service;
    late List<Uri> launched;
    late bool launchOk;
    late List<String> clipboard;

    Future<void> open(WidgetTester tester, {String language = 'en'}) async {
      SharedPreferences.setMockInitialValues({
        'first_run.language': language,
        'first_run.onboarded': true,
        'first_run.consent_version': kConsentVersion,
        'first_run.consent_at': '2026-09-29T10:15:00.000Z',
      });
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') clipboard.add((call.arguments as Map)['text'] as String);
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flavorProvider.overrideWithValue(AppFlavor.dev),
            sharedPreferencesProvider.overrideWithValue(prefs),
            bookingStoreProvider.overrideWithValue(store),
            bookingServiceProvider.overrideWithValue(service),
            launchLinkProvider.overrideWithValue((uri) async {
              launched.add(uri);
              return launchOk;
            }),
            laneBatterySourceProvider.overrideWithValue(_NoBattery()),
            laneClockProvider.overrideWithValue(() => RoadsideFakes.now),
          ],
          child: const RoadsideApp(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      ProviderScope.containerOf(tester.element(find.byType(Scaffold).first))
          .read(routerProvider)
          .go(AppRoutes.booking(id));
      await tester.pumpAndSettle();
    }

    void tall(WidgetTester tester) {
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    Future<void> tapText(WidgetTester tester, String text) async {
      await tester.ensureVisible(find.text(text));
      await tester.pumpAndSettle();
      await tester.tap(find.text(text));
      await tester.pumpAndSettle();
    }

    setUp(() {
      store = InMemoryBookingStore();
      service = FakeBookingService(InMemoryPriceCatalog(), (_) async => null, store: store);
      launched = [];
      launchOk = true;
      clipboard = [];
    });

    testWidgets('U12: who is working and for how long; no Cancel', (tester) async {
      tall(tester);
      final b = RoadsideFakes.booking(status: BookingStatus.inProgress);
      store.put(id, b.copyWith(customerId: FakeBookingService.customerId));
      await open(tester);
      expect(find.byType(WorkingView), findsOneWidget);
      expect(find.text('Kiran Patel is working on it'), findsOneWidget);
      final minutes = RoadsideFakes.now.difference(b.timestamps.started!).inMinutes;
      expect(find.textContaining('$minutes min so far'), findsOneWidget);
      expect(find.text('Cancel booking'), findsNothing);
    });

    testWidgets('U13: the amount, payee, QR; Pay opens the exact UPI link', (tester) async {
      tall(tester);
      store.put(id, done(upiId: 'kiran.patel@okaxis'));
      await open(tester);
      expect(find.byType(PaymentView), findsOneWidget);
      expect(find.text('₹450'), findsOneWidget);
      expect(find.text('The estimate was ₹350–₹600'), findsOneWidget);
      expect(find.text('kiran.patel@okaxis'), findsOneWidget);
      expect(find.byType(LaneQrCode), findsOneWidget);
      final qr = tester.widget<LaneQrCode>(find.byType(LaneQrCode));

      await tapText(tester, 'Pay with UPI app');
      final uri = launched.single;
      expect(uri.scheme, 'upi');
      expect(uri.queryParameters['pa'], 'kiran.patel@okaxis');
      expect(uri.queryParameters['am'], '450.00');
      expect(qr.data, uri.toString(), reason: 'the QR is the same link');
    });

    testWidgets('no UPI app: says what to do instead', (tester) async {
      tall(tester);
      launchOk = false;
      store.put(id, done(upiId: 'kiran.patel@okaxis'));
      await open(tester);
      await tapText(tester, 'Pay with UPI app');
      expect(find.textContaining('No UPI app opened'), findsOneWidget);
      await tester.pump(LaneToast.visibleFor);
    });

    testWidgets('copy UPI ID', (tester) async {
      tall(tester);
      store.put(id, done(upiId: 'kiran.patel@okaxis'));
      await open(tester);
      await tapText(tester, 'Copy UPI ID');
      expect(clipboard, ['kiran.patel@okaxis']);
      expect(find.text('UPI ID copied'), findsOneWidget);
      await tester.pump(LaneToast.visibleFor);
    });

    testWidgets('a malformed UPI ID: no pay link or QR, pay in cash, I have paid still works', (
      tester,
    ) async {
      tall(tester);
      store.put(id, done(upiId: 'not-a-upi-id'));
      await open(tester);
      expect(find.text('Pay with UPI app'), findsNothing);
      expect(find.byType(LaneQrCode), findsNothing);
      expect(find.text('Pay Kiran Patel in cash, or ask them for their UPI ID.'), findsOneWidget);
      await tapText(tester, 'I HAVE PAID');
      expect(store[id]!.paymentStatus, PaymentStatus.customerMarkedPaid);
    });

    testWidgets('I have paid → waiting for the mechanic → confirmed', (tester) async {
      tall(tester);
      store.put(id, done(upiId: 'kiran.patel@okaxis'));
      await open(tester);
      await tapText(tester, 'I HAVE PAID');
      expect(find.text('Waiting for Kiran Patel to confirm'), findsOneWidget);
      expect(find.text('They check that ₹450 arrived in their UPI app.'), findsOneWidget);

      store.put(id, done(payment: PaymentStatus.confirmed));
      await tester.pumpAndSettle();
      expect(find.text('Paid ₹450'), findsOneWidget);
      expect(find.text('Thank you! Kiran Patel confirmed your payment.'), findsOneWidget);
    });

    testWidgets('something is wrong: a description is required, then disputed', (tester) async {
      tall(tester);
      store.put(id, done(upiId: 'kiran.patel@okaxis'));
      await open(tester);
      await tapText(tester, "Something's wrong");
      final send = find.widgetWithText(LaneButton, 'Report problem');
      expect(tester.widget<LaneButton>(send).onPressed, isNull);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      expect(tester.widget<LaneButton>(send).onPressed, isNull, reason: 'blank is not a description');
      await tester.enterText(find.byType(TextField), 'Asked for ₹200 more');
      await tester.pump();
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(store[id]!.paymentStatus, PaymentStatus.disputed);
      expect(find.text("We're looking into it"), findsOneWidget);
      await tester.pump(LaneToast.visibleFor);
    });

    testWidgets('a network failure on I have paid: a message, and nothing changes', (tester) async {
      tall(tester);
      store.put(id, done(upiId: 'kiran.patel@okaxis'));
      service.failNext = const BookingException(BookingException.network);
      await open(tester);
      await tapText(tester, 'I HAVE PAID');
      expect(find.textContaining("Couldn't update the payment"), findsOneWidget);
      expect(store[id]!.paymentStatus, PaymentStatus.pending);
      await tester.pump(LaneToast.visibleFor);
    });

    testWidgets('the mechanic already moved it on: no error, the screen just follows', (tester) async {
      tall(tester);
      store.put(id, done(upiId: 'kiran.patel@okaxis'));
      service.failNext = const BookingException(BookingException.invalidPaymentStatus);
      await open(tester);
      await tapText(tester, 'I HAVE PAID');
      expect(find.textContaining("Couldn't update the payment"), findsNothing);
    });

    testWidgets('no final amount yet: says so, and I have paid is off', (tester) async {
      tall(tester);
      store.put(id, done(amount: null, upiId: 'kiran.patel@okaxis'));
      await open(tester);
      expect(find.text('Waiting for the mechanic to enter the final amount.'), findsOneWidget);
      expect(tester.widget<LaneButton>(find.widgetWithText(LaneButton, 'I HAVE PAID')).onPressed, isNull);
    });

    for (final payment in [PaymentStatus.pending, PaymentStatus.customerMarkedPaid, PaymentStatus.disputed]) {
      testWidgets('$payment fits at 320 px, 200% text, Hindi', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        store.put(id, done(payment: payment, upiId: 'kiran.patel@okaxis'));
        await open(tester, language: 'hi');
        expect(tester.takeException(), isNull);
      });
    }
  });
}
