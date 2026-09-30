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

  @override
  String journey_rail_step(int step, int total, String stop) {
    return '$total में से चरण $step: $stop';
  }

  @override
  String journey_rail_cancelled(String stop) {
    return 'समाप्त: $stop';
  }

  @override
  String get trust_verified => 'सत्यापित';

  @override
  String get trust_verified_workshop => 'सत्यापित वर्कशॉप';

  @override
  String trust_verified_independent(int years) {
    return 'सत्यापित स्वतंत्र मैकेनिक · $years वर्ष';
  }

  @override
  String trust_jobs(int count) {
    return '$count काम';
  }

  @override
  String get trust_start_code => 'शुरू करने का कोड';

  @override
  String get trust_start_code_hint => 'यह कोड केवल तब बताएँ जब मैकेनिक आपके पास खड़ा हो।';

  @override
  String get otp_show_big => 'बड़ा दिखाएँ';

  @override
  String get otp_close => 'बंद करें';

  @override
  String get otp_input_label => 'कोड';

  @override
  String countdown_seconds_left(int seconds) {
    return '$seconds सेकंड बाकी';
  }

  @override
  String get accuracy_locating => 'आपकी लोकेशन ढूँढ रहे हैं';

  @override
  String accuracy_meters(int meters) {
    return '±$meters मी';
  }

  @override
  String accuracy_adjust(int meters) {
    return '±$meters मी · पिन ठीक करें';
  }

  @override
  String accuracy_semantics(int meters) {
    return 'लोकेशन $meters मीटर तक सटीक';
  }

  @override
  String price_range_semantics(String min, String max) {
    return '$min से $max';
  }

  @override
  String get glare_turn_on => 'धूप मोड: तेज़ रोशनी के लिए गहरा कंट्रास्ट';

  @override
  String get glare_turn_off => 'धूप मोड बंद करें';
}
