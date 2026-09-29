// #95: C7 Permission explainer and C9 Help & FAQ.
import 'dart:async';

import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
import 'package:customer_app/features/help/presentation/help_screen.dart';
import 'package:customer_app/features/permissions/application/permission_service.dart';
import 'package:customer_app/features/permissions/presentation/permission_explainer_screen.dart';
import 'package:customer_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

/// A phone whose permission answers the test controls.
class FakePermissions implements PermissionService {
  FakePermissions(this.current, {this.onRequest});

  PermissionAccess current;

  /// What the system prompt answers.
  PermissionAccess Function()? onRequest;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<PermissionAccess> status(AppPermission permission) async => current;

  @override
  Future<PermissionAccess> request(AppPermission permission) async {
    requests++;
    return current = onRequest?.call() ?? current;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

late FakePermissions permissions;
final launched = <Uri>[];

Future<Widget> app({String language = 'en', ({String phone, String grievanceEmail})? contacts}) async {
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
      launchLinkProvider.overrideWithValue((uri) async {
        launched.add(uri);
        return true;
      }),
      supportContactsProvider.overrideWithValue(
        contacts ?? (phone: '+917900000000', grievanceEmail: 'grievance@example.in'),
      ),
      laneBatterySourceProvider.overrideWithValue(_NoBattery()),
      laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 29, 6, 30)),
    ],
    child: const RoadsideApp(),
  );
}

Future<void> pastSplash(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

/// A tiny app with one button that calls [ensurePermission], like a real feature would.
Widget ensureApp(void Function(bool) onResult) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Consumer(
            builder: (context, ref, _) => Center(
              child: LaneButton.primary(
                label: 'Find me',
                onPressed: () async => onResult(await ensurePermission(context, ref, AppPermission.location)),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/permission/:kind',
        builder: (context, state) =>
            PermissionExplainerScreen(permission: AppPermission.values.byName(state.pathParameters['kind']!)),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      permissionServiceProvider.overrideWithValue(permissions),
      laneBatterySourceProvider.overrideWithValue(_NoBattery()),
    ],
    child: LaneApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    ),
  );
}

void main() {
  setUp(() {
    launched.clear();
    permissions = FakePermissions(PermissionAccess.askable, onRequest: () => PermissionAccess.granted);
  });

  group('C7 permission explainer', () {
    testWidgets('explains first; the system prompt comes only after Allow; granted closes it', (
      tester,
    ) async {
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      bool? result;
      unawaited(
        tester
            .element(find.byType(Scaffold).last)
            .push<bool>(permissionRoute(AppPermission.location))
            .then((v) => result = v),
      );
      await tester.pumpAndSettle();

      expect(find.text('Allow location'), findsOneWidget);
      expect(permissions.requests, 0, reason: 'no system prompt before the explainer');
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();
      expect(permissions.requests, 1);
      expect(result, isTrue);
      expect(find.byType(PermissionExplainerScreen), findsNothing);
    });

    testWidgets('Not now closes with false and never prompts', (tester) async {
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      bool? result;
      unawaited(
        tester
            .element(find.byType(Scaffold).last)
            .push<bool>(permissionRoute(AppPermission.camera))
            .then((v) => result = v),
      );
      await tester.pumpAndSettle();
      expect(find.text('Allow camera'), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
      expect(permissions.requests, 0);
    });

    testWidgets('denied once: stays, can ask again', (tester) async {
      permissions.onRequest = () => PermissionAccess.askable;
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      unawaited(
        tester.element(find.byType(Scaffold).last).push<bool>(permissionRoute(AppPermission.notifications)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();
      expect(find.text('Allow notifications'), findsOneWidget);
      expect(find.text('Allow'), findsOneWidget);
    });

    testWidgets('blocked: Open settings, and coming back re-checks', (tester) async {
      permissions.current = PermissionAccess.blocked;
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      bool? result;
      unawaited(
        tester
            .element(find.byType(Scaffold).last)
            .push<bool>(permissionRoute(AppPermission.location))
            .then((v) => result = v),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining("turned off in your phone's settings"), findsOneWidget);
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      expect(permissions.settingsOpened, 1);
      expect(permissions.requests, 0);

      // The user allows it in Settings and returns to the app.
      permissions.current = PermissionAccess.granted;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('ensurePermission: already granted returns true without the explainer', (tester) async {
      permissions.current = PermissionAccess.granted;
      final results = <bool>[];
      await tester.pumpWidget(ensureApp(results.add));
      await tester.tap(find.text('Find me'));
      await tester.pumpAndSettle();
      expect(results, [true]);
      expect(find.byType(PermissionExplainerScreen), findsNothing);
    });

    testWidgets('ensurePermission: not granted shows the explainer and returns the answer', (tester) async {
      final results = <bool>[];
      await tester.pumpWidget(ensureApp(results.add));
      await tester.tap(find.text('Find me'));
      await tester.pumpAndSettle();
      expect(find.byType(PermissionExplainerScreen), findsOneWidget);
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();
      expect(results, [true]);
    });

    testWidgets('fits at 320 px, 200% text, Hindi', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      permissions.current = PermissionAccess.blocked;
      await tester.pumpWidget(await app(language: 'hi'));
      await pastSplash(tester);
      unawaited(
        tester.element(find.byType(Scaffold).last).push<bool>(permissionRoute(AppPermission.location)),
      );
      await tester.pumpAndSettle();
      expect(find.text('सेटिंग्स खोलें'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('C9 Help & FAQ', () {
    // The Help list itself (the search field is a scrollable too).
    final helpList = find.descendant(of: find.byType(HelpScreen), matching: find.byType(Scrollable)).first;

    Future<void> openHelp(
      WidgetTester tester, {
      String language = 'en',
      ({String phone, String grievanceEmail})? contacts,
    }) async {
      await tester.pumpWidget(await app(language: language, contacts: contacts));
      await pastSplash(tester);
      // Secondary buttons show their label in caps (ThreeUI Spinning Border).
      await tester.tap(find.text((language == 'en' ? 'Help & FAQ' : 'मदद और FAQ').toUpperCase()));
      await tester.pumpAndSettle();
      expect(find.byType(HelpScreen), findsOneWidget);
    }

    testWidgets('questions expand and collapse', (tester) async {
      await openHelp(tester);
      expect(find.textContaining('4-digit code in your app'), findsNothing);
      await tester.tap(find.text('What is the start code?'));
      await tester.pumpAndSettle();
      expect(find.textContaining('4-digit code in your app'), findsOneWidget);
      await tester.tap(find.text('What is the start code?'));
      await tester.pumpAndSettle();
      expect(find.textContaining('4-digit code in your app'), findsNothing);
    });

    testWidgets('search filters questions and answers; nothing found offers a call', (tester) async {
      await openHelp(tester);
      await tester.enterText(find.byType(TextField), 'upi');
      await tester.pumpAndSettle();
      expect(find.text('How do I pay?'), findsOneWidget);
      expect(find.text('Can I cancel?'), findsNothing);

      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pumpAndSettle();
      expect(find.text('No matching questions'), findsOneWidget);
      await tester.tap(find.widgetWithText(LaneButton, 'Call support').first);
      expect(launched.single, Uri(scheme: 'tel', path: '+917900000000'));
    });

    testWidgets('call, WhatsApp and grievance email open the right links', (tester) async {
      await openHelp(tester);
      await tester.scrollUntilVisible(find.text('grievance@example.in'), 200, scrollable: helpList);
      await tester.tap(find.widgetWithText(LaneButton, 'CALL SUPPORT'));
      await tester.tap(find.widgetWithText(LaneButton, 'WHATSAPP'));
      await tester.ensureVisible(find.widgetWithText(LaneButton, 'grievance@example.in'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(LaneButton, 'grievance@example.in'));
      expect(launched, [
        Uri(scheme: 'tel', path: '+917900000000'),
        Uri.https('wa.me', '917900000000'),
        Uri(scheme: 'mailto', path: 'grievance@example.in'),
      ]);
    });

    testWidgets('grievance officer is always shown, even before contacts are configured', (tester) async {
      await openHelp(tester, contacts: (phone: '', grievanceEmail: ''));
      await tester.scrollUntilVisible(find.text('Grievance officer'), 200, scrollable: helpList);
      expect(find.widgetWithText(LaneButton, 'CALL SUPPORT'), findsNothing);
    });

    testWidgets('fits at 320 px, 200% text, Hindi', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openHelp(tester, language: 'hi');
      expect(tester.takeException(), isNull);
    });
  });
}
