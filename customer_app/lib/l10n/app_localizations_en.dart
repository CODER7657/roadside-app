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

  @override
  String get home_my_vehicles => 'My vehicles';

  @override
  String get vehicles_title => 'My vehicles';

  @override
  String get vehicles_add => 'Add vehicle';

  @override
  String get vehicles_empty_title => 'No vehicles yet';

  @override
  String get vehicles_empty_body => 'Add your vehicle once, and booking help takes one tap.';

  @override
  String get vehicles_default_label => 'Default';

  @override
  String get vehicles_delete => 'Delete';

  @override
  String get vehicles_removed => 'Vehicle removed';

  @override
  String get vehicles_undo => 'Undo';

  @override
  String get vehicle_add_step => 'New vehicle';

  @override
  String get vehicle_add_title => 'Your vehicle';

  @override
  String get vehicle_type_label => 'Type';

  @override
  String get vehicle_type_car => 'Car';

  @override
  String get vehicle_type_bike => 'Bike';

  @override
  String get vehicle_type_scooter => 'Scooter';

  @override
  String get vehicle_type_ev => 'EV';

  @override
  String get vehicle_brand_label => 'Brand';

  @override
  String get vehicle_brand_hint => 'e.g. Maruti Suzuki';

  @override
  String get vehicle_model_label => 'Model';

  @override
  String get vehicle_model_hint => 'e.g. Swift';

  @override
  String get vehicle_reg_label => 'Registration number';

  @override
  String get vehicle_reg_hint => 'GJ 01 AB 1234';

  @override
  String get vehicle_fuel_label => 'Fuel';

  @override
  String get fuel_petrol => 'Petrol';

  @override
  String get fuel_diesel => 'Diesel';

  @override
  String get fuel_cng => 'CNG';

  @override
  String get fuel_electric => 'Electric';

  @override
  String get vehicle_make_default => 'Make this my default';

  @override
  String get vehicle_save => 'Save vehicle';

  @override
  String get error_field_required => 'Please fill this in';

  @override
  String get error_field_too_long => 'That is too long';

  @override
  String get error_field_invalid => 'Please check this';

  @override
  String get error_reg_no_invalid => 'Check the number, e.g. GJ 01 AB 1234 or 22 BH 1234 AA';

  @override
  String get home_get_help => 'Get help';

  @override
  String booking_step(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get booking_next => 'Next';

  @override
  String get problem_title => 'What\'s wrong?';

  @override
  String get problem_vehicle_label => 'Vehicle';

  @override
  String get problem_no_vehicle_title => 'Add your vehicle first';

  @override
  String get problem_no_vehicle_body => 'The mechanic needs to know what they are fixing.';

  @override
  String get problem_add_vehicle => 'Add vehicle';

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
  String get photos_title => 'Photos and details';

  @override
  String get photos_body =>
      'Optional. Photos help the mechanic bring the right parts. We remove the location from every photo.';

  @override
  String get photos_take => 'Take photo';

  @override
  String get photos_gallery => 'Choose from gallery';

  @override
  String photos_count(int count, int max) {
    return '$count of $max photos';
  }

  @override
  String photos_remove(int n) {
    return 'Remove photo $n';
  }

  @override
  String photos_uploading(int n) {
    return 'Uploading photo $n';
  }

  @override
  String photos_retry(int n) {
    return 'Photo $n did not upload. Try again';
  }

  @override
  String get photos_error_limit => 'You can add up to 4 photos.';

  @override
  String get photos_error_too_large => 'That photo is too large. Try another one.';

  @override
  String get photos_error_failed => 'Couldn\'t add that photo. Try again.';

  @override
  String get photos_error_upload => 'Some photos did not upload. Retry them or remove them to continue.';

  @override
  String get description_label => 'What happened?';

  @override
  String get description_hint => 'For example: rear tyre went flat near the toll plaza';

  @override
  String get photos_skip => 'Skip';

  @override
  String photos_item(int n) {
    return 'Photo $n';
  }

  @override
  String get booking_back_home => 'Back to home';

  @override
  String get location_title => 'Where are you?';

  @override
  String get location_hint => 'Drag the map so the pin is on your vehicle.';

  @override
  String get location_no_permission =>
      'Location is off for this app. Drag the map to your spot, or allow location.';

  @override
  String get location_allow => 'Allow location';

  @override
  String get location_gps_off => 'Your phone\'s location is switched off.';

  @override
  String get location_turn_on => 'Turn on location';

  @override
  String get location_no_fix => 'We couldn\'t find you. Drag the map to your spot.';

  @override
  String get location_finding_address => 'Finding the address…';

  @override
  String get location_no_address => 'No street address here. The mechanic will use the Plus Code.';

  @override
  String location_plus_code(String code) {
    return 'Plus Code $code';
  }

  @override
  String get location_landmark_label => 'Landmark (optional)';

  @override
  String get location_landmark_hint => 'For example: opposite the petrol pump';

  @override
  String get location_far_warning => 'The pin is more than 2 km from where your phone is.';

  @override
  String get location_someone_else => 'I\'m booking for someone else';

  @override
  String get location_confirm => 'Confirm pickup';

  @override
  String get location_recenter => 'Go to my location';

  @override
  String get location_retry => 'Try again';

  @override
  String get price_title => 'Your estimate';

  @override
  String get price_book => 'Book mechanic';

  @override
  String get price_note =>
      'You pay the mechanic directly after the job, by UPI or cash. The amount can change if parts are needed.';

  @override
  String get price_error_out_of_area =>
      'We\'re not in this area yet. We serve Ahmedabad, Ankleshwar and Bharuch.';

  @override
  String get price_change_pickup => 'Change pickup';

  @override
  String get price_error_active_booking => 'You already have a booking in progress.';

  @override
  String get price_open_booking => 'Open my booking';

  @override
  String get price_error_paused =>
      'Bookings are paused for a short while. Please try again in a few minutes.';

  @override
  String get price_error_unavailable => 'We can\'t price this problem yet. Our support team can help.';

  @override
  String get price_get_support => 'Get support';

  @override
  String get price_error_vehicle => 'This vehicle was removed. Choose another one.';

  @override
  String get price_choose_vehicle => 'Choose vehicle';

  @override
  String get price_error_rate_limited => 'Too many tries. Please wait a few minutes and try again.';

  @override
  String get price_error_network => 'Couldn\'t book. Check your connection and try again.';

  @override
  String get searching_title => 'Booking sent';

  @override
  String get searching_body => 'We\'re finding the nearest mechanic.';
}
