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
