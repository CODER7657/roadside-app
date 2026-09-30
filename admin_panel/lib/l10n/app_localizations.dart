import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('gu'), Locale('hi')];

  /// Browser tab title of the admin panel.
  ///
  /// In en, this message translates to:
  /// **'Roadside Console'**
  String get app_title;

  /// A0: title on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Roadside console'**
  String get signin_title;

  /// A0: who can sign in.
  ///
  /// In en, this message translates to:
  /// **'For Roadside admins only. Sign in with your approved Google account.'**
  String get signin_body;

  /// A0: primary button.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signin_google_button;

  /// A0: while Google sign-in and the admin check run.
  ///
  /// In en, this message translates to:
  /// **'Checking your access'**
  String get signin_checking_title;

  /// A0: the Google popup failed or was closed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in didn\'t work. Try again.'**
  String get signin_error_message;

  /// A0: a signed-in account without the admin role.
  ///
  /// In en, this message translates to:
  /// **'Not authorised'**
  String get signin_not_authorised_title;

  /// A0: explains the sign-out. {account} is the Google email.
  ///
  /// In en, this message translates to:
  /// **'{account} isn\'t an admin account, so we signed it out. Ask the Roadside team if you need access.'**
  String signin_not_authorised_body(String account);

  /// A0: signs in again with a different Google account.
  ///
  /// In en, this message translates to:
  /// **'Use another account'**
  String get signin_not_authorised_retry;

  /// A0: stands in for the email when Google didn't give one.
  ///
  /// In en, this message translates to:
  /// **'This account'**
  String get signin_unknown_account;

  /// A0: this build has no Firebase project.
  ///
  /// In en, this message translates to:
  /// **'Console not connected'**
  String get signin_unconfigured_title;

  /// A0: for developers; shown only in a misconfigured build.
  ///
  /// In en, this message translates to:
  /// **'This build isn\'t linked to a Firebase project yet. Build it with the env file for dev or prod.'**
  String get signin_unconfigured_body;

  /// Rail: A1.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get console_nav_dashboard;

  /// Rail: A2 mechanic approvals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get console_nav_approvals;

  /// Rail: A3 live map and list.
  ///
  /// In en, this message translates to:
  /// **'Live bookings'**
  String get console_nav_live;

  /// Rail: A4 price chart.
  ///
  /// In en, this message translates to:
  /// **'Prices'**
  String get console_nav_prices;

  /// Rail: A5.
  ///
  /// In en, this message translates to:
  /// **'Complaints & reviews'**
  String get console_nav_complaints;

  /// Rail: A6.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get console_nav_settings;

  /// Accessibility label of the city filter chips.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get console_filter_label;

  /// City filter: no filter.
  ///
  /// In en, this message translates to:
  /// **'All cities'**
  String get console_city_all;

  /// City filter chip.
  ///
  /// In en, this message translates to:
  /// **'Ahmedabad'**
  String get console_city_ahmedabad;

  /// City filter chip.
  ///
  /// In en, this message translates to:
  /// **'Ankleshwar'**
  String get console_city_ankleshwar;

  /// City filter chip.
  ///
  /// In en, this message translates to:
  /// **'Bharuch'**
  String get console_city_bharuch;

  /// Top bar: signs the admin out.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get console_sign_out;

  /// Placeholder for a screen not built yet.
  ///
  /// In en, this message translates to:
  /// **'Coming next'**
  String get console_section_coming_title;

  /// Placeholder body. {issue} is a GitHub issue number.
  ///
  /// In en, this message translates to:
  /// **'This screen arrives with issue #{issue}.'**
  String console_section_coming_body(String issue);

  /// Vehicle type.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get vehicle_type_car;

  /// Vehicle type (motorcycle).
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get vehicle_type_bike;

  /// Vehicle type.
  ///
  /// In en, this message translates to:
  /// **'Scooter'**
  String get vehicle_type_scooter;

  /// Vehicle type (electric vehicle).
  ///
  /// In en, this message translates to:
  /// **'EV'**
  String get vehicle_type_ev;

  /// Problem type flat_tyre.
  ///
  /// In en, this message translates to:
  /// **'Flat tyre'**
  String get problem_type_flat_tyre;

  /// Problem type battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get problem_type_battery;

  /// Problem type wont_start.
  ///
  /// In en, this message translates to:
  /// **'Won\'t start'**
  String get problem_type_wont_start;

  /// Problem type overheating.
  ///
  /// In en, this message translates to:
  /// **'Overheating'**
  String get problem_type_overheating;

  /// Problem type accident.
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get problem_type_accident;

  /// Problem type fuel.
  ///
  /// In en, this message translates to:
  /// **'Out of fuel'**
  String get problem_type_fuel;

  /// Problem type other.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get problem_type_other;

  /// A4: heading when the city filter is All.
  ///
  /// In en, this message translates to:
  /// **'Default prices, all cities'**
  String get prices_scope_default;

  /// A4: under the default heading.
  ///
  /// In en, this message translates to:
  /// **'Customers see these ranges unless their city has its own.'**
  String get prices_scope_default_help;

  /// A4: heading when a city is picked. {city} is the city name.
  ///
  /// In en, this message translates to:
  /// **'{city} prices'**
  String prices_scope_city(String city);

  /// A4: under the city heading.
  ///
  /// In en, this message translates to:
  /// **'Only for this city. Leave a cell blank to use the default shown in grey.'**
  String get prices_scope_city_help;

  /// A4: first column header.
  ///
  /// In en, this message translates to:
  /// **'Problem'**
  String get prices_column_problem;

  /// A4: screen-reader label of a min field.
  ///
  /// In en, this message translates to:
  /// **'{vehicle}, {problem}: minimum'**
  String prices_min_label(String vehicle, String problem);

  /// A4: screen-reader label of a max field.
  ///
  /// In en, this message translates to:
  /// **'{vehicle}, {problem}: maximum'**
  String prices_max_label(String vehicle, String problem);

  /// A4: count of edited cells.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No unsaved changes} =1{1 unsaved change} other{{count} unsaved changes}}'**
  String prices_unsaved(int count);

  /// A4: drops unsaved edits.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get prices_discard;

  /// A4: saves all edits at once.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get prices_save;

  /// A4: after a successful save.
  ///
  /// In en, this message translates to:
  /// **'Prices saved. New bookings use them now.'**
  String get prices_saved_toast;

  /// A4: the save failed as a whole.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Nothing was changed. Try again.'**
  String get prices_save_failed;

  /// A4: a city override for a price that has no default yet.
  ///
  /// In en, this message translates to:
  /// **'Set the price for All cities first, then the city\'s own.'**
  String get prices_missing_default;

  /// A4: loading failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the prices.'**
  String get prices_load_failed;

  /// A4 cell error.
  ///
  /// In en, this message translates to:
  /// **'Enter both amounts'**
  String get prices_error_required;

  /// A4 cell error.
  ///
  /// In en, this message translates to:
  /// **'Whole rupees only'**
  String get prices_error_number;

  /// A4 cell error.
  ///
  /// In en, this message translates to:
  /// **'Between ₹1 and ₹1,00,000'**
  String get prices_error_range;

  /// A4 cell error.
  ///
  /// In en, this message translates to:
  /// **'Minimum must be less than maximum'**
  String get prices_error_order;

  /// Mechanic status.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get mechanic_status_pending;

  /// Mechanic status.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get mechanic_status_approved;

  /// Mechanic status.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get mechanic_status_blocked;

  /// Mechanic type (PLAN §10.0).
  ///
  /// In en, this message translates to:
  /// **'Workshop'**
  String get mechanic_type_workshop;

  /// Mechanic type (PLAN §10.0).
  ///
  /// In en, this message translates to:
  /// **'Independent'**
  String get mechanic_type_independent;

  /// A2 type filter.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get approvals_type_all;

  /// A2 search field label.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get approvals_search_label;

  /// A2 search hint.
  ///
  /// In en, this message translates to:
  /// **'Mechanic name'**
  String get approvals_search_hint;

  /// A2 empty list. {status} is a status name.
  ///
  /// In en, this message translates to:
  /// **'Nothing here: no mechanics with status {status}.'**
  String approvals_empty(String status);

  /// A2 load error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load mechanics.'**
  String get approvals_load_failed;

  /// Independent mechanic's experience.
  ///
  /// In en, this message translates to:
  /// **'{years, plural, =1{1 year} other{{years} years}}'**
  String approvals_experience(int years);

  /// A2: when the mechanic registered.
  ///
  /// In en, this message translates to:
  /// **'registered {date}'**
  String approvals_registered(String date);

  /// Independent: where they start from.
  ///
  /// In en, this message translates to:
  /// **'Base area'**
  String get approvals_base_area;

  /// Independent: vehicle they arrive on.
  ///
  /// In en, this message translates to:
  /// **'Travel vehicle ({vehicle})'**
  String approvals_travel_vehicle(String vehicle);

  /// Workshop name.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get approvals_shop_name;

  /// Workshop address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get approvals_shop_address;

  /// Problem types they fix.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get approvals_services;

  /// Vehicle types they work on.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get approvals_vehicle_types;

  /// A2 section title.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get approvals_photos;

  /// Photo label.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get approvals_photo_profile;

  /// Photo label.
  ///
  /// In en, this message translates to:
  /// **'Shop photo'**
  String get approvals_photo_shop;

  /// Photo label.
  ///
  /// In en, this message translates to:
  /// **'Toolkit photo {n}'**
  String approvals_photo_toolkit(int n);

  /// A2 KYC section title.
  ///
  /// In en, this message translates to:
  /// **'Identity and payment'**
  String get approvals_kyc;

  /// A2: no KYC document.
  ///
  /// In en, this message translates to:
  /// **'KYC not submitted yet.'**
  String get approvals_kyc_missing;

  /// KYC field.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get approvals_upi;

  /// KYC field.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get approvals_phone;

  /// Independent: optional reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get approvals_reference;

  /// Opens a signed URL.
  ///
  /// In en, this message translates to:
  /// **'Open ID proof'**
  String get approvals_document_id;

  /// Opens a signed URL.
  ///
  /// In en, this message translates to:
  /// **'Open selfie with ID'**
  String get approvals_document_selfie;

  /// Opens a signed URL.
  ///
  /// In en, this message translates to:
  /// **'Open address proof'**
  String get approvals_document_address;

  /// A2 KYC note (PLAN §12.11).
  ///
  /// In en, this message translates to:
  /// **'Documents open in a new tab through a link that expires in minutes. Don\'t download them.'**
  String get approvals_documents_note;

  /// A2: no signed URL returned.
  ///
  /// In en, this message translates to:
  /// **'That document isn\'t available.'**
  String get approvals_document_missing;

  /// A2 section title.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get approvals_checklist;

  /// Workshop checklist.
  ///
  /// In en, this message translates to:
  /// **'Shop photo shows a real workshop'**
  String get approvals_check_shop_photo;

  /// Workshop checklist.
  ///
  /// In en, this message translates to:
  /// **'ID proof matches the name'**
  String get approvals_check_id_proof;

  /// Workshop checklist.
  ///
  /// In en, this message translates to:
  /// **'Services and vehicles make sense'**
  String get approvals_check_services;

  /// Independent checklist.
  ///
  /// In en, this message translates to:
  /// **'Selfie matches the ID'**
  String get approvals_check_selfie;

  /// Independent checklist.
  ///
  /// In en, this message translates to:
  /// **'Address proof checked'**
  String get approvals_check_address;

  /// Independent checklist.
  ///
  /// In en, this message translates to:
  /// **'Toolkit photos show real tools'**
  String get approvals_check_toolkit;

  /// Independent: before logging the call.
  ///
  /// In en, this message translates to:
  /// **'Verification call notes'**
  String get approvals_call_notes_label;

  /// Example notes.
  ///
  /// In en, this message translates to:
  /// **'Video call, ID matched, 6 years at Patel Motors confirmed.'**
  String get approvals_call_notes_hint;

  /// Records the call (admin callable).
  ///
  /// In en, this message translates to:
  /// **'Log verification call'**
  String get approvals_call_log;

  /// Toast.
  ///
  /// In en, this message translates to:
  /// **'Verification call logged.'**
  String get approvals_call_logged;

  /// Independent: the logged call.
  ///
  /// In en, this message translates to:
  /// **'Call logged {date}: {notes}'**
  String approvals_call_done(String date, String notes);

  /// A2 primary action.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approvals_approve;

  /// Toast.
  ///
  /// In en, this message translates to:
  /// **'Approved. They can go online now.'**
  String get approvals_approved;

  /// A2 destructive action.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get approvals_block;

  /// Block reason, required.
  ///
  /// In en, this message translates to:
  /// **'Why are you blocking them?'**
  String get approvals_block_reason_label;

  /// Block reason hint.
  ///
  /// In en, this message translates to:
  /// **'For example: ID proof doesn\'t match'**
  String get approvals_block_reason_hint;

  /// Confirms the block.
  ///
  /// In en, this message translates to:
  /// **'Block mechanic'**
  String get approvals_block_confirm;

  /// Cancels blocking.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get approvals_block_cancel;

  /// Toast.
  ///
  /// In en, this message translates to:
  /// **'Blocked. They\'re signed out everywhere.'**
  String get approvals_blocked;

  /// A2 detail for blocked mechanics.
  ///
  /// In en, this message translates to:
  /// **'This mechanic is blocked and can\'t receive jobs.'**
  String get approvals_blocked_note;

  /// A2 footer.
  ///
  /// In en, this message translates to:
  /// **'Every approval, block and call is recorded in the audit log.'**
  String get approvals_audit_note;

  /// Why Approve is disabled.
  ///
  /// In en, this message translates to:
  /// **'Approve needs the KYC documents first.'**
  String get approvals_why_kyc;

  /// Why Approve is disabled.
  ///
  /// In en, this message translates to:
  /// **'Tick every checklist item to approve.'**
  String get approvals_why_checklist;

  /// Why Approve is disabled (PLAN §10.0).
  ///
  /// In en, this message translates to:
  /// **'Log the verification call to approve an independent mechanic.'**
  String get approvals_why_call;

  /// The callable isn't deployed or reachable.
  ///
  /// In en, this message translates to:
  /// **'That action isn\'t available yet. Try again later.'**
  String get approvals_error_unavailable;

  /// failed-precondition.
  ///
  /// In en, this message translates to:
  /// **'The server refused: check the mechanic\'s status and the verification call.'**
  String get approvals_error_precondition;

  /// permission-denied.
  ///
  /// In en, this message translates to:
  /// **'Your admin access has changed. Sign in again.'**
  String get approvals_error_not_allowed;

  /// Other errors.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Nothing was changed.'**
  String get approvals_error_unknown;

  /// Booking status: requested (rail: Requested).
  ///
  /// In en, this message translates to:
  /// **'Searching'**
  String get booking_status_requested;

  /// Booking status.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get booking_status_accepted;

  /// Booking status: arriving.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get booking_status_arriving;

  /// Booking status.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get booking_status_arrived;

  /// Booking status: in progress.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get booking_status_in_progress;

  /// Booking status: completed.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get booking_status_completed;

  /// Booking status.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get booking_status_cancelled;

  /// Booking status: no mechanic found.
  ///
  /// In en, this message translates to:
  /// **'No mechanic'**
  String get booking_status_no_mechanic;

  /// A1 heading for today.
  ///
  /// In en, this message translates to:
  /// **'Today, {date}'**
  String dashboard_today(String date);

  /// A1 day stepper.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get dashboard_previous_day;

  /// A1 day stepper.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get dashboard_next_day;

  /// A1 error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the dashboard.'**
  String get dashboard_load_failed;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get dashboard_stat_bookings;

  /// Stat card.
  ///
  /// In en, this message translates to:
  /// **'Mechanics online'**
  String get dashboard_stat_active_mechanics;

  /// Under the online count.
  ///
  /// In en, this message translates to:
  /// **'Right now'**
  String get dashboard_stat_active_mechanics_note;

  /// Stat card: completed / ended bookings.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get dashboard_stat_completion;

  /// Stat card: accept to arrive.
  ///
  /// In en, this message translates to:
  /// **'Median arrival'**
  String get dashboard_stat_median_arrival;

  /// Under the arrival stat.
  ///
  /// In en, this message translates to:
  /// **'Accepted to arrived'**
  String get dashboard_stat_median_arrival_note;

  /// Duration in minutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String dashboard_minutes(int minutes);

  /// Stat card: OTP SMS success rate.
  ///
  /// In en, this message translates to:
  /// **'SMS success'**
  String get dashboard_stat_sms;

  /// SMS rate comes from Cloud Monitoring, not Firestore.
  ///
  /// In en, this message translates to:
  /// **'From monitoring (#62)'**
  String get dashboard_stat_sms_note;

  /// A1 table title.
  ///
  /// In en, this message translates to:
  /// **'Bookings this day'**
  String get dashboard_bookings_title;

  /// A1 empty table.
  ///
  /// In en, this message translates to:
  /// **'No bookings this day.'**
  String get dashboard_bookings_empty;

  /// Table column.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get dashboard_column_booking;

  /// Table column.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get dashboard_column_customer;

  /// Table column.
  ///
  /// In en, this message translates to:
  /// **'Mechanic'**
  String get dashboard_column_mechanic;

  /// Table column.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get dashboard_column_status;

  /// Table column.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get dashboard_column_amount;

  /// A3 error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load live bookings.'**
  String get live_load_failed;

  /// A3 empty.
  ///
  /// In en, this message translates to:
  /// **'No active bookings right now.'**
  String get live_empty;

  /// A3 status filter.
  ///
  /// In en, this message translates to:
  /// **'All active'**
  String get live_status_all;

  /// A3 vehicle filter.
  ///
  /// In en, this message translates to:
  /// **'All vehicles'**
  String get live_vehicle_all;

  /// Screen-reader label of the map.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Map with no active bookings} =1{Map with 1 active booking} other{Map with {count} active bookings}}'**
  String live_map_label(int count);

  /// A3 detail. {details} is name and phone.
  ///
  /// In en, this message translates to:
  /// **'Customer: {details}'**
  String live_customer(String details);

  /// A3 detail. {details} is name and phone.
  ///
  /// In en, this message translates to:
  /// **'Mechanic: {details}'**
  String live_mechanic(String details);

  /// A3 detail before accept.
  ///
  /// In en, this message translates to:
  /// **'Searching within {km} km'**
  String live_searching(int km);

  /// A3 action.
  ///
  /// In en, this message translates to:
  /// **'Cancel as admin'**
  String get live_cancel;

  /// Reason, required (PLAN §9).
  ///
  /// In en, this message translates to:
  /// **'Why are you cancelling?'**
  String get live_cancel_reason_label;

  /// Reason hint.
  ///
  /// In en, this message translates to:
  /// **'For example: customer asked by phone'**
  String get live_cancel_reason_hint;

  /// Confirms the admin cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get live_cancel_confirm;

  /// A3 footer.
  ///
  /// In en, this message translates to:
  /// **'Customer and mechanic are notified. The cancel is recorded with your account.'**
  String get live_cancel_note;

  /// Toast.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled.'**
  String get live_cancelled;

  /// failed-precondition on cancel.
  ///
  /// In en, this message translates to:
  /// **'This booking can\'t be cancelled any more.'**
  String get live_cancel_refused;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
