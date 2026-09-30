// #49 "Done when: only admin-claim users can open the panel" (PLAN §12.11).

import 'package:admin_panel/app/router.dart';
import 'package:admin_panel/features/auth/application/admin_session.dart';
import 'package:admin_panel/features/console/application/city_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';

import 'support.dart';

void main() {
  testPanel('signed out: only A0 with Google sign-in, no phone login', (tester) async {
    await pumpPanel(tester);
    auth.emit(null);
    await settle(tester);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.textContaining('phone', findRichText: true), findsNothing);
    expect(find.text('Dashboard'), findsNothing);
  });

  testPanel('the panel runs in Night by default', (tester) async {
    await pumpPanel(tester);
    expect(container.read(laneModeProvider), LaneMode.night);
  });

  testPanel('an admin signs in and lands on the dashboard inside the console', (tester) async {
    await pumpPanel(tester);
    auth.emit(null);
    await settle(tester);
    auth.nextSignIn = admin;
    await tester.tap(find.text('Sign in with Google'));
    await settle(tester);

    expect(container.read(adminSessionProvider), isA<SessionAdmin>());
    expect(container.read(routerProvider).state.matchedLocation, '/dashboard');
    for (final label in [
      'Dashboard',
      'Approvals',
      'Live bookings',
      'Prices',
      'Complaints & reviews',
      'Settings',
    ]) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    expect(find.text('ops@example.com'), findsOneWidget);
  });

  for (final (name, account) in [
    ('a customer (phone, role customer)', user(role: 'customer', provider: 'phone')),
    ('a mechanic', user(role: 'mechanic', provider: 'phone')),
    ('a Google account without the claim', user()),
    ('a phone account that somehow has the admin claim', user(role: 'admin', provider: 'phone')),
  ]) {
    testPanel('$name is told "Not authorised" and signed out', (tester) async {
      await pumpPanel(tester);
      auth.emit(account);
      await settle(tester);

      expect(find.text('Not authorised'), findsOneWidget);
      expect(find.textContaining('someone@example.com'), findsOneWidget);
      expect(auth.signOuts, 1);
      expect(container.read(adminSessionProvider), isA<SessionNotAuthorised>());
      expect(container.read(routerProvider).state.matchedLocation, signInPath);
    });
  }

  testPanel('non-admins cannot deep-link into the console', (tester) async {
    await pumpPanel(tester);
    auth.emit(user(role: 'customer', provider: 'phone'));
    await settle(tester);
    container.read(routerProvider).go('/prices');
    await settle(tester);
    expect(container.read(routerProvider).state.matchedLocation, signInPath);
    expect(find.text('Prices'), findsNothing);
  });

  testPanel('"Use another account" can switch to an admin', (tester) async {
    await pumpPanel(tester);
    auth.emit(user());
    await settle(tester);
    auth.nextSignIn = admin;
    await tester.tap(find.bySemanticsLabel('Use another account')); // secondary labels render in caps
    await settle(tester);
    expect(container.read(adminSessionProvider), isA<SessionAdmin>());
  });

  testPanel('a revoked claim takes effect on the next token refresh', (tester) async {
    await pumpPanel(tester);
    auth.emit(admin);
    await settle(tester);
    expect(container.read(routerProvider).state.matchedLocation, '/dashboard');

    auth.emit(user(email: 'ops@example.com')); // same account, claim removed by tool/revoke_admin
    await settle(tester);
    expect(find.text('Not authorised'), findsOneWidget);
    expect(auth.signOuts, 1);
  });

  testPanel('a failed Google popup shows an error and stays signed out', (tester) async {
    await pumpPanel(tester);
    auth.emit(null);
    await settle(tester);
    auth.failSignIn = true;
    await tester.tap(find.text('Sign in with Google'));
    await settle(tester);
    expect(find.text("Sign-in didn't work. Try again."), findsOneWidget);
    expect(container.read(adminSessionProvider), isA<SessionSignedOut>());
  });

  testPanel('sign out returns to A0', (tester) async {
    await pumpPanel(tester);
    auth.emit(admin);
    await settle(tester);
    await tester.tap(find.text('Sign out'));
    await settle(tester);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(auth.signOuts, 1);
  });

  testPanel('a build without Firebase says so instead of crashing', (tester) async {
    await pumpPanel(tester, configured: false);
    await settle(tester);
    expect(find.text('Console not connected'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsNothing);
  });

  testPanel('rail navigation and the city filter, which survives switching screens', (tester) async {
    await pumpPanel(tester);
    auth.emit(admin);
    await settle(tester);

    expect(container.read(cityFilterProvider), isNull);
    await tester.tap(find.text('Bharuch'));
    await settle(tester);
    expect(container.read(cityFilterProvider), CityId.bharuch);

    await tester.tap(find.text('Approvals').first);
    await settle(tester);
    expect(container.read(routerProvider).state.matchedLocation, '/approvals');
    expect(find.textContaining('#50'), findsOneWidget);
    expect(container.read(cityFilterProvider), CityId.bharuch);

    await tester.tap(find.text('All cities'));
    await settle(tester);
    expect(container.read(cityFilterProvider), isNull);
  });
}
