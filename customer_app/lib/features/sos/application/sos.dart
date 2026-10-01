import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../booking/application/estimate.dart';
import '../../booking/application/live_booking.dart';
import '../../booking/data/plus_code.dart';
import '../../connectivity/connectivity.dart';
import '../../contacts/application/contacts.dart';
import '../../help/presentation/help_screen.dart' show launchLinkProvider;
import '../../home/application/home_location.dart';
import '../data/share_links.dart';

// Seam: no links until #92 wires Firebase (then CallableShareLinkService(functions, AppEnv.shareOrigin)).
final shareLinkServiceProvider = Provider<ShareLinkService>((ref) => const NoShareLinkService());

/// The system share sheet (WhatsApp and the rest). Tests override it.
final shareTextProvider = Provider<Future<void> Function(String text)>(
  (ref) =>
      (text) => SharePlus.instance.share(ShareParams(text: text)),
);

/// How long SOS waits for a trip link before sending without it.
const kShareLinkWait = Duration(seconds: 4);

/// A point to send: lat/lng with 6 decimals (about 10 cm) and its Plus Code.
typedef SosPlace = ({double lat, double lng});

String mapsLink(SosPlace p) =>
    'https://maps.google.com/?q=${p.lat.toStringAsFixed(6)},${p.lng.toStringAsFixed(6)}';

/// The SMS: who needs help, where, and the live trip when there is one.
String sosMessage(AppLocalizations l10n, {SosPlace? place, Uri? tripLink}) => [
  if (place != null)
    l10n.sos_sms_body(mapsLink(place), encodePlusCode(place.lat, place.lng))
  else
    l10n.sos_sms_body_no_location,
  if (tripLink != null) l10n.sos_sms_trip(tripLink.toString()),
].join(' ');

/// `sms:` to several numbers at once. Android's messaging apps take them comma-separated; the
/// app never sends by itself (no SEND_SMS permission, PLAN §10).
Uri smsUri(List<String> phones, String body) =>
    Uri.parse('sms:${phones.join(',')}?body=${Uri.encodeComponent(body)}');

/// What the SOS hold did.
enum SosOutcome { opened, failed }

final sosProvider = Provider<Sos>(Sos.new);

/// SOS (PLAN §10 Customer advanced): the phone's SMS app opens addressed to the emergency
/// contacts (U17), with the location and, during a booking, the live-trip link.
class Sos {
  Sos(this._ref);

  final Ref _ref;

  /// Where the customer is: the latest fix on Home, else the active booking's pickup.
  SosPlace? get place {
    final fix = _ref.read(homeLocationProvider).fix;
    if (fix != null) return (lat: fix.position.lat, lng: fix.position.lng);
    final pickup = activeBooking?.pickup.geopoint;
    if (pickup != null) return (lat: pickup.latitude, lng: pickup.longitude);
    return null;
  }

  /// The booking in progress, if any (live trip links exist only for those).
  Booking? get activeBooking {
    final active = _ref.read(activeBookingProvider);
    if (active == null) return null;
    final b = _ref.read(liveBookingProvider(active.bookingId)).value;
    return b != null && b.status.isActive ? b : null;
  }

  /// The trip link, or null. Skipped offline, and never waits more than [kShareLinkWait].
  Future<Uri?> tripLink() async {
    final active = _ref.read(activeBookingProvider);
    if (active == null || activeBooking == null || _ref.read(isOfflineProvider)) return null;
    return _ref
        .read(shareLinkServiceProvider)
        .create(active.bookingId)
        .timeout(kShareLinkWait, onTimeout: () => null);
  }

  /// After the hold: the SMS app addressed to every saved contact (or to nobody, so the
  /// customer can pick) with the message.
  Future<SosOutcome> alertContacts(AppLocalizations l10n) async {
    // The sheet keeps the list loaded; if it isn't yet, wait a moment rather than send to nobody.
    final contacts =
        _ref.read(savedContactsProvider).value ??
        await _ref
            .read(savedContactsProvider.future)
            .timeout(const Duration(seconds: 2), onTimeout: () => const <Contact>[])
            .catchError((Object _) => const <Contact>[]);
    final body = sosMessage(l10n, place: place, tripLink: await tripLink());
    final ok = await _ref.read(launchLinkProvider)(smsUri([for (final c in contacts) c.phone], body));
    return ok ? SosOutcome.opened : SosOutcome.failed;
  }

  Future<bool> call112() => _ref.read(launchLinkProvider)(Uri(scheme: 'tel', path: '112'));

  /// Share trip: the live link when there is one, else the location, through the share sheet.
  Future<void> shareTrip(AppLocalizations l10n) async {
    final link = await tripLink();
    final p = place;
    final String text;
    if (link != null) {
      text = l10n.sos_share_trip_text(link.toString());
    } else if (p != null) {
      text = l10n.sos_share_location_text(mapsLink(p));
    } else {
      return;
    }
    await _ref.read(shareTextProvider)(text);
  }
}
