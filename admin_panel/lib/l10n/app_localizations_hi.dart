// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get app_title => 'Roadside कंसोल';

  @override
  String get signin_title => 'Roadside कंसोल';

  @override
  String get signin_body => 'सिर्फ़ Roadside एडमिन के लिए। अपने स्वीकृत Google खाते से साइन इन करें।';

  @override
  String get signin_google_button => 'Google से साइन इन करें';

  @override
  String get signin_checking_title => 'आपकी पहुँच जाँची जा रही है';

  @override
  String get signin_error_message => 'साइन इन नहीं हो पाया। फिर से कोशिश करें।';

  @override
  String get signin_not_authorised_title => 'अनुमति नहीं है';

  @override
  String signin_not_authorised_body(String account) {
    return '$account एडमिन खाता नहीं है, इसलिए हमने इसे साइन आउट कर दिया। पहुँच चाहिए तो Roadside टीम से पूछें।';
  }

  @override
  String get signin_not_authorised_retry => 'दूसरा खाता इस्तेमाल करें';

  @override
  String get signin_unknown_account => 'यह खाता';

  @override
  String get signin_unconfigured_title => 'कंसोल जुड़ा नहीं है';

  @override
  String get signin_unconfigured_body =>
      'यह बिल्ड अभी किसी Firebase प्रोजेक्ट से नहीं जुड़ा है। dev या prod की env फ़ाइल के साथ बिल्ड करें।';

  @override
  String get console_nav_dashboard => 'डैशबोर्ड';

  @override
  String get console_nav_approvals => 'मंज़ूरियाँ';

  @override
  String get console_nav_live => 'लाइव बुकिंग';

  @override
  String get console_nav_prices => 'कीमतें';

  @override
  String get console_nav_complaints => 'शिकायतें और रिव्यू';

  @override
  String get console_nav_settings => 'सेटिंग्स';

  @override
  String get console_filter_label => 'शहर';

  @override
  String get console_city_all => 'सभी शहर';

  @override
  String get console_city_ahmedabad => 'अहमदाबाद';

  @override
  String get console_city_ankleshwar => 'अंकलेश्वर';

  @override
  String get console_city_bharuch => 'भरूच';

  @override
  String get console_sign_out => 'साइन आउट';

  @override
  String get console_section_coming_title => 'जल्द आ रहा है';

  @override
  String console_section_coming_body(String issue) {
    return 'यह स्क्रीन इश्यू #$issue के साथ आएगी।';
  }
}
