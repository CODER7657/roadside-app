import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../data/admin_auth.dart';

/// Where the console's sign-in gate stands (PLAN §12.11).
sealed class AdminSession {
  const AdminSession();
}

/// No Firebase project in this build (no env file and no emulators).
class SessionUnconfigured extends AdminSession {
  const SessionUnconfigured();
}

class SessionLoading extends AdminSession {
  const SessionLoading();
}

class SessionSignedOut extends AdminSession {
  const SessionSignedOut();
}

/// A Google account without the admin claim. It has already been signed out.
class SessionNotAuthorised extends AdminSession {
  const SessionNotAuthorised(this.email);

  final String? email;
}

class SessionAdmin extends AdminSession {
  const SessionAdmin(this.user);

  final AdminUser user;
}

/// The console's auth. Null when Firebase isn't configured. Overridden in `bootstrap` and tests.
final adminAuthProvider = Provider<AdminAuth?>((ref) => null);

final adminSessionProvider = NotifierProvider<AdminSessionController, AdminSession>(
  AdminSessionController.new,
);

class AdminSessionController extends Notifier<AdminSession> {
  @override
  AdminSession build() {
    final auth = ref.watch(adminAuthProvider);
    if (auth == null) return const SessionUnconfigured();
    final sub = auth.userChanges().listen((user) => _onUser(auth, user));
    ref.onDispose(sub.cancel);
    return const SessionLoading();
  }

  void _onUser(AdminAuth auth, AdminUser? user) {
    if (user == null) {
      // Keep "Not authorised" on screen after we signed that account out.
      if (state is! SessionNotAuthorised) state = const SessionSignedOut();
      return;
    }
    if (user.isAdmin) {
      state = SessionAdmin(user);
      LaneLog.i('admin signed in', {'uid': user.uid});
      return;
    }
    // Anyone else is told and signed out at once (PLAN §10 admin, §12.11).
    state = SessionNotAuthorised(user.email);
    LaneLog.w('non-admin sign-in rejected', fields: {'uid': user.uid});
    unawaited(auth.signOut());
  }

  Future<void> signIn() async {
    final auth = ref.read(adminAuthProvider);
    if (auth == null) return;
    state = const SessionLoading();
    try {
      await auth.signInWithGoogle();
    } catch (e, st) {
      LaneLog.w('google sign-in failed', error: e, stackTrace: st);
      state = const SessionSignedOut();
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const SessionSignedOut();
    await ref.read(adminAuthProvider)?.signOut();
  }
}
