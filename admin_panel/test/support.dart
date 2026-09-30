// Shared test setup: a fake Google auth, the panel in its real container (Night mode), and a
// testWidgets wrapper that disposes the container before flutter_test checks for timers.

import 'dart:async';

import 'package:admin_panel/app/app.dart';
import 'package:admin_panel/app/flavor.dart';
import 'package:admin_panel/features/auth/application/admin_session.dart';
import 'package:admin_panel/features/auth/data/admin_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';

class FakeAdminAuth implements AdminAuth {
  final _users = StreamController<AdminUser?>.broadcast();
  AdminUser? nextSignIn;
  bool failSignIn = false;
  int signOuts = 0;

  void emit(AdminUser? user) => _users.add(user);

  @override
  Stream<AdminUser?> userChanges() => _users.stream;

  @override
  Future<void> signInWithGoogle() async {
    if (failSignIn) throw Exception('popup-closed-by-user');
    emit(nextSignIn);
  }

  @override
  Future<void> signOut() async {
    signOuts++;
    emit(null);
  }
}

AdminUser user({String? role, String provider = 'google.com', String email = 'someone@example.com'}) =>
    AdminUser(
      uid: 'u1',
      email: email,
      claims: RoleClaims.fromTokenClaims({'role': ?role}),
      signInProvider: provider,
    );

final admin = user(role: 'admin', email: 'ops@example.com');

class NoBattery implements LaneBatterySource {
  const NoBattery();

  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

late FakeAdminAuth auth;
late ProviderContainer container;

/// Pumps the whole panel at desktop size.
Future<void> pumpPanel(
  WidgetTester tester, {
  bool configured = true,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  container = createAdminContainer(
    overrides: [
      flavorProvider.overrideWithValue(AppFlavor.dev),
      adminAuthProvider.overrideWithValue(configured ? auth : null),
      laneBatterySourceProvider.overrideWithValue(const NoBattery()),
      ...overrides,
    ],
  );
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const AdminApp()));
  await tester.pump();
}

Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// testWidgets with a fresh [auth], disposing [container] inside the test.
void testPanel(String description, Future<void> Function(WidgetTester tester) body) {
  testWidgets(description, (tester) async {
    auth = FakeAdminAuth();
    await body(tester);
    await tester.pump(LaneToast.visibleFor + const Duration(seconds: 1)); // let toasts time out
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
  });
}
