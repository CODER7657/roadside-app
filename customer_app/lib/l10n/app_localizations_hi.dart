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
  String get home_placeholder_title => 'सड़क पर मदद, मिनटों में';

  @override
  String get home_placeholder_body =>
      'हम सब कुछ तैयार कर रहे हैं। मैकेनिक बुक करने की सुविधा अगले अपडेट में आएगी।';

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
}
