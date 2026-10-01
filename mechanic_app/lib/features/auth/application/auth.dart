import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../app/firebase.dart';
import '../data/auth_repository.dart';

/// Overridden in `bootstrap` with Firebase Auth when Firebase is connected.
final authRepositoryProvider = Provider<AuthRepository>((ref) => InMemoryAuthRepository());

/// The signed-in mechanic, or null. Loading until Auth has restored the session.
final authUserProvider = StreamProvider<AuthUser?>((ref) => ref.watch(authRepositoryProvider).watchUser());

/// The signed-in mechanic's uid, or null (signed out, or Auth still loading).
final signedInUidProvider = Provider<String?>((ref) => ref.watch(authUserProvider).value?.uid);

/// Firebase and the signed-in mechanic, or null (no Firebase, or signed out). The repositories
/// use Firebase with it and their in-memory fakes without it.
final signedInFirebaseProvider = Provider<(FirebaseServices, AuthUser)?>((ref) {
  final firebase = ref.watch(firebaseServicesProvider);
  if (firebase == null) return null;
  final user = ref.watch(authUserProvider).value;
  return user == null ? null : (firebase, user);
});

/// The clock the resend countdown runs on. Tests override it.
final loginClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

abstract final class LoginTiming {
  /// C6: "Resend in 0:30" before a new code can be asked for.
  static const resendAfter = Duration(seconds: 30);
}

@immutable
class LoginState {
  const LoginState({
    this.phone,
    this.verificationId,
    this.resendToken,
    this.codeSentAt,
    this.busy = false,
    this.error,
  });

  /// E.164, once a code was asked for.
  final String? phone;

  /// Set while C6 waits for the code.
  final String? verificationId;
  final int? resendToken;
  final DateTime? codeSentAt;
  final bool busy;
  final LoginError? error;

  bool get awaitingCode => verificationId != null;

  LoginState copyWith({
    String? phone,
    String? verificationId,
    int? resendToken,
    DateTime? codeSentAt,
    bool? busy,
    LoginError? error,
    bool clearError = false,
    bool clearCode = false,
  }) => LoginState(
    phone: phone ?? this.phone,
    verificationId: clearCode ? null : verificationId ?? this.verificationId,
    resendToken: clearCode ? null : resendToken ?? this.resendToken,
    codeSentAt: clearCode ? null : codeSentAt ?? this.codeSentAt,
    busy: busy ?? this.busy,
    error: clearError ? null : error ?? this.error,
  );
}

final loginProvider = NotifierProvider<LoginController, LoginState>(LoginController.new);

/// C5–C6. Signing in changes [authUserProvider]; the router then moves on by itself.
class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  AuthRepository get _auth => ref.read(authRepositoryProvider);

  /// C5 "Send code". True when C6 should open (a code is on its way).
  Future<bool> sendCode(String input) async {
    if (state.busy) return false;
    if (validatePhone(input) != null) {
      state = state.copyWith(error: LoginError.invalidNumber);
      return false;
    }
    final phone = normalizePhone(input)!;
    state = LoginState(phone: phone, busy: true);
    return _send(phone);
  }

  /// C6 "Resend code", once [LoginTiming.resendAfter] has passed.
  Future<void> resend() async {
    final phone = state.phone;
    if (state.busy || phone == null || resendIn() > Duration.zero) return;
    state = state.copyWith(busy: true, clearError: true);
    await _send(phone, resendToken: state.resendToken);
  }

  Future<bool> _send(String phone, {int? resendToken}) async {
    final result = await _auth.sendCode(phone, resendToken: resendToken);
    switch (result) {
      case CodeSent(:final verificationId, :final resendToken):
        state = state.copyWith(
          busy: false,
          verificationId: verificationId,
          resendToken: resendToken,
          codeSentAt: ref.read(loginClockProvider)(),
          clearError: true,
        );
        return true;
      case SignedInInstantly():
        // Signed in: the next login (after a sign-out) starts from C5 again.
        state = const LoginState();
        return false;
      case SendCodeFailed(:final error):
        state = state.copyWith(busy: false, error: error);
        return false;
    }
  }

  /// C6 "Verify" (or all six digits typed). Signing in moves the app on.
  Future<void> verify(String code) async {
    final id = state.verificationId;
    if (state.busy || id == null) return;
    state = state.copyWith(busy: true, clearError: true);
    final error = await _auth.verifyCode(verificationId: id, code: code);
    // Signed in: the next login (after a sign-out) starts from C5 again.
    state = error == null ? const LoginState() : state.copyWith(busy: false, error: error);
  }

  /// C6 "Change number": back to C5, keeping the number to edit.
  void changeNumber() => state = state.copyWith(clearCode: true, clearError: true);

  void clearError() => state = state.copyWith(clearError: true);

  /// Time left before "Resend code" works; zero once it does.
  Duration resendIn() {
    final sentAt = state.codeSentAt;
    if (sentAt == null) return Duration.zero;
    final left = LoginTiming.resendAfter - ref.read(loginClockProvider)().difference(sentAt);
    return left.isNegative ? Duration.zero : left;
  }
}
