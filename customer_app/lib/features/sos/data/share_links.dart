import 'package:cloud_functions/cloud_functions.dart';
import 'package:roadside_core/roadside_core.dart';

/// Live-trip links for family (`createShareLink`, #111): `<SHARE_ORIGIN>/t/<token>`. The link
/// stops working when the job ends or after 3 h; the app never has to revoke it.
abstract interface class ShareLinkService {
  /// The link for [bookingId], or null when there can't be one (no share site configured,
  /// the booking isn't active, offline). Never throws: SOS must go out without it.
  Future<Uri?> create(String bookingId);
}

class CallableShareLinkService implements ShareLinkService {
  CallableShareLinkService(this._functions, this._origin);

  /// `FirebaseFunctions.instanceFor(region: 'asia-south1')`.
  final FirebaseFunctions _functions;
  final String _origin;

  @override
  Future<Uri?> create(String bookingId) async {
    if (_origin.isEmpty) return null;
    try {
      final result = await _functions.httpsCallable('createShareLink').call<Map<String, Object?>>({
        'bookingId': bookingId,
      });
      final path = result.data['path'];
      if (path is! String || !path.startsWith('/t/')) return null;
      return Uri.parse(_origin).resolve(path);
    } on Object catch (e, s) {
      // error_booking_not_active, rate limit, offline: the message goes without the link.
      LaneLog.w(
        'share link not created',
        error: e is FirebaseFunctionsException ? e.message : e,
        stackTrace: s,
      );
      return null;
    }
  }
}

/// Until #92 wires Firebase: no link. A made-up one would send family to a dead page.
class NoShareLinkService implements ShareLinkService {
  const NoShareLinkService();

  @override
  Future<Uri?> create(String bookingId) async => null;
}
