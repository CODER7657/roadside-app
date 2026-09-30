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

  @override
  String get booking_status_requested => 'खोज रहे हैं';

  @override
  String get booking_status_accepted => 'स्वीकार';

  @override
  String get booking_status_arriving => 'रास्ते में';

  @override
  String get booking_status_arrived => 'पहुँच गए';

  @override
  String get booking_status_in_progress => 'काम चल रहा है';

  @override
  String get booking_status_completed => 'पूरा';

  @override
  String get booking_status_cancelled => 'रद्द';

  @override
  String get booking_status_no_mechanic => 'कोई मैकेनिक नहीं';

  @override
  String dashboard_today(String date) {
    return 'आज, $date';
  }

  @override
  String get dashboard_previous_day => 'पिछला दिन';

  @override
  String get dashboard_next_day => 'अगला दिन';

  @override
  String get dashboard_load_failed => 'डैशबोर्ड लोड नहीं हो सका।';

  @override
  String get dashboard_stat_bookings => 'बुकिंग';

  @override
  String get dashboard_stat_active_mechanics => 'ऑनलाइन मैकेनिक';

  @override
  String get dashboard_stat_active_mechanics_note => 'अभी';

  @override
  String get dashboard_stat_completion => 'पूरा होने की दर';

  @override
  String get dashboard_stat_median_arrival => 'औसत पहुँच समय';

  @override
  String get dashboard_stat_median_arrival_note => 'स्वीकार से पहुँचने तक';

  @override
  String dashboard_minutes(int minutes) {
    return '$minutes मिनट';
  }

  @override
  String get dashboard_stat_sms => 'SMS सफलता';

  @override
  String get dashboard_stat_sms_note => 'मॉनिटरिंग से (#62)';

  @override
  String get dashboard_bookings_title => 'इस दिन की बुकिंग';

  @override
  String get dashboard_bookings_empty => 'इस दिन कोई बुकिंग नहीं।';

  @override
  String get dashboard_column_booking => 'बुकिंग';

  @override
  String get dashboard_column_customer => 'ग्राहक';

  @override
  String get dashboard_column_mechanic => 'मैकेनिक';

  @override
  String get dashboard_column_status => 'स्थिति';

  @override
  String get dashboard_column_amount => 'रकम';

  @override
  String get live_load_failed => 'लाइव बुकिंग लोड नहीं हो सकीं।';

  @override
  String get live_empty => 'अभी कोई चालू बुकिंग नहीं।';

  @override
  String get live_status_all => 'सभी चालू';

  @override
  String get live_vehicle_all => 'सभी वाहन';

  @override
  String live_map_label(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'नक्शा, $count चालू बुकिंग',
      one: 'नक्शा, 1 चालू बुकिंग',
      zero: 'नक्शा, कोई चालू बुकिंग नहीं',
    );
    return '$_temp0';
  }

  @override
  String live_customer(String details) {
    return 'ग्राहक: $details';
  }

  @override
  String live_mechanic(String details) {
    return 'मैकेनिक: $details';
  }

  @override
  String live_searching(int km) {
    return '$km किमी के अंदर खोज रहे हैं';
  }

  @override
  String get live_cancel => 'एडमिन के रूप में रद्द करें';

  @override
  String get live_cancel_reason_label => 'आप क्यों रद्द कर रहे हैं?';

  @override
  String get live_cancel_reason_hint => 'जैसे: ग्राहक ने फ़ोन पर कहा';

  @override
  String get live_cancel_confirm => 'बुकिंग रद्द करें';

  @override
  String get live_cancel_note =>
      'ग्राहक और मैकेनिक को सूचना जाती है। रद्द करना आपके खाते के साथ दर्ज होता है।';

  @override
  String get live_cancelled => 'बुकिंग रद्द हो गई।';

  @override
  String get live_cancel_refused => 'यह बुकिंग अब रद्द नहीं हो सकती।';

  @override
  String get complaints_tab_open => 'खुली';

  @override
  String complaints_tab_open_count(int count) {
    return 'खुली ($count)';
  }

  @override
  String get complaints_tab_resolved => 'सुलझी';

  @override
  String get complaints_tab_reviews => 'रिव्यू';

  @override
  String get complaints_load_failed => 'शिकायतें लोड नहीं हो सकीं।';

  @override
  String get complaints_empty_open => 'कोई खुली शिकायत नहीं।';

  @override
  String get complaints_empty_resolved => 'अभी कोई सुलझी शिकायत नहीं।';

  @override
  String get complaints_empty_reviews => 'अभी कोई रिव्यू नहीं।';

  @override
  String complaints_title(String category, String ref) {
    return '$category · $ref';
  }

  @override
  String complaints_raised_by_customer(String name) {
    return 'ग्राहक $name ने दर्ज की';
  }

  @override
  String complaints_raised_by_mechanic(String name) {
    return 'मैकेनिक $name ने दर्ज की';
  }

  @override
  String complaints_resolution(String text) {
    return 'समाधान: $text';
  }

  @override
  String get complaints_resolution_label => 'समाधान नोट';

  @override
  String get complaints_resolution_hint =>
      'जैसे: दोनों को कॉल किया, UPI ट्रांसफ़र मिला, मैकेनिक से पुष्टि की।';

  @override
  String get complaints_resolve => 'सुलझाएँ';

  @override
  String get complaints_resolved => 'शिकायत सुलझ गई।';

  @override
  String complaints_stars(int stars) {
    String _temp0 = intl.Intl.pluralLogic(stars, locale: localeName, other: '$stars स्टार', one: '1 स्टार');
    return '$_temp0';
  }

  @override
  String get complaints_category_payment => 'भुगतान विवाद';

  @override
  String get complaints_category_service => 'सेवा';

  @override
  String get complaints_category_safety => 'सुरक्षा';

  @override
  String get complaints_category_other => 'अन्य';

  @override
  String get payment_status_pending => 'अभी भुगतान नहीं';

  @override
  String get payment_status_marked_paid => 'ग्राहक कहता है भुगतान किया';

  @override
  String get payment_status_confirmed => 'भुगतान, पुष्टि हुई';

  @override
  String get payment_status_disputed => 'विवादित';

  @override
  String get settings_load_failed => 'सेटिंग्स लोड नहीं हो सकीं।';

  @override
  String get settings_app_title => 'ऐप';

  @override
  String get settings_min_build_label => 'न्यूनतम समर्थित बिल्ड';

  @override
  String get settings_min_build_help => 'पुराने बिल्ड को इस्तेमाल से पहले अपडेट करना होगा।';

  @override
  String get settings_maintenance_label => 'रखरखाव संदेश';

  @override
  String get settings_maintenance_help => 'ऐप में सबको दिखता है। न दिखाना हो तो खाली छोड़ें।';

  @override
  String get settings_support_phone_label => 'सहायता फ़ोन';

  @override
  String get settings_support_phone_hint => '+91 98XXX XXXXX';

  @override
  String get settings_phone_invalid => 'देश कोड के साथ फ़ोन नंबर डालें, जैसे +91…';

  @override
  String get settings_dispatch_label => 'नई बुकिंग लें';

  @override
  String get settings_dispatch_on => 'चालू: ग्राहक बुक कर सकते हैं।';

  @override
  String get settings_dispatch_off => 'बंद: वापस चालू करने तक हर नई बुकिंग मना होगी।';

  @override
  String get settings_save => 'सहेजें';

  @override
  String get settings_saved => 'सहेजा गया। ऐप एक मिनट में इसे ले लेंगे।';

  @override
  String get settings_areas_title => 'सेवा क्षेत्र';

  @override
  String settings_area_missing(String city) {
    return '$city अभी सेट नहीं है (सीड चलाएँ)।';
  }

  @override
  String get settings_area_on => 'चालू: यहाँ बुकिंग ली जाती हैं।';

  @override
  String settings_area_off(String city) {
    return 'बंद: $city में नई बुकिंग को \"अभी आपके इलाके में नहीं\" दिखेगा।';
  }

  @override
  String settings_area_radius_label(String city) {
    return '$city दायरा (किमी)';
  }

  @override
  String get settings_area_radius_invalid => '1 से 100 किमी के बीच';

  @override
  String settings_area_save(String city) {
    return '$city सहेजें';
  }

  @override
  String get settings_admins_title => 'एडमिन';

  @override
  String get settings_admins_note => 'सिर्फ़ पढ़ने के लिए। एडमिन tool/admin से जोड़े और हटाए जाते हैं।';

  @override
  String get complaints_audit_note => 'समाधान आपके खाते के साथ ऑडिट लॉग में दर्ज होता है।';
}
