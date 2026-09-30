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

  @override
  String get register_type_title => 'Join as a mechanic';

  @override
  String get register_about_title => 'About you';

  @override
  String get register_work_title => 'Your work';

  @override
  String get register_id_title => 'ID and payment';

  @override
  String get register_next => 'Next';

  @override
  String get register_submit => 'Send for approval';

  @override
  String get register_error_upload =>
      'A photo didn\'t upload. Check your connection and send again; photos already sent won\'t upload twice.';

  @override
  String get register_error_save => 'We couldn\'t save your details. Check your connection and send again.';

  @override
  String get register_type_question => 'Do you have a workshop?';

  @override
  String get register_type_workshop => 'Yes, I have a workshop';

  @override
  String get register_type_independent => 'No, I work independently';

  @override
  String get register_city_label => 'Your city';

  @override
  String get register_city_help => 'You get jobs in this city. Only our team can change it later.';

  @override
  String get city_ahmedabad => 'Ahmedabad';

  @override
  String get city_ankleshwar => 'Ankleshwar';

  @override
  String get city_bharuch => 'Bharuch';

  @override
  String get register_photo_source_title => 'Add a photo';

  @override
  String get register_photo_camera => 'Take a photo';

  @override
  String get register_photo_gallery => 'Choose from gallery';

  @override
  String get register_photo_too_large => 'That photo is too large. Try another one.';

  @override
  String get register_photo_add => 'Add photo';

  @override
  String get register_photo_remove => 'Remove photo';

  @override
  String get register_name_label => 'Your name';

  @override
  String get register_photo_profile => 'Your photo (customers see it)';

  @override
  String get register_shop_heading => 'Your shop';

  @override
  String get register_shop_name_label => 'Shop name';

  @override
  String get register_shop_address_label => 'Shop address';

  @override
  String get register_photo_shop => 'Shop photo';

  @override
  String get register_independent_heading => 'How you work';

  @override
  String get register_experience_label => 'Years of experience';

  @override
  String get register_base_area_label => 'Where you usually start from';

  @override
  String get register_base_area_hint => 'e.g. GIDC Ankleshwar';

  @override
  String get register_travel_heading => 'What you travel on';

  @override
  String get register_travel_reg_label => 'Its number plate';

  @override
  String get register_travel_reg_hint => 'e.g. GJ 16 CK 4471';

  @override
  String get register_toolkit_heading => 'Your tools';

  @override
  String get register_toolkit_help => 'Add at least 2 photos of the tools you carry.';

  @override
  String register_photo_toolkit(int number) {
    return 'Tools $number';
  }

  @override
  String get vehicle_type_car => 'Car';

  @override
  String get vehicle_type_bike => 'Bike';

  @override
  String get vehicle_type_scooter => 'Scooter';

  @override
  String get vehicle_type_ev => 'EV';

  @override
  String get register_vehicles_label => 'Vehicles you work on';

  @override
  String get register_services_label => 'What you can fix';

  @override
  String get problem_type_flat_tyre => 'Flat tyre';

  @override
  String get problem_type_battery => 'Battery';

  @override
  String get problem_type_wont_start => 'Won\'t start';

  @override
  String get problem_type_overheating => 'Overheating';

  @override
  String get problem_type_accident => 'Accident';

  @override
  String get problem_type_fuel => 'Out of fuel';

  @override
  String get problem_type_other => 'Something else';

  @override
  String get register_id_private => 'Only our verification team sees these. Customers never do.';

  @override
  String get register_photo_id_proof => 'ID proof';

  @override
  String get register_photo_selfie => 'Selfie holding your ID';

  @override
  String get register_photo_address_proof => 'Address proof';

  @override
  String get register_upi_heading => 'Where customers pay you';

  @override
  String get register_upi_id_label => 'UPI ID';

  @override
  String get register_upi_id_hint => 'e.g. name@bank';

  @override
  String get register_upi_name_label => 'Name on the UPI account';

  @override
  String get register_reference_heading => 'Someone who knows your work (optional)';

  @override
  String get register_reference_help => 'For example a workshop you trained at.';

  @override
  String get register_reference_name_label => 'Their name';

  @override
  String get register_reference_phone_label => 'Their phone';

  @override
  String get register_reference_phone_hint => '+91…';

  @override
  String get error_field_required => 'Please fill this in';

  @override
  String get error_field_too_long => 'That is too long';

  @override
  String get error_field_invalid => 'Please check this';

  @override
  String get error_reg_no_invalid => 'Check the number, e.g. GJ 01 AB 1234 or 22 BH 1234 AA';

  @override
  String get error_phone_invalid => 'Check the number, e.g. +91 98765 43210';

  @override
  String get error_upi_invalid => 'Check the UPI ID, e.g. name@bank';

  @override
  String get error_experience_invalid => 'Enter years as a number, 0 to 60';

  @override
  String get error_toolkit_photos_too_few => 'Add at least 2 photos of your tools';

  @override
  String get pending_title => 'We\'re checking your details';

  @override
  String get pending_body_workshop => 'Usually within 24 hours. We\'ll let you know.';

  @override
  String get pending_body_independent => 'We\'ll call you for a short verification, usually within 24 hours.';

  @override
  String get pending_blocked_title => 'Your account is on hold';

  @override
  String get pending_blocked_body => 'Please call support to find out more.';

  @override
  String get pending_item_shop => 'Shop details';

  @override
  String get pending_item_details => 'Your details and tools';

  @override
  String get pending_item_id => 'ID proof';

  @override
  String get pending_item_id_selfie => 'ID, selfie and address proof';

  @override
  String get pending_item_call => 'Verification call';

  @override
  String get pending_received => 'Received';

  @override
  String get pending_checking => 'Checking…';

  @override
  String get pending_call_waiting => 'We\'ll call you';

  @override
  String get dashboard_title => 'Today';

  @override
  String get dashboard_online => 'You\'re online';

  @override
  String get dashboard_online_body => 'We\'ll send you jobs nearby.';

  @override
  String get dashboard_finding_location => 'Finding your location…';

  @override
  String get dashboard_offline => 'You\'re offline';

  @override
  String get dashboard_offline_body =>
      'Go online to get jobs. We only use your location while you\'re online.';

  @override
  String get dashboard_gps_off => 'Your phone\'s location is switched off. Turn it on to go online.';

  @override
  String get dashboard_turn_on_location => 'Turn on location';

  @override
  String get dashboard_lost_connection =>
      'You went offline: we couldn\'t update your location for 2 minutes. Check your connection and go online again.';

  @override
  String get dashboard_jobs_today => 'Jobs today';

  @override
  String get dashboard_earned_today => 'Earned today';

  @override
  String get dashboard_recent_jobs => 'Recent jobs';

  @override
  String get dashboard_no_jobs_yet => 'No jobs yet today. Stay online and they\'ll come to you.';

  @override
  String get offer_title => 'New job';

  @override
  String get offer_distance => 'Distance';

  @override
  String offer_distance_value(String km) {
    return '$km km';
  }

  @override
  String get offer_area => 'Area';

  @override
  String get offer_slide_accept => 'Slide to accept';

  @override
  String get offer_decline => 'Decline';

  @override
  String get offer_failed => 'Couldn\'t reach us. Check your connection and slide again.';

  @override
  String get offer_expired_title => 'This job has timed out';

  @override
  String get offer_expired_body => 'Offers last 30 seconds. We\'ll send you the next one nearby.';

  @override
  String get offer_withdrawn_title => 'This job was taken back';

  @override
  String get offer_withdrawn_body => 'The customer cancelled or no longer needs help.';

  @override
  String get offer_taken_title => 'This job is no longer available';

  @override
  String get offer_taken_body => 'It went to another mechanic. Stay online for the next one.';

  @override
  String get offer_not_available_title => 'You can\'t take this job right now';

  @override
  String get offer_not_available_body => 'You\'re offline or already on a job.';

  @override
  String get offer_profile_incomplete_title => 'Finish your profile first';

  @override
  String get offer_profile_incomplete_body => 'Some details are missing. Complete your profile to take jobs.';

  @override
  String get offer_not_approved_title => 'You\'re not approved yet';

  @override
  String get offer_not_approved_body =>
      'We\'re still checking your documents. You can take jobs once you\'re approved.';

  @override
  String get offer_back => 'Back to dashboard';

  @override
  String get offer_notification_title => 'New job nearby';

  @override
  String get offer_notification_body => 'Open within 30 seconds to accept.';

  @override
  String get stop_requested => 'Requested';

  @override
  String get stop_accepted => 'Accepted';

  @override
  String get stop_on_the_way => 'On the way';

  @override
  String get stop_arrived => 'Arrived';

  @override
  String get stop_working => 'Working';

  @override
  String get stop_done => 'Done';

  @override
  String get job_headline_accepted => 'Start the trip when you set off';

  @override
  String get job_headline_arriving => 'On your way to the customer';

  @override
  String get job_headline_arrived => 'You\'re at the customer';

  @override
  String get job_headline_working => 'Job in progress';

  @override
  String job_eta(int minutes) {
    return 'About $minutes min away';
  }

  @override
  String get job_start_trip => 'Start trip';

  @override
  String get job_arrived => 'I\'ve arrived';

  @override
  String get job_ask_start_code => 'Ask the customer for their 4-digit start code to begin.';

  @override
  String get job_open_in_maps => 'Open in Maps';

  @override
  String get job_call => 'Call';

  @override
  String get job_error_not_at_pickup => 'You\'re not at the pickup yet. Get within 100 m and try again.';

  @override
  String get job_error_location =>
      'We can\'t see your location right now. Keep the app open with GPS on, then try again.';

  @override
  String get job_error_failed => 'Couldn\'t reach us. Check your connection and try again.';

  @override
  String get job_tracking_title => 'Sharing your location';

  @override
  String get job_tracking_text => 'With your customer, only while you\'re on this job.';

  @override
  String get job_cancelled_title => 'This job was cancelled';

  @override
  String get job_cancelled_body => 'You\'re free for the next one.';

  @override
  String get job_done_title => 'Job done';

  @override
  String get job_done_body => 'Nice work.';

  @override
  String get job_missing_title => 'We can\'t find this job';

  @override
  String get job_missing_body => 'It may have been cancelled.';

  @override
  String get login_phone_title => 'Your mobile number';

  @override
  String get login_country_code => '+91';

  @override
  String get login_phone_label => 'Mobile number';

  @override
  String get login_phone_hint => '98765 43210';

  @override
  String get login_phone_helper => 'We\'ll send a 6-digit code by SMS.';

  @override
  String get login_send_code => 'Send code';

  @override
  String get login_code_title => 'Enter the code';

  @override
  String login_code_sent_to(String phone) {
    return 'Sent to $phone';
  }

  @override
  String get login_change_number => 'Change number';

  @override
  String login_resend_in(String time) {
    return 'Resend in $time';
  }

  @override
  String get login_resend => 'Resend code';

  @override
  String get login_verify => 'Verify';

  @override
  String get login_error_invalid_number => 'Enter a 10-digit Indian mobile number.';

  @override
  String get login_error_invalid_code => 'That code isn\'t right. Check the SMS and try again.';

  @override
  String get login_error_code_expired => 'This code has expired. Send a new one.';

  @override
  String get login_error_too_many => 'Too many tries. Wait a while, then try again.';

  @override
  String get login_error_network => 'No connection. Check your internet and try again.';

  @override
  String get login_error_failed => 'Something went wrong. Try again.';

  @override
  String get job_location_needed =>
      'The customer can\'t see you coming. Allow location so they can follow you.';

  @override
  String get job_allow_location => 'Allow location';

  @override
  String get job_gps_off =>
      'Your phone\'s location is switched off. Turn it on so the customer can see you coming.';

  @override
  String get job_turn_on_location => 'Turn on location';

  @override
  String get job_eta_here => 'You\'re at the pickup';
}
