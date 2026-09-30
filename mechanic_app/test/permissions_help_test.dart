// #122: C7 Permission explainer (incl. full-screen offers) and C9 Help & FAQ.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:mechanic_app/app/app.dart';
import 'package:mechanic_app/app/flavor.dart';
import 'package:mechanic_app/features/first_run/application/first_run.dart';
import 'package:mechanic_app/features/help/presentation/help_screen.dart';
import 'package:mechanic_app/features/permissions/application/permission_service.dart';
import 'package:mechanic_app/features/permissions/presentation/permission_explainer_screen.dart';
import 'package:mechanic_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

/// A phone whose permission answers the test controls.
class FakePermissions implements PermissionService {
  FakePermissions(this.current, {this.onRequest});

  PermissionAccess current;

  /// What the system prompt (or the full-screen settings page) answers.
  PermissionAccess Function()? onRequest;
  final requested = <AppPermission>[];
  int settingsOpened = 0;

  @override
  Future<PermissionAccess> status(AppPermission permission) async => current;

  @override
  Future<PermissionAccess> request(AppPermission permission) async {
    requested.add(permission);
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
    'first_run.consent_at': '2026-09-30T10:15:00.000Z',
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
      laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 30, 6, 30)),
    ],
    child: const MechanicApp(),
  );
}

Future<void> pastSplash(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

/// Opens the explainer for [p] from home and records what it returns.
Future<List<bool?>> openExplainer(WidgetTester tester, AppPermission p) async {
  final results = <bool?>[];
  unawaited(tester.element(find.byType(Scaffold).last).push<bool>(permissionRoute(p)).then(results.add));
  await tester.pumpAndSettle();
  return results;
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
                label: 'Go online',
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
      final result = await openExplainer(tester, AppPermission.location);

      expect(find.text('Allow location'), findsOneWidget);
      expect(find.textContaining("Only while you're online or on a job"), findsOneWidget);
      expect(permissions.requested, isEmpty, reason: 'no system prompt before the explainer');
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();
      expect(permissions.requested, [AppPermission.location]);
      expect(result, [true]);
      expect(find.byType(PermissionExplainerScreen), findsNothing);
    });

    testWidgets('every mechanic permission has its own explainer', (tester) async {
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      for (final (p, title) in [
        (AppPermission.camera, 'Allow camera'),
        (AppPermission.notifications, 'Allow notifications'),
        (AppPermission.fullScreenOffers, 'Show job offers on the lock screen'),
      ]) {
        final result = await openExplainer(tester, p);
        expect(find.text(title), findsOneWidget);
        await tester.tap(find.text('Not now'));
        await tester.pumpAndSettle();
        expect(result, [false]);
      }
      expect(permissions.requested, isEmpty, reason: 'Not now never prompts');
    });

    testWidgets('full-screen offers: Allow opens its settings page; coming back re-checks', (tester) async {
      // The settings page doesn't answer straight away: the user switches it on and returns.
      permissions.onRequest = () => PermissionAccess.askable;
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      final result = await openExplainer(tester, AppPermission.fullScreenOffers);
      expect(find.textContaining('like an incoming call'), findsOneWidget);
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();
      expect(permissions.requested, [AppPermission.fullScreenOffers]);
      expect(result, isEmpty, reason: 'still waiting for the user');

      permissions.current = PermissionAccess.granted;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(result, [true]);
    });

    testWidgets('denied once: stays, can ask again', (tester) async {
      permissions.onRequest = () => PermissionAccess.askable;
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      await openExplainer(tester, AppPermission.notifications);
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();
      expect(find.text('Allow notifications'), findsOneWidget);
      expect(find.text('Allow'), findsOneWidget);
    });

    testWidgets('blocked: Open settings, and coming back re-checks', (tester) async {
      permissions.current = PermissionAccess.blocked;
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      final result = await openExplainer(tester, AppPermission.location);
      expect(find.textContaining("turned off in your phone's settings"), findsOneWidget);
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      expect(permissions.settingsOpened, 1);
      expect(permissions.requested, isEmpty);

      permissions.current = PermissionAccess.granted;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(result, [true]);
    });

    testWidgets('ensurePermission: already granted returns true without the explainer', (tester) async {
      permissions.current = PermissionAccess.granted;
      final results = <bool>[];
      await tester.pumpWidget(ensureApp(results.add));
      await tester.tap(find.text('Go online'));
      await tester.pumpAndSettle();
      expect(results, [true]);
      expect(find.byType(PermissionExplainerScreen), findsNothing);
    });

    testWidgets('ensurePermission: not granted shows the explainer and returns the answer', (tester) async {
      final results = <bool>[];
      await tester.pumpWidget(ensureApp(results.add));
      await tester.tap(find.text('Go online'));
      await tester.pumpAndSettle();
      expect(find.byType(PermissionExplainerScreen), findsOneWidget);
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();
      expect(results, [true]);
    });

    for (final p in AppPermission.values) {
      testWidgets('${p.name} fits at 320 px, 200% text, Gujarati (blocked)', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        permissions.current = PermissionAccess.blocked;
        await tester.pumpWidget(await app(language: 'gu'));
        await pastSplash(tester);
        await openExplainer(tester, p);
        expect(find.text('સેટિંગ્સ ખોલો'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('full-screen access over the platform channel', () {
    const channel = MethodChannel('roadside/full_screen_intent');
    final calls = <String>[];
    var canUse = false;

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call.method);
        return switch (call.method) {
          'canUse' => canUse,
          'openSettings' => true,
          _ => null,
        };
      });
    });
    tearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );

    test('status follows canUse', () async {
      const service = PlatformPermissionService();
      canUse = false;
      expect(await service.status(AppPermission.fullScreenOffers), PermissionAccess.askable);
      canUse = true;
      expect(await service.status(AppPermission.fullScreenOffers), PermissionAccess.granted);
    });

    test('request opens the settings page, then re-reads the status', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      canUse = false;
      expect(
        await const PlatformPermissionService().request(AppPermission.fullScreenOffers),
        PermissionAccess.askable,
      );
      expect(calls, ['openSettings', 'canUse']);
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

    testWidgets('mechanic questions expand and collapse', (tester) async {
      await openHelp(tester);
      expect(find.text('How do I get jobs?'), findsOneWidget);
      expect(find.textContaining('After 5 wrong tries'), findsNothing);
      await tester.tap(find.text('What is the start code?'));
      await tester.pumpAndSettle();
      expect(find.textContaining('After 5 wrong tries'), findsOneWidget);
      await tester.tap(find.text('What is the start code?'));
      await tester.pumpAndSettle();
      expect(find.textContaining('After 5 wrong tries'), findsNothing);
    });

    testWidgets('search filters questions and answers; nothing found offers a call', (tester) async {
      await openHelp(tester);
      await tester.enterText(find.byType(TextField), 'upi');
      await tester.pumpAndSettle();
      expect(find.text('How do I get paid?'), findsOneWidget);
      expect(find.text('Can I cancel a job?'), findsNothing);

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
