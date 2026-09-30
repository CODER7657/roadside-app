// #29: M4 incoming offer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:lane_ui/lane_ui.dart' as lane show PriceRange;
import 'package:mechanic_app/app/app.dart';
import 'package:mechanic_app/app/flavor.dart';
import 'package:mechanic_app/app/router.dart';
import 'package:mechanic_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:mechanic_app/features/first_run/application/first_run.dart';
import 'package:mechanic_app/features/offers/application/offers.dart';
import 'package:mechanic_app/features/offers/data/offer_alerts.dart';
import 'package:mechanic_app/features/offers/data/offer_repository.dart';
import 'package:mechanic_app/features/offers/presentation/offer_screen.dart';
import 'package:mechanic_app/features/registration/application/registration.dart';
import 'package:roadside_core/roadside_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

final now = DateTime(2026, 9, 30, 12);

/// An offer the server made [ago] before [now] (30 s window, server timestamps).
Offer offer({
  Duration ago = const Duration(seconds: 6),
  OfferState state = OfferState.pending,
  bool withCreatedAt = true,
}) => Offer(
  bookingId: 'b-1',
  mechanicId: 'mech-1',
  vehicleType: VehicleType.car,
  problemType: ProblemType.flatTyre,
  regNo: 'GJ01AB1234',
  distanceKm: 2.43,
  areaName: 'Thaltej',
  priceEstimate: const PriceRange(min: 350, max: 600),
  expiresAt: now.subtract(ago).add(const Duration(seconds: 30)),
  createdAt: withCreatedAt ? now.subtract(ago) : null,
  state: state,
);

void main() {
  group('OfferPush.parse', () {
    test('offers and withdrawals', () {
      final p = OfferPush.parse({'type': 'offer', 'offerId': 'o-1', 'bookingId': 'b-1'})!;
      expect((p.withdrawn, p.offerId, p.bookingId), (false, 'o-1', 'b-1'));
      expect(
        OfferPush.parse({'type': 'offer_withdrawn', 'offerId': 'o-1', 'bookingId': 'b-1'})!.withdrawn,
        isTrue,
      );
    });

    test('ignores status pushes and malformed data', () {
      expect(OfferPush.parse({'type': 'booking_accepted', 'bookingId': 'b-1'}), isNull);
      expect(OfferPush.parse({'type': 'offer', 'offerId': '', 'bookingId': 'b-1'}), isNull);
      expect(OfferPush.parse({'type': 'offer', 'offerId': 7, 'bookingId': 'b-1'}), isNull);
      expect(OfferPush.parse(const {}), isNull);
    });
  });

  group('offers logic', () {
    test('callable error keys map to outcomes', () {
      expect(outcomeForError('error_offer_unavailable'), OfferOutcome.unavailable);
      expect(outcomeForError('error_offer_expired'), OfferOutcome.expired);
      expect(outcomeForError('error_not_available'), OfferOutcome.notAvailable);
      expect(outcomeForError('error_profile_incomplete'), OfferOutcome.profileIncomplete);
      expect(outcomeForError('error_mechanic_not_approved'), OfferOutcome.notApproved);
      expect(outcomeForError('error_internal'), OfferOutcome.failed);
      expect(outcomeForError(null), OfferOutcome.failed);
    });

    test("window: the server's expiresAt − createdAt", () {
      expect(offerWindow(offer()), const Duration(seconds: 30));
      expect(offerWindow(offer(withCreatedAt: false)), kOfferWindow);
    });

    test('elapsed: a late push starts the ring part-drained', () {
      expect(elapsedOf(offer(ago: Duration.zero), now), Duration.zero);
      expect(elapsedOf(offer(), now), const Duration(seconds: 6));
    });

    test('elapsed: a phone clock that is off is ignored', () {
      // 60 s fast: outside the window, so the ring starts full.
      expect(elapsedOf(offer(ago: Duration.zero), now.add(const Duration(seconds: 60))), Duration.zero);
      // Slow: the offer looks like it's from the future.
      expect(elapsedOf(offer(ago: Duration.zero), now.subtract(const Duration(seconds: 20))), Duration.zero);
      // No server createdAt yet.
      expect(elapsedOf(offer(withCreatedAt: false), now), Duration.zero);
    });

    test('notification ids are stable per offer', () {
      expect(notificationIdFor('o-1'), notificationIdFor('o-1'));
      expect(notificationIdFor('o-1'), isNonNegative);
    });
  });

  group('handleOfferPush', () {
    late SilentOfferAlerts alerts;
    late GoRouter router;
    final pushed = <String>[];

    setUp(() {
      alerts = SilentOfferAlerts();
      pushed.clear();
      router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox()),
          GoRoute(
            path: '/offer/:id',
            builder: (_, s) {
              pushed.add(s.pathParameters['id']!);
              return const SizedBox();
            },
          ),
        ],
      );
      addTearDown(router.dispose);
    });

    Future<void> handle(OfferPush p, {required bool foreground}) => handleOfferPush(
      p,
      appInForeground: foreground,
      router: router,
      alerts: alerts,
      title: 't',
      body: 'b',
    );

    testWidgets('foreground: opens M4 straight away, no notification', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      // Not awaited: push() completes only when the page is popped.
      handle(const OfferPush(withdrawn: false, offerId: 'o-1', bookingId: 'b-1'), foreground: true).ignore();
      await tester.pumpAndSettle();
      expect(pushed, ['o-1']);
      expect(alerts.shown, isEmpty);
    });

    test('background: posts the full-screen notification', () async {
      await handle(const OfferPush(withdrawn: false, offerId: 'o-1', bookingId: 'b-1'), foreground: false);
      expect(alerts.shown, ['o-1']);
    });

    test('withdrawn: clears the notification', () async {
      await handle(const OfferPush(withdrawn: true, offerId: 'o-1', bookingId: 'b-1'), foreground: false);
      expect(alerts.cancelled, ['o-1']);
      expect(alerts.shown, isEmpty);
    });
  });

  group('M4 screen', () {
    late InMemoryOfferRepository offers;
    late SilentOfferAlerts alerts;

    /// [clock] is the phone's clock; [now] is the server's.
    Future<Widget> app({String language = 'en', Offer? o, DateTime? clock}) async {
      SharedPreferences.setMockInitialValues({
        'first_run.language': language,
        'first_run.onboarded': true,
        'first_run.consent_version': kConsentVersion,
        'first_run.consent_at': '2026-09-30T10:15:00.000Z',
      });
      final prefs = await SharedPreferences.getInstance();
      offers = InMemoryOfferRepository({'o-1': o ?? offer()});
      return ProviderScope(
        overrides: [
          flavorProvider.overrideWithValue(AppFlavor.dev),
          sharedPreferencesProvider.overrideWithValue(prefs),
          registrationRepositoryProvider.overrideWithValue(approvedMechanic()),
          offerRepositoryProvider.overrideWithValue(offers),
          offerAlertsProvider.overrideWithValue(alerts),
          offerClockProvider.overrideWithValue(() => clock ?? now),
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 30, 6, 30)),
        ],
        child: const MechanicApp(),
      );
    }

    /// Opens M4 for o-1 the way a push in the foreground does.
    Future<void> openOffer(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      GoRouter.of(tester.element(find.byType(DashboardScreen))).push<void>(offerRoute('o-1')).ignore();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    Future<void> slide(WidgetTester tester) async {
      final slider = find.byType(LaneSlideToConfirm);
      final box = tester.getRect(slider);
      await tester.timedDragFrom(
        Offset(box.left + 24, box.center.dy),
        Offset(box.width, 0),
        const Duration(milliseconds: 400),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    setUp(() => alerts = SilentOfferAlerts());

    testWidgets('shows problem, plate, distance, area and price; never an address', (tester) async {
      await tester.pumpWidget(await app());
      await openOffer(tester);
      expect(find.byType(OfferScreen), findsOneWidget);
      expect(find.text('New job'), findsOneWidget);
      expect(find.text('Flat tyre · Car'), findsOneWidget);
      expect(find.byType(PlateChip), findsOneWidget);
      expect(find.text('2.4 km'), findsOneWidget);
      expect(find.text('Thaltej'), findsOneWidget);
      expect(find.byType(lane.PriceRange), findsOneWidget);
      expect(find.byType(CountdownRing), findsOneWidget);
      expect(find.text('Slide to accept'), findsOneWidget);
      expect(alerts.lockScreen, [true], reason: 'M4 may show over the lock screen');
    });

    testWidgets('slide to accept → the job; lock-screen access switched off again', (tester) async {
      await tester.pumpWidget(await app());
      await openOffer(tester);
      await slide(tester);
      await tester.pumpAndSettle();
      expect(offers.responses, [('o-1', true)]);
      expect(find.byType(JobAcceptedScreen), findsOneWidget);
      expect(alerts.lockScreen, [true, false]);
      expect(alerts.cancelled, ['o-1'], reason: 'the notification is cleared');
    });

    testWidgets('Decline → back to the dashboard', (tester) async {
      await tester.pumpWidget(await app());
      await openOffer(tester);
      await tester.tap(find.text('Decline'));
      await tester.pumpAndSettle();
      expect(offers.responses, [('o-1', false)]);
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('the ring runs out but the offer is still pending → Accept still works', (tester) async {
      await tester.pumpWidget(await app());
      await openOffer(tester);
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(find.text('This job has timed out'), findsNothing);
      await slide(tester);
      await tester.pumpAndSettle();
      expect(offers.responses, [('o-1', true)]);
      expect(find.byType(JobAcceptedScreen), findsOneWidget);
    });

    for (final ahead in const [Duration(seconds: 60), Duration(seconds: 15)]) {
      testWidgets('phone clock ${ahead.inSeconds} s fast: the offer stays acceptable', (tester) async {
        await tester.pumpWidget(
          await app(
            o: offer(ago: Duration.zero),
            clock: now.add(ahead),
          ),
        );
        await openOffer(tester);
        await tester.pumpAndSettle();
        expect(find.text('This job has timed out'), findsNothing);
        expect(find.byType(LaneSlideToConfirm), findsOneWidget);
        await slide(tester);
        await tester.pumpAndSettle();
        expect(offers.responses, [('o-1', true)]);
        expect(find.byType(JobAcceptedScreen), findsOneWidget);
      });
    }

    testWidgets('the server expires the offer while M4 is open → timed out', (tester) async {
      await tester.pumpWidget(await app());
      await openOffer(tester);
      offers.setState('o-1', OfferState.expired);
      await tester.pumpAndSettle();
      expect(find.text('This job has timed out'), findsOneWidget);
      expect(find.byType(LaneSlideToConfirm), findsNothing);
      await tester.tap(find.text('Back to dashboard'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    for (final (outcome, title) in [
      (OfferOutcome.expired, 'This job has timed out'),
      (OfferOutcome.unavailable, 'This job is no longer available'),
      (OfferOutcome.notAvailable, "You can't take this job right now"),
      (OfferOutcome.profileIncomplete, 'Finish your profile first'),
      (OfferOutcome.notApproved, "You're not approved yet"),
    ]) {
      testWidgets('accept answered ${outcome.name} → "$title"', (tester) async {
        await tester.pumpWidget(await app());
        await openOffer(tester);
        offers.nextOutcome = outcome;
        await slide(tester);
        await tester.pumpAndSettle();
        expect(find.text(title), findsOneWidget);
      });
    }

    testWidgets('network failure: says so and the slider works again', (tester) async {
      await tester.pumpWidget(await app());
      await openOffer(tester);
      offers.nextOutcome = OfferOutcome.failed;
      await slide(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining("Couldn't reach us"), findsOneWidget);
      await slide(tester);
      await tester.pumpAndSettle();
      expect(offers.responses, hasLength(2));
      expect(find.byType(JobAcceptedScreen), findsOneWidget);
    });

    testWidgets('fits at 320 px and 200% text in Gujarati', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(await app(language: 'gu'));
      await openOffer(tester);
      expect(find.text('નવું કામ'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
    });
  });

  test('approved mechanics can open offers and jobs; registration is behind them', () {
    const approved = AsyncData<MechanicStatus?>(MechanicStatus.approved);
    expect(registrationRedirect(approved, offerRoute('o-1')), isNull);
    expect(registrationRedirect(approved, jobRoute('b-1')), isNull);
    expect(registrationRedirect(approved, AppRoutes.register), AppRoutes.home);
    expect(
      registrationRedirect(const AsyncData<MechanicStatus?>(MechanicStatus.pending), offerRoute('o-1')),
      AppRoutes.pending,
    );
  });
}
