import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadside_core/roadside_core.dart';

/// The signed-in Google account and its role claims, read from the ID token.
class AdminUser {
  const AdminUser({
    required this.uid,
    required this.email,
    required this.claims,
    required this.signInProvider,
  });

  final String uid;
  final String? email;
  final RoleClaims claims;

  /// `firebase.sign_in_provider` from the token, e.g. `google.com` or `phone`.
  final String? signInProvider;

  /// Admins sign in with Google and carry the `role: admin` claim (PLAN §12.11 layers 1–2).
  /// Phone-OTP accounts are never admins, even with a stray claim.
  bool get isAdmin => claims.isAdmin && signInProvider == 'google.com';
}

/// Sign-in for the console: Google only, no phone login, no sign-up (PLAN §12.11).
abstract interface class AdminAuth {
  /// Emits on sign-in, sign-out and ID-token refresh (so a revoked claim takes effect).
  Stream<AdminUser?> userChanges();

  Future<void> signInWithGoogle();

  Future<void> signOut();
}

class FirebaseAdminAuth implements AdminAuth {
  FirebaseAdminAuth(this._auth);

  final FirebaseAuth _auth;

  @override
  Stream<AdminUser?> userChanges() => _auth.idTokenChanges().asyncMap((user) async {
    if (user == null) return null;
    final token = await user.getIdTokenResult();
    return AdminUser(
      uid: user.uid,
      email: user.email,
      claims: RoleClaims.fromTokenClaims(token.claims),
      signInProvider: token.signInProvider,
    );
  });

  @override
  Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider()..setCustomParameters({'prompt': 'select_account'});
    final result = await _auth.signInWithPopup(provider);
    // Claims granted since the last token was minted (tool/grant_admin) apply straight away.
    await result.user?.getIdToken(true);
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
