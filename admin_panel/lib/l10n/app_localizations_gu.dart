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

  @override
  String get mechanic_status_pending => 'બાકી';

  @override
  String get mechanic_status_approved => 'મંજૂર';

  @override
  String get mechanic_status_blocked => 'બ્લૉક';

  @override
  String get mechanic_type_workshop => 'વર્કશૉપ';

  @override
  String get mechanic_type_independent => 'સ્વતંત્ર';

  @override
  String get approvals_type_all => 'બધા પ્રકાર';

  @override
  String get approvals_search_label => 'શોધો';

  @override
  String get approvals_search_hint => 'મિકેનિકનું નામ';

  @override
  String approvals_empty(String status) {
    return 'અહીં કંઈ નથી: $status સ્થિતિવાળા કોઈ મિકેનિક નથી.';
  }

  @override
  String get approvals_load_failed => 'મિકેનિક લોડ ન થયા.';

  @override
  String approvals_experience(int years) {
    String _temp0 = intl.Intl.pluralLogic(years, locale: localeName, other: '$years વર્ષ', one: '1 વર્ષ');
    return '$_temp0';
  }

  @override
  String approvals_registered(String date) {
    return '$dateએ નોંધાયા';
  }

  @override
  String get approvals_base_area => 'બેઝ વિસ્તાર';

  @override
  String approvals_travel_vehicle(String vehicle) {
    return 'આવવાનું વાહન ($vehicle)';
  }

  @override
  String get approvals_shop_name => 'દુકાન';

  @override
  String get approvals_shop_address => 'સરનામું';

  @override
  String get approvals_services => 'સેવાઓ';

  @override
  String get approvals_vehicle_types => 'વાહનો';

  @override
  String get approvals_photos => 'ફોટા';

  @override
  String get approvals_photo_profile => 'પ્રોફાઇલ ફોટો';

  @override
  String get approvals_photo_shop => 'દુકાનનો ફોટો';

  @override
  String approvals_photo_toolkit(int n) {
    return 'ઓજારોનો ફોટો $n';
  }

  @override
  String get approvals_kyc => 'ઓળખ અને ચુકવણી';

  @override
  String get approvals_kyc_missing => 'KYC હજી જમા નથી થયું.';

  @override
  String get approvals_upi => 'UPI';

  @override
  String get approvals_phone => 'ફોન';

  @override
  String get approvals_reference => 'રેફરન્સ';

  @override
  String get approvals_document_id => 'ID પ્રૂફ ખોલો';

  @override
  String get approvals_document_selfie => 'ID સાથે સેલ્ફી ખોલો';

  @override
  String get approvals_document_address => 'સરનામાનો પ્રૂફ ખોલો';

  @override
  String get approvals_documents_note =>
      'દસ્તાવેજો નવા ટૅબમાં એવી લિંકથી ખૂલે છે જે થોડી મિનિટમાં પૂરી થાય છે. તેને ડાઉનલોડ ન કરો.';

  @override
  String get approvals_document_missing => 'આ દસ્તાવેજ ઉપલબ્ધ નથી.';

  @override
  String get approvals_checklist => 'ચેકલિસ્ટ';

  @override
  String get approvals_check_shop_photo => 'દુકાનના ફોટામાં સાચી વર્કશૉપ છે';

  @override
  String get approvals_check_id_proof => 'ID પ્રૂફ નામ સાથે મેળ ખાય છે';

  @override
  String get approvals_check_services => 'સેવાઓ અને વાહનો યોગ્ય લાગે છે';

  @override
  String get approvals_check_selfie => 'સેલ્ફી ID સાથે મેળ ખાય છે';

  @override
  String get approvals_check_address => 'સરનામાનો પ્રૂફ તપાસ્યો';

  @override
  String get approvals_check_toolkit => 'ઓજારોના ફોટામાં સાચાં ઓજારો છે';

  @override
  String get approvals_call_notes_label => 'વેરિફિકેશન કૉલની નોંધ';

  @override
  String get approvals_call_notes_hint => 'વીડિયો કૉલ, ID મેળ ખાધું, પટેલ મોટર્સમાં 6 વર્ષની પુષ્ટિ.';

  @override
  String get approvals_call_log => 'વેરિફિકેશન કૉલ નોંધો';

  @override
  String get approvals_call_logged => 'વેરિફિકેશન કૉલ નોંધાયો.';

  @override
  String approvals_call_done(String date, String notes) {
    return 'કૉલ નોંધાયો $date: $notes';
  }

  @override
  String get approvals_approve => 'મંજૂર કરો';

  @override
  String get approvals_approved => 'મંજૂર થયું. હવે તેઓ ઑનલાઇન થઈ શકે છે.';

  @override
  String get approvals_block => 'બ્લૉક કરો';

  @override
  String get approvals_block_reason_label => 'તમે તેમને કેમ બ્લૉક કરો છો?';

  @override
  String get approvals_block_reason_hint => 'દા.ત.: ID પ્રૂફ મેળ ખાતું નથી';

  @override
  String get approvals_block_confirm => 'મિકેનિકને બ્લૉક કરો';

  @override
  String get approvals_block_cancel => 'રદ કરો';

  @override
  String get approvals_blocked => 'બ્લૉક કર્યા. તેમને બધે સાઇન આઉટ કર્યા.';

  @override
  String get approvals_blocked_note => 'આ મિકેનિક બ્લૉક છે અને કામ લઈ શકતા નથી.';

  @override
  String get approvals_audit_note => 'દરેક મંજૂરી, બ્લૉક અને કૉલ ઑડિટ લૉગમાં નોંધાય છે.';

  @override
  String get approvals_why_kyc => 'મંજૂરી પહેલાં KYC દસ્તાવેજો જોઈએ.';

  @override
  String get approvals_why_checklist => 'મંજૂર કરવા ચેકલિસ્ટની દરેક આઇટમ ટિક કરો.';

  @override
  String get approvals_why_call => 'સ્વતંત્ર મિકેનિકને મંજૂર કરવા વેરિફિકેશન કૉલ નોંધો.';

  @override
  String get approvals_error_unavailable => 'આ કામ હજી ઉપલબ્ધ નથી. પછી પ્રયાસ કરો.';

  @override
  String get approvals_error_precondition => 'સર્વરે ના પાડી: મિકેનિકની સ્થિતિ અને વેરિફિકેશન કૉલ તપાસો.';

  @override
  String get approvals_error_not_allowed => 'તમારી એડમિન ઍક્સેસ બદલાઈ છે. ફરી સાઇન ઇન કરો.';

  @override
  String get approvals_error_unknown => 'કંઈક ખોટું થયું. કંઈ બદલાયું નથી.';
}
