// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Roadside';

  @override
  String get home_placeholder_title => 'Help on the road, in minutes';

  @override
  String get home_placeholder_body =>
      'We\'re getting everything ready. Booking a mechanic arrives in the next update.';

  @override
  String flow_step_label(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get splash_tagline => 'Help on the road, in minutes';

  @override
  String get splash_loading => 'Getting things ready';

  @override
  String get language_title => 'Choose your language';

  @override
  String get language_body => 'You can change it later in Settings.';

  @override
  String get language_continue => 'Continue';

  @override
  String get onboarding_slide1_title => 'Help in minutes';

  @override
  String get onboarding_slide1_body => 'Tell us what\'s wrong. The nearest verified mechanic comes to you.';

  @override
  String get onboarding_slide2_title => 'Track them live';

  @override
  String get onboarding_slide2_body => 'See your mechanic on the map, with a live arrival time.';

  @override
  String get onboarding_slide3_title => 'Safe and verified';

  @override
  String get onboarding_slide3_body =>
      'Every mechanic is ID-checked. Share your trip with family in one tap.';

  @override
  String get onboarding_next => 'Next';

  @override
  String get onboarding_skip => 'Skip';

  @override
  String get onboarding_start => 'Get started';

  @override
  String get consent_title => 'Your privacy';

  @override
  String get consent_intro => 'We only collect what we need to send you help.';

  @override
  String get consent_point_collect => 'Your phone number, name, vehicles and any photos you add.';

  @override
  String get consent_point_location => 'Your location, only while you book and while help is on the way.';

  @override
  String get consent_point_delete => 'You can see, correct or delete your data at any time.';

  @override
  String get consent_age => 'I am 18 or older';

  @override
  String get consent_notice => 'I agree to the privacy notice';

  @override
  String get consent_agree => 'Agree and continue';

  @override
  String get consent_read_notice => 'Read the full notice';

  @override
  String get privacy_title => 'Privacy notice';

  @override
  String get privacy_collect_title => 'What we collect';

  @override
  String get privacy_collect_body =>
      'Your phone number, name and language, the vehicles you add, photos you attach to a booking, and your location while you book or a mechanic is on the way.';

  @override
  String get privacy_use_title => 'Why we use it';

  @override
  String get privacy_use_body =>
      'Only to find you a mechanic, show them where you are and keep both of you safe. We don\'t show ads or sell your data.';

  @override
  String get privacy_keep_title => 'How long we keep it';

  @override
  String get privacy_keep_body =>
      'Live location: 24 hours after the job. Chat: 90 days. Booking records: 3 years for tax, anonymised if you delete your account.';

  @override
  String get privacy_rights_title => 'Your rights';

  @override
  String get privacy_rights_body =>
      'See and correct your details in the app, withdraw your consent, or delete your account from Settings.';

  @override
  String get privacy_contact_title => 'Questions or complaints';

  @override
  String get privacy_contact_body => 'Contact our grievance officer from Help & FAQ.';

  @override
  String get home_help => 'Help & FAQ';

  @override
  String get permission_location_title => 'Allow location';

  @override
  String get permission_location_body =>
      'So the mechanic can find you. We only use your location while you book and while help is on the way.';

  @override
  String get permission_camera_title => 'Allow camera';

  @override
  String get permission_camera_body =>
      'To add photos of the problem. Only the photos you choose are shared with your mechanic.';

  @override
  String get permission_notifications_title => 'Allow notifications';

  @override
  String get permission_notifications_body =>
      'So we can tell you when a mechanic accepts, is on the way and arrives.';

  @override
  String get permission_blocked_body =>
      'It\'s turned off in your phone\'s settings. Open Settings, tap Permissions and allow it.';

  @override
  String get permission_allow => 'Allow';

  @override
  String get permission_open_settings => 'Open settings';

  @override
  String get permission_not_now => 'Not now';

  @override
  String get help_title => 'Help';

  @override
  String get help_search_label => 'Search questions';

  @override
  String get help_search_hint => 'e.g. price, start code';

  @override
  String get help_no_results_title => 'No matching questions';

  @override
  String get help_no_results_body => 'Try other words, or call us.';

  @override
  String get help_call_support => 'Call support';

  @override
  String get help_whatsapp => 'WhatsApp';

  @override
  String get help_grievance_title => 'Grievance officer';

  @override
  String get help_grievance_body =>
      'For complaints about your data or privacy, write to our grievance officer. We reply within 7 days.';

  @override
  String get help_faq_price_q => 'How much will it cost?';

  @override
  String get help_faq_price_a =>
      'You see a price range before you book. The mechanic sets the final amount in the app after the job, and you pay them directly by UPI.';

  @override
  String get help_faq_verified_q => 'Are the mechanics verified?';

  @override
  String get help_faq_verified_a =>
      'Yes. We check every mechanic\'s ID before they get jobs. Mechanics without a workshop also do a verification call.';

  @override
  String get help_faq_code_q => 'What is the start code?';

  @override
  String get help_faq_code_a =>
      'A 4-digit code in your app. Share it only when the mechanic is standing with you; the job starts when they enter it.';

  @override
  String get help_faq_pay_q => 'How do I pay?';

  @override
  String get help_faq_pay_a =>
      'By UPI, straight to the mechanic: open your UPI app from ours or scan the QR, then tap \"I have paid\". We never ask for card or bank details.';

  @override
  String get help_faq_cancel_q => 'Can I cancel?';

  @override
  String get help_faq_cancel_a =>
      'Yes, any time before the job starts. Tell us why in one tap so we can improve.';

  @override
  String get help_faq_area_q => 'Where does it work?';

  @override
  String get help_faq_area_a =>
      'Ahmedabad, Ankleshwar and Bharuch for now, including highway stretches nearby. More cities are coming.';
}
