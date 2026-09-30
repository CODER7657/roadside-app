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
  String get home_placeholder_title => 'आपके पास के काम, जब आप तैयार हों';

  @override
  String get home_placeholder_body =>
      'हम सब कुछ तैयार कर रहे हैं। रजिस्ट्रेशन और ऑनलाइन होने की सुविधा अगले अपडेट में आएगी।';

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
}
