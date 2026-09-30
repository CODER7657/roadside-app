// #33: M7 Job complete + M8 Payment confirmation.
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:mechanic_app/app/app.dart';
import 'package:mechanic_app/app/flavor.dart';
import 'package:mechanic_app/features/dashboard/application/online.dart';
import 'package:mechanic_app/features/dashboard/data/location_service.dart';
import 'package:mechanic_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:mechanic_app/features/first_run/application/first_run.dart';
import 'package:mechanic_app/features/job/application/job.dart';
import 'package:mechanic_app/features/job/data/job_repository.dart';
import 'package:mechanic_app/features/job/presentation/complete_job_screen.dart';
import 'package:mechanic_app/features/job/presentation/payment_view.dart';
import 'package:mechanic_app/features/offers/application/offers.dart';
import 'package:mechanic_app/features/permissions/application/permission_service.dart';
import 'package:mechanic_app/features/registration/application/registration.dart';
import 'package:mechanic_app/features/registration/data/mechanic_photos.dart';
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

/// A real 1×1 PNG, so Image.memory can decode it.
final tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

class _FakePicker implements PhotoPicker {
  int picks = 0;

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    picks++;
    return tinyPng;
  }
}

const pickup = GeoPoint(23.0225, 72.5714);

Booking booking(BookingStatus status, {PaymentStatus payment = PaymentStatus.pending, int? finalAmount}) =>
    Booking.fromJson({
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
      'finalAmount': ?finalAmount,
      'paymentStatus': payment.value,
      'customerCard': {'name': 'Priya Shah', 'phone': '+919812345678'},
      'idempotencyKey': 'k-1',
    });

void main() {
  group('M7 / M8 logic', () {
    const estimate = PriceRange(min: 350, max: 600);

    test('the amount rule matches completeJob: 0.5× the minimum to 3× the maximum', () {
      expect(amountBounds(estimate), (min: 175, max: 1800));
      expect(amountNeedsReason(175, estimate), isFalse);
      expect(amountNeedsReason(1800, estimate), isFalse);
      expect(amountNeedsReason(174, estimate), isTrue);
      expect(amountNeedsReason(1801, estimate), isTrue);
    });

    test('completeJob and payment errors map to outcomes', () {
      expect(
        completeResultForError('error_amount_reason_required', {'min': 175, 'max': 1800}),
        isA<AmountNeedsReason>().having((r) => r.max, 'max', 1800),
      );
      expect(
        completeResultForError('error_photo_invalid', null),
        isA<CompleteRejected>().having((r) => r.problem, 'problem', CompleteProblem.photoInvalid),
      );
      expect(
        completeResultForError('error_invalid_status', null),
        isA<CompleteRejected>().having((r) => r.problem, 'problem', CompleteProblem.invalidStatus),
      );
      expect(
        completeResultForError('error_internal', null),
        isA<CompleteRejected>().having((r) => r.problem, 'problem', CompleteProblem.failed),
      );
      expect(paymentOutcomeForError('error_invalid_status'), PaymentOutcome.invalidStatus);
      expect(paymentOutcomeForError('error_internal'), PaymentOutcome.failed);
    });

    test('the fake follows §9: complete, then the customer marks paid, then confirm', () async {
      final jobs = InMemoryJobRepository({'b-1': booking(BookingStatus.inProgress)});
      expect(
        await jobs.completeJob('b-1', finalAmount: 5000, beforePhotoUrls: [], afterPhotoUrls: ['u']),
        isA<AmountNeedsReason>(),
      );
      expect(
        await jobs.completeJob('b-1', finalAmount: 450, beforePhotoUrls: [], afterPhotoUrls: ['u']),
        isA<JobCompleted>(),
      );
      expect(await jobs.confirmPayment('b-1'), PaymentOutcome.invalidStatus, reason: 'not marked paid yet');
      jobs.setPayment('b-1', PaymentStatus.customerMarkedPaid);
      expect(await jobs.confirmPayment('b-1'), PaymentOutcome.ok);
    });
  });

  group('M7 / M8 screens', () {
    late InMemoryJobRepository jobs;
    late FakeWorkPhotoUploader uploader;
    late _FakePicker picker;

    Future<Widget> app(Booking b, {String language = 'en'}) async {
      SharedPreferences.setMockInitialValues({
        'first_run.language': language,
        'first_run.onboarded': true,
        'first_run.consent_version': kConsentVersion,
        'first_run.consent_at': '2026-09-30T10:15:00.000Z',
      });
      final prefs = await SharedPreferences.getInstance();
      jobs = InMemoryJobRepository({'b-1': b});
      return ProviderScope(
        overrides: [
          flavorProvider.overrideWithValue(AppFlavor.dev),
          sharedPreferencesProvider.overrideWithValue(prefs),
          registrationRepositoryProvider.overrideWithValue(approvedMechanic()),
          jobRepositoryProvider.overrideWithValue(jobs),
          workPhotoUploaderProvider.overrideWithValue(uploader),
          photoPickerProvider.overrideWithValue(picker),
          photoCompressorProvider.overrideWithValue(PhotoCompressor(encode: (bytes, quality) async => bytes)),
          locationServiceProvider.overrideWithValue(_NoLocation()),
          permissionServiceProvider.overrideWithValue(_GrantAll()),
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 30, 6, 30)),
        ],
        child: const MechanicApp(),
      );
    }

    Future<void> go(WidgetTester tester, String route) async {
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      GoRouter.of(tester.element(find.byType(DashboardScreen))).go(route);
      await tester.pumpAndSettle();
    }

    Future<void> tapText(WidgetTester tester, String text) async {
      await tester.ensureVisible(find.text(text).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(text).first);
      await tester.pumpAndSettle();
    }

    Future<void> addPhoto(WidgetTester tester, int index) async {
      final add = find.text('Add photo');
      await tester.ensureVisible(add.at(index));
      await tester.pumpAndSettle();
      await tester.tap(add.at(index));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Take a photo'));
      await tester.pumpAndSettle();
    }

    Future<void> slide(WidgetTester tester) async {
      final slider = find.byType(LaneSlideToConfirm);
      await tester.ensureVisible(slider);
      final box = tester.getRect(slider);
      await tester.timedDragFrom(
        Offset(box.left + 24, box.center.dy),
        Offset(box.width, 0),
        const Duration(milliseconds: 400),
      );
      await tester.pumpAndSettle();
    }

    Future<void> typeAmount(WidgetTester tester, String amount) async {
      final field = find.descendant(
        of: find.byKey(const ValueKey('finalAmount')),
        matching: find.byType(TextField),
      );
      await tester.ensureVisible(field);
      await tester.enterText(field, amount);
      await tester.pumpAndSettle();
    }

    setUp(() {
      uploader = FakeWorkPhotoUploader();
      picker = _FakePicker();
    });

    testWidgets('M5 in progress → Finish the job → M7', (tester) async {
      await tester.pumpWidget(await app(booking(BookingStatus.inProgress)));
      await go(tester, jobRoute('b-1'));
      expect(find.text('Job in progress'), findsOneWidget);
      await tapText(tester, 'Finish the job');
      expect(find.byType(CompleteJobScreen), findsOneWidget);
      expect(find.text('Estimate was ₹350–₹600'), findsOneWidget);
    });

    testWidgets('slide with nothing: says what is missing, calls nothing', (tester) async {
      await tester.pumpWidget(await app(booking(BookingStatus.inProgress)));
      await go(tester, completeJobRoute('b-1'));
      await slide(tester);
      expect(find.text('Add at least one photo of the finished work.'), findsOneWidget);
      expect(find.text("Enter the amount you're charging."), findsOneWidget);
      expect(jobs.calls, isEmpty);
    });

    testWidgets('after photo + amount → uploads to work/, completes, M8 waits for payment', (tester) async {
      await tester.pumpWidget(await app(booking(BookingStatus.inProgress)));
      await go(tester, completeJobRoute('b-1'));
      await addPhoto(tester, 0);
      await typeAmount(tester, '450');
      await slide(tester);
      expect(uploader.uploaded.single, startsWith('bookings/b-1/work/after-'));
      expect(jobs.calls, ['completeJob:b-1']);
      expect(find.byType(PaymentView), findsOneWidget);
      expect(find.text('Waiting for payment'), findsOneWidget);
      expect(find.text('₹450'), findsOneWidget);
    });

    testWidgets('an amount outside 0.5×–3× needs a reason', (tester) async {
      await tester.pumpWidget(await app(booking(BookingStatus.inProgress)));
      await go(tester, completeJobRoute('b-1'));
      await addPhoto(tester, 0);
      await typeAmount(tester, '5000');
      // Below the fold on a phone-sized test screen.
      await tester.scrollUntilVisible(
        find.textContaining('outside the usual range'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('This is outside the usual range (₹175–₹1,800). Why?'), findsOneWidget);
      await slide(tester);
      expect(find.text('Pick a reason.'), findsOneWidget);
      expect(jobs.calls, isEmpty);
      await tapText(tester, 'Parts');
      await slide(tester);
      expect(jobs.calls, ['completeJob:b-1']);
      expect(find.text('Waiting for payment'), findsOneWidget);
    });

    testWidgets('an upload failure says so and stays on M7', (tester) async {
      await tester.pumpWidget(await app(booking(BookingStatus.inProgress)));
      await go(tester, completeJobRoute('b-1'));
      await addPhoto(tester, 0);
      await typeAmount(tester, '450');
      uploader.failNext = 1;
      await slide(tester);
      expect(find.textContaining("didn't upload"), findsOneWidget);
      expect(find.byType(CompleteJobScreen), findsOneWidget);
      expect(jobs.calls, isEmpty);
      await tester.pump(LaneToast.visibleFor);
    });

    testWidgets('M8: the customer says they paid → Yes, received → confirmed', (tester) async {
      await tester.pumpWidget(
        await app(
          booking(BookingStatus.completed, payment: PaymentStatus.customerMarkedPaid, finalAmount: 450),
        ),
      );
      await go(tester, jobRoute('b-1'));
      expect(find.text('Customer says they paid'), findsOneWidget);
      expect(find.text('₹450'), findsOneWidget);
      expect(find.text('Check your UPI app for a payment from Priya.'), findsOneWidget);
      await tapText(tester, 'Yes, received');
      expect(jobs.calls, ['confirmPayment:b-1']);
      expect(find.text('Payment received'), findsOneWidget);
    });

    testWidgets('M8: Not received → what went wrong → disputed', (tester) async {
      await tester.pumpWidget(
        await app(
          booking(BookingStatus.completed, payment: PaymentStatus.customerMarkedPaid, finalAmount: 450),
        ),
      );
      await go(tester, jobRoute('b-1'));
      await tapText(tester, 'NOT RECEIVED');
      expect(find.text('What went wrong?'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, 'Nothing came in my UPI app');
      await tester.pumpAndSettle();
      await tapText(tester, 'Report it');
      expect(jobs.disputes, ['Nothing came in my UPI app']);
      expect(find.text("We're looking into it"), findsOneWidget);
    });

    testWidgets('M8 pending → the customer marks paid while M8 is open', (tester) async {
      await tester.pumpWidget(await app(booking(BookingStatus.completed, finalAmount: 450)));
      await go(tester, jobRoute('b-1'));
      expect(find.text('Waiting for payment'), findsOneWidget);
      jobs.setPayment('b-1', PaymentStatus.customerMarkedPaid);
      await tester.pumpAndSettle();
      expect(find.text('Yes, received'), findsOneWidget);
    });

    for (final language in ['gu', 'hi']) {
      testWidgets('M7 and M8 fit at 320 px and 200% text in $language', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(await app(booking(BookingStatus.inProgress), language: language));
        await go(tester, completeJobRoute('b-1'));
        expect(find.byType(CompleteJobScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
        jobs.setStatus('b-1', BookingStatus.completed);
        jobs.setPayment('b-1', PaymentStatus.customerMarkedPaid);
        await tester.pumpAndSettle();
        expect(find.byType(PaymentView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
