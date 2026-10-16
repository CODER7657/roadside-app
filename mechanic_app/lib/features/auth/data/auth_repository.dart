import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../registration/data/registration_repository.dart';

/// The signed-in mechanic, as Firebase Auth knows them.
@immutable
class AuthUser {
  const AuthUser({required this.uid, required this.phone});

  final String uid;

  /// E.164 (`+91…`). Shown on screen only; never logged.
  final String phone;
}

/// Why a login step didn't work, for the message on C5 / C6.
enum LoginError {
  /// Not a 10-digit Indian mobile (the SMS region policy only allows India).
  invalidNumber,

  /// The code doesn't match.
  invalidCode,

  /// The code or the verification session ran out: send a new one.
  codeExpired,

  /// Firebase's abuse limits (too many codes or attempts from this phone or number).
  tooManyAttempts,

  /// No connection.
  network,

  /// Anything else.
  failed,
}

/// Maps a `FirebaseAuthException.code` to what C5 / C6 say.
LoginError loginErrorFor(String code) => switch (code) {
  'invalid-phone-number' || 'missing-phone-number' => LoginError.invalidNumber,
  'invalid-verification-code' || 'missing-verification-code' => LoginError.invalidCode,
  'session-expired' || 'code-expired' || 'invalid-verification-id' => LoginError.codeExpired,
  'too-many-requests' || 'quota-exceeded' => LoginError.tooManyAttempts,
  'network-request-failed' => LoginError.network,
  _ => LoginError.failed,
};

/// What asking for a code gave.
sealed class SendCodeResult {
  const SendCodeResult();
}

/// The SMS is on its way; C6 asks for the code.
final class CodeSent extends SendCodeResult {
  const CodeSent({required this.verificationId, this.resendToken});

  final String verificationId;

  /// Lets "Resend code" reuse the session instead of starting over.
  final int? resendToken;
}

/// Android verified the number by itself (SMS Retriever or instant verification) and signed
/// in: no code to type.
final class SignedInInstantly extends SendCodeResult {
  const SignedInInstantly();
}

final class SendCodeFailed extends SendCodeResult {
  const SendCodeFailed(this.error);

  final LoginError error;
}

/// Phone login (PLAN §3, §12.2): Firebase Auth with an OTP by SMS, India only.
abstract interface class AuthRepository {
  /// The signed-in mechanic, or null; emits on sign-in and sign-out.
  Stream<AuthUser?> watchUser();

  AuthUser? get currentUser;

  /// Sends the code to [phone] (E.164). Pass [resendToken] from [CodeSent] to resend.
  Future<SendCodeResult> sendCode(String phone, {int? resendToken});

  /// Signs in with the code from the SMS. Null on success.
  Future<LoginError?> verifyCode({required String verificationId, required String code});

  /// `getIdToken(true)`, for new custom claims (#101).
  Future<void> refreshClaims();

  Future<void> signOut();
}

/// The session registration writes with (`uid`, the Auth phone number, claims refresh).
class AuthRepositorySession implements AuthSession {
  AuthRepositorySession(this._user, this._auth);

  final AuthUser _user;
  final AuthRepository _auth;

  @override
  String get uid => _user.uid;

  @override
  String get phone => _user.phone;

  @override
  Future<void> refreshClaims() => _auth.refreshClaims();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  /// How long Android waits for the SMS to arrive by itself (SMS Retriever, no SMS permission)
  /// before the mechanic types it.
  static const autoRetrievalTimeout = Duration(seconds: 60);

  /// If Firebase never answers (no codeSent, no failure), C5 stops waiting after this.
  static const sendTimeout = Duration(seconds: 90);

  static AuthUser? _toUser(User? user) =>
      user == null ? null : AuthUser(uid: user.uid, phone: user.phoneNumber ?? '');

  @override
  Stream<AuthUser?> watchUser() => _auth.authStateChanges().map(_toUser);

  @override
  AuthUser? get currentUser => _toUser(_auth.currentUser);

  @override
  Future<SendCodeResult> sendCode(String phone, {int? resendToken}) async {
    final result = Completer<SendCodeResult>();
    void complete(SendCodeResult r) {
      if (!result.isCompleted) result.complete(r);
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        forceResendingToken: resendToken,
        timeout: autoRetrievalTimeout,
        // Also fires after codeSent when the SMS is read automatically: signing in then moves
        // the app on through the auth state, whatever C6 is showing.
        verificationCompleted: (credential) async {
          try {
            await _auth.signInWithCredential(credential);
            complete(const SignedInInstantly());
          } on FirebaseAuthException catch (e) {
            complete(SendCodeFailed(loginErrorFor(e.code)));
          }
        },
        verificationFailed: (e) {
          if (result.isCompleted) {
            LaneLog.w('phone verification failed after the code was sent', fields: {'reason': e.code});
          }
          complete(SendCodeFailed(loginErrorFor(e.code)));
        },
        codeSent: (verificationId, token) =>
            complete(CodeSent(verificationId: verificationId, resendToken: token)),
        codeAutoRetrievalTimeout: (_) {},
      );
    } on FirebaseAuthException catch (e) {
      complete(SendCodeFailed(loginErrorFor(e.code)));
    } catch (_) {
      // A platform error (e.g. Play services missing) must not leave C5 spinning.
      complete(const SendCodeFailed(LoginError.failed));
    }
    return result.future.timeout(sendTimeout, onTimeout: () => const SendCodeFailed(LoginError.network));
  }

  @override
  Future<LoginError?> verifyCode({required String verificationId, required String code}) async {
    try {
      await _auth.signInWithCredential(
        PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return loginErrorFor(e.code);
    } catch (_) {
      return LoginError.failed;
    }
  }

  @override
  Future<void> refreshClaims() async => _auth.currentUser?.getIdToken(true);

  @override
  Future<void> signOut() => _auth.signOut();
}

/// Without Firebase (tests, a checkout without config): starts signed in as `signedInAs`, as the
/// app did before login existed. Signed out, it takes [testCode] for any Indian mobile, like
/// the dev project's test numbers.
class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository({AuthUser? signedInAs = defaultUser, this.testCode = '123456'}) : _user = signedInAs;

  static const defaultUser = AuthUser(uid: 'me', phone: '+919000000001');

  final String testCode;
  AuthUser? _user;
  final _changes = StreamController<AuthUser?>.broadcast();

  /// What the next [sendCode] returns instead of [CodeSent] (tests).
  SendCodeResult? nextSend;
  final sentTo = <String>[];
  int claimRefreshes = 0;

  @override
  AuthUser? get currentUser => _user;

  void _set(AuthUser? user) {
    _user = user;
    _changes.add(user);
  }

  @override
  Stream<AuthUser?> watchUser() async* {
    yield _user;
    yield* _changes.stream;
  }

  @override
  Future<SendCodeResult> sendCode(String phone, {int? resendToken}) async {
    sentTo.add(phone);
    final forced = nextSend;
    nextSend = null;
    if (forced is SignedInInstantly) _set(AuthUser(uid: 'me', phone: phone));
    if (forced != null) return forced;
    if (!isIndianMobile(phone)) return const SendCodeFailed(LoginError.invalidNumber);
    return CodeSent(verificationId: 'fake:$phone', resendToken: (resendToken ?? 0) + 1);
  }

  @override
  Future<LoginError?> verifyCode({required String verificationId, required String code}) async {
    if (code != testCode) return LoginError.invalidCode;
    _set(AuthUser(uid: 'me', phone: verificationId.replaceFirst('fake:', '')));
    return null;
  }

  @override
  Future<void> refreshClaims() async => claimRefreshes++;

  @override
  Future<void> signOut() async => _set(null);
}
