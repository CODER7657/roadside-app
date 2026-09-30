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

  @override
  String get vehicle_type_car => 'કાર';

  @override
  String get vehicle_type_bike => 'બાઇક';

  @override
  String get vehicle_type_scooter => 'સ્કૂટર';

  @override
  String get vehicle_type_ev => 'EV';

  @override
  String get problem_type_flat_tyre => 'ટાયર પંક્ચર';

  @override
  String get problem_type_battery => 'બેટરી';

  @override
  String get problem_type_wont_start => 'ચાલુ થતું નથી';

  @override
  String get problem_type_overheating => 'વધુ ગરમ';

  @override
  String get problem_type_accident => 'અકસ્માત';

  @override
  String get problem_type_fuel => 'ઈંધણ ખલાસ';

  @override
  String get problem_type_other => 'બીજું કંઈ';

  @override
  String get prices_scope_default => 'ડિફૉલ્ટ કિંમતો, બધાં શહેરો';

  @override
  String get prices_scope_default_help => 'ગ્રાહકોને આ જ ભાવ દેખાય છે, સિવાય કે તેમના શહેરના પોતાના ભાવ હોય.';

  @override
  String prices_scope_city(String city) {
    return '$cityની કિંમતો';
  }

  @override
  String get prices_scope_city_help => 'ફક્ત આ શહેર માટે. ડિફૉલ્ટ (ભૂખરો) ભાવ વાપરવા ખાનું ખાલી રાખો.';

  @override
  String get prices_column_problem => 'સમસ્યા';

  @override
  String prices_min_label(String vehicle, String problem) {
    return '$vehicle, $problem: ઓછામાં ઓછું';
  }

  @override
  String prices_max_label(String vehicle, String problem) {
    return '$vehicle, $problem: વધુમાં વધુ';
  }

  @override
  String prices_unsaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ફેરફાર સાચવવાના બાકી',
      one: '1 ફેરફાર સાચવવાનો બાકી',
      zero: 'સાચવવાના કોઈ ફેરફાર નથી',
    );
    return '$_temp0';
  }

  @override
  String get prices_discard => 'રદ કરો';

  @override
  String get prices_save => 'ફેરફાર સાચવો';

  @override
  String get prices_saved_toast => 'કિંમતો સાચવી. નવી બુકિંગ હવે આનાથી થશે.';

  @override
  String get prices_save_failed => 'સાચવી શકાયું નહીં. કંઈ બદલાયું નથી. ફરી પ્રયાસ કરો.';

  @override
  String get prices_missing_default => 'પહેલાં બધાં શહેરોની કિંમત નક્કી કરો, પછી શહેરની પોતાની.';

  @override
  String get prices_load_failed => 'કિંમતો લોડ ન થઈ.';

  @override
  String get prices_error_required => 'બંને રકમ લખો';

  @override
  String get prices_error_number => 'ફક્ત પૂરા રૂપિયા';

  @override
  String get prices_error_range => '₹1 થી ₹1,00,000 વચ્ચે';

  @override
  String get prices_error_order => 'ઓછામાં ઓછું, વધુમાં વધુથી ઓછું હોવું જોઈએ';
}
