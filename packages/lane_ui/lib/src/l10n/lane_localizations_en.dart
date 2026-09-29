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
}
