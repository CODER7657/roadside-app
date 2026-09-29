// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get app_title => 'Roadside';

  @override
  String get home_placeholder_title => 'રસ્તા પર મદદ, મિનિટોમાં';

  @override
  String get home_placeholder_body =>
      'અમે બધું તૈયાર કરી રહ્યા છીએ. મિકેનિક બુક કરવાની સુવિધા આગલા અપડેટમાં આવશે.';

  @override
  String flow_step_label(int step, int total) {
    return '$total માંથી પગલું $step';
  }

  @override
  String get splash_tagline => 'રસ્તા પર મદદ, મિનિટોમાં';

  @override
  String get splash_loading => 'તૈયારી થઈ રહી છે';

  @override
  String get language_title => 'તમારી ભાષા પસંદ કરો';

  @override
  String get language_body => 'તમે તેને પછીથી સેટિંગ્સમાં બદલી શકો છો.';

  @override
  String get language_continue => 'આગળ વધો';

  @override
  String get onboarding_slide1_title => 'મિનિટોમાં મદદ';

  @override
  String get onboarding_slide1_body => 'શું તકલીફ છે તે કહો. સૌથી નજીકનો ચકાસાયેલ મિકેનિક તમારી પાસે આવે છે.';

  @override
  String get onboarding_slide2_title => 'લાઇવ ટ્રેક કરો';

  @override
  String get onboarding_slide2_body => 'મિકેનિકને નકશા પર જુઓ, પહોંચવાના લાઇવ સમય સાથે.';

  @override
  String get onboarding_slide3_title => 'સુરક્ષિત અને ચકાસાયેલ';

  @override
  String get onboarding_slide3_body =>
      'દરેક મિકેનિકની ઓળખ તપાસાય છે. એક ટેપમાં પરિવાર સાથે તમારી મુસાફરી શેર કરો.';

  @override
  String get onboarding_next => 'આગળ';

  @override
  String get onboarding_skip => 'છોડો';

  @override
  String get onboarding_start => 'શરૂ કરો';

  @override
  String get consent_title => 'તમારી ગોપનીયતા';

  @override
  String get consent_intro => 'તમને મદદ મોકલવા માટે જરૂરી હોય એટલી જ માહિતી અમે લઈએ છીએ.';

  @override
  String get consent_point_collect => 'તમારો ફોન નંબર, નામ, વાહનો અને તમે ઉમેરેલા ફોટા.';

  @override
  String get consent_point_location => 'તમારું લોકેશન, ફક્ત બુકિંગ વખતે અને મદદ રસ્તામાં હોય ત્યાં સુધી.';

  @override
  String get consent_point_delete => 'તમે ગમે ત્યારે તમારો ડેટા જોઈ, સુધારી કે કાઢી શકો છો.';

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
      'તમારો ફોન નંબર, નામ અને ભાષા, તમે ઉમેરેલા વાહનો, બુકિંગમાં જોડેલા ફોટા, અને બુકિંગ વખતે અથવા મિકેનિક રસ્તામાં હોય ત્યાં સુધી તમારું લોકેશન.';

  @override
  String get privacy_use_title => 'અમે તેનો ઉપયોગ શા માટે કરીએ છીએ';

  @override
  String get privacy_use_body =>
      'ફક્ત તમારા માટે મિકેનિક શોધવા, તેને તમારું સ્થાન બતાવવા અને તમને બંનેને સુરક્ષિત રાખવા. અમે જાહેરાતો બતાવતા નથી કે તમારો ડેટા વેચતા નથી.';

  @override
  String get privacy_keep_title => 'અમે તેને કેટલો સમય રાખીએ છીએ';

  @override
  String get privacy_keep_body =>
      'લાઇવ લોકેશન: કામના 24 કલાક પછી સુધી. ચેટ: 90 દિવસ. બુકિંગ રેકોર્ડ: ટેક્સ માટે 3 વર્ષ, ખાતું કાઢી નાખો તો અનામી.';

  @override
  String get privacy_rights_title => 'તમારા અધિકારો';

  @override
  String get privacy_rights_body =>
      'એપમાં તમારી વિગતો જુઓ અને સુધારો, તમારી સંમતિ પાછી ખેંચો, અથવા સેટિંગ્સમાંથી તમારું ખાતું કાઢી નાખો.';

  @override
  String get privacy_contact_title => 'પ્રશ્નો કે ફરિયાદો';

  @override
  String get privacy_contact_body => 'મદદ અને FAQ માંથી અમારા ફરિયાદ અધિકારીનો સંપર્ક કરો.';
}
