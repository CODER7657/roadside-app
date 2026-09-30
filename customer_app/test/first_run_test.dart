// #11: C1 Splash → C2 Language → C3 Onboarding → C4 Consent → home.
import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/app/router.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
import 'package:customer_app/features/first_run/presentation/consent_screen.dart';
import 'package:customer_app/features/first_run/presentation/language_screen.dart';
import 'package:customer_app/features/first_run/presentation/onboarding_screen.dart';
import 'package:customer_app/features/first_run/presentation/privacy_notice_screen.dart';
import 'package:customer_app/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

final consentTime = DateTime.utc(2026, 9, 29, 10, 15);

Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

Widget app(SharedPreferences prefs) => ProviderScope(
  overrides: [
    flavorProvider.overrideWithValue(AppFlavor.dev),
    sharedPreferencesProvider.overrideWithValue(prefs),
    firstRunClockProvider.overrideWithValue(() => consentTime),
    laneBatterySourceProvider.overrideWithValue(_NoBattery()),
    laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 29, 6, 30)),
  ],
  child: const RoadsideApp(),
);

const completed = {
  'first_run.language': 'en',
  'first_run.onboarded': true,
  'first_run.consent_version': kConsentVersion,
  'first_run.consent_at': '2026-09-29T10:15:00.000Z',
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

    test('an older consent version asks again', () {
      final old = FirstRunState(
        languageCode: 'en',
        onboarded: true,
        consent: ConsentRecord(version: '2020-01-v0', acceptedAt: consentTime),
      );
      expect(firstRunRedirect(old, AppRoutes.home), FirstRunStep.consent);
    });
  });

  testWidgets('first run end to end: splash, Hindi, onboarding, consent, home; saved', (tester) async {
    final prefs = await prefsWith({});
    await tester.pumpWidget(app(prefs));
    await pastSplash(tester);

    // C2: English by default (test locale); choosing Hindi switches the app at once.
    expect(find.byType(LanguageScreen), findsOneWidget);
    await tester.tap(find.text('हिन्दी'));
    await tester.pumpAndSettle();
    expect(find.text('अपनी भाषा चुनें'), findsOneWidget);
    await tester.tap(find.text('आगे बढ़ें'));
    await tester.pumpAndSettle();

    // C3: three slides.
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('मिनटों में मदद'), findsOneWidget);
    await tester.tap(find.text('आगे'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('आगे'));
    await tester.pumpAndSettle();
    expect(find.text('छोड़ें'), findsNothing, reason: 'no Skip on the last slide');
    await tester.tap(find.text('शुरू करें'));
    await tester.pumpAndSettle();

    // C4: agree is disabled until both boxes are ticked.
    expect(find.byType(ConsentScreen), findsOneWidget);
    Future<void> tapAgree() async {
      await tester.tap(find.text('सहमत हूँ, आगे बढ़ें'), warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    await tapAgree();
    expect(find.byType(ConsentScreen), findsOneWidget);
    await tester.ensureVisible(find.text('मेरी उम्र 18 वर्ष या उससे अधिक है'));
    await tester.tap(find.text('मेरी उम्र 18 वर्ष या उससे अधिक है'));
    await tester.pumpAndSettle();
    await tapAgree();
    expect(find.byType(ConsentScreen), findsOneWidget, reason: 'the notice box is still unticked');
    await tester.ensureVisible(find.text('मैं गोपनीयता सूचना से सहमत हूँ'));
    await tester.tap(find.text('मैं गोपनीयता सूचना से सहमत हूँ'));
    await tester.pumpAndSettle();
    await tapAgree();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(prefs.getString('first_run.language'), 'hi');
    expect(prefs.getBool('first_run.onboarded'), isTrue);
    expect(prefs.getString('first_run.consent_version'), kConsentVersion);
    expect(prefs.getString('first_run.consent_at'), consentTime.toIso8601String());
  });

  testWidgets('Skip goes straight to consent', (tester) async {
    final prefs = await prefsWith({'first_run.language': 'en'});
    await tester.pumpWidget(app(prefs));
    await pastSplash(tester);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(ConsentScreen), findsOneWidget);
  });

  testWidgets('the full notice opens from consent and comes back', (tester) async {
    final prefs = await prefsWith({'first_run.language': 'gu', 'first_run.onboarded': true});
    await tester.pumpWidget(app(prefs));
    await pastSplash(tester);
    await tester.tap(find.text('સંપૂર્ણ સૂચના વાંચો'));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyNoticeScreen), findsOneWidget);
    expect(find.text('અમે શું લઈએ છીએ'), findsOneWidget);
    await tester.tap(find.byType(LaneBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(ConsentScreen), findsOneWidget);
  });

  testWidgets('a returning user lands on home, in their language', (tester) async {
    final prefs = await prefsWith({...completed, 'first_run.language': 'gu'});
    await tester.pumpWidget(app(prefs));
    await pastSplash(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.widgetWithText(LaneButton, 'મદદ મેળવો'), findsOneWidget);
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
}
