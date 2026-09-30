// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get app_title => 'Roadside કન્સોલ';

  @override
  String get signin_title => 'Roadside કન્સોલ';

  @override
  String get signin_body => 'ફક્ત Roadside એડમિન માટે. તમારા મંજૂર Google એકાઉન્ટથી સાઇન ઇન કરો.';

  @override
  String get signin_google_button => 'Google વડે સાઇન ઇન કરો';

  @override
  String get signin_checking_title => 'તમારી ઍક્સેસ તપાસી રહ્યા છીએ';

  @override
  String get signin_error_message => 'સાઇન ઇન ન થયું. ફરી પ્રયાસ કરો.';

  @override
  String get signin_not_authorised_title => 'પરવાનગી નથી';

  @override
  String signin_not_authorised_body(String account) {
    return '$account એડમિન એકાઉન્ટ નથી, તેથી અમે તેને સાઇન આઉટ કર્યું. ઍક્સેસ જોઈએ તો Roadside ટીમને પૂછો.';
  }

  @override
  String get signin_not_authorised_retry => 'બીજું એકાઉન્ટ વાપરો';

  @override
  String get signin_unknown_account => 'આ એકાઉન્ટ';

  @override
  String get signin_unconfigured_title => 'કન્સોલ જોડાયેલું નથી';

  @override
  String get signin_unconfigured_body =>
      'આ બિલ્ડ હજી કોઈ Firebase પ્રોજેક્ટ સાથે જોડાયેલું નથી. dev અથવા prodની env ફાઇલ સાથે બિલ્ડ કરો.';

  @override
  String get console_nav_dashboard => 'ડેશબોર્ડ';

  @override
  String get console_nav_approvals => 'મંજૂરીઓ';

  @override
  String get console_nav_live => 'લાઇવ બુકિંગ';

  @override
  String get console_nav_prices => 'કિંમતો';

  @override
  String get console_nav_complaints => 'ફરિયાદો અને રિવ્યૂ';

  @override
  String get console_nav_settings => 'સેટિંગ્સ';

  @override
  String get console_filter_label => 'શહેર';

  @override
  String get console_city_all => 'બધાં શહેરો';

  @override
  String get console_city_ahmedabad => 'અમદાવાદ';

  @override
  String get console_city_ankleshwar => 'અંકલેશ્વર';

  @override
  String get console_city_bharuch => 'ભરૂચ';

  @override
  String get console_sign_out => 'સાઇન આઉટ';

  @override
  String get console_section_coming_title => 'ટૂંક સમયમાં';

  @override
  String console_section_coming_body(String issue) {
    return 'આ સ્ક્રીન ઇશ્યૂ #$issue સાથે આવશે.';
  }
}
