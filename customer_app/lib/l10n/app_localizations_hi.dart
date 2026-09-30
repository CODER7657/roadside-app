// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get app_title => 'Roadside';

  @override
  String flow_step_label(int step, int total) {
    return '$total में से चरण $step';
  }

  @override
  String get splash_tagline => 'सड़क पर मदद, मिनटों में';

  @override
  String get splash_loading => 'तैयारी हो रही है';

  @override
  String get language_title => 'अपनी भाषा चुनें';

  @override
  String get language_body => 'आप इसे बाद में सेटिंग्स में बदल सकते हैं।';

  @override
  String get language_continue => 'आगे बढ़ें';

  @override
  String get onboarding_slide1_title => 'मिनटों में मदद';

  @override
  String get onboarding_slide1_body => 'बताइए क्या खराबी है। सबसे पास का सत्यापित मैकेनिक आपके पास आता है।';

  @override
  String get onboarding_slide2_title => 'लाइव ट्रैक करें';

  @override
  String get onboarding_slide2_body => 'मैकेनिक को नक्शे पर देखें, पहुँचने के लाइव समय के साथ।';

  @override
  String get onboarding_slide3_title => 'सुरक्षित और सत्यापित';

  @override
  String get onboarding_slide3_body =>
      'हर मैकेनिक की पहचान जाँची जाती है। एक टैप में परिवार के साथ अपनी यात्रा साझा करें।';

  @override
  String get onboarding_next => 'आगे';

  @override
  String get onboarding_skip => 'छोड़ें';

  @override
  String get onboarding_start => 'शुरू करें';

  @override
  String get consent_title => 'आपकी गोपनीयता';

  @override
  String get consent_intro => 'हम केवल वही जानकारी लेते हैं जो आप तक मदद भेजने के लिए ज़रूरी है।';

  @override
  String get consent_point_collect => 'आपका फ़ोन नंबर, नाम, गाड़ियाँ और आपके द्वारा जोड़ी गई तस्वीरें।';

  @override
  String get consent_point_location => 'आपकी लोकेशन, केवल बुकिंग के समय और जब तक मदद रास्ते में है।';

  @override
  String get consent_point_delete => 'आप कभी भी अपना डेटा देख, सुधार या हटा सकते हैं।';

  @override
  String get consent_age => 'मेरी उम्र 18 वर्ष या उससे अधिक है';

  @override
  String get consent_notice => 'मैं गोपनीयता सूचना से सहमत हूँ';

  @override
  String get consent_agree => 'सहमत हूँ, आगे बढ़ें';

  @override
  String get consent_read_notice => 'पूरी सूचना पढ़ें';

  @override
  String get privacy_title => 'गोपनीयता सूचना';

  @override
  String get privacy_collect_title => 'हम क्या लेते हैं';

  @override
  String get privacy_collect_body =>
      'आपका फ़ोन नंबर, नाम और भाषा, आपकी जोड़ी गई गाड़ियाँ, बुकिंग में लगाई गई तस्वीरें, और बुकिंग के समय या मैकेनिक के रास्ते में होने तक आपकी लोकेशन।';

  @override
  String get privacy_use_title => 'हम इसका उपयोग क्यों करते हैं';

  @override
  String get privacy_use_body =>
      'केवल आपके लिए मैकेनिक ढूँढने, उसे आपकी जगह दिखाने और आप दोनों को सुरक्षित रखने के लिए। हम विज्ञापन नहीं दिखाते और आपका डेटा नहीं बेचते।';

  @override
  String get privacy_keep_title => 'हम इसे कितने समय तक रखते हैं';

  @override
  String get privacy_keep_body =>
      'लाइव लोकेशन: काम के 24 घंटे बाद तक। चैट: 90 दिन। बुकिंग रिकॉर्ड: टैक्स के लिए 3 साल, खाता हटाने पर गुमनाम।';

  @override
  String get privacy_rights_title => 'आपके अधिकार';

  @override
  String get privacy_rights_body =>
      'ऐप में अपनी जानकारी देखें और सुधारें, अपनी सहमति वापस लें, या सेटिंग्स से अपना खाता हटाएँ।';

  @override
  String get privacy_contact_title => 'प्रश्न या शिकायत';

  @override
  String get privacy_contact_body => 'मदद और FAQ से हमारे शिकायत अधिकारी से संपर्क करें।';

  @override
  String get home_help => 'मदद और FAQ';

  @override
  String get permission_location_title => 'लोकेशन की अनुमति दें';

  @override
  String get permission_location_body =>
      'ताकि मैकेनिक आपको ढूँढ सके। हम आपकी लोकेशन केवल बुकिंग के समय और मदद के रास्ते में होने तक उपयोग करते हैं।';

  @override
  String get permission_camera_title => 'कैमरा की अनुमति दें';

  @override
  String get permission_camera_body =>
      'समस्या की तस्वीरें जोड़ने के लिए। केवल आपकी चुनी हुई तस्वीरें मैकेनिक के साथ साझा होती हैं।';

  @override
  String get permission_notifications_title => 'सूचनाओं की अनुमति दें';

  @override
  String get permission_notifications_body =>
      'ताकि हम आपको बता सकें कि मैकेनिक ने कब स्वीकार किया, कब रास्ते में है और कब पहुँचा।';

  @override
  String get permission_blocked_body =>
      'यह आपके फ़ोन की सेटिंग्स में बंद है। सेटिंग्स खोलें, अनुमतियाँ पर टैप करें और इसे चालू करें।';

  @override
  String get permission_allow => 'अनुमति दें';

  @override
  String get permission_open_settings => 'सेटिंग्स खोलें';

  @override
  String get permission_not_now => 'अभी नहीं';

  @override
  String get help_title => 'मदद';

  @override
  String get help_search_label => 'प्रश्न खोजें';

  @override
  String get help_search_hint => 'जैसे कीमत, शुरू करने का कोड';

  @override
  String get help_no_results_title => 'कोई मेल खाता प्रश्न नहीं';

  @override
  String get help_no_results_body => 'दूसरे शब्द आज़माएँ, या हमें कॉल करें।';

  @override
  String get help_call_support => 'सहायता को कॉल करें';

  @override
  String get help_whatsapp => 'WhatsApp';

  @override
  String get help_grievance_title => 'शिकायत अधिकारी';

  @override
  String get help_grievance_body =>
      'अपने डेटा या गोपनीयता से जुड़ी शिकायतों के लिए हमारे शिकायत अधिकारी को लिखें। हम 7 दिनों में जवाब देते हैं।';

  @override
  String get help_faq_price_q => 'इसका खर्च कितना होगा?';

  @override
  String get help_faq_price_a =>
      'बुक करने से पहले आपको कीमत की सीमा दिखती है। काम के बाद मैकेनिक ऐप में अंतिम राशि डालता है, और आप UPI से सीधे उसे भुगतान करते हैं।';

  @override
  String get help_faq_verified_q => 'क्या मैकेनिक सत्यापित हैं?';

  @override
  String get help_faq_verified_a =>
      'हाँ। काम मिलने से पहले हम हर मैकेनिक की पहचान जाँचते हैं। बिना वर्कशॉप वाले मैकेनिक का वेरिफ़िकेशन कॉल भी होता है।';

  @override
  String get help_faq_code_q => 'शुरू करने का कोड क्या है?';

  @override
  String get help_faq_code_a =>
      'आपके ऐप में 4 अंकों का कोड। इसे केवल तब बताएँ जब मैकेनिक आपके पास खड़ा हो; वह इसे डालता है तब काम शुरू होता है।';

  @override
  String get help_faq_pay_q => 'मैं भुगतान कैसे करूँ?';

  @override
  String get help_faq_pay_a =>
      'UPI से, सीधे मैकेनिक को: हमारे ऐप से अपना UPI ऐप खोलें या QR स्कैन करें, फिर \"मैंने भुगतान कर दिया\" पर टैप करें। हम कभी कार्ड या बैंक विवरण नहीं माँगते।';

  @override
  String get help_faq_cancel_q => 'क्या मैं रद्द कर सकता हूँ?';

  @override
  String get help_faq_cancel_a =>
      'हाँ, काम शुरू होने से पहले कभी भी। एक टैप में कारण बताएँ ताकि हम सुधार कर सकें।';

  @override
  String get help_faq_area_q => 'यह कहाँ काम करता है?';

  @override
  String get help_faq_area_a =>
      'अभी अहमदाबाद, अंकलेश्वर और भरूच में, आसपास के हाईवे सहित। और शहर जल्द आ रहे हैं।';

  @override
  String get home_my_vehicles => 'मेरी गाड़ियाँ';

  @override
  String get vehicles_title => 'मेरी गाड़ियाँ';

  @override
  String get vehicles_add => 'गाड़ी जोड़ें';

  @override
  String get vehicles_empty_title => 'अभी कोई गाड़ी नहीं';

  @override
  String get vehicles_empty_body => 'अपनी गाड़ी एक बार जोड़ें, फिर मदद बुक करना एक टैप में।';

  @override
  String get vehicles_default_label => 'डिफ़ॉल्ट';

  @override
  String get vehicles_delete => 'हटाएँ';

  @override
  String get vehicles_removed => 'गाड़ी हटा दी गई';

  @override
  String get vehicles_undo => 'वापस लाएँ';

  @override
  String get vehicle_add_step => 'नई गाड़ी';

  @override
  String get vehicle_add_title => 'आपकी गाड़ी';

  @override
  String get vehicle_type_label => 'प्रकार';

  @override
  String get vehicle_type_car => 'कार';

  @override
  String get vehicle_type_bike => 'बाइक';

  @override
  String get vehicle_type_scooter => 'स्कूटर';

  @override
  String get vehicle_type_ev => 'EV';

  @override
  String get vehicle_brand_label => 'ब्रांड';

  @override
  String get vehicle_brand_hint => 'जैसे मारुति सुज़ुकी';

  @override
  String get vehicle_model_label => 'मॉडल';

  @override
  String get vehicle_model_hint => 'जैसे स्विफ़्ट';

  @override
  String get vehicle_reg_label => 'रजिस्ट्रेशन नंबर';

  @override
  String get vehicle_reg_hint => 'GJ 01 AB 1234';

  @override
  String get vehicle_fuel_label => 'ईंधन';

  @override
  String get fuel_petrol => 'पेट्रोल';

  @override
  String get fuel_diesel => 'डीज़ल';

  @override
  String get fuel_cng => 'CNG';

  @override
  String get fuel_electric => 'इलेक्ट्रिक';

  @override
  String get vehicle_make_default => 'इसे मेरी डिफ़ॉल्ट गाड़ी बनाएँ';

  @override
  String get vehicle_save => 'गाड़ी सहेजें';

  @override
  String get error_field_required => 'कृपया इसे भरें';

  @override
  String get error_field_too_long => 'यह बहुत लंबा है';

  @override
  String get error_field_invalid => 'कृपया इसे जाँचें';

  @override
  String get error_reg_no_invalid => 'नंबर जाँचें, जैसे GJ 01 AB 1234 या 22 BH 1234 AA';

  @override
  String get home_get_help => 'मदद लें';

  @override
  String booking_step(int step, int total) {
    return 'चरण $step / $total';
  }

  @override
  String get booking_next => 'आगे';

  @override
  String get problem_title => 'क्या खराबी है?';

  @override
  String get problem_vehicle_label => 'वाहन';

  @override
  String get problem_no_vehicle_title => 'पहले अपना वाहन जोड़ें';

  @override
  String get problem_no_vehicle_body => 'मैकेनिक को पता होना चाहिए कि क्या ठीक करना है।';

  @override
  String get problem_add_vehicle => 'वाहन जोड़ें';

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
  String get photos_title => 'फ़ोटो और जानकारी';

  @override
  String get photos_body =>
      'वैकल्पिक। फ़ोटो से मैकेनिक सही पुर्ज़े ला पाता है। हम हर फ़ोटो से लोकेशन हटा देते हैं।';

  @override
  String get photos_take => 'फ़ोटो लें';

  @override
  String get photos_gallery => 'गैलरी से चुनें';

  @override
  String photos_count(int count, int max) {
    return '$max में से $count फ़ोटो';
  }

  @override
  String photos_remove(int n) {
    return 'फ़ोटो $n हटाएँ';
  }

  @override
  String photos_uploading(int n) {
    return 'फ़ोटो $n अपलोड हो रही है';
  }

  @override
  String photos_retry(int n) {
    return 'फ़ोटो $n अपलोड नहीं हुई। फिर से कोशिश करें';
  }

  @override
  String get photos_error_limit => 'आप 4 फ़ोटो तक जोड़ सकते हैं।';

  @override
  String get photos_error_too_large => 'यह फ़ोटो बहुत बड़ी है। दूसरी आज़माएँ।';

  @override
  String get photos_error_failed => 'फ़ोटो नहीं जुड़ सकी। फिर से कोशिश करें।';

  @override
  String get photos_error_upload =>
      'कुछ फ़ोटो अपलोड नहीं हुईं। आगे बढ़ने के लिए फिर से कोशिश करें या उन्हें हटाएँ।';

  @override
  String get description_label => 'क्या हुआ?';

  @override
  String get description_hint => 'जैसे: टोल प्लाज़ा के पास पिछला टायर पंचर हो गया';

  @override
  String get photos_skip => 'छोड़ें';

  @override
  String photos_item(int n) {
    return 'फ़ोटो $n';
  }

  @override
  String get booking_back_home => 'होम पर वापस';

  @override
  String get location_title => 'आप कहाँ हैं?';

  @override
  String get location_hint => 'मैप को खिसकाएँ ताकि पिन आपके वाहन पर हो।';

  @override
  String get location_no_permission =>
      'इस ऐप के लिए लोकेशन बंद है। मैप को अपनी जगह तक खिसकाएँ, या लोकेशन की अनुमति दें।';

  @override
  String get location_allow => 'लोकेशन की अनुमति दें';

  @override
  String get location_gps_off => 'आपके फ़ोन की लोकेशन बंद है।';

  @override
  String get location_turn_on => 'लोकेशन चालू करें';

  @override
  String get location_no_fix => 'हम आपको ढूँढ नहीं पाए। मैप को अपनी जगह तक खिसकाएँ।';

  @override
  String get location_finding_address => 'पता ढूँढ रहे हैं…';

  @override
  String get location_no_address => 'यहाँ कोई पता नहीं है। मैकेनिक प्लस कोड से आएगा।';

  @override
  String location_plus_code(String code) {
    return 'प्लस कोड $code';
  }

  @override
  String get location_landmark_label => 'पास की पहचान (वैकल्पिक)';

  @override
  String get location_landmark_hint => 'जैसे: पेट्रोल पंप के सामने';

  @override
  String get location_far_warning => 'पिन आपके फ़ोन की जगह से 2 किमी से ज़्यादा दूर है।';

  @override
  String get location_someone_else => 'मैं किसी और के लिए बुक कर रहा/रही हूँ';

  @override
  String get location_confirm => 'पिकअप पक्का करें';

  @override
  String get location_recenter => 'मेरी लोकेशन पर जाएँ';

  @override
  String get location_retry => 'फिर से कोशिश करें';

  @override
  String get price_title => 'आपका अनुमान';

  @override
  String get price_book => 'मैकेनिक बुक करें';

  @override
  String get price_note =>
      'काम के बाद आप सीधे मैकेनिक को UPI या नकद से भुगतान करते हैं। पुर्ज़े लगें तो राशि बदल सकती है।';

  @override
  String get price_error_out_of_area =>
      'हम अभी इस इलाके में नहीं हैं। हम अहमदाबाद, अंकलेश्वर और भरूच में सेवा देते हैं।';

  @override
  String get price_change_pickup => 'पिकअप बदलें';

  @override
  String get price_error_active_booking => 'आपकी एक बुकिंग पहले से चल रही है।';

  @override
  String get price_open_booking => 'मेरी बुकिंग खोलें';

  @override
  String get price_error_paused => 'बुकिंग कुछ देर के लिए रुकी हैं। कृपया कुछ मिनट बाद फिर कोशिश करें।';

  @override
  String get price_error_unavailable =>
      'हम अभी इस समस्या की कीमत नहीं बता सकते। हमारी सहायता टीम मदद कर सकती है।';

  @override
  String get price_get_support => 'सहायता लें';

  @override
  String get price_error_vehicle => 'यह वाहन हटा दिया गया है। कोई दूसरा चुनें।';

  @override
  String get price_choose_vehicle => 'वाहन चुनें';

  @override
  String get price_error_rate_limited => 'बहुत ज़्यादा कोशिशें। कृपया कुछ मिनट रुककर फिर कोशिश करें।';

  @override
  String get price_error_network => 'बुक नहीं हो सका। अपना कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get searching_title => 'मैकेनिक ढूँढ रहे हैं';

  @override
  String get searching_body => 'हम सबसे पास का मैकेनिक ढूँढ रहे हैं।';

  @override
  String searching_radius(int km) {
    return 'हम आपसे $km किमी के अंदर के मैकेनिकों से पूछ रहे हैं।';
  }

  @override
  String get cancel_booking => 'बुकिंग रद्द करें';

  @override
  String get cancel_title => 'यह बुकिंग रद्द करें?';

  @override
  String get cancel_body_searching => 'हम तुरंत मैकेनिक ढूँढना बंद कर देंगे।';

  @override
  String get cancel_body_assigned => 'आपके मैकेनिक को तुरंत बताया जाएगा। कृपया कारण चुनें।';

  @override
  String get cancel_confirm => 'बुकिंग रद्द करें';

  @override
  String get cancel_keep => 'बुकिंग रखें';

  @override
  String get cancel_reason_found_help => 'कहीं और मदद मिल गई';

  @override
  String get cancel_reason_fixed_myself => 'खुद ठीक कर लिया';

  @override
  String get cancel_reason_too_slow => 'बहुत देर हो रही है';

  @override
  String get cancel_reason_wrong_details => 'गलत वाहन या जगह';

  @override
  String get cancel_reason_other => 'कुछ और';

  @override
  String get cancel_reason_text => 'और बताएँ (वैकल्पिक)';

  @override
  String get cancel_error_too_late => 'अब रद्द नहीं हो सकता: काम शुरू हो चुका है।';

  @override
  String get cancel_error_network => 'रद्द नहीं हो सका। अपना कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get no_mechanic_title => 'अभी कोई मैकेनिक खाली नहीं है';

  @override
  String get no_mechanic_body =>
      'पास के सभी मैकेनिक व्यस्त हैं। कुछ मिनट बाद फिर कोशिश करें, या हमसे बात करें।';

  @override
  String get no_mechanic_try_again => 'फिर से कोशिश करें';

  @override
  String get cancelled_title => 'बुकिंग रद्द हो गई';

  @override
  String get cancelled_by_you => 'आपने यह बुकिंग रद्द की।';

  @override
  String get cancelled_by_mechanic => 'मैकेनिक को रद्द करना पड़ा। आपसे कोई शुल्क नहीं लिया गया।';

  @override
  String get cancelled_by_support => 'हमारी सहायता टीम ने यह बुकिंग रद्द की।';

  @override
  String get live_not_found => 'यह बुकिंग नहीं मिली।';

  @override
  String get assigned_title => 'एक मैकेनिक आ रहा है';

  @override
  String get assigned_on_the_way => 'आपका मैकेनिक रास्ते में है';

  @override
  String get assigned_arrived => 'आपका मैकेनिक पहुँच गया है';

  @override
  String get stop_requested => 'अनुरोध';

  @override
  String get stop_accepted => 'स्वीकार';

  @override
  String get stop_on_the_way => 'रास्ते में';

  @override
  String get stop_arrived => 'पहुँच गए';

  @override
  String get stop_working => 'काम जारी';

  @override
  String get stop_done => 'पूरा';

  @override
  String get notif_start_code_locked_title => 'किसी ने आपका स्टार्ट कोड आज़माया';

  @override
  String get notif_start_code_locked_body =>
      'किसी ने आपका स्टार्ट कोड 5 बार आज़माया। इसे केवल अपने मैकेनिक को सामने से बताएँ।';

  @override
  String tracking_on_the_way(String name) {
    return '$name रास्ते में हैं';
  }

  @override
  String tracking_arrived(String name) {
    return '$name पहुँच गए हैं';
  }

  @override
  String tracking_eta(int minutes) {
    return '$minutes मिनट';
  }

  @override
  String get tracking_away => 'दूर';

  @override
  String tracking_waiting(String name) {
    return '$name की लोकेशन का इंतज़ार…';
  }

  @override
  String tracking_stale(int minutes) {
    return 'लोकेशन $minutes मिनट पहले अपडेट हुई। शायद नेटवर्क नहीं है।';
  }

  @override
  String tracking_call(String name) {
    return '$name को कॉल करें';
  }

  @override
  String get tracking_call_failed => 'फ़ोन ऐप नहीं खुल सका।';

  @override
  String get tracking_start_code => 'शुरू करने का कोड';

  @override
  String get tracking_start_code_hint => 'यह कोड केवल तब बताएँ जब मैकेनिक आपके पास खड़ा हो।';

  @override
  String working_title(String name) {
    return '$name काम कर रहे हैं';
  }

  @override
  String working_since(String time, int minutes) {
    return '$time बजे शुरू · अब तक $minutes मिनट';
  }

  @override
  String get working_started => 'काम शुरू हो गया है।';

  @override
  String payment_title(String name) {
    return '$name को भुगतान करें';
  }

  @override
  String payment_estimate_was(String min, String max) {
    return 'अनुमान $min–$max था';
  }

  @override
  String get payment_no_amount => 'मैकेनिक के अंतिम राशि डालने का इंतज़ार है।';

  @override
  String get payment_pay_upi => 'UPI ऐप से भुगतान करें';

  @override
  String payment_qr_label(String amount, String name) {
    return '$name को $amount भुगतान करने का QR कोड';
  }

  @override
  String get payment_qr_hint => 'या किसी भी UPI ऐप से स्कैन करें';

  @override
  String get payment_copy_upi => 'UPI ID कॉपी करें';

  @override
  String get payment_upi_copied => 'UPI ID कॉपी हो गई';

  @override
  String get payment_no_upi_app => 'कोई UPI ऐप नहीं खुला। दूसरे फ़ोन से QR स्कैन करें, या नकद दें।';

  @override
  String payment_cash(String name) {
    return '$name को नकद दें, या उनसे UPI ID पूछें।';
  }

  @override
  String get payment_i_have_paid => 'मैंने भुगतान कर दिया';

  @override
  String get payment_problem => 'कुछ गड़बड़ है';

  @override
  String get payment_error_network => 'भुगतान अपडेट नहीं हो सका। अपना कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String payment_waiting_title(String name) {
    return '$name की पुष्टि का इंतज़ार';
  }

  @override
  String payment_waiting_body(String amount) {
    return 'वे देखेंगे कि $amount उनके UPI ऐप में आ गए।';
  }

  @override
  String payment_confirmed_title(String amount) {
    return '$amount का भुगतान हुआ';
  }

  @override
  String get payment_confirmed_title_plain => 'भुगतान की पुष्टि हुई';

  @override
  String payment_confirmed_body(String name) {
    return 'धन्यवाद! $name ने आपके भुगतान की पुष्टि की।';
  }

  @override
  String get payment_disputed_title => 'हम इसे देख रहे हैं';

  @override
  String get payment_disputed_body => 'हमारी टीम इस भुगतान के बारे में आपसे संपर्क करेगी।';

  @override
  String get payment_dispute_title => 'भुगतान में क्या गड़बड़ है?';

  @override
  String get payment_dispute_label => 'बताएँ क्या हुआ';

  @override
  String get payment_dispute_hint => 'जैसे: दिखाई गई राशि से ज़्यादा माँगा';

  @override
  String get payment_dispute_send => 'समस्या बताएँ';

  @override
  String get payment_dispute_sent => 'धन्यवाद। हम इसे देखेंगे।';

  @override
  String get cancel_keep_open => 'वापस जाएँ';

  @override
  String review_rate(String name) {
    return '$name को रेटिंग दें';
  }

  @override
  String get review_step => 'आपकी समीक्षा';

  @override
  String review_title(String name) {
    return '$name कैसे रहे?';
  }

  @override
  String review_stars_label(String name) {
    return '$name के लिए रेटिंग';
  }

  @override
  String get review_tags_good => 'क्या अच्छा रहा?';

  @override
  String get review_tags_bad => 'क्या गलत हुआ?';

  @override
  String get review_tag_on_time => 'समय पर';

  @override
  String get review_tag_friendly => 'विनम्र';

  @override
  String get review_tag_fixed_fast => 'जल्दी ठीक किया';

  @override
  String get review_tag_fair_price => 'सही कीमत';

  @override
  String get review_tag_late => 'देर से आए';

  @override
  String get review_tag_rude => 'बदतमीज़';

  @override
  String get review_tag_overcharged => 'ज़्यादा पैसे लिए';

  @override
  String get review_tag_not_fixed => 'ठीक नहीं हुआ';

  @override
  String get review_comment_label => 'और कुछ? (वैकल्पिक)';

  @override
  String get review_submit => 'समीक्षा भेजें';

  @override
  String get review_thanks => 'आपकी समीक्षा के लिए धन्यवाद!';

  @override
  String get review_error => 'समीक्षा नहीं भेजी जा सकी। अपना कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get review_not_allowed => 'इस बुकिंग की समीक्षा नहीं की जा सकती।';

  @override
  String get review_already => 'आपने इस बुकिंग को रेटिंग दे दी है। धन्यवाद!';

  @override
  String get home_city_outside => 'हमारे क्षेत्र से बाहर';

  @override
  String get home_locating => 'आपकी लोकेशन ढूँढ रहे हैं…';

  @override
  String get home_no_location => 'पास की मदद देखने के लिए अपनी लोकेशन दें। इसके बिना भी मदद ले सकते हैं।';

  @override
  String get home_show_location => 'मेरी लोकेशन दिखाएँ';

  @override
  String get home_no_fix => 'हम आपकी लोकेशन नहीं ढूँढ पाए। फिर भी मदद ले सकते हैं और पिन खुद लगा सकते हैं।';

  @override
  String get home_outside_title => 'हम अभी आपके क्षेत्र में नहीं हैं';

  @override
  String get home_outside_body =>
      'हम अहमदाबाद, अंकलेश्वर और भरूच में सेवा देते हैं। SMS से अपनी लोकेशन भेजें, हमारी टीम मदद ढूँढने में सहायता करेगी।';

  @override
  String get home_sms_location => 'SMS से मेरी लोकेशन भेजें';

  @override
  String home_sms_body(String link, String code) {
    return 'मुझे सड़क पर मदद चाहिए। मेरी लोकेशन: $link (प्लस कोड $code)';
  }

  @override
  String get home_sms_failed => 'SMS ऐप नहीं खुल सका।';

  @override
  String get home_booking_active => 'आपकी बुकिंग चल रही है';

  @override
  String get home_booking_open => 'खोलने के लिए टैप करें';

  @override
  String get contacts_title => 'आपातकालीन संपर्क';

  @override
  String get contacts_body => 'SOS इन लोगों को आपकी लाइव लोकेशन भेजता है। अधिकतम 3।';

  @override
  String get contacts_empty =>
      'अभी कोई संपर्क नहीं। किसी ऐसे व्यक्ति को जोड़ें जो आपात स्थिति में मदद कर सके।';

  @override
  String get contacts_add_picker => 'संपर्कों से जोड़ें';

  @override
  String get contacts_add_manual => 'नंबर लिखें';

  @override
  String get contacts_full => 'आप अधिकतम 3 संपर्क सेव कर सकते हैं।';

  @override
  String contacts_remove(String name) {
    return '$name को हटाएँ';
  }

  @override
  String get contacts_save => 'सेव करें';

  @override
  String get contacts_saved => 'संपर्क सेव हो गए।';

  @override
  String get contacts_save_failed => 'आपके संपर्क सेव नहीं हो सके। दोबारा कोशिश करें।';

  @override
  String get contacts_error_invalid => 'यह नंबर इस्तेमाल नहीं हो सकता। मोबाइल नंबर डालें।';

  @override
  String get contacts_error_duplicate => 'यह नंबर पहले से सूची में है।';

  @override
  String get contacts_picker_failed => 'आपके संपर्क नहीं खुल सके। नंबर लिखकर जोड़ें।';

  @override
  String get contacts_manual_title => 'संपर्क जोड़ें';

  @override
  String get contacts_name_label => 'नाम';

  @override
  String get contacts_phone_label => 'मोबाइल नंबर';

  @override
  String get contacts_manual_add => 'जोड़ें';

  @override
  String get contacts_discard_title => 'बदलाव छोड़ दें?';

  @override
  String get contacts_discard => 'छोड़ें';

  @override
  String get contacts_keep_editing => 'बदलाव जारी रखें';

  @override
  String get contacts_error => 'आपके संपर्क लोड नहीं हो सके।';

  @override
  String get contacts_retry => 'दोबारा कोशिश करें';

  @override
  String get chat_open => 'चैट';

  @override
  String get chat_title => 'चैट';

  @override
  String get chat_empty_title => 'अभी कोई संदेश नहीं';

  @override
  String chat_empty_body(String name) {
    return '$name को कुछ भी बताएँ जिससे वे आपको या आपकी गाड़ी को ढूँढ सकें।';
  }

  @override
  String get chat_closed => 'यह चैट बंद हो गई है। आप इसे 30 दिन तक पढ़ सकते हैं।';

  @override
  String chat_you(String text) {
    return 'आप: $text';
  }

  @override
  String chat_from(String name, String text) {
    return '$name: $text';
  }

  @override
  String get chat_photo_title => 'फ़ोटो भेजें';

  @override
  String get chat_photo_take => 'फ़ोटो खींचें';

  @override
  String get chat_photo_gallery => 'गैलरी से चुनें';

  @override
  String get chat_photo_too_large => 'यह फ़ोटो बहुत बड़ी है। कोई दूसरी चुनें।';

  @override
  String get chat_photo_failed => 'फ़ोटो नहीं जुड़ सकी। दोबारा कोशिश करें।';

  @override
  String get chat_error => 'चैट लोड नहीं हो सकी। अपना कनेक्शन जाँचें।';

  @override
  String get chat_error_retry => 'दोबारा कोशिश करें';

  @override
  String get home_profile => 'प्रोफ़ाइल और सेटिंग्स';

  @override
  String get profile_title => 'प्रोफ़ाइल और सेटिंग्स';

  @override
  String get profile_error => 'आपकी प्रोफ़ाइल लोड नहीं हो सकी। आपकी सेटिंग्स फिर भी काम करती हैं।';

  @override
  String get profile_language => 'भाषा';

  @override
  String get profile_language_title => 'अपनी भाषा चुनें';

  @override
  String get profile_display_mode => 'डिस्प्ले मोड';

  @override
  String get profile_display_auto => 'ऑटो';

  @override
  String get profile_display_auto_hint => 'सूर्यास्त के हिसाब से दिन या रात। बैटरी कम होने पर सेवर।';

  @override
  String get profile_display_day => 'दिन';

  @override
  String get profile_display_day_hint => 'हमेशा हल्की स्क्रीन।';

  @override
  String get profile_display_night => 'रात';

  @override
  String get profile_display_night_hint => 'हमेशा गहरी स्क्रीन।';

  @override
  String get profile_display_glare => 'धूप मोड';

  @override
  String get profile_display_glare_hint => 'तेज़ धूप के लिए सफ़ेद पर काला, बड़े अक्षर।';

  @override
  String get profile_chime => 'पहुँचने की घंटी';

  @override
  String get profile_chime_hint => 'मैकेनिक के पहुँचने पर एक छोटी आवाज़।';

  @override
  String get profile_contacts => 'आपातकालीन संपर्क';

  @override
  String profile_contacts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सेव किए गए',
      zero: 'अभी कोई सेव नहीं',
    );
    return '$_temp0';
  }

  @override
  String get profile_privacy => 'गोपनीयता और डेटा';

  @override
  String get profile_licenses => 'ओपन-सोर्स लाइसेंस';
}
