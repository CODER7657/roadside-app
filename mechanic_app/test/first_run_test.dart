// #121: C1 Splash → C2 Language → C3 Onboarding → C4 Consent → home.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:mechanic_app/app/app.dart';
import 'package:mechanic_app/app/flavor.dart';
import 'package:mechanic_app/app/router.dart';
import 'package:mechanic_app/features/first_run/application/first_run.dart';
import 'package:mechanic_app/features/first_run/presentation/consent_screen.dart';
import 'package:mechanic_app/features/first_run/presentation/language_screen.dart';
import 'package:mechanic_app/features/first_run/presentation/onboarding_screen.dart';
import 'package:mechanic_app/features/first_run/presentation/privacy_notice_screen.dart';
import 'package:mechanic_app/features/first_run/presentation/splash_screen.dart';
import 'package:mechanic_app/features/home/presentation/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mechanic_app/features/registration/application/registration.dart';
import 'package:mechanic_app/features/registration/data/registration_repository.dart';
import 'package:mechanic_app/features/registration/presentation/registration_screen.dart';

import 'support.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

final consentTime = DateTime.utc(2026, 9, 30, 10, 15);

Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

Widget app(SharedPreferences prefs, {RegistrationRepository? registration}) => ProviderScope(
  overrides: [
    flavorProvider.overrideWithValue(AppFlavor.dev),
    sharedPreferencesProvider.overrideWithValue(prefs),
    registrationRepositoryProvider.overrideWithValue(registration ?? approvedMechanic()),
    firstRunClockProvider.overrideWithValue(() => consentTime),
    laneBatterySourceProvider.overrideWithValue(_NoBattery()),
    laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 30, 6, 30)),
  ],
  child: const MechanicApp(),
);

const completed = {
  'first_run.language': 'en',
  'first_run.onboarded': true,
  'first_run.consent_version': kConsentVersion,
  'first_run.consent_at': '2026-09-30T10:15:00.000Z',
};

/// Lets the splash's short delay pass, then settles on the next screen.
Future<void> pastSplash(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  group('firstRunRedirect', () {
    const fresh = FirstRunState();
    const chosen = FirstRunState(languageCode: 'hi');
    final done = FirstRunState(
      languageCode: 'hi',
      onboarded: true,
      consent: ConsentRecord(version: kConsentVersion, acceptedAt: consentTime),
    );

    test('a fresh install is sent to the first unfinished step', () {
      expect(firstRunRedirect(fresh, AppRoutes.home), FirstRunStep.language);
      expect(
        firstRunRedirect(fresh, FirstRunStep.consent),
        FirstRunStep.language,
        reason: 'no skipping ahead',
      );
      expect(firstRunRedirect(chosen, AppRoutes.home), FirstRunStep.onboarding);
    });

    test('earlier steps stay reachable (change language); splash and notice always', () {
      expect(firstRunRedirect(chosen, FirstRunStep.language), isNull);
      expect(firstRunRedirect(fresh, AppRoutes.splash), isNull);
      expect(firstRunRedirect(fresh, AppRoutes.privacy), isNull);
    });

    test('once done, first-run screens lead home', () {
      expect(firstRunRedirect(done, AppRoutes.home), isNull);
      expect(firstRunRedirect(done, FirstRunStep.onboarding), AppRoutes.home);
    });

    test('consent to an older or the customer notice asks again', () {
      for (final version in ['2020-01-v0', '2026-09-v1']) {
        final old = FirstRunState(
          languageCode: 'en',
          onboarded: true,
          consent: ConsentRecord(version: version, acceptedAt: consentTime),
        );
        expect(firstRunRedirect(old, AppRoutes.home), FirstRunStep.consent, reason: version);
      }
    });
  });

  testWidgets('C1 splash shows the brand line on the horizon still', (tester) async {
    await tester.pumpWidget(app(await prefsWith({})));
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Jobs near you, paid straight to you'), findsOneWidget);
    await pastSplash(tester);
  });

  testWidgets('first run end to end: splash, Gujarati, onboarding, consent, then M1; saved', (tester) async {
    final prefs = await prefsWith({});
    // A brand-new mechanic: not registered yet, so first run leads into registration (M1).
    await tester.pumpWidget(app(prefs, registration: InMemoryRegistrationRepository()));
    await pastSplash(tester);

    // C2: English by default (test locale); choosing Gujarati switches the app at once.
    expect(find.byType(LanguageScreen), findsOneWidget);
    await tester.tap(find.text('ગુજરાતી'));
    await tester.pumpAndSettle();
    expect(find.text('તમારી ભાષા પસંદ કરો'), findsOneWidget);
    await tester.tap(find.text('આગળ વધો'));
    await tester.pumpAndSettle();

    // C3: three mechanic slides.
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('તમારી નજીકના કામ'), findsOneWidget);
    await tester.tap(find.text('આગળ'));
    await tester.pumpAndSettle();
    expect(find.text('ગ્રાહક સુધી પહોંચો, તેમના કોડથી શરૂ કરો'), findsOneWidget);
    await tester.tap(find.text('આગળ'));
    await tester.pumpAndSettle();
    expect(find.text('પૈસા સીધા તમારા UPI માં'), findsOneWidget);
    expect(find.text('છોડો'), findsNothing, reason: 'no Skip on the last slide');
    await tester.tap(find.text('શરૂ કરો'));
    await tester.pumpAndSettle();

    // C4: agree is disabled until both boxes are ticked.
    expect(find.byType(ConsentScreen), findsOneWidget);
    Future<void> tapAgree() async {
      await tester.tap(find.text('સંમત છું, આગળ વધો'), warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    await tapAgree();
    expect(find.byType(ConsentScreen), findsOneWidget);
    await tester.ensureVisible(find.text('મારી ઉંમર 18 વર્ષ કે તેથી વધુ છે'));
    await tester.tap(find.text('મારી ઉંમર 18 વર્ષ કે તેથી વધુ છે'));
    await tester.pumpAndSettle();
    await tapAgree();
    expect(find.byType(ConsentScreen), findsOneWidget, reason: 'the notice box is still unticked');
    await tester.ensureVisible(find.text('હું ગોપનીયતા સૂચના સાથે સંમત છું'));
    await tester.tap(find.text('હું ગોપનીયતા સૂચના સાથે સંમત છું'));
    await tester.pumpAndSettle();
    await tapAgree();

    expect(find.byType(RegistrationScreen), findsOneWidget);
    expect(prefs.getString('first_run.language'), 'gu');
    expect(prefs.getBool('first_run.onboarded'), isTrue);
    expect(prefs.getString('first_run.consent_version'), kConsentVersion);
    expect(prefs.getString('first_run.consent_at'), consentTime.toIso8601String());
  });

  testWidgets('Skip goes straight to consent', (tester) async {
    await tester.pumpWidget(app(await prefsWith({'first_run.language': 'en'})));
    await pastSplash(tester);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(ConsentScreen), findsOneWidget);
  });

  testWidgets('the consent screen explains KYC and on-the-job location', (tester) async {
    await tester.pumpWidget(app(await prefsWith({'first_run.language': 'en', 'first_run.onboarded': true})));
    await pastSplash(tester);
    expect(find.textContaining('ID documents for verification'), findsOneWidget);
    expect(find.textContaining("Never when you're offline"), findsOneWidget);
  });

  testWidgets('the full notice opens from consent and comes back', (tester) async {
    await tester.pumpWidget(app(await prefsWith({'first_run.language': 'hi', 'first_run.onboarded': true})));
    await pastSplash(tester);
    await tester.tap(find.text('पूरी सूचना पढ़ें'));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyNoticeScreen), findsOneWidget);
    expect(find.text('हम क्या लेते हैं'), findsOneWidget);
    await tester.tap(find.byType(LaneBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(ConsentScreen), findsOneWidget);
  });

  testWidgets('a returning mechanic lands on home, in their language', (tester) async {
    await tester.pumpWidget(app(await prefsWith({...completed, 'first_run.language': 'gu'})));
    await pastSplash(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('તમારી નજીકના કામ, જ્યારે તમે તૈયાર હો'), findsOneWidget);
  });

  for (final (name, values) in [
    ('language', <String, Object>{}),
    ('onboarding', {'first_run.language': 'hi'}),
    ('consent', {'first_run.language': 'hi', 'first_run.onboarded': true}),
  ]) {
    testWidgets('$name screen fits at 320 px and 200% text in Hindi', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      tester.platformDispatcher.localesTestValue = [const Locale('hi')];
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pumpWidget(app(await prefsWith(values)));
      await pastSplash(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('privacy notice fits at 320 px and 200% text in Gujarati', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(app(await prefsWith({'first_run.language': 'gu', 'first_run.onboarded': true})));
    await pastSplash(tester);
    // At 200% the notice button is below the fold of a lazy list; the tap is covered above.
    // push() completes only when the page is popped, so it isn't awaited.
    unawaited(GoRouter.of(tester.element(find.byType(ConsentScreen))).push(AppRoutes.privacy));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyNoticeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
