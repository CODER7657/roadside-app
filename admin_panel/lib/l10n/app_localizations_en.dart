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
}
