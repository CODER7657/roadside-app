// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get app_title => 'Roadside Mechanic';

  @override
  String flow_step_label(int step, int total) {
    return '$total में से चरण $step';
  }

  @override
  String get splash_tagline => 'आपके पास के काम, पैसा सीधे आपको';

  @override
  String get splash_loading => 'तैयारी हो रही है';

  @override
  String get language_title => 'अपनी भाषा चुनें';

  @override
  String get language_body => 'आप इसे बाद में सेटिंग्स में बदल सकते हैं।';

  @override
  String get language_continue => 'आगे बढ़ें';

  @override
  String get onboarding_slide1_title => 'आपके पास के काम';

  @override
  String get onboarding_slide1_body =>
      'ऑनलाइन हों और हम आपको पास की खराब गाड़ियों के काम भेजेंगे। जो चाहें उसे स्लाइड करके स्वीकार करें।';

  @override
  String get onboarding_slide2_title => 'ग्राहक तक पहुँचें, उनके कोड से शुरू करें';

  @override
  String get onboarding_slide2_body =>
      'ग्राहक तक नेविगेट करें। पहुँचने पर वे आपको काम शुरू करने का कोड बताएँगे।';

  @override
  String get onboarding_slide3_title => 'पैसा सीधे आपके UPI में';

  @override
  String get onboarding_slide3_body => 'ग्राहक सीधे आपको भुगतान करते हैं। ऐप आपका पैसा कभी नहीं रखता।';

  @override
  String get onboarding_next => 'आगे';

  @override
  String get onboarding_skip => 'छोड़ें';

  @override
  String get onboarding_start => 'शुरू करें';

  @override
  String get consent_title => 'आपकी गोपनीयता';

  @override
  String get consent_intro =>
      'हम सिर्फ़ वही लेते हैं जो आपको काम भेजने और ग्राहकों को सुरक्षित रखने के लिए ज़रूरी है।';

  @override
  String get consent_point_collect =>
      'आपका फ़ोन नंबर, नाम, फ़ोटो, पहचान के लिए ID दस्तावेज़ और आपकी UPI जानकारी।';

  @override
  String get consent_point_location =>
      'आपकी लोकेशन, सिर्फ़ जब आप ऑनलाइन हों या काम पर हों। ऑफ़लाइन होने पर कभी नहीं।';

  @override
  String get consent_point_delete => 'आप कभी भी अपना डेटा देख, सुधार या मिटा सकते हैं।';

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
      'आपका फ़ोन नंबर, नाम और भाषा; आपकी प्रोफ़ाइल और दुकान या औज़ारों की फ़ोटो; आपकी पहचान के लिए ID प्रूफ़ (और अगर आप बिना दुकान के काम करते हैं तो उसके साथ सेल्फ़ी और पते का प्रमाण); आपकी UPI ID और नाम; और ऑनलाइन या काम पर होने के दौरान आपकी लोकेशन।';

  @override
  String get privacy_use_title => 'हम इसका उपयोग क्यों करते हैं';

  @override
  String get privacy_use_body =>
      'आपकी पहचान जाँचने, आपको पास के काम भेजने, ग्राहकों को दिखाने कि कौन आ रहा है और रास्ते में आप कहाँ हैं, और उन्हें आपको भुगतान करने देने के लिए। हम विज्ञापन नहीं दिखाते और आपका डेटा नहीं बेचते।';

  @override
  String get privacy_keep_title => 'हम इसे कितने समय तक रखते हैं';

  @override
  String get privacy_keep_body =>
      'ऑनलाइन लोकेशन आपके चलने के साथ बदलती रहती है और ऑफ़लाइन होने पर हटा दी जाती है। काम के दौरान की लाइव लोकेशन: काम ख़त्म होने के 24 घंटे बाद तक। चैट: 90 दिन। ID दस्तावेज़: आपके छोड़ने के 180 दिन बाद तक। काम के रिकॉर्ड: टैक्स के लिए 3 साल।';

  @override
  String get privacy_rights_title => 'आपके अधिकार';

  @override
  String get privacy_rights_body =>
      'ऐप में अपनी जानकारी देखें और सुधारें, अपनी सहमति वापस लें, या सेटिंग्स से अपना खाता मिटाएँ।';

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
      'ताकि हम आपको पास के काम भेज सकें और ग्राहकों को दिखा सकें कि आप रास्ते में हैं। सिर्फ़ जब आप ऑनलाइन हों या काम पर हों; काम के दौरान एक सूचना दिखती है कि यह चालू है।';

  @override
  String get permission_camera_title => 'कैमरा की अनुमति दें';

  @override
  String get permission_camera_body =>
      'अपनी प्रोफ़ाइल, दुकान या औज़ारों की फ़ोटो, अपने ID दस्तावेज़, और हर काम से पहले और बाद की फ़ोटो जोड़ने के लिए।';

  @override
  String get permission_notifications_title => 'सूचनाओं की अनुमति दें';

  @override
  String get permission_notifications_body =>
      'ताकि आपको नए काम के ऑफ़र तुरंत मिलें, और ऐप बंद होने पर भी अपने कामों की जानकारी मिले।';

  @override
  String get permission_full_screen_title => 'लॉक स्क्रीन पर काम के ऑफ़र दिखाएँ';

  @override
  String get permission_full_screen_body =>
      'नया काम आने वाली कॉल की तरह पूरी स्क्रीन पर दिखता है, ताकि कोई छूटे नहीं। अगली स्क्रीन पर इस ऐप के लिए फ़ुल-स्क्रीन सूचनाएँ चालू करें।';

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
  String get help_search_hint => 'जैसे ऑफ़र, शुरू करने का कोड, भुगतान';

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
  String get help_faq_jobs_q => 'मुझे काम कैसे मिलेंगे?';

  @override
  String get help_faq_jobs_a =>
      'मंज़ूरी मिलने के बाद होम स्क्रीन पर ऑनलाइन हों। पास की खराब गाड़ियाँ आपको ऑफ़र के रूप में आएँगी; 30 सेकंड में स्लाइड करके स्वीकार करें।';

  @override
  String get help_faq_no_offers_q => 'मुझे ऑफ़र क्यों नहीं मिल रहे?';

  @override
  String get help_faq_no_offers_a =>
      'देखें कि आप ऑनलाइन हैं, मंज़ूर हैं, अपने शहर में हैं, और आपकी गाड़ियों के प्रकार और सेवाएँ भरी हैं। लोकेशन चालू रखकर ऐप खुला रखें; ऑफ़र सिर्फ़ पास के मैकेनिकों को जाते हैं।';

  @override
  String get help_faq_verify_q => 'जाँच कैसे होती है?';

  @override
  String get help_faq_verify_a =>
      'काम मिलने से पहले हम आपकी ID और फ़ोटो जाँचते हैं। अगर आप बिना वर्कशॉप के काम करते हैं, तो हम एक छोटी जाँच के लिए कॉल भी करते हैं।';

  @override
  String get help_faq_code_q => 'शुरू करने का कोड क्या है?';

  @override
  String get help_faq_code_a =>
      'पहुँचने पर ग्राहक आपको 4 अंकों का कोड बताएँगे। काम शुरू करने के लिए इसे डालें। 5 बार गलत होने पर यह 10 मिनट के लिए बंद हो जाता है।';

  @override
  String get help_faq_pay_q => 'मुझे पैसा कैसे मिलेगा?';

  @override
  String get help_faq_pay_a =>
      'ग्राहक आपको सीधे UPI से भुगतान करते हैं। अपना UPI ऐप देखें, फिर पुष्टि करें पर टैप करें। अगर पैसा नहीं आया, तो नहीं मिला पर टैप करें और हम जाँच करेंगे।';

  @override
  String get help_faq_cancel_q => 'क्या मैं काम रद्द कर सकता हूँ?';

  @override
  String get help_faq_cancel_a =>
      'हाँ, लेकिन इससे आपकी विश्वसनीयता पर असर पड़ता है। पहुँचने से पहले काम दूसरे मैकेनिक को जाता है; पहुँचने के बाद कारण बताएँ।';

  @override
  String get register_type_title => 'मैकेनिक के रूप में जुड़ें';

  @override
  String get register_about_title => 'आपके बारे में';

  @override
  String get register_work_title => 'आपका काम';

  @override
  String get register_id_title => 'पहचान और भुगतान';

  @override
  String get register_next => 'आगे';

  @override
  String get register_submit => 'मंज़ूरी के लिए भेजें';

  @override
  String get register_error_upload =>
      'एक फ़ोटो अपलोड नहीं हुई। अपना कनेक्शन जाँचें और फिर से भेजें; भेजी जा चुकी फ़ोटो दोबारा अपलोड नहीं होंगी।';

  @override
  String get register_error_save => 'हम आपकी जानकारी सेव नहीं कर पाए। अपना कनेक्शन जाँचें और फिर से भेजें।';

  @override
  String get register_type_question => 'क्या आपकी वर्कशॉप है?';

  @override
  String get register_type_workshop => 'हाँ, मेरी वर्कशॉप है';

  @override
  String get register_type_independent => 'नहीं, मैं अकेले काम करता हूँ';

  @override
  String get register_city_label => 'आपका शहर';

  @override
  String get register_city_help => 'आपको इसी शहर में काम मिलेंगे। बाद में इसे सिर्फ़ हमारी टीम बदल सकती है।';

  @override
  String get city_ahmedabad => 'अहमदाबाद';

  @override
  String get city_ankleshwar => 'अंकलेश्वर';

  @override
  String get city_bharuch => 'भरूच';

  @override
  String get register_photo_source_title => 'फ़ोटो जोड़ें';

  @override
  String get register_photo_camera => 'फ़ोटो खींचें';

  @override
  String get register_photo_gallery => 'गैलरी से चुनें';

  @override
  String get register_photo_too_large => 'यह फ़ोटो बहुत बड़ी है। कोई दूसरी आज़माएँ।';

  @override
  String get register_photo_add => 'फ़ोटो जोड़ें';

  @override
  String get register_photo_remove => 'फ़ोटो हटाएँ';

  @override
  String get register_name_label => 'आपका नाम';

  @override
  String get register_photo_profile => 'आपकी फ़ोटो (ग्राहक देखते हैं)';

  @override
  String get register_shop_heading => 'आपकी दुकान';

  @override
  String get register_shop_name_label => 'दुकान का नाम';

  @override
  String get register_shop_address_label => 'दुकान का पता';

  @override
  String get register_photo_shop => 'दुकान की फ़ोटो';

  @override
  String get register_independent_heading => 'आप कैसे काम करते हैं';

  @override
  String get register_experience_label => 'अनुभव के साल';

  @override
  String get register_base_area_label => 'आप आमतौर पर कहाँ से निकलते हैं';

  @override
  String get register_base_area_hint => 'जैसे GIDC अंकलेश्वर';

  @override
  String get register_travel_heading => 'आप किस पर आते-जाते हैं';

  @override
  String get register_travel_reg_label => 'उसकी नंबर प्लेट';

  @override
  String get register_travel_reg_hint => 'जैसे GJ 16 CK 4471';

  @override
  String get register_toolkit_heading => 'आपके औज़ार';

  @override
  String get register_toolkit_help => 'आप जो औज़ार साथ रखते हैं उनकी कम से कम 2 फ़ोटो जोड़ें।';

  @override
  String register_photo_toolkit(int number) {
    return 'औज़ार $number';
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
  String get register_vehicles_label => 'आप किन गाड़ियों पर काम करते हैं';

  @override
  String get register_services_label => 'आप क्या ठीक कर सकते हैं';

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
  String get register_id_private => 'इन्हें सिर्फ़ हमारी जाँच टीम देखती है। ग्राहक कभी नहीं देखते।';

  @override
  String get register_photo_id_proof => 'पहचान पत्र';

  @override
  String get register_photo_selfie => 'पहचान पत्र पकड़े हुए सेल्फ़ी';

  @override
  String get register_photo_address_proof => 'पते का प्रमाण';

  @override
  String get register_upi_heading => 'ग्राहक आपको कहाँ भुगतान करें';

  @override
  String get register_upi_id_label => 'UPI ID';

  @override
  String get register_upi_id_hint => 'जैसे name@bank';

  @override
  String get register_upi_name_label => 'UPI खाते पर नाम';

  @override
  String get register_reference_heading => 'कोई जो आपका काम जानता हो (वैकल्पिक)';

  @override
  String get register_reference_help => 'जैसे कोई वर्कशॉप जहाँ आपने सीखा।';

  @override
  String get register_reference_name_label => 'उनका नाम';

  @override
  String get register_reference_phone_label => 'उनका फ़ोन';

  @override
  String get register_reference_phone_hint => '+91…';

  @override
  String get error_field_required => 'कृपया इसे भरें';

  @override
  String get error_field_too_long => 'यह बहुत लंबा है';

  @override
  String get error_field_invalid => 'कृपया इसे जाँचें';

  @override
  String get error_reg_no_invalid => 'नंबर जाँचें, जैसे GJ 01 AB 1234 या 22 BH 1234 AA';

  @override
  String get error_phone_invalid => 'नंबर जाँचें, जैसे +91 98765 43210';

  @override
  String get error_upi_invalid => 'UPI ID जाँचें, जैसे name@bank';

  @override
  String get error_experience_invalid => 'साल अंकों में लिखें, 0 से 60';

  @override
  String get error_toolkit_photos_too_few => 'अपने औज़ारों की कम से कम 2 फ़ोटो जोड़ें';

  @override
  String get pending_title => 'हम आपकी जानकारी जाँच रहे हैं';

  @override
  String get pending_body_workshop => 'आमतौर पर 24 घंटे में। हम आपको बताएँगे।';

  @override
  String get pending_body_independent => 'एक छोटी जाँच के लिए हम आपको कॉल करेंगे, आमतौर पर 24 घंटे में।';

  @override
  String get pending_blocked_title => 'आपका खाता रोका गया है';

  @override
  String get pending_blocked_body => 'ज़्यादा जानने के लिए कृपया सहायता को कॉल करें।';

  @override
  String get pending_item_shop => 'दुकान की जानकारी';

  @override
  String get pending_item_details => 'आपकी जानकारी और औज़ार';

  @override
  String get pending_item_id => 'पहचान पत्र';

  @override
  String get pending_item_id_selfie => 'पहचान, सेल्फ़ी और पते का प्रमाण';

  @override
  String get pending_item_call => 'जाँच कॉल';

  @override
  String get pending_received => 'मिल गया';

  @override
  String get pending_checking => 'जाँच हो रही है…';

  @override
  String get pending_call_waiting => 'हम कॉल करेंगे';

  @override
  String get dashboard_title => 'आज';

  @override
  String get dashboard_online => 'आप ऑनलाइन हैं';

  @override
  String get dashboard_online_body => 'हम आपको पास के काम भेजेंगे।';

  @override
  String get dashboard_finding_location => 'आपकी लोकेशन ढूँढ रहे हैं…';

  @override
  String get dashboard_offline => 'आप ऑफ़लाइन हैं';

  @override
  String get dashboard_offline_body =>
      'काम पाने के लिए ऑनलाइन हों। हम आपकी लोकेशन सिर्फ़ ऑनलाइन होने पर इस्तेमाल करते हैं।';

  @override
  String get dashboard_gps_off => 'आपके फ़ोन की लोकेशन बंद है। ऑनलाइन होने के लिए इसे चालू करें।';

  @override
  String get dashboard_turn_on_location => 'लोकेशन चालू करें';

  @override
  String get dashboard_lost_connection =>
      'आप ऑफ़लाइन हो गए: 2 मिनट तक हम आपकी लोकेशन अपडेट नहीं कर पाए। अपना कनेक्शन जाँचें और फिर से ऑनलाइन हों।';

  @override
  String get dashboard_jobs_today => 'आज के काम';

  @override
  String get dashboard_earned_today => 'आज की कमाई';

  @override
  String get dashboard_recent_jobs => 'हाल के काम';

  @override
  String get dashboard_no_jobs_yet => 'आज अभी तक कोई काम नहीं। ऑनलाइन रहें, काम आपके पास आएँगे।';
}
