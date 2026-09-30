// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'lane_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LaneLocalizationsEn extends LaneLocalizations {
  LaneLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get offline_strip_message => 'You\'re offline. Calls and SMS still work.';

  @override
  String get error_state_title => 'Something went wrong';

  @override
  String get error_state_retry => 'Try again';

  @override
  String get skeleton_loading => 'Loading';

  @override
  String journey_rail_step(int step, int total, String stop) {
    return 'Step $step of $total: $stop';
  }

  @override
  String journey_rail_cancelled(String stop) {
    return 'Ended: $stop';
  }

  @override
  String get trust_verified => 'Verified';

  @override
  String get trust_verified_workshop => 'Verified workshop';

  @override
  String trust_verified_independent(int years) {
    return 'Verified independent mechanic · $years yrs';
  }

  @override
  String trust_jobs(int count) {
    return '$count jobs';
  }

  @override
  String get trust_start_code => 'Start code';

  @override
  String get trust_start_code_hint => 'Share this code only when the mechanic is standing with you.';

  @override
  String get otp_show_big => 'Show large';

  @override
  String get otp_close => 'Close';

  @override
  String get otp_input_label => 'Code';

  @override
  String countdown_seconds_left(int seconds) {
    return '$seconds seconds left';
  }

  @override
  String get accuracy_locating => 'Finding your location';

  @override
  String accuracy_meters(int meters) {
    return '±$meters m';
  }

  @override
  String accuracy_adjust(int meters) {
    return '±$meters m · Adjust pin';
  }

  @override
  String accuracy_semantics(int meters) {
    return 'Location accurate to $meters metres';
  }

  @override
  String price_range_semantics(String min, String max) {
    return '$min to $max';
  }
}
