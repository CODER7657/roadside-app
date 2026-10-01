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

  @override
  String get home_help => 'મદદ અને FAQ';

  @override
  String get permission_location_title => 'લોકેશનની પરવાનગી આપો';

  @override
  String get permission_location_body =>
      'જેથી મિકેનિક તમને શોધી શકે. અમે તમારું લોકેશન ફક્ત બુકિંગ વખતે અને મદદ રસ્તામાં હોય ત્યાં સુધી વાપરીએ છીએ.';

  @override
  String get permission_camera_title => 'કૅમેરાની પરવાનગી આપો';

  @override
  String get permission_camera_body =>
      'સમસ્યાના ફોટા ઉમેરવા માટે. ફક્ત તમે પસંદ કરેલા ફોટા જ મિકેનિક સાથે શેર થાય છે.';

  @override
  String get permission_notifications_title => 'સૂચનાઓની પરવાનગી આપો';

  @override
  String get permission_notifications_body =>
      'જેથી અમે તમને કહી શકીએ કે મિકેનિકે ક્યારે સ્વીકાર્યું, ક્યારે રસ્તામાં છે અને ક્યારે પહોંચ્યો.';

  @override
  String get permission_blocked_body =>
      'તે તમારા ફોનના સેટિંગ્સમાં બંધ છે. સેટિંગ્સ ખોલો, પરવાનગીઓ પર ટેપ કરો અને તેને ચાલુ કરો.';

  @override
  String get permission_allow => 'પરવાનગી આપો';

  @override
  String get permission_open_settings => 'સેટિંગ્સ ખોલો';

  @override
  String get permission_not_now => 'હમણાં નહીં';

  @override
  String get help_title => 'મદદ';

  @override
  String get help_search_label => 'પ્રશ્નો શોધો';

  @override
  String get help_search_hint => 'જેમ કે કિંમત, શરૂ કરવાનો કોડ';

  @override
  String get help_no_results_title => 'કોઈ મેળ ખાતો પ્રશ્ન નથી';

  @override
  String get help_no_results_body => 'બીજા શબ્દો અજમાવો, અથવા અમને કૉલ કરો.';

  @override
  String get help_call_support => 'સહાયને કૉલ કરો';

  @override
  String get help_whatsapp => 'WhatsApp';

  @override
  String get help_grievance_title => 'ફરિયાદ અધિકારી';

  @override
  String get help_grievance_body =>
      'તમારા ડેટા કે ગોપનીયતા વિશેની ફરિયાદો માટે અમારા ફરિયાદ અધિકારીને લખો. અમે 7 દિવસમાં જવાબ આપીએ છીએ.';

  @override
  String get help_faq_price_q => 'તેનો ખર્ચ કેટલો થશે?';

  @override
  String get help_faq_price_a =>
      'બુક કરતા પહેલાં તમને કિંમતની શ્રેણી દેખાય છે. કામ પછી મિકેનિક એપમાં અંતિમ રકમ નાખે છે, અને તમે UPI થી સીધા તેને ચૂકવો છો.';

  @override
  String get help_faq_verified_q => 'શું મિકેનિક ચકાસાયેલા છે?';

  @override
  String get help_faq_verified_a =>
      'હા. કામ મળે તે પહેલાં અમે દરેક મિકેનિકની ઓળખ તપાસીએ છીએ. વર્કશોપ વગરના મિકેનિકનો ચકાસણી કૉલ પણ થાય છે.';

  @override
  String get help_faq_code_q => 'શરૂ કરવાનો કોડ શું છે?';

  @override
  String get help_faq_code_a =>
      'તમારી એપમાં 4 અંકનો કોડ. મિકેનિક તમારી સાથે ઊભો હોય ત્યારે જ તે જણાવો; તે દાખલ કરે ત્યારે કામ શરૂ થાય છે.';

  @override
  String get help_faq_pay_q => 'હું ચુકવણી કેવી રીતે કરું?';

  @override
  String get help_faq_pay_a =>
      'UPI થી, સીધા મિકેનિકને: અમારી એપમાંથી તમારી UPI એપ ખોલો અથવા QR સ્કેન કરો, પછી \"મેં ચુકવણી કરી દીધી\" પર ટેપ કરો. અમે ક્યારેય કાર્ડ કે બેંકની વિગતો માગતા નથી.';

  @override
  String get help_faq_cancel_q => 'શું હું રદ કરી શકું?';

  @override
  String get help_faq_cancel_a =>
      'હા, કામ શરૂ થાય તે પહેલાં ગમે ત્યારે. એક ટેપમાં કારણ જણાવો જેથી અમે સુધારી શકીએ.';

  @override
  String get help_faq_area_q => 'તે ક્યાં કામ કરે છે?';

  @override
  String get help_faq_area_a =>
      'હાલ અમદાવાદ, અંકલેશ્વર અને ભરૂચમાં, નજીકના હાઇવે સહિત. વધુ શહેરો જલદી આવી રહ્યા છે.';

  @override
  String get home_my_vehicles => 'મારાં વાહનો';

  @override
  String get vehicles_title => 'મારાં વાહનો';

  @override
  String get vehicles_add => 'વાહન ઉમેરો';

  @override
  String get vehicles_empty_title => 'હજી કોઈ વાહન નથી';

  @override
  String get vehicles_empty_body => 'તમારું વાહન એક વાર ઉમેરો, પછી મદદ બુક કરવી એક ટેપમાં.';

  @override
  String get vehicles_default_label => 'ડિફૉલ્ટ';

  @override
  String get vehicles_delete => 'કાઢી નાખો';

  @override
  String get vehicles_removed => 'વાહન કાઢી નાખ્યું';

  @override
  String get vehicles_undo => 'પાછું લાવો';

  @override
  String get vehicle_add_step => 'નવું વાહન';

  @override
  String get vehicle_add_title => 'તમારું વાહન';

  @override
  String get vehicle_type_label => 'પ્રકાર';

  @override
  String get vehicle_type_car => 'કાર';

  @override
  String get vehicle_type_bike => 'બાઇક';

  @override
  String get vehicle_type_scooter => 'સ્કૂટર';

  @override
  String get vehicle_type_ev => 'EV';

  @override
  String get vehicle_brand_label => 'બ્રાન્ડ';

  @override
  String get vehicle_brand_hint => 'જેમ કે મારુતિ સુઝુકી';

  @override
  String get vehicle_model_label => 'મૉડલ';

  @override
  String get vehicle_model_hint => 'જેમ કે સ્વિફ્ટ';

  @override
  String get vehicle_reg_label => 'રજિસ્ટ્રેશન નંબર';

  @override
  String get vehicle_reg_hint => 'GJ 01 AB 1234';

  @override
  String get vehicle_fuel_label => 'ઇંધણ';

  @override
  String get fuel_petrol => 'પેટ્રોલ';

  @override
  String get fuel_diesel => 'ડીઝલ';

  @override
  String get fuel_cng => 'CNG';

  @override
  String get fuel_electric => 'ઇલેક્ટ્રિક';

  @override
  String get vehicle_make_default => 'આને મારું ડિફૉલ્ટ વાહન બનાવો';

  @override
  String get vehicle_save => 'વાહન સાચવો';

  @override
  String get error_field_required => 'કૃપા કરી આ ભરો';

  @override
  String get error_field_too_long => 'આ બહુ લાંબું છે';

  @override
  String get error_field_invalid => 'કૃપા કરી આ તપાસો';

  @override
  String get error_reg_no_invalid => 'નંબર તપાસો, જેમ કે GJ 01 AB 1234 અથવા 22 BH 1234 AA';

  @override
  String get home_get_help => 'મદદ મેળવો';

  @override
  String booking_step(int step, int total) {
    return 'પગલું $step / $total';
  }

  @override
  String get booking_next => 'આગળ';

  @override
  String get problem_title => 'શું તકલીફ છે?';

  @override
  String get problem_vehicle_label => 'વાહન';

  @override
  String get problem_no_vehicle_title => 'પહેલાં તમારું વાહન ઉમેરો';

  @override
  String get problem_no_vehicle_body => 'મિકેનિકને ખબર હોવી જોઈએ કે શું રિપેર કરવાનું છે.';

  @override
  String get problem_add_vehicle => 'વાહન ઉમેરો';

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
  String get photos_title => 'ફોટા અને વિગત';

  @override
  String get photos_body =>
      'વૈકલ્પિક. ફોટાથી મિકેનિક સાચા પાર્ટ્સ લાવી શકે છે. અમે દરેક ફોટામાંથી લોકેશન દૂર કરીએ છીએ.';

  @override
  String get photos_take => 'ફોટો લો';

  @override
  String get photos_gallery => 'ગેલેરીમાંથી પસંદ કરો';

  @override
  String photos_count(int count, int max) {
    return '$max માંથી $count ફોટા';
  }

  @override
  String photos_remove(int n) {
    return 'ફોટો $n દૂર કરો';
  }

  @override
  String photos_uploading(int n) {
    return 'ફોટો $n અપલોડ થઈ રહ્યો છે';
  }

  @override
  String photos_retry(int n) {
    return 'ફોટો $n અપલોડ ન થયો. ફરી પ્રયાસ કરો';
  }

  @override
  String get photos_error_limit => 'તમે 4 ફોટા સુધી ઉમેરી શકો છો.';

  @override
  String get photos_error_too_large => 'આ ફોટો ખૂબ મોટો છે. બીજો અજમાવો.';

  @override
  String get photos_error_failed => 'ફોટો ઉમેરી શકાયો નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get photos_error_upload => 'કેટલાક ફોટા અપલોડ ન થયા. આગળ વધવા ફરી પ્રયાસ કરો અથવા તેમને દૂર કરો.';

  @override
  String get description_label => 'શું થયું?';

  @override
  String get description_hint => 'જેમ કે: ટોલ પ્લાઝા પાસે પાછળનું ટાયર પંક્ચર થયું';

  @override
  String get photos_skip => 'છોડો';

  @override
  String photos_item(int n) {
    return 'ફોટો $n';
  }

  @override
  String get booking_back_home => 'હોમ પર પાછા';

  @override
  String get location_title => 'તમે ક્યાં છો?';

  @override
  String get location_hint => 'નકશો ખસેડો જેથી પિન તમારા વાહન પર આવે.';

  @override
  String get location_no_permission =>
      'આ એપ માટે લોકેશન બંધ છે. નકશો તમારી જગ્યા સુધી ખસેડો, અથવા લોકેશનની મંજૂરી આપો.';

  @override
  String get location_allow => 'લોકેશનની મંજૂરી આપો';

  @override
  String get location_gps_off => 'તમારા ફોનનું લોકેશન બંધ છે.';

  @override
  String get location_turn_on => 'લોકેશન ચાલુ કરો';

  @override
  String get location_no_fix => 'અમે તમને શોધી શક્યા નહીં. નકશો તમારી જગ્યા સુધી ખસેડો.';

  @override
  String get location_finding_address => 'સરનામું શોધી રહ્યા છીએ…';

  @override
  String get location_no_address => 'અહીં કોઈ સરનામું નથી. મિકેનિક પ્લસ કોડથી આવશે.';

  @override
  String location_plus_code(String code) {
    return 'પ્લસ કોડ $code';
  }

  @override
  String get location_landmark_label => 'નજીકની ઓળખ (વૈકલ્પિક)';

  @override
  String get location_landmark_hint => 'જેમ કે: પેટ્રોલ પંપની સામે';

  @override
  String get location_far_warning => 'પિન તમારા ફોનની જગ્યાથી 2 કિમીથી વધુ દૂર છે.';

  @override
  String get location_someone_else => 'હું બીજા કોઈ માટે બુક કરું છું';

  @override
  String get location_confirm => 'પિકઅપ પાકું કરો';

  @override
  String get location_recenter => 'મારા લોકેશન પર જાઓ';

  @override
  String get location_retry => 'ફરી પ્રયાસ કરો';

  @override
  String get price_title => 'તમારો અંદાજ';

  @override
  String get price_book => 'મિકેનિક બુક કરો';

  @override
  String get price_note =>
      'કામ પછી તમે સીધા મિકેનિકને UPI અથવા રોકડથી ચૂકવો છો. પાર્ટ્સ લાગે તો રકમ બદલાઈ શકે છે.';

  @override
  String get price_error_out_of_area =>
      'અમે હજી આ વિસ્તારમાં નથી. અમે અમદાવાદ, અંકલેશ્વર અને ભરૂચમાં સેવા આપીએ છીએ.';

  @override
  String get price_change_pickup => 'પિકઅપ બદલો';

  @override
  String get price_error_active_booking => 'તમારું એક બુકિંગ પહેલેથી ચાલુ છે.';

  @override
  String get price_open_booking => 'મારું બુકિંગ ખોલો';

  @override
  String get price_error_paused => 'બુકિંગ થોડા સમય માટે બંધ છે. કૃપા કરીને થોડી મિનિટ પછી ફરી પ્રયાસ કરો.';

  @override
  String get price_error_unavailable =>
      'અમે હજી આ સમસ્યાની કિંમત કહી શકતા નથી. અમારી સહાય ટીમ મદદ કરી શકે છે.';

  @override
  String get price_get_support => 'સહાય મેળવો';

  @override
  String get price_error_vehicle => 'આ વાહન દૂર કરાયું છે. બીજું પસંદ કરો.';

  @override
  String get price_choose_vehicle => 'વાહન પસંદ કરો';

  @override
  String get price_error_rate_limited => 'ઘણા બધા પ્રયાસો. કૃપા કરીને થોડી મિનિટ રાહ જોઈ ફરી પ્રયાસ કરો.';

  @override
  String get price_error_network => 'બુક થઈ શક્યું નહીં. તમારું કનેક્શન તપાસી ફરી પ્રયાસ કરો.';

  @override
  String get searching_title => 'મિકેનિક શોધી રહ્યા છીએ';

  @override
  String get searching_body => 'અમે સૌથી નજીકનો મિકેનિક શોધી રહ્યા છીએ.';

  @override
  String searching_radius(int km) {
    return 'અમે તમારાથી $km કિમીની અંદરના મિકેનિકને પૂછી રહ્યા છીએ.';
  }

  @override
  String get cancel_booking => 'બુકિંગ રદ કરો';

  @override
  String get cancel_title => 'આ બુકિંગ રદ કરવું છે?';

  @override
  String get cancel_body_searching => 'અમે તરત મિકેનિક શોધવાનું બંધ કરીશું.';

  @override
  String get cancel_body_assigned => 'તમારા મિકેનિકને તરત જણાવાશે. કૃપા કરીને કારણ પસંદ કરો.';

  @override
  String get cancel_confirm => 'બુકિંગ રદ કરો';

  @override
  String get cancel_keep => 'બુકિંગ રાખો';

  @override
  String get cancel_reason_found_help => 'બીજે મદદ મળી ગઈ';

  @override
  String get cancel_reason_fixed_myself => 'જાતે રિપેર કરી લીધું';

  @override
  String get cancel_reason_too_slow => 'ઘણી વાર લાગે છે';

  @override
  String get cancel_reason_wrong_details => 'ખોટું વાહન અથવા જગ્યા';

  @override
  String get cancel_reason_other => 'બીજું કંઈ';

  @override
  String get cancel_reason_text => 'વધુ જણાવો (વૈકલ્પિક)';

  @override
  String get cancel_error_too_late => 'હવે રદ થઈ શકે નહીં: કામ શરૂ થઈ ગયું છે.';

  @override
  String get cancel_error_network => 'રદ થઈ શક્યું નહીં. તમારું કનેક્શન તપાસી ફરી પ્રયાસ કરો.';

  @override
  String get no_mechanic_title => 'હમણાં કોઈ મિકેનિક ખાલી નથી';

  @override
  String get no_mechanic_body =>
      'નજીકના બધા મિકેનિક વ્યસ્ત છે. થોડી મિનિટ પછી ફરી પ્રયાસ કરો, અથવા અમારી સાથે વાત કરો.';

  @override
  String get no_mechanic_try_again => 'ફરી પ્રયાસ કરો';

  @override
  String get cancelled_title => 'બુકિંગ રદ થયું';

  @override
  String get cancelled_by_you => 'તમે આ બુકિંગ રદ કર્યું.';

  @override
  String get cancelled_by_mechanic => 'મિકેનિકને રદ કરવું પડ્યું. તમારી પાસેથી કોઈ ચાર્જ લેવાયો નથી.';

  @override
  String get cancelled_by_support => 'અમારી સહાય ટીમે આ બુકિંગ રદ કર્યું.';

  @override
  String get live_not_found => 'આ બુકિંગ મળ્યું નહીં.';

  @override
  String get assigned_title => 'એક મિકેનિક આવી રહ્યો છે';

  @override
  String get assigned_on_the_way => 'તમારો મિકેનિક રસ્તામાં છે';

  @override
  String get assigned_arrived => 'તમારો મિકેનિક પહોંચી ગયો છે';

  @override
  String get stop_requested => 'વિનંતી';

  @override
  String get stop_accepted => 'સ્વીકાર્યું';

  @override
  String get stop_on_the_way => 'રસ્તામાં';

  @override
  String get stop_arrived => 'પહોંચ્યા';

  @override
  String get stop_working => 'કામ ચાલુ';

  @override
  String get stop_done => 'પૂર્ણ';

  @override
  String get notif_start_code_locked_title => 'કોઈએ તમારો સ્ટાર્ટ કોડ અજમાવ્યો';

  @override
  String get notif_start_code_locked_body =>
      'કોઈએ તમારો સ્ટાર્ટ કોડ 5 વાર અજમાવ્યો. તે ફક્ત તમારા મિકેનિકને રૂબરૂ જ જણાવો.';

  @override
  String tracking_on_the_way(String name) {
    return '$name રસ્તામાં છે';
  }

  @override
  String tracking_arrived(String name) {
    return '$name પહોંચી ગયા છે';
  }

  @override
  String tracking_eta(int minutes) {
    return '$minutes મિનિટ';
  }

  @override
  String get tracking_away => 'દૂર';

  @override
  String tracking_waiting(String name) {
    return '$nameના લોકેશનની રાહ…';
  }

  @override
  String tracking_stale(int minutes) {
    return 'લોકેશન $minutes મિનિટ પહેલાં અપડેટ થયું. કદાચ નેટવર્ક નથી.';
  }

  @override
  String tracking_call(String name) {
    return '$nameને કૉલ કરો';
  }

  @override
  String get tracking_call_failed => 'ફોન એપ ખૂલી નહીં.';

  @override
  String get tracking_start_code => 'શરૂ કરવાનો કોડ';

  @override
  String get tracking_start_code_hint => 'મિકેનિક તમારી સાથે ઊભો હોય ત્યારે જ આ કોડ જણાવો.';

  @override
  String working_title(String name) {
    return '$name કામ કરી રહ્યા છે';
  }

  @override
  String working_since(String time, int minutes) {
    return '$time વાગ્યે શરૂ · અત્યાર સુધી $minutes મિનિટ';
  }

  @override
  String get working_started => 'કામ શરૂ થઈ ગયું છે.';

  @override
  String payment_title(String name) {
    return '$nameને ચુકવણી કરો';
  }

  @override
  String payment_estimate_was(String min, String max) {
    return 'અંદાજ $min–$max હતો';
  }

  @override
  String get payment_no_amount => 'મિકેનિક અંતિમ રકમ દાખલ કરે તેની રાહ.';

  @override
  String get payment_pay_upi => 'UPI એપથી ચુકવણી કરો';

  @override
  String payment_qr_label(String amount, String name) {
    return '$nameને $amount ચુકવવાનો QR કોડ';
  }

  @override
  String get payment_qr_hint => 'અથવા કોઈપણ UPI એપથી સ્કેન કરો';

  @override
  String get payment_copy_upi => 'UPI ID કૉપિ કરો';

  @override
  String get payment_upi_copied => 'UPI ID કૉપિ થઈ';

  @override
  String get payment_no_upi_app => 'કોઈ UPI એપ ખૂલી નહીં. બીજા ફોનથી QR સ્કેન કરો, અથવા રોકડ આપો.';

  @override
  String payment_cash(String name) {
    return '$nameને રોકડ આપો, અથવા તેમનું UPI ID પૂછો.';
  }

  @override
  String get payment_i_have_paid => 'મેં ચુકવણી કરી દીધી';

  @override
  String get payment_problem => 'કંઈક ખોટું છે';

  @override
  String get payment_error_network => 'ચુકવણી અપડેટ થઈ નહીં. તમારું કનેક્શન તપાસી ફરી પ્રયાસ કરો.';

  @override
  String payment_waiting_title(String name) {
    return '$nameની પુષ્ટિની રાહ';
  }

  @override
  String payment_waiting_body(String amount) {
    return 'તેઓ જોશે કે $amount તેમની UPI એપમાં આવ્યા.';
  }

  @override
  String payment_confirmed_title(String amount) {
    return '$amount ચૂકવાયા';
  }

  @override
  String get payment_confirmed_title_plain => 'ચુકવણીની પુષ્ટિ થઈ';

  @override
  String payment_confirmed_body(String name) {
    return 'આભાર! $nameએ તમારી ચુકવણીની પુષ્ટિ કરી.';
  }

  @override
  String get payment_disputed_title => 'અમે આ જોઈ રહ્યા છીએ';

  @override
  String get payment_disputed_body => 'અમારી ટીમ આ ચુકવણી વિશે તમારો સંપર્ક કરશે.';

  @override
  String get payment_dispute_title => 'ચુકવણીમાં શું ખોટું છે?';

  @override
  String get payment_dispute_label => 'શું થયું તે જણાવો';

  @override
  String get payment_dispute_hint => 'જેમ કે: બતાવેલી રકમ કરતાં વધુ માંગ્યું';

  @override
  String get payment_dispute_send => 'સમસ્યા જણાવો';

  @override
  String get payment_dispute_sent => 'આભાર. અમે આ જોઈશું.';

  @override
  String get cancel_keep_open => 'પાછા જાઓ';

  @override
  String review_rate(String name) {
    return '$nameને રેટિંગ આપો';
  }

  @override
  String get review_step => 'તમારી સમીક્ષા';

  @override
  String review_title(String name) {
    return '$name કેવા રહ્યા?';
  }

  @override
  String review_stars_label(String name) {
    return '$name માટે રેટિંગ';
  }

  @override
  String get review_tags_good => 'શું સારું રહ્યું?';

  @override
  String get review_tags_bad => 'શું ખોટું થયું?';

  @override
  String get review_tag_on_time => 'સમયસર';

  @override
  String get review_tag_friendly => 'મૈત્રીપૂર્ણ';

  @override
  String get review_tag_fixed_fast => 'ઝડપથી રિપેર કર્યું';

  @override
  String get review_tag_fair_price => 'યોગ્ય કિંમત';

  @override
  String get review_tag_late => 'મોડા આવ્યા';

  @override
  String get review_tag_rude => 'અસભ્ય';

  @override
  String get review_tag_overcharged => 'વધુ પૈસા લીધા';

  @override
  String get review_tag_not_fixed => 'રિપેર ન થયું';

  @override
  String get review_comment_label => 'બીજું કંઈ? (વૈકલ્પિક)';

  @override
  String get review_submit => 'સમીક્ષા મોકલો';

  @override
  String get review_thanks => 'તમારી સમીક્ષા બદલ આભાર!';

  @override
  String get review_error => 'સમીક્ષા મોકલી શકાઈ નહીં. તમારું કનેક્શન તપાસી ફરી પ્રયાસ કરો.';

  @override
  String get review_not_allowed => 'આ બુકિંગની સમીક્ષા થઈ શકે નહીં.';

  @override
  String get review_already => 'તમે આ બુકિંગને રેટિંગ આપી દીધું છે. આભાર!';

  @override
  String get home_city_outside => 'અમારા વિસ્તારની બહાર';

  @override
  String get home_locating => 'તમારું લોકેશન શોધી રહ્યા છીએ…';

  @override
  String get home_no_location => 'નજીકની મદદ જોવા તમારું લોકેશન આપો. તેના વિના પણ મદદ લઈ શકો છો.';

  @override
  String get home_show_location => 'મારું લોકેશન બતાવો';

  @override
  String get home_no_fix => 'અમે તમારું લોકેશન શોધી શક્યા નહીં. છતાં મદદ લઈ શકો છો અને પિન જાતે મૂકી શકો છો.';

  @override
  String get home_outside_title => 'અમે હજી તમારા વિસ્તારમાં નથી';

  @override
  String get home_outside_body =>
      'અમે અમદાવાદ, અંકલેશ્વર અને ભરૂચમાં સેવા આપીએ છીએ. SMSથી તમારું લોકેશન મોકલો, અમારી ટીમ મદદ શોધવામાં સહાય કરશે.';

  @override
  String get home_sms_location => 'SMSથી મારું લોકેશન મોકલો';

  @override
  String home_sms_body(String link, String code) {
    return 'મને રસ્તા પર મદદ જોઈએ છે. મારું લોકેશન: $link (પ્લસ કોડ $code)';
  }

  @override
  String get home_sms_failed => 'SMS એપ ખૂલી નહીં.';

  @override
  String get home_booking_active => 'તમારું બુકિંગ ચાલુ છે';

  @override
  String get home_booking_open => 'ખોલવા ટેપ કરો';

  @override
  String get contacts_title => 'કટોકટી સંપર્કો';

  @override
  String get contacts_body => 'SOS આ લોકોને તમારું લાઇવ લોકેશન મોકલે છે. વધુમાં વધુ 3.';

  @override
  String get contacts_empty => 'હજી કોઈ સંપર્ક નથી. કટોકટીમાં મદદ કરી શકે તેવા કોઈને ઉમેરો.';

  @override
  String get contacts_add_picker => 'સંપર્કોમાંથી ઉમેરો';

  @override
  String get contacts_add_manual => 'નંબર લખો';

  @override
  String get contacts_full => 'તમે વધુમાં વધુ 3 સંપર્કો સેવ કરી શકો છો.';

  @override
  String contacts_remove(String name) {
    return '$nameને દૂર કરો';
  }

  @override
  String get contacts_save => 'સેવ કરો';

  @override
  String get contacts_saved => 'સંપર્કો સેવ થયા.';

  @override
  String get contacts_save_failed => 'તમારા સંપર્કો સેવ થઈ શક્યા નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get contacts_error_invalid => 'આ નંબર વાપરી શકાય નહીં. મોબાઇલ નંબર નાખો.';

  @override
  String get contacts_error_duplicate => 'આ નંબર પહેલેથી યાદીમાં છે.';

  @override
  String get contacts_picker_failed => 'તમારા સંપર્કો ખૂલી શક્યા નહીં. નંબર લખીને ઉમેરો.';

  @override
  String get contacts_manual_title => 'સંપર્ક ઉમેરો';

  @override
  String get contacts_name_label => 'નામ';

  @override
  String get contacts_phone_label => 'મોબાઇલ નંબર';

  @override
  String get contacts_manual_add => 'ઉમેરો';

  @override
  String get contacts_discard_title => 'ફેરફારો છોડી દેવા છે?';

  @override
  String get contacts_discard => 'છોડી દો';

  @override
  String get contacts_keep_editing => 'ફેરફાર ચાલુ રાખો';

  @override
  String get contacts_error => 'તમારા સંપર્કો લોડ થઈ શક્યા નહીં.';

  @override
  String get contacts_retry => 'ફરી પ્રયાસ કરો';

  @override
  String get chat_open => 'ચેટ';

  @override
  String get chat_title => 'ચેટ';

  @override
  String get chat_empty_title => 'હજી કોઈ સંદેશ નથી';

  @override
  String chat_empty_body(String name) {
    return '$nameને એવું કંઈ પણ કહો જેનાથી તેઓ તમને કે તમારા વાહનને શોધી શકે.';
  }

  @override
  String get chat_closed => 'આ ચેટ બંધ થઈ ગઈ છે. તમે તેને 30 દિવસ સુધી વાંચી શકો છો.';

  @override
  String chat_you(String text) {
    return 'તમે: $text';
  }

  @override
  String chat_from(String name, String text) {
    return '$name: $text';
  }

  @override
  String get chat_photo_title => 'ફોટો મોકલો';

  @override
  String get chat_photo_take => 'ફોટો પાડો';

  @override
  String get chat_photo_gallery => 'ગેલેરીમાંથી પસંદ કરો';

  @override
  String get chat_photo_too_large => 'આ ફોટો બહુ મોટો છે. બીજો પસંદ કરો.';

  @override
  String get chat_photo_failed => 'ફોટો ઉમેરી શકાયો નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get chat_error => 'ચેટ લોડ થઈ શકી નહીં. તમારું કનેક્શન તપાસો.';

  @override
  String get chat_error_retry => 'ફરી પ્રયાસ કરો';

  @override
  String get home_profile => 'પ્રોફાઇલ અને સેટિંગ્સ';

  @override
  String get profile_title => 'પ્રોફાઇલ અને સેટિંગ્સ';

  @override
  String get profile_error => 'તમારી પ્રોફાઇલ લોડ થઈ શકી નહીં. તમારી સેટિંગ્સ તો પણ કામ કરે છે.';

  @override
  String get profile_language => 'ભાષા';

  @override
  String get profile_language_title => 'તમારી ભાષા પસંદ કરો';

  @override
  String get profile_display_mode => 'ડિસ્પ્લે મોડ';

  @override
  String get profile_display_auto => 'ઑટો';

  @override
  String get profile_display_auto_hint => 'સૂર્યાસ્ત મુજબ દિવસ કે રાત. બેટરી ઓછી હોય ત્યારે સેવર.';

  @override
  String get profile_display_day => 'દિવસ';

  @override
  String get profile_display_day_hint => 'હંમેશા આછી સ્ક્રીન.';

  @override
  String get profile_display_night => 'રાત';

  @override
  String get profile_display_night_hint => 'હંમેશા ઘેરી સ્ક્રીન.';

  @override
  String get profile_display_glare => 'તડકા મોડ';

  @override
  String get profile_display_glare_hint => 'તેજ તડકા માટે સફેદ પર કાળું, મોટા અક્ષર.';

  @override
  String get profile_chime => 'પહોંચવાની ઘંટડી';

  @override
  String get profile_chime_hint => 'મિકેનિક પહોંચે ત્યારે નાનો અવાજ.';

  @override
  String get profile_contacts => 'કટોકટી સંપર્કો';

  @override
  String profile_contacts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count સેવ કરેલા',
      zero: 'હજુ કોઈ સેવ નથી',
    );
    return '$_temp0';
  }

  @override
  String get profile_privacy => 'ગોપનીયતા અને ડેટા';

  @override
  String get profile_licenses => 'ઓપન-સોર્સ લાઇસન્સ';

  @override
  String get home_history => 'તમારા બુકિંગ';

  @override
  String get history_title => 'બુકિંગ';

  @override
  String get history_filter_all => 'બધા';

  @override
  String get history_filter_active => 'ચાલુ';

  @override
  String get history_filter_past => 'પાછલા';

  @override
  String get history_status_searching => 'શોધી રહ્યા છીએ';

  @override
  String get history_status_cancelled => 'રદ';

  @override
  String get history_status_no_mechanic => 'મિકેનિક ન મળ્યો';

  @override
  String get history_today => 'આજે';

  @override
  String get history_yesterday => 'ગઈકાલે';

  @override
  String get history_empty_title => 'હજુ કોઈ બુકિંગ નથી';

  @override
  String get history_empty_body => 'મદદ લીધા પછી બુકિંગ અને તેની રસીદ અહીં દેખાશે.';

  @override
  String get history_empty_action => 'નકશા પર જાઓ';

  @override
  String get history_none_active => 'હાલ કોઈ બુકિંગ ચાલુ નથી';

  @override
  String get history_none_past => 'કોઈ પાછલા બુકિંગ નથી';

  @override
  String get history_show_all => 'બધા બતાવો';

  @override
  String get history_error => 'તમારા બુકિંગ લોડ થઈ શક્યા નહીં. કનેક્શન તપાસો.';

  @override
  String get detail_title => 'બુકિંગ';

  @override
  String get detail_missing => 'આ બુકિંગ ઉપલબ્ધ નથી.';

  @override
  String get detail_back_to_history => 'બુકિંગ પર પાછા';

  @override
  String get detail_report => 'સમસ્યા જણાવો';

  @override
  String get detail_no_mechanic => 'નજીકમાં કોઈ મિકેનિક ફ્રી નહોતો. કોઈ પૈસા લેવાયા નથી.';

  @override
  String detail_cancelled_by_you(String time) {
    return 'તમે $time વાગ્યે રદ કર્યું.';
  }

  @override
  String detail_cancelled_at(String time) {
    return '$time વાગ્યે રદ થયું.';
  }

  @override
  String get detail_mechanic => 'મિકેનિક';

  @override
  String get detail_amount => 'રકમ';

  @override
  String get detail_paid_by => 'ચુકવણી';

  @override
  String get detail_upi => 'UPI';

  @override
  String detail_upi_to(String name) {
    return '$name ને UPI';
  }

  @override
  String get detail_payment => 'ચુકવણીની સ્થિતિ';

  @override
  String get detail_payment_pending => 'હજુ ચુકવણી થઈ નથી';

  @override
  String get detail_payment_marked => 'મિકેનિકની પુષ્ટિની રાહ';

  @override
  String get detail_payment_confirmed => 'ચુકવણી થઈ ગઈ, મિકેનિકે પુષ્ટિ કરી';

  @override
  String get detail_payment_disputed => 'તપાસ ચાલુ છે';

  @override
  String get detail_nothing_to_pay => 'કંઈ ચૂકવવાનું નથી';

  @override
  String get sos_button => 'કટોકટી SOS';

  @override
  String get sos_title => 'કટોકટી';

  @override
  String sos_body(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'તમારા $count કટોકટી સંપર્કોને તમારું લોકેશન મોકલવા દબાવી રાખો.',
      one: 'તમારા કટોકટી સંપર્કને તમારું લોકેશન મોકલવા દબાવી રાખો.',
    );
    return '$_temp0';
  }

  @override
  String get sos_body_loading => 'તમારા કટોકટી સંપર્કોને તમારું લોકેશન મોકલવા દબાવી રાખો.';

  @override
  String get sos_body_no_contacts =>
      'કોઈ કટોકટી સંપર્ક સેવ નથી. દબાવી રાખતાં મેસેજ એપ ખુલશે, ત્યાં તમે કોને મોકલવું તે પસંદ કરી શકો.';

  @override
  String get sos_hold_hint => 'SOS મોકલવા 1.5 સેકન્ડ દબાવી રાખો';

  @override
  String get sos_hold_caption => '1.5 સેકન્ડ દબાવી રાખો. વહેલું છોડશો તો કંઈ નહીં જાય.';

  @override
  String get sos_opening => 'તમારી મેસેજ એપ ખુલી રહી છે…';

  @override
  String get sos_opened => 'તમારી મેસેજ એપમાં SOS તૈયાર છે. મોકલો દબાવો.';

  @override
  String get sos_failed => 'મેસેજ એપ ખુલી શકી નહીં. 112 પર કૉલ કરો.';

  @override
  String get sos_call_112 => '112 પર કૉલ કરો';

  @override
  String get sos_call_failed => 'કૉલ શરૂ થઈ શક્યો નહીં. 112 ડાયલ કરો.';

  @override
  String get sos_share_trip => 'ટ્રિપ શેર કરો';

  @override
  String get sos_add_contacts => 'કટોકટી સંપર્કો ઉમેરો';

  @override
  String sos_sms_body(String link, String code) {
    return 'SOS: મને મદદ જોઈએ છે. મારું લોકેશન: $link (પ્લસ કોડ $code).';
  }

  @override
  String get sos_sms_body_no_location => 'SOS: મને મદદ જોઈએ છે. મારું લોકેશન હાલ ઉપલબ્ધ નથી.';

  @override
  String sos_sms_trip(String link) {
    return 'મારી લાઇવ ટ્રિપ જુઓ: $link';
  }

  @override
  String sos_share_trip_text(String link) {
    return 'મારી રોડસાઇડ મદદની ટ્રિપ લાઇવ જુઓ: $link';
  }

  @override
  String sos_share_location_text(String link) {
    return 'હું અહીં રોડસાઇડ મદદની રાહ જોઉં છું: $link';
  }

  @override
  String get home_offline => 'તમે ઑફલાઇન છો. મદદ લેવા ઇન્ટરનેટ જોઈએ.';

  @override
  String get home_offline_sms =>
      'તમે ઑફલાઇન છો. તમે હજુ પણ SMS થી તમારું લોકેશન અમારી હેલ્પલાઇન પર મોકલી શકો છો.';
}
