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

  @override
  String get mechanic_status_pending => 'लंबित';

  @override
  String get mechanic_status_approved => 'मंज़ूर';

  @override
  String get mechanic_status_blocked => 'ब्लॉक';

  @override
  String get mechanic_type_workshop => 'वर्कशॉप';

  @override
  String get mechanic_type_independent => 'स्वतंत्र';

  @override
  String get approvals_type_all => 'सभी प्रकार';

  @override
  String get approvals_search_label => 'खोजें';

  @override
  String get approvals_search_hint => 'मैकेनिक का नाम';

  @override
  String approvals_empty(String status) {
    return 'यहाँ कुछ नहीं: $status स्थिति वाला कोई मैकेनिक नहीं।';
  }

  @override
  String get approvals_load_failed => 'मैकेनिक लोड नहीं हो सके।';

  @override
  String approvals_experience(int years) {
    String _temp0 = intl.Intl.pluralLogic(years, locale: localeName, other: '$years साल', one: '1 साल');
    return '$_temp0';
  }

  @override
  String approvals_registered(String date) {
    return '$date को रजिस्टर';
  }

  @override
  String get approvals_base_area => 'बेस इलाका';

  @override
  String approvals_travel_vehicle(String vehicle) {
    return 'आने का वाहन ($vehicle)';
  }

  @override
  String get approvals_shop_name => 'दुकान';

  @override
  String get approvals_shop_address => 'पता';

  @override
  String get approvals_services => 'सेवाएँ';

  @override
  String get approvals_vehicle_types => 'वाहन';

  @override
  String get approvals_photos => 'फ़ोटो';

  @override
  String get approvals_photo_profile => 'प्रोफ़ाइल फ़ोटो';

  @override
  String get approvals_photo_shop => 'दुकान की फ़ोटो';

  @override
  String approvals_photo_toolkit(int n) {
    return 'औज़ारों की फ़ोटो $n';
  }

  @override
  String get approvals_kyc => 'पहचान और भुगतान';

  @override
  String get approvals_kyc_missing => 'KYC अभी जमा नहीं हुआ।';

  @override
  String get approvals_upi => 'UPI';

  @override
  String get approvals_phone => 'फ़ोन';

  @override
  String get approvals_reference => 'रेफ़रेंस';

  @override
  String get approvals_document_id => 'ID प्रूफ़ खोलें';

  @override
  String get approvals_document_selfie => 'ID के साथ सेल्फ़ी खोलें';

  @override
  String get approvals_document_address => 'पते का प्रूफ़ खोलें';

  @override
  String get approvals_documents_note =>
      'दस्तावेज़ नए टैब में ऐसे लिंक से खुलते हैं जो कुछ मिनट में खत्म हो जाता है। इन्हें डाउनलोड न करें।';

  @override
  String get approvals_document_missing => 'यह दस्तावेज़ उपलब्ध नहीं है।';

  @override
  String get approvals_checklist => 'चेकलिस्ट';

  @override
  String get approvals_check_shop_photo => 'दुकान की फ़ोटो में असली वर्कशॉप है';

  @override
  String get approvals_check_id_proof => 'ID प्रूफ़ नाम से मेल खाता है';

  @override
  String get approvals_check_services => 'सेवाएँ और वाहन ठीक लगते हैं';

  @override
  String get approvals_check_selfie => 'सेल्फ़ी ID से मेल खाती है';

  @override
  String get approvals_check_address => 'पते का प्रूफ़ जाँचा';

  @override
  String get approvals_check_toolkit => 'औज़ारों की फ़ोटो में असली औज़ार हैं';

  @override
  String get approvals_call_notes_label => 'वेरिफ़िकेशन कॉल के नोट्स';

  @override
  String get approvals_call_notes_hint => 'वीडियो कॉल, ID मेल खाया, पटेल मोटर्स में 6 साल की पुष्टि।';

  @override
  String get approvals_call_log => 'वेरिफ़िकेशन कॉल दर्ज करें';

  @override
  String get approvals_call_logged => 'वेरिफ़िकेशन कॉल दर्ज हुई।';

  @override
  String approvals_call_done(String date, String notes) {
    return 'कॉल दर्ज $date: $notes';
  }

  @override
  String get approvals_approve => 'मंज़ूर करें';

  @override
  String get approvals_approved => 'मंज़ूर हो गया। अब वे ऑनलाइन जा सकते हैं।';

  @override
  String get approvals_block => 'ब्लॉक करें';

  @override
  String get approvals_block_reason_label => 'आप उन्हें क्यों ब्लॉक कर रहे हैं?';

  @override
  String get approvals_block_reason_hint => 'जैसे: ID प्रूफ़ मेल नहीं खाता';

  @override
  String get approvals_block_confirm => 'मैकेनिक को ब्लॉक करें';

  @override
  String get approvals_block_cancel => 'रद्द करें';

  @override
  String get approvals_blocked => 'ब्लॉक कर दिया। उन्हें हर जगह से साइन आउट कर दिया गया।';

  @override
  String get approvals_blocked_note => 'यह मैकेनिक ब्लॉक है और काम नहीं ले सकता।';

  @override
  String get approvals_audit_note => 'हर मंज़ूरी, ब्लॉक और कॉल ऑडिट लॉग में दर्ज होती है।';

  @override
  String get approvals_why_kyc => 'मंज़ूरी से पहले KYC दस्तावेज़ चाहिए।';

  @override
  String get approvals_why_checklist => 'मंज़ूर करने के लिए चेकलिस्ट का हर आइटम टिक करें।';

  @override
  String get approvals_why_call => 'स्वतंत्र मैकेनिक को मंज़ूर करने के लिए वेरिफ़िकेशन कॉल दर्ज करें।';

  @override
  String get approvals_error_unavailable => 'यह काम अभी उपलब्ध नहीं है। बाद में कोशिश करें।';

  @override
  String get approvals_error_precondition =>
      'सर्वर ने मना किया: मैकेनिक की स्थिति और वेरिफ़िकेशन कॉल जाँचें।';

  @override
  String get approvals_error_not_allowed => 'आपकी एडमिन पहुँच बदल गई है। फिर से साइन इन करें।';

  @override
  String get approvals_error_unknown => 'कुछ गड़बड़ हुई। कुछ नहीं बदला।';
}
