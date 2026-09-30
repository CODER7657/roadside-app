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

  @override
  String get vehicle_type_car => 'कार';

  @override
  String get vehicle_type_bike => 'बाइक';

  @override
  String get vehicle_type_scooter => 'स्कूटर';

  @override
  String get vehicle_type_ev => 'EV';

  @override
  String get problem_type_flat_tyre => 'टायर पंचर';

  @override
  String get problem_type_battery => 'बैटरी';

  @override
  String get problem_type_wont_start => 'स्टार्ट नहीं हो रही';

  @override
  String get problem_type_overheating => 'ज़्यादा गरम';

  @override
  String get problem_type_accident => 'दुर्घटना';

  @override
  String get problem_type_fuel => 'ईंधन खत्म';

  @override
  String get problem_type_other => 'कुछ और';

  @override
  String get prices_scope_default => 'डिफ़ॉल्ट कीमतें, सभी शहर';

  @override
  String get prices_scope_default_help => 'ग्राहकों को यही दाम दिखते हैं, जब तक उनके शहर के अपने दाम न हों।';

  @override
  String prices_scope_city(String city) {
    return '$city की कीमतें';
  }

  @override
  String get prices_scope_city_help =>
      'सिर्फ़ इस शहर के लिए। डिफ़ॉल्ट (धूसर) दाम इस्तेमाल करने के लिए खाना खाली छोड़ें।';

  @override
  String get prices_column_problem => 'समस्या';

  @override
  String prices_min_label(String vehicle, String problem) {
    return '$vehicle, $problem: न्यूनतम';
  }

  @override
  String prices_max_label(String vehicle, String problem) {
    return '$vehicle, $problem: अधिकतम';
  }

  @override
  String prices_unsaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बदलाव सहेजना बाकी',
      one: '1 बदलाव सहेजना बाकी',
      zero: 'कोई बदलाव सहेजना बाकी नहीं',
    );
    return '$_temp0';
  }

  @override
  String get prices_discard => 'रद्द करें';

  @override
  String get prices_save => 'बदलाव सहेजें';

  @override
  String get prices_saved_toast => 'कीमतें सहेजी गईं। नई बुकिंग अब इन्हीं से होंगी।';

  @override
  String get prices_save_failed => 'सहेजा नहीं जा सका। कुछ नहीं बदला। फिर से कोशिश करें।';

  @override
  String get prices_missing_default => 'पहले सभी शहरों की कीमत तय करें, फिर शहर की अपनी।';

  @override
  String get prices_load_failed => 'कीमतें लोड नहीं हो सकीं।';

  @override
  String get prices_error_required => 'दोनों रकम डालें';

  @override
  String get prices_error_number => 'सिर्फ़ पूरे रुपये';

  @override
  String get prices_error_range => '₹1 से ₹1,00,000 के बीच';

  @override
  String get prices_error_order => 'न्यूनतम, अधिकतम से कम होना चाहिए';
}
