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
}
