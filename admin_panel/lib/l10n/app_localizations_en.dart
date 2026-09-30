// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Roadside Console';

  @override
  String get signin_title => 'Roadside console';

  @override
  String get signin_body => 'For Roadside admins only. Sign in with your approved Google account.';

  @override
  String get signin_google_button => 'Sign in with Google';

  @override
  String get signin_checking_title => 'Checking your access';

  @override
  String get signin_error_message => 'Sign-in didn\'t work. Try again.';

  @override
  String get signin_not_authorised_title => 'Not authorised';

  @override
  String signin_not_authorised_body(String account) {
    return '$account isn\'t an admin account, so we signed it out. Ask the Roadside team if you need access.';
  }

  @override
  String get signin_not_authorised_retry => 'Use another account';

  @override
  String get signin_unknown_account => 'This account';

  @override
  String get signin_unconfigured_title => 'Console not connected';

  @override
  String get signin_unconfigured_body =>
      'This build isn\'t linked to a Firebase project yet. Build it with the env file for dev or prod.';

  @override
  String get console_nav_dashboard => 'Dashboard';

  @override
  String get console_nav_approvals => 'Approvals';

  @override
  String get console_nav_live => 'Live bookings';

  @override
  String get console_nav_prices => 'Prices';

  @override
  String get console_nav_complaints => 'Complaints & reviews';

  @override
  String get console_nav_settings => 'Settings';

  @override
  String get console_filter_label => 'City';

  @override
  String get console_city_all => 'All cities';

  @override
  String get console_city_ahmedabad => 'Ahmedabad';

  @override
  String get console_city_ankleshwar => 'Ankleshwar';

  @override
  String get console_city_bharuch => 'Bharuch';

  @override
  String get console_sign_out => 'Sign out';

  @override
  String get console_section_coming_title => 'Coming next';

  @override
  String console_section_coming_body(String issue) {
    return 'This screen arrives with issue #$issue.';
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
  String get prices_scope_default => 'Default prices, all cities';

  @override
  String get prices_scope_default_help => 'Customers see these ranges unless their city has its own.';

  @override
  String prices_scope_city(String city) {
    return '$city prices';
  }

  @override
  String get prices_scope_city_help =>
      'Only for this city. Leave a cell blank to use the default shown in grey.';

  @override
  String get prices_column_problem => 'Problem';

  @override
  String prices_min_label(String vehicle, String problem) {
    return '$vehicle, $problem: minimum';
  }

  @override
  String prices_max_label(String vehicle, String problem) {
    return '$vehicle, $problem: maximum';
  }

  @override
  String prices_unsaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unsaved changes',
      one: '1 unsaved change',
      zero: 'No unsaved changes',
    );
    return '$_temp0';
  }

  @override
  String get prices_discard => 'Discard';

  @override
  String get prices_save => 'Save changes';

  @override
  String get prices_saved_toast => 'Prices saved. New bookings use them now.';

  @override
  String get prices_save_failed => 'Couldn\'t save. Nothing was changed. Try again.';

  @override
  String get prices_missing_default => 'Set the price for All cities first, then the city\'s own.';

  @override
  String get prices_load_failed => 'Couldn\'t load the prices.';

  @override
  String get prices_error_required => 'Enter both amounts';

  @override
  String get prices_error_number => 'Whole rupees only';

  @override
  String get prices_error_range => 'Between ₹1 and ₹1,00,000';

  @override
  String get prices_error_order => 'Minimum must be less than maximum';

  @override
  String get mechanic_status_pending => 'Pending';

  @override
  String get mechanic_status_approved => 'Approved';

  @override
  String get mechanic_status_blocked => 'Blocked';

  @override
  String get mechanic_type_workshop => 'Workshop';

  @override
  String get mechanic_type_independent => 'Independent';

  @override
  String get approvals_type_all => 'All types';

  @override
  String get approvals_search_label => 'Search';

  @override
  String get approvals_search_hint => 'Mechanic name';

  @override
  String approvals_empty(String status) {
    return 'Nothing here: no mechanics with status $status.';
  }

  @override
  String get approvals_load_failed => 'Couldn\'t load mechanics.';

  @override
  String approvals_experience(int years) {
    String _temp0 = intl.Intl.pluralLogic(years, locale: localeName, other: '$years years', one: '1 year');
    return '$_temp0';
  }

  @override
  String approvals_registered(String date) {
    return 'registered $date';
  }

  @override
  String get approvals_base_area => 'Base area';

  @override
  String approvals_travel_vehicle(String vehicle) {
    return 'Travel vehicle ($vehicle)';
  }

  @override
  String get approvals_shop_name => 'Shop';

  @override
  String get approvals_shop_address => 'Address';

  @override
  String get approvals_services => 'Services';

  @override
  String get approvals_vehicle_types => 'Vehicles';

  @override
  String get approvals_photos => 'Photos';

  @override
  String get approvals_photo_profile => 'Profile photo';

  @override
  String get approvals_photo_shop => 'Shop photo';

  @override
  String approvals_photo_toolkit(int n) {
    return 'Toolkit photo $n';
  }

  @override
  String get approvals_kyc => 'Identity and payment';

  @override
  String get approvals_kyc_missing => 'KYC not submitted yet.';

  @override
  String get approvals_upi => 'UPI';

  @override
  String get approvals_phone => 'Phone';

  @override
  String get approvals_reference => 'Reference';

  @override
  String get approvals_document_id => 'Open ID proof';

  @override
  String get approvals_document_selfie => 'Open selfie with ID';

  @override
  String get approvals_document_address => 'Open address proof';

  @override
  String get approvals_documents_note =>
      'Documents open in a new tab through a link that expires in minutes. Don\'t download them.';

  @override
  String get approvals_document_missing => 'That document isn\'t available.';

  @override
  String get approvals_checklist => 'Checklist';

  @override
  String get approvals_check_shop_photo => 'Shop photo shows a real workshop';

  @override
  String get approvals_check_id_proof => 'ID proof matches the name';

  @override
  String get approvals_check_services => 'Services and vehicles make sense';

  @override
  String get approvals_check_selfie => 'Selfie matches the ID';

  @override
  String get approvals_check_address => 'Address proof checked';

  @override
  String get approvals_check_toolkit => 'Toolkit photos show real tools';

  @override
  String get approvals_call_notes_label => 'Verification call notes';

  @override
  String get approvals_call_notes_hint => 'Video call, ID matched, 6 years at Patel Motors confirmed.';

  @override
  String get approvals_call_log => 'Log verification call';

  @override
  String get approvals_call_logged => 'Verification call logged.';

  @override
  String approvals_call_done(String date, String notes) {
    return 'Call logged $date: $notes';
  }

  @override
  String get approvals_approve => 'Approve';

  @override
  String get approvals_approved => 'Approved. They can go online now.';

  @override
  String get approvals_block => 'Block';

  @override
  String get approvals_block_reason_label => 'Why are you blocking them?';

  @override
  String get approvals_block_reason_hint => 'For example: ID proof doesn\'t match';

  @override
  String get approvals_block_confirm => 'Block mechanic';

  @override
  String get approvals_block_cancel => 'Cancel';

  @override
  String get approvals_blocked => 'Blocked. They\'re signed out everywhere.';

  @override
  String get approvals_blocked_note => 'This mechanic is blocked and can\'t receive jobs.';

  @override
  String get approvals_audit_note => 'Every approval, block and call is recorded in the audit log.';

  @override
  String get approvals_why_kyc => 'Approve needs the KYC documents first.';

  @override
  String get approvals_why_checklist => 'Tick every checklist item to approve.';

  @override
  String get approvals_why_call => 'Log the verification call to approve an independent mechanic.';

  @override
  String get approvals_error_unavailable => 'That action isn\'t available yet. Try again later.';

  @override
  String get approvals_error_precondition =>
      'The server refused: check the mechanic\'s status and the verification call.';

  @override
  String get approvals_error_not_allowed => 'Your admin access has changed. Sign in again.';

  @override
  String get approvals_error_unknown => 'Something went wrong. Nothing was changed.';

  @override
  String get booking_status_requested => 'Searching';

  @override
  String get booking_status_accepted => 'Accepted';

  @override
  String get booking_status_arriving => 'On the way';

  @override
  String get booking_status_arrived => 'Arrived';

  @override
  String get booking_status_in_progress => 'Working';

  @override
  String get booking_status_completed => 'Done';

  @override
  String get booking_status_cancelled => 'Cancelled';

  @override
  String get booking_status_no_mechanic => 'No mechanic';

  @override
  String dashboard_today(String date) {
    return 'Today, $date';
  }

  @override
  String get dashboard_previous_day => 'Previous day';

  @override
  String get dashboard_next_day => 'Next day';

  @override
  String get dashboard_load_failed => 'Couldn\'t load the dashboard.';

  @override
  String get dashboard_stat_bookings => 'Bookings';

  @override
  String get dashboard_stat_active_mechanics => 'Mechanics online';

  @override
  String get dashboard_stat_active_mechanics_note => 'Right now';

  @override
  String get dashboard_stat_completion => 'Completion';

  @override
  String get dashboard_stat_median_arrival => 'Median arrival';

  @override
  String get dashboard_stat_median_arrival_note => 'Accepted to arrived';

  @override
  String dashboard_minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get dashboard_stat_sms => 'SMS success';

  @override
  String get dashboard_stat_sms_note => 'From monitoring (#62)';

  @override
  String get dashboard_bookings_title => 'Bookings this day';

  @override
  String get dashboard_bookings_empty => 'No bookings this day.';

  @override
  String get dashboard_column_booking => 'Booking';

  @override
  String get dashboard_column_customer => 'Customer';

  @override
  String get dashboard_column_mechanic => 'Mechanic';

  @override
  String get dashboard_column_status => 'Status';

  @override
  String get dashboard_column_amount => 'Amount';

  @override
  String get live_load_failed => 'Couldn\'t load live bookings.';

  @override
  String get live_empty => 'No active bookings right now.';

  @override
  String get live_status_all => 'All active';

  @override
  String get live_vehicle_all => 'All vehicles';

  @override
  String live_map_label(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Map with $count active bookings',
      one: 'Map with 1 active booking',
      zero: 'Map with no active bookings',
    );
    return '$_temp0';
  }

  @override
  String live_customer(String details) {
    return 'Customer: $details';
  }

  @override
  String live_mechanic(String details) {
    return 'Mechanic: $details';
  }

  @override
  String live_searching(int km) {
    return 'Searching within $km km';
  }

  @override
  String get live_cancel => 'Cancel as admin';

  @override
  String get live_cancel_reason_label => 'Why are you cancelling?';

  @override
  String get live_cancel_reason_hint => 'For example: customer asked by phone';

  @override
  String get live_cancel_confirm => 'Cancel booking';

  @override
  String get live_cancel_note =>
      'Customer and mechanic are notified. The cancel is recorded with your account.';

  @override
  String get live_cancelled => 'Booking cancelled.';

  @override
  String get live_cancel_refused => 'This booking can\'t be cancelled any more.';
}
