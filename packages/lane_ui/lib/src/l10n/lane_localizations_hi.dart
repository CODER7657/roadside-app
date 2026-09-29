// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'lane_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class LaneLocalizationsHi extends LaneLocalizations {
  LaneLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get offline_strip_message => 'आप ऑफ़लाइन हैं। कॉल और SMS अब भी काम करते हैं।';

  @override
  String get error_state_title => 'कुछ गड़बड़ हो गई';

  @override
  String get error_state_retry => 'फिर से कोशिश करें';

  @override
  String get skeleton_loading => 'लोड हो रहा है';
}
