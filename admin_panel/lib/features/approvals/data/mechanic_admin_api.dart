import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/firebase_providers.dart';

/// KYC documents an admin can open, as returned by `getKycDocumentUrls`.
enum KycDocument { idProof, selfieWithId, addressProof }

/// Why an admin action failed, in words the screen can show.
enum AdminActionFailure {
  /// The callable isn't deployed yet (#130) or the backend is unreachable.
  unavailable,

  /// The server refused: wrong state, e.g. an independent mechanic without a verification call.
  precondition,

  /// The session lost the admin claim.
  notAllowed,
  unknown,
}

class AdminActionException implements Exception {
  const AdminActionException(this.failure);

  final AdminActionFailure failure;

  @override
  String toString() => 'AdminActionException($failure)';
}

/// The A2 admin callables (#130). Each checks the admin claim, writes `auditLogs`, and sets the
/// 🔒 fields and claims clients can't (PLAN §10.0, §12.2).
abstract interface class MechanicAdminApi {
  Future<void> approve(String uid);

  Future<void> block(String uid, {required String reason});

  Future<void> logVerificationCall(String uid, {required String notes});

  /// Short-lived signed URLs (≤ 5 min) for the documents this mechanic uploaded.
  Future<Map<KycDocument, Uri>> kycDocumentUrls(String uid);
}

class FirebaseMechanicAdminApi implements MechanicAdminApi {
  FirebaseMechanicAdminApi(this._functions);

  final FirebaseFunctions _functions;

  Future<Object?> _call(String name, Map<String, Object?> data) async {
    try {
      return (await _functions.httpsCallable(name).call<Object?>(data)).data;
    } on FirebaseFunctionsException catch (e) {
      throw AdminActionException(switch (e.code) {
        'not-found' || 'unavailable' || 'internal' => AdminActionFailure.unavailable,
        'failed-precondition' => AdminActionFailure.precondition,
        'permission-denied' || 'unauthenticated' => AdminActionFailure.notAllowed,
        _ => AdminActionFailure.unknown,
      });
    }
  }

  @override
  Future<void> approve(String uid) => _call('approveMechanic', {'uid': uid});

  @override
  Future<void> block(String uid, {required String reason}) =>
      _call('blockMechanic', {'uid': uid, 'reason': reason});

  @override
  Future<void> logVerificationCall(String uid, {required String notes}) =>
      _call('logVerificationCall', {'uid': uid, 'notes': notes});

  @override
  Future<Map<KycDocument, Uri>> kycDocumentUrls(String uid) async {
    final data = await _call('getKycDocumentUrls', {'uid': uid});
    final urls = data is Map ? data : const <Object?, Object?>{};
    return {
      for (final doc in KycDocument.values)
        if (urls[doc.name] case final String url when Uri.tryParse(url)?.scheme == 'https')
          doc: Uri.parse(url),
    };
  }
}

final mechanicAdminApiProvider = Provider<MechanicAdminApi>(
  (ref) => FirebaseMechanicAdminApi(ref.watch(functionsProvider)),
);
