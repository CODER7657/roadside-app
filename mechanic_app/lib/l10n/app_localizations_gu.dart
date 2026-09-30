// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get app_title => 'Roadside Mechanic';

  @override
  String get home_placeholder_title => 'તમારી નજીકના કામ, જ્યારે તમે તૈયાર હો';

  @override
  String get home_placeholder_body =>
      'અમે બધું તૈયાર કરી રહ્યા છીએ. નોંધણી અને ઓનલાઇન થવાની સુવિધા આગલા અપડેટમાં આવશે.';

  @override
  String flow_step_label(int step, int total) {
    return '$total માંથી પગલું $step';
  }

  @override
  String get splash_tagline => 'તમારી નજીકના કામ, પૈસા સીધા તમને';

  @override
  String get splash_loading => 'તૈયારી થઈ રહી છે';

  @override
  String get language_title => 'તમારી ભાષા પસંદ કરો';

  @override
  String get language_body => 'તમે તેને પછીથી સેટિંગ્સમાં બદલી શકો છો.';

  @override
  String get language_continue => 'આગળ વધો';

  @override
  String get onboarding_slide1_title => 'તમારી નજીકના કામ';

  @override
  String get onboarding_slide1_body =>
      'ઓનલાઇન થાઓ અને અમે તમને નજીકના બગડેલાં વાહનોના કામ મોકલીશું. જે જોઈએ તે સ્લાઇડ કરીને સ્વીકારો.';

  @override
  String get onboarding_slide2_title => 'ગ્રાહક સુધી પહોંચો, તેમના કોડથી શરૂ કરો';

  @override
  String get onboarding_slide2_body =>
      'ગ્રાહક સુધી નેવિગેટ કરો. પહોંચો ત્યારે તેઓ તમને કામ શરૂ કરવાનો કોડ કહેશે.';

  @override
  String get onboarding_slide3_title => 'પૈસા સીધા તમારા UPI માં';

  @override
  String get onboarding_slide3_body => 'ગ્રાહકો સીધા તમને ચૂકવે છે. એપ ક્યારેય તમારા પૈસા રાખતી નથી.';

  @override
  String get onboarding_next => 'આગળ';

  @override
  String get onboarding_skip => 'છોડો';

  @override
  String get onboarding_start => 'શરૂ કરો';

  @override
  String get consent_title => 'તમારી ગોપનીયતા';

  @override
  String get consent_intro =>
      'અમે ફક્ત એટલું જ લઈએ છીએ જે તમને કામ મોકલવા અને ગ્રાહકોને સુરક્ષિત રાખવા માટે જરૂરી છે.';

  @override
  String get consent_point_collect => 'તમારો ફોન નંબર, નામ, ફોટા, ઓળખ માટે ID દસ્તાવેજો અને તમારી UPI વિગતો.';

  @override
  String get consent_point_location =>
      'તમારું લોકેશન, ફક્ત જ્યારે તમે ઓનલાઇન હો કે કામ પર હો. ઓફલાઇન હો ત્યારે ક્યારેય નહીં.';

  @override
  String get consent_point_delete => 'તમે ગમે ત્યારે તમારો ડેટા જોઈ, સુધારી કે ડિલીટ કરી શકો છો.';

  @override
  String get consent_age => 'મારી ઉંમર 18 વર્ષ કે તેથી વધુ છે';

  @override
  String get consent_notice => 'હું ગોપનીયતા સૂચના સાથે સંમત છું';

  @override
  String get consent_agree => 'સંમત છું, આગળ વધો';

  @override
  String get consent_read_notice => 'સંપૂર્ણ સૂચના વાંચો';

  @override
  String get privacy_title => 'ગોપનીયતા સૂચના';

  @override
  String get privacy_collect_title => 'અમે શું લઈએ છીએ';

  @override
  String get privacy_collect_body =>
      'તમારો ફોન નંબર, નામ અને ભાષા; તમારી પ્રોફાઇલ અને દુકાન કે ઓજારોના ફોટા; તમારી ઓળખ ચકાસવા ID પ્રૂફ (અને જો તમે દુકાન વગર કામ કરતા હો તો તેની સાથે સેલ્ફી અને સરનામાનો પુરાવો); તમારી UPI ID અને નામ; અને તમે ઓનલાઇન કે કામ પર હો ત્યારે તમારું લોકેશન.';

  @override
  String get privacy_use_title => 'અમે તેનો ઉપયોગ શા માટે કરીએ છીએ';

  @override
  String get privacy_use_body =>
      'તમારી ઓળખ ચકાસવા, તમને નજીકના કામ મોકલવા, ગ્રાહકોને બતાવવા કે કોણ આવી રહ્યું છે અને રસ્તામાં તમે ક્યાં છો, અને તેમને તમને ચૂકવણી કરવા દેવા માટે. અમે જાહેરાતો બતાવતા નથી અને તમારો ડેટા વેચતા નથી.';

  @override
  String get privacy_keep_title => 'અમે તેને કેટલો સમય રાખીએ છીએ';

  @override
  String get privacy_keep_body =>
      'ઓનલાઇન લોકેશન તમે ફરો તેમ બદલાતું રહે છે અને ઓફલાઇન થાઓ ત્યારે દૂર થાય છે. કામ દરમિયાનનું લાઇવ લોકેશન: કામ પૂરું થયાના 24 કલાક સુધી. ચેટ: 90 દિવસ. ID દસ્તાવેજો: તમે છોડો તેના 180 દિવસ સુધી. કામના રેકોર્ડ: ટેક્સ માટે 3 વર્ષ.';

  @override
  String get privacy_rights_title => 'તમારા અધિકારો';

  @override
  String get privacy_rights_body =>
      'એપમાં તમારી વિગતો જુઓ અને સુધારો, તમારી સંમતિ પાછી ખેંચો, અથવા સેટિંગ્સમાંથી તમારું ખાતું ડિલીટ કરો.';

  @override
  String get privacy_contact_title => 'પ્રશ્નો કે ફરિયાદો';

  @override
  String get privacy_contact_body => 'મદદ અને FAQ માંથી અમારા ફરિયાદ અધિકારીનો સંપર્ક કરો.';
}
