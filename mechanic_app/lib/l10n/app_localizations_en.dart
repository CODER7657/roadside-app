// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Roadside Mechanic';

  @override
  String get home_placeholder_title => 'Jobs near you, when you\'re ready';

  @override
  String get home_placeholder_body =>
      'We\'re getting everything ready. Registration and going online arrive in the next update.';

  @override
  String flow_step_label(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get splash_tagline => 'Jobs near you, paid straight to you';

  @override
  String get splash_loading => 'Getting things ready';

  @override
  String get language_title => 'Choose your language';

  @override
  String get language_body => 'You can change it later in Settings.';

  @override
  String get language_continue => 'Continue';

  @override
  String get onboarding_slide1_title => 'Jobs near you';

  @override
  String get onboarding_slide1_body =>
      'Go online and we send you breakdowns close by. Slide to accept the ones you want.';

  @override
  String get onboarding_slide2_title => 'Reach them, start with their code';

  @override
  String get onboarding_slide2_body =>
      'Navigate to the customer. When you arrive, they read you a start code to begin the job.';

  @override
  String get onboarding_slide3_title => 'Paid straight to your UPI';

  @override
  String get onboarding_slide3_body => 'Customers pay you directly. The app never holds your money.';

  @override
  String get onboarding_next => 'Next';

  @override
  String get onboarding_skip => 'Skip';

  @override
  String get onboarding_start => 'Get started';

  @override
  String get consent_title => 'Your privacy';

  @override
  String get consent_intro => 'We only collect what we need to send you jobs and keep customers safe.';

  @override
  String get consent_point_collect =>
      'Your phone number, name, photos, ID documents for verification and your UPI details.';

  @override
  String get consent_point_location =>
      'Your location, only while you\'re online or on a job. Never when you\'re offline.';

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
      'Your phone number, name and language; your profile and shop or toolkit photos; your ID proof (and, if you work without a shop, a selfie with it and an address proof) to verify you; your UPI ID and name; and your location while you\'re online or on a job.';

  @override
  String get privacy_use_title => 'Why we use it';

  @override
  String get privacy_use_body =>
      'To verify you, send you nearby jobs, show customers who is coming and where you are on the way, and let them pay you. We don\'t show ads or sell your data.';

  @override
  String get privacy_keep_title => 'How long we keep it';

  @override
  String get privacy_keep_body =>
      'Your online location is replaced as you move and cleared when you go offline. Live location during a job: 24 hours after it ends. Chat: 90 days. ID documents: until 180 days after you leave. Job records: 3 years for tax.';

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
      'So we can send you jobs nearby and show customers you\'re on the way. Only while you\'re online or on a job; during a job a notification shows it\'s on.';

  @override
  String get permission_camera_title => 'Allow camera';

  @override
  String get permission_camera_body =>
      'To add your profile, shop or toolkit photos, your ID documents, and before and after photos of each job.';

  @override
  String get permission_notifications_title => 'Allow notifications';

  @override
  String get permission_notifications_body =>
      'So you hear new job offers straight away, and get updates on your jobs even when the app is closed.';

  @override
  String get permission_full_screen_title => 'Show job offers on the lock screen';

  @override
  String get permission_full_screen_body =>
      'A new job fills the screen like an incoming call, so you never miss one. On the next screen, turn on full-screen notifications for this app.';

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
  String get help_search_hint => 'e.g. offers, start code, payment';

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
  String get help_faq_jobs_q => 'How do I get jobs?';

  @override
  String get help_faq_jobs_a =>
      'Once you\'re approved, go online on the home screen. Nearby breakdowns come to you as offers; slide to accept within 30 seconds.';

  @override
  String get help_faq_no_offers_q => 'Why am I not getting offers?';

  @override
  String get help_faq_no_offers_a =>
      'Check that you\'re online, approved, and in your city, and that your vehicle types and services are set. Keep the app open with location on; offers only go to mechanics close by.';

  @override
  String get help_faq_verify_q => 'How does verification work?';

  @override
  String get help_faq_verify_a =>
      'We check your ID and photos before you get jobs. If you work without a workshop, we also call you for a short verification.';

  @override
  String get help_faq_code_q => 'What is the start code?';

  @override
  String get help_faq_code_a =>
      'When you arrive, the customer reads you a 4-digit code. Enter it to start the job. After 5 wrong tries it locks for 10 minutes.';

  @override
  String get help_faq_pay_q => 'How do I get paid?';

  @override
  String get help_faq_pay_a =>
      'The customer pays you directly by UPI. Check your UPI app, then tap Confirm. If the money hasn\'t arrived, tap Not received and we\'ll look into it.';

  @override
  String get help_faq_cancel_q => 'Can I cancel a job?';

  @override
  String get help_faq_cancel_a =>
      'Yes, but it counts against your reliability. Before you arrive, the job goes to another mechanic; after you arrive, tell us why.';
}
