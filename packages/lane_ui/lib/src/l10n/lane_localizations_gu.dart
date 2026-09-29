// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'lane_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class LaneLocalizationsGu extends LaneLocalizations {
  LaneLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get offline_strip_message => 'તમે ઑફલાઇન છો. કૉલ અને SMS હજી ચાલે છે.';

  @override
  String get error_state_title => 'કંઈક ખોટું થયું';

  @override
  String get error_state_retry => 'ફરી પ્રયાસ કરો';

  @override
  String get skeleton_loading => 'લોડ થઈ રહ્યું છે';

  @override
  String journey_rail_step(int step, int total, String stop) {
    return '$total માંથી પગલું $step: $stop';
  }

  @override
  String journey_rail_cancelled(String stop) {
    return 'સમાપ્ત: $stop';
  }

  @override
  String get trust_verified => 'ચકાસાયેલ';

  @override
  String get trust_verified_workshop => 'ચકાસાયેલ વર્કશોપ';

  @override
  String trust_verified_independent(int years) {
    return 'ચકાસાયેલ સ્વતંત્ર મિકેનિક · $years વર્ષ';
  }

  @override
  String trust_jobs(int count) {
    return '$count કામ';
  }

  @override
  String get trust_start_code => 'શરૂ કરવાનો કોડ';

  @override
  String get trust_start_code_hint => 'મિકેનિક તમારી સાથે ઊભો હોય ત્યારે જ આ કોડ જણાવો.';

  @override
  String get otp_show_big => 'મોટું બતાવો';

  @override
  String get otp_close => 'બંધ કરો';

  @override
  String get otp_input_label => 'કોડ';

  @override
  String countdown_seconds_left(int seconds) {
    return '$seconds સેકન્ડ બાકી';
  }
}
