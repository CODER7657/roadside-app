// #123: C5–C6 phone login, the auth gate and the Firebase switch.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:mechanic_app/app/app.dart';
import 'package:mechanic_app/app/flavor.dart';
import 'package:mechanic_app/app/router.dart';
import 'package:mechanic_app/app/secure_window.dart';
import 'package:mechanic_app/features/auth/application/auth.dart';
import 'package:mechanic_app/features/auth/data/auth_repository.dart';
import 'package:mechanic_app/features/auth/presentation/login_screen.dart';
import 'package:mechanic_app/features/dashboard/application/online.dart';
import 'package:mechanic_app/features/dashboard/data/presence_repository.dart';
import 'package:mechanic_app/features/first_run/application/first_run.dart';
import 'package:mechanic_app/features/registration/application/registration.dart';
import 'package:mechanic_app/features/registration/data/registration_repository.dart';
import 'package:mechanic_app/features/registration/presentation/registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

class _FakeSecureWindow implements SecureWindow {
  final calls = <bool>[];

  @override
  Future<void> setSecure(bool secure) async => calls.add(secure);
}

const signedIn = AuthUser(uid: 'me', phone: '+919876543210');

void main() {
  group('login logic', () {
    test('Firebase error codes map to what C5 / C6 say', () {
      expect(loginErrorFor('invalid-phone-number'), LoginError.invalidNumber);
      expect(loginErrorFor('invalid-verification-code'), LoginError.invalidCode);
      expect(loginErrorFor('session-expired'), LoginError.codeExpired);
      expect(loginErrorFor('too-many-requests'), LoginError.tooManyAttempts);
      expect(loginErrorFor('quota-exceeded'), LoginError.tooManyAttempts);
      expect(loginErrorFor('network-request-failed'), LoginError.network);
      expect(loginErrorFor('internal-error'), LoginError.failed);
    });

    test('the phone shows as +91 98765 43210; the countdown as 0:24', () {
      expect(displayPhone('+919876543210'), '+91 98765 43210');
      expect(displayPhone('+14155550100'), '+14155550100');
      expect(formatCountdown(const Duration(seconds: 24)), '0:24');
      expect(formatCountdown(const Duration(seconds: 90)), '1:30');
    });

    test('auth gate: signed out → C5; signed in → past login; waits while loading', () {
      const out = AsyncData<AuthUser?>(null);
      const inside = AsyncData<AuthUser?>(signedIn);
      expect(authRedirect(out, AppRoutes.home), AppRoutes.login);
      expect(authRedirect(out, '/offer/o-1'), AppRoutes.login);
      expect(authRedirect(out, AppRoutes.login), isNull);
      expect(authRedirect(out, AppRoutes.loginCode), isNull);
      for (final open in [AppRoutes.help, AppRoutes.privacy, AppRoutes.splash, '/permission/location']) {
        expect(authRedirect(out, open), isNull, reason: open);
      }
      expect(authRedirect(inside, AppRoutes.login), AppRoutes.home);
      expect(authRedirect(inside, AppRoutes.loginCode), AppRoutes.home);
      expect(authRedirect(inside, AppRoutes.home), isNull);
      expect(authRedirect(const AsyncLoading<AuthUser?>(), AppRoutes.home), isNull);
    });

    test('without Firebase the repositories stay on their fakes, signed in or not', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(signedInFirebaseProvider), isNull);
      expect(container.read(presenceRepositoryProvider), isA<InMemoryPresenceRepository>());
      expect(container.read(registrationRepositoryProvider), isA<InMemoryRegistrationRepository>());
    });
  });

  group('LoginController', () {
    late InMemoryAuthRepository auth;
    late ProviderContainer container;
    late DateTime now;

    setUp(() {
      auth = InMemoryAuthRepository(signedInAs: null);
      now = DateTime.utc(2026, 9, 30, 10);
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          loginClockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);
    });

    LoginController c() => container.read(loginProvider.notifier);
    LoginState s() => container.read(loginProvider);

    test('a number that is not a 10-digit Indian mobile is refused before any SMS', () async {
      for (final bad in ['', '12345', '5876543210', '98765432101']) {
        expect(await c().sendCode(bad), isFalse, reason: bad);
        expect(s().error, LoginError.invalidNumber);
      }
      expect(auth.sentTo, isEmpty);
    });

    test('a good number is sent as E.164 and C6 waits for the code', () async {
      expect(await c().sendCode('98765 43210'), isTrue);
      expect(auth.sentTo, ['+919876543210']);
      expect(s().awaitingCode, isTrue);
      expect(s().phone, '+919876543210');
      expect(c().resendIn(), LoginTiming.resendAfter);
    });

    test('Android verified the number by itself: signed in, no code screen', () async {
      auth.nextSend = const SignedInInstantly();
      expect(await c().sendCode('9876543210'), isFalse);
      expect(auth.currentUser, isNotNull);
    });

    test('a failed send says why', () async {
      auth.nextSend = const SendCodeFailed(LoginError.tooManyAttempts);
      expect(await c().sendCode('9876543210'), isFalse);
      expect(s().error, LoginError.tooManyAttempts);
      expect(s().awaitingCode, isFalse);
    });

    test('resend only after 30 s, reusing the session', () async {
      await c().sendCode('9876543210');
      await c().resend();
      expect(auth.sentTo, hasLength(1), reason: 'too early');
      now = now.add(const Duration(seconds: 31));
      expect(c().resendIn(), Duration.zero);
      await c().resend();
      expect(auth.sentTo, hasLength(2));
      expect(c().resendIn(), LoginTiming.resendAfter, reason: 'the countdown starts again');
    });

    test('a wrong code says so; the right one signs in', () async {
      await c().sendCode('9876543210');
      await c().verify('000000');
      expect(s().error, LoginError.invalidCode);
      expect(auth.currentUser, isNull);
      await c().verify('123456');
      expect(s().error, isNull);
      expect(auth.currentUser?.phone, '+919876543210');
      expect(s().awaitingCode, isFalse, reason: 'a later login starts from C5');
      expect(s().phone, isNull);
    });

    test('change number goes back to C5 and keeps the number', () async {
      await c().sendCode('9876543210');
      c().changeNumber();
      expect(s().awaitingCode, isFalse);
      expect(s().phone, '+919876543210');
    });
  });

  group('C5–C6 screens', () {
    late InMemoryAuthRepository auth;
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
      return ProviderScope(
        overrides: [
          flavorProvider.overrideWithValue(AppFlavor.dev),
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(auth),
          registrationRepositoryProvider.overrideWithValue(InMemoryRegistrationRepository()),
          secureWindowProvider.overrideWithValue(secure),
          loginClockProvider.overrideWithValue(() => now),
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 30, 6, 30)),
        ],
        child: const MechanicApp(),
      );
    }

    Future<void> start(WidgetTester tester, {String language = 'en'}) async {
      await tester.pumpWidget(await app(language: language));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }

    Future<void> enterNumber(WidgetTester tester, String number) async {
      await tester.enterText(find.byType(TextField), number);
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
    }

    Future<void> enterCode(WidgetTester tester, String code) async {
      await tester.enterText(
        find.descendant(of: find.byType(LaneOtpInput), matching: find.byType(TextField)),
        code,
      );
      await tester.pump();
      await tester.pumpAndSettle();
    }

    setUp(() {
      auth = InMemoryAuthRepository(signedInAs: null);
      secure = _FakeSecureWindow();
      now = DateTime.utc(2026, 9, 30, 10);
    });

    testWidgets('signed out after first run → C5, with the screen kept out of screenshots', (tester) async {
      await start(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Your mobile number'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);
      expect(secure.calls, [true]);
    });

    testWidgets('a bad number shows the error and stays on C5', (tester) async {
      await start(tester);
      await enterNumber(tester, '12345');
      expect(find.text('Enter a 10-digit Indian mobile number.'), findsOneWidget);
      expect(find.byType(OtpScreen), findsNothing);
      expect(auth.sentTo, isEmpty);
    });

    testWidgets('number → code → signed in → M1 for a new mechanic', (tester) async {
      await start(tester);
      await enterNumber(tester, '9876543210');
      expect(find.byType(OtpScreen), findsOneWidget);
      expect(find.text('Sent to +91 98765 43210'), findsOneWidget);
      expect(find.text('Resend in 0:30'), findsOneWidget);
      expect(secure.calls, [true], reason: 'C5 -> C6 keeps the window secure (no off in between)');

      await enterCode(tester, '000000');
      expect(find.text("That code isn't right. Check the SMS and try again."), findsOneWidget);
      expect(find.byType(OtpScreen), findsOneWidget);

      await enterCode(tester, '123456');
      expect(find.byType(RegistrationScreen), findsOneWidget);
      expect(secure.calls.last, isFalse, reason: 'secure only while login is open');
    });

    testWidgets('Change number goes back to C5 with the number filled in', (tester) async {
      await start(tester);
      await enterNumber(tester, '9876543210');
      await tester.tap(find.text('Change number'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);
    });

    testWidgets('Resend appears after 30 s and sends again', (tester) async {
      await start(tester);
      await enterNumber(tester, '9876543210');
      now = now.add(const Duration(seconds: 12));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Resend in 0:18'), findsOneWidget);
      now = now.add(const Duration(seconds: 20));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Resend code'));
      await tester.pumpAndSettle();
      expect(auth.sentTo, hasLength(2));
      expect(find.text('Resend in 0:30'), findsOneWidget);
    });

    testWidgets('a code opened without a session goes back to C5', (tester) async {
      await start(tester);
      final router = ProviderScope.containerOf(tester.element(find.byType(LoginScreen))).read(routerProvider);
      router.go(AppRoutes.loginCode);
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('already signed in: never sees login', (tester) async {
      auth = InMemoryAuthRepository(signedInAs: signedIn);
      await start(tester);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(RegistrationScreen), findsOneWidget);
    });

    for (final language in ['gu', 'hi']) {
      testWidgets('C5 and C6 fit at 320 px and 200% text in $language', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await start(tester, language: language);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
        // Long Gujarati lines at 200% push the field below the fold: scroll to it.
        await tester.scrollUntilVisible(
          find.byType(TextField),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.enterText(find.byType(TextField), '9876543210');
        await tester.tap(find.byType(LaneButton).last);
        await tester.pumpAndSettle();
        expect(find.byType(OtpScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
