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

  @override
  String get home_help => 'મદદ અને FAQ';

  @override
  String get permission_location_title => 'લોકેશનની પરવાનગી આપો';

  @override
  String get permission_location_body =>
      'જેથી અમે તમને નજીકના કામ મોકલી શકીએ અને ગ્રાહકોને બતાવી શકીએ કે તમે રસ્તામાં છો. ફક્ત જ્યારે તમે ઓનલાઇન હો કે કામ પર હો; કામ દરમિયાન એક સૂચના બતાવે છે કે તે ચાલુ છે.';

  @override
  String get permission_camera_title => 'કૅમેરાની પરવાનગી આપો';

  @override
  String get permission_camera_body =>
      'તમારી પ્રોફાઇલ, દુકાન કે ઓજારોના ફોટા, તમારા ID દસ્તાવેજો, અને દરેક કામ પહેલાં અને પછીના ફોટા ઉમેરવા માટે.';

  @override
  String get permission_notifications_title => 'સૂચનાઓની પરવાનગી આપો';

  @override
  String get permission_notifications_body =>
      'જેથી તમને નવા કામની ઓફર તરત મળે, અને એપ બંધ હોય ત્યારે પણ તમારા કામની માહિતી મળે.';

  @override
  String get permission_full_screen_title => 'લૉક સ્ક્રીન પર કામની ઓફર બતાવો';

  @override
  String get permission_full_screen_body =>
      'નવું કામ આવતા કૉલની જેમ આખી સ્ક્રીન પર દેખાય છે, જેથી કોઈ ચૂકી ન જાય. આગલી સ્ક્રીન પર આ એપ માટે ફુલ-સ્ક્રીન સૂચનાઓ ચાલુ કરો.';

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
  String get help_search_hint => 'જેમ કે ઓફર, શરૂ કરવાનો કોડ, ચૂકવણી';

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
  String get help_faq_jobs_q => 'મને કામ કેવી રીતે મળશે?';

  @override
  String get help_faq_jobs_a =>
      'મંજૂરી મળ્યા પછી હોમ સ્ક્રીન પર ઓનલાઇન થાઓ. નજીકના બગડેલાં વાહનો તમને ઓફર તરીકે આવશે; 30 સેકન્ડમાં સ્લાઇડ કરીને સ્વીકારો.';

  @override
  String get help_faq_no_offers_q => 'મને ઓફર કેમ નથી મળતી?';

  @override
  String get help_faq_no_offers_a =>
      'તપાસો કે તમે ઓનલાઇન છો, મંજૂર છો, તમારા શહેરમાં છો, અને તમારાં વાહનોના પ્રકાર અને સેવાઓ ભરેલી છે. લોકેશન ચાલુ રાખી એપ ખુલ્લી રાખો; ઓફર ફક્ત નજીકના મિકેનિકને જાય છે.';

  @override
  String get help_faq_verify_q => 'ચકાસણી કેવી રીતે થાય છે?';

  @override
  String get help_faq_verify_a =>
      'કામ મળે તે પહેલાં અમે તમારી ID અને ફોટા તપાસીએ છીએ. જો તમે વર્કશોપ વગર કામ કરતા હો, તો અમે ટૂંકી ચકાસણી માટે કૉલ પણ કરીએ છીએ.';

  @override
  String get help_faq_code_q => 'શરૂ કરવાનો કોડ શું છે?';

  @override
  String get help_faq_code_a =>
      'પહોંચો ત્યારે ગ્રાહક તમને 4 અંકનો કોડ કહેશે. કામ શરૂ કરવા તે દાખલ કરો. 5 વાર ખોટો થાય તો તે 10 મિનિટ માટે બંધ થઈ જાય છે.';

  @override
  String get help_faq_pay_q => 'મને પૈસા કેવી રીતે મળશે?';

  @override
  String get help_faq_pay_a =>
      'ગ્રાહક તમને સીધા UPI થી ચૂકવે છે. તમારી UPI એપ તપાસો, પછી પુષ્ટિ કરો પર ટેપ કરો. જો પૈસા ન આવ્યા હોય, તો નથી મળ્યા પર ટેપ કરો અને અમે તપાસ કરીશું.';

  @override
  String get help_faq_cancel_q => 'શું હું કામ રદ કરી શકું?';

  @override
  String get help_faq_cancel_a =>
      'હા, પણ તેની અસર તમારી વિશ્વસનીયતા પર પડે છે. પહોંચતા પહેલાં કામ બીજા મિકેનિકને જાય છે; પહોંચ્યા પછી કારણ જણાવો.';

  @override
  String get register_type_title => 'મિકેનિક તરીકે જોડાઓ';

  @override
  String get register_about_title => 'તમારા વિશે';

  @override
  String get register_work_title => 'તમારું કામ';

  @override
  String get register_id_title => 'ઓળખ અને ચૂકવણી';

  @override
  String get register_next => 'આગળ';

  @override
  String get register_submit => 'મંજૂરી માટે મોકલો';

  @override
  String get register_error_upload =>
      'એક ફોટો અપલોડ ન થયો. તમારું કનેક્શન તપાસો અને ફરી મોકલો; મોકલાયેલા ફોટા ફરી અપલોડ નહીં થાય.';

  @override
  String get register_error_save => 'અમે તમારી વિગતો સેવ ન કરી શક્યા. તમારું કનેક્શન તપાસો અને ફરી મોકલો.';

  @override
  String get register_type_question => 'શું તમારી વર્કશોપ છે?';

  @override
  String get register_type_workshop => 'હા, મારી વર્કશોપ છે';

  @override
  String get register_type_independent => 'ના, હું સ્વતંત્ર રીતે કામ કરું છું';

  @override
  String get register_city_label => 'તમારું શહેર';

  @override
  String get register_city_help => 'તમને આ જ શહેરમાં કામ મળશે. પછીથી તે ફક્ત અમારી ટીમ બદલી શકે છે.';

  @override
  String get city_ahmedabad => 'અમદાવાદ';

  @override
  String get city_ankleshwar => 'અંકલેશ્વર';

  @override
  String get city_bharuch => 'ભરૂચ';

  @override
  String get register_photo_source_title => 'ફોટો ઉમેરો';

  @override
  String get register_photo_camera => 'ફોટો પાડો';

  @override
  String get register_photo_gallery => 'ગેલેરીમાંથી પસંદ કરો';

  @override
  String get register_photo_too_large => 'આ ફોટો ખૂબ મોટો છે. બીજો અજમાવો.';

  @override
  String get register_photo_add => 'ફોટો ઉમેરો';

  @override
  String get register_photo_remove => 'ફોટો કાઢો';

  @override
  String get register_name_label => 'તમારું નામ';

  @override
  String get register_photo_profile => 'તમારો ફોટો (ગ્રાહકો જુએ છે)';

  @override
  String get register_shop_heading => 'તમારી દુકાન';

  @override
  String get register_shop_name_label => 'દુકાનનું નામ';

  @override
  String get register_shop_address_label => 'દુકાનનું સરનામું';

  @override
  String get register_photo_shop => 'દુકાનનો ફોટો';

  @override
  String get register_independent_heading => 'તમે કેવી રીતે કામ કરો છો';

  @override
  String get register_experience_label => 'અનુભવનાં વર્ષ';

  @override
  String get register_base_area_label => 'તમે સામાન્ય રીતે ક્યાંથી નીકળો છો';

  @override
  String get register_base_area_hint => 'જેમ કે GIDC અંકલેશ્વર';

  @override
  String get register_travel_heading => 'તમે શેના પર આવ-જા કરો છો';

  @override
  String get register_travel_reg_label => 'તેની નંબર પ્લેટ';

  @override
  String get register_travel_reg_hint => 'જેમ કે GJ 16 CK 4471';

  @override
  String get register_toolkit_heading => 'તમારાં ઓજારો';

  @override
  String get register_toolkit_help => 'તમે સાથે રાખો છો તે ઓજારોના ઓછામાં ઓછા 2 ફોટા ઉમેરો.';

  @override
  String register_photo_toolkit(int number) {
    return 'ઓજારો $number';
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
  String get register_vehicles_label => 'તમે કયાં વાહનો પર કામ કરો છો';

  @override
  String get register_services_label => 'તમે શું રિપેર કરી શકો છો';

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
  String get register_id_private => 'આ ફક્ત અમારી ચકાસણી ટીમ જુએ છે. ગ્રાહકો ક્યારેય નહીં.';

  @override
  String get register_photo_id_proof => 'ઓળખપત્ર';

  @override
  String get register_photo_selfie => 'ઓળખપત્ર પકડીને સેલ્ફી';

  @override
  String get register_photo_address_proof => 'સરનામાનો પુરાવો';

  @override
  String get register_upi_heading => 'ગ્રાહકો તમને ક્યાં ચૂકવે';

  @override
  String get register_upi_id_label => 'UPI ID';

  @override
  String get register_upi_id_hint => 'જેમ કે name@bank';

  @override
  String get register_upi_name_label => 'UPI ખાતા પરનું નામ';

  @override
  String get register_reference_heading => 'કોઈ જે તમારું કામ જાણે (વૈકલ્પિક)';

  @override
  String get register_reference_help => 'જેમ કે કોઈ વર્કશોપ જ્યાં તમે શીખ્યા.';

  @override
  String get register_reference_name_label => 'તેમનું નામ';

  @override
  String get register_reference_phone_label => 'તેમનો ફોન';

  @override
  String get register_reference_phone_hint => '+91…';

  @override
  String get error_field_required => 'કૃપા કરી આ ભરો';

  @override
  String get error_field_too_long => 'આ બહુ લાંબું છે';

  @override
  String get error_field_invalid => 'કૃપા કરી આ તપાસો';

  @override
  String get error_reg_no_invalid => 'નંબર તપાસો, જેમ કે GJ 01 AB 1234 અથવા 22 BH 1234 AA';

  @override
  String get error_phone_invalid => 'નંબર તપાસો, જેમ કે +91 98765 43210';

  @override
  String get error_upi_invalid => 'UPI ID તપાસો, જેમ કે name@bank';

  @override
  String get error_experience_invalid => 'વર્ષ અંકમાં લખો, 0 થી 60';

  @override
  String get error_toolkit_photos_too_few => 'તમારાં ઓજારોના ઓછામાં ઓછા 2 ફોટા ઉમેરો';

  @override
  String get pending_title => 'અમે તમારી વિગતો તપાસી રહ્યા છીએ';

  @override
  String get pending_body_workshop => 'સામાન્ય રીતે 24 કલાકમાં. અમે તમને જણાવીશું.';

  @override
  String get pending_body_independent => 'ટૂંકી ચકાસણી માટે અમે તમને કૉલ કરીશું, સામાન્ય રીતે 24 કલાકમાં.';

  @override
  String get pending_blocked_title => 'તમારું ખાતું રોકવામાં આવ્યું છે';

  @override
  String get pending_blocked_body => 'વધુ જાણવા કૃપા કરી સહાયને કૉલ કરો.';

  @override
  String get pending_item_shop => 'દુકાનની વિગતો';

  @override
  String get pending_item_details => 'તમારી વિગતો અને ઓજારો';

  @override
  String get pending_item_id => 'ઓળખપત્ર';

  @override
  String get pending_item_id_selfie => 'ઓળખ, સેલ્ફી અને સરનામાનો પુરાવો';

  @override
  String get pending_item_call => 'ચકાસણી કૉલ';

  @override
  String get pending_received => 'મળી ગયું';

  @override
  String get pending_checking => 'તપાસ ચાલુ છે…';

  @override
  String get pending_call_waiting => 'અમે કૉલ કરીશું';

  @override
  String get dashboard_title => 'આજે';

  @override
  String get dashboard_online => 'તમે ઓનલાઇન છો';

  @override
  String get dashboard_online_body => 'અમે તમને નજીકના કામ મોકલીશું.';

  @override
  String get dashboard_finding_location => 'તમારું લોકેશન શોધી રહ્યા છીએ…';

  @override
  String get dashboard_offline => 'તમે ઓફલાઇન છો';

  @override
  String get dashboard_offline_body =>
      'કામ મેળવવા ઓનલાઇન થાઓ. અમે તમારું લોકેશન ફક્ત ઓનલાઇન હો ત્યારે જ વાપરીએ છીએ.';

  @override
  String get dashboard_gps_off => 'તમારા ફોનનું લોકેશન બંધ છે. ઓનલાઇન થવા તેને ચાલુ કરો.';

  @override
  String get dashboard_turn_on_location => 'લોકેશન ચાલુ કરો';

  @override
  String get dashboard_lost_connection =>
      'તમે ઓફલાઇન થઈ ગયા: 2 મિનિટ સુધી અમે તમારું લોકેશન અપડેટ ન કરી શક્યા. તમારું કનેક્શન તપાસો અને ફરી ઓનલાઇન થાઓ.';

  @override
  String get dashboard_jobs_today => 'આજનાં કામ';

  @override
  String get dashboard_earned_today => 'આજની કમાણી';

  @override
  String get dashboard_recent_jobs => 'તાજેતરનાં કામ';

  @override
  String get dashboard_no_jobs_yet => 'આજે હજી કોઈ કામ નથી. ઓનલાઇન રહો, કામ તમારી પાસે આવશે.';

  @override
  String get offer_title => 'નવું કામ';

  @override
  String get offer_distance => 'અંતર';

  @override
  String offer_distance_value(String km) {
    return '$km કિમી';
  }

  @override
  String get offer_area => 'વિસ્તાર';

  @override
  String get offer_slide_accept => 'સ્વીકારવા સ્લાઇડ કરો';

  @override
  String get offer_decline => 'ના પાડો';

  @override
  String get offer_failed => 'અમારા સુધી પહોંચી ન શક્યા. તમારું કનેક્શન તપાસો અને ફરી સ્લાઇડ કરો.';

  @override
  String get offer_expired_title => 'આ કામનો સમય પૂરો થઈ ગયો';

  @override
  String get offer_expired_body => 'ઓફર 30 સેકન્ડની હોય છે. અમે તમને આગલું નજીકનું કામ મોકલીશું.';

  @override
  String get offer_withdrawn_title => 'આ કામ પાછું લેવાયું';

  @override
  String get offer_withdrawn_body => 'ગ્રાહકે રદ કર્યું અથવા હવે મદદની જરૂર નથી.';

  @override
  String get offer_taken_title => 'આ કામ હવે ઉપલબ્ધ નથી';

  @override
  String get offer_taken_body => 'તે બીજા મિકેનિકને મળ્યું. આગલા માટે ઓનલાઇન રહો.';

  @override
  String get offer_not_available_title => 'તમે હમણાં આ કામ ન લઈ શકો';

  @override
  String get offer_not_available_body => 'તમે ઓફલાઇન છો અથવા પહેલેથી કોઈ કામ પર છો.';

  @override
  String get offer_profile_incomplete_title => 'પહેલાં તમારી પ્રોફાઇલ પૂરી કરો';

  @override
  String get offer_profile_incomplete_body => 'કેટલીક માહિતી બાકી છે. કામ લેવા માટે તમારી પ્રોફાઇલ પૂરી કરો.';

  @override
  String get offer_not_approved_title => 'તમે હજી મંજૂર થયા નથી';

  @override
  String get offer_not_approved_body =>
      'અમે હજી તમારા દસ્તાવેજો તપાસી રહ્યા છીએ. મંજૂરી મળ્યા પછી તમે કામ લઈ શકશો.';

  @override
  String get offer_back => 'ડેશબોર્ડ પર પાછા';

  @override
  String get offer_notification_title => 'નજીકમાં નવું કામ';

  @override
  String get offer_notification_body => 'સ્વીકારવા 30 સેકન્ડમાં ખોલો.';

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
  String get job_headline_accepted => 'નીકળો ત્યારે મુસાફરી શરૂ કરો';

  @override
  String get job_headline_arriving => 'ગ્રાહક પાસે જઈ રહ્યા છો';

  @override
  String get job_headline_arrived => 'તમે ગ્રાહક પાસે છો';

  @override
  String get job_headline_working => 'કામ ચાલુ છે';

  @override
  String job_eta(int minutes) {
    return 'આશરે $minutes મિનિટ દૂર';
  }

  @override
  String get job_start_trip => 'મુસાફરી શરૂ કરો';

  @override
  String get job_arrived => 'હું પહોંચી ગયો';

  @override
  String get job_ask_start_code => 'શરૂ કરવા ગ્રાહક પાસેથી તેમનો 4 અંકનો કોડ માગો.';

  @override
  String get job_open_in_maps => 'મેપ્સમાં ખોલો';

  @override
  String get job_call => 'કૉલ કરો';

  @override
  String get job_error_not_at_pickup => 'તમે હજી પિકઅપ પર નથી. 100 મીટરની અંદર આવી ફરી પ્રયાસ કરો.';

  @override
  String get job_error_location =>
      'અમે હમણાં તમારું લોકેશન જોઈ શકતા નથી. GPS ચાલુ રાખી એપ ખુલ્લી રાખો, પછી પ્રયાસ કરો.';

  @override
  String get job_error_failed => 'અમારા સુધી પહોંચી ન શક્યા. તમારું કનેક્શન તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get job_tracking_title => 'તમારું લોકેશન શેર થઈ રહ્યું છે';

  @override
  String get job_tracking_text => 'તમારા ગ્રાહક સાથે, ફક્ત આ કામ દરમિયાન.';

  @override
  String get job_cancelled_title => 'આ કામ રદ થયું';

  @override
  String get job_cancelled_body => 'તમે આગલા કામ માટે ફ્રી છો.';

  @override
  String get job_done_title => 'કામ પૂરું';

  @override
  String get job_done_body => 'સરસ કામ.';

  @override
  String get job_missing_title => 'અમને આ કામ મળતું નથી';

  @override
  String get job_missing_body => 'કદાચ તે રદ થયું છે.';

  @override
  String get login_phone_title => 'તમારો મોબાઇલ નંબર';

  @override
  String get login_country_code => '+91';

  @override
  String get login_phone_label => 'મોબાઇલ નંબર';

  @override
  String get login_phone_hint => '98765 43210';

  @override
  String get login_phone_helper => 'અમે SMS દ્વારા 6 અંકનો કોડ મોકલીશું.';

  @override
  String get login_send_code => 'કોડ મોકલો';

  @override
  String get login_code_title => 'કોડ દાખલ કરો';

  @override
  String login_code_sent_to(String phone) {
    return '$phone પર મોકલ્યો';
  }

  @override
  String get login_change_number => 'નંબર બદલો';

  @override
  String login_resend_in(String time) {
    return '$time માં ફરી મોકલો';
  }

  @override
  String get login_resend => 'કોડ ફરી મોકલો';

  @override
  String get login_verify => 'ચકાસો';

  @override
  String get login_error_invalid_number => '10 અંકનો ભારતીય મોબાઇલ નંબર દાખલ કરો.';

  @override
  String get login_error_invalid_code => 'આ કોડ સાચો નથી. SMS જોઈને ફરી પ્રયાસ કરો.';

  @override
  String get login_error_code_expired => 'આ કોડની મુદત પૂરી થઈ ગઈ. નવો કોડ મોકલો.';

  @override
  String get login_error_too_many => 'ઘણા બધા પ્રયાસ થયા. થોડી વાર પછી ફરી પ્રયાસ કરો.';

  @override
  String get login_error_network => 'ઇન્ટરનેટ નથી. કનેક્શન તપાસીને ફરી પ્રયાસ કરો.';

  @override
  String get login_error_failed => 'કંઈક ખોટું થયું. ફરી પ્રયાસ કરો.';

  @override
  String get job_location_needed =>
      'ગ્રાહક તમને આવતા જોઈ શકતા નથી. લોકેશનની મંજૂરી આપો જેથી તેઓ તમને જોઈ શકે.';

  @override
  String get job_allow_location => 'લોકેશનની મંજૂરી આપો';

  @override
  String get job_gps_off => 'તમારા ફોનનું લોકેશન બંધ છે. તેને ચાલુ કરો જેથી ગ્રાહક તમને આવતા જોઈ શકે.';

  @override
  String get job_turn_on_location => 'લોકેશન ચાલુ કરો';

  @override
  String get job_eta_here => 'તમે પિકઅપ પર પહોંચી ગયા છો';
}
