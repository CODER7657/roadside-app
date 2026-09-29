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

  /// App name in the task switcher. Placeholder until the client names the app (HANDOFF §4.9).
  ///
  /// In en, this message translates to:
  /// **'Roadside'**
  String get app_title;

  /// Temporary home screen until U1 Home (#12) lands.
  ///
  /// In en, this message translates to:
  /// **'Help on the road, in minutes'**
  String get home_placeholder_title;

  /// Temporary home screen body until U1 Home (#12) lands.
  ///
  /// In en, this message translates to:
  /// **'We\'re getting everything ready. Booking a mechanic arrives in the next update.'**
  String get home_placeholder_body;

  /// Progress label on multi-step flows.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String flow_step_label(int step, int total);

  /// C1 Splash: brand line.
  ///
  /// In en, this message translates to:
  /// **'Help on the road, in minutes'**
  String get splash_tagline;

  /// C1 Splash: shown while the app starts.
  ///
  /// In en, this message translates to:
  /// **'Getting things ready'**
  String get splash_loading;

  /// C2 Language: screen title.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get language_title;

  /// C2 Language: reassurance under the title.
  ///
  /// In en, this message translates to:
  /// **'You can change it later in Settings.'**
  String get language_body;

  /// C2 Language: primary button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get language_continue;

  /// C3 Onboarding, slide 1 title.
  ///
  /// In en, this message translates to:
  /// **'Help in minutes'**
  String get onboarding_slide1_title;

  /// C3 Onboarding, slide 1 body.
  ///
  /// In en, this message translates to:
  /// **'Tell us what\'s wrong. The nearest verified mechanic comes to you.'**
  String get onboarding_slide1_body;

  /// C3 Onboarding, slide 2 title.
  ///
  /// In en, this message translates to:
  /// **'Track them live'**
  String get onboarding_slide2_title;

  /// C3 Onboarding, slide 2 body.
  ///
  /// In en, this message translates to:
  /// **'See your mechanic on the map, with a live arrival time.'**
  String get onboarding_slide2_body;

  /// C3 Onboarding, slide 3 title.
  ///
  /// In en, this message translates to:
  /// **'Safe and verified'**
  String get onboarding_slide3_title;

  /// C3 Onboarding, slide 3 body.
  ///
  /// In en, this message translates to:
  /// **'Every mechanic is ID-checked. Share your trip with family in one tap.'**
  String get onboarding_slide3_body;

  /// C3 Onboarding: go to the next slide.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next;

  /// C3 Onboarding: skip the slides.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// C3 Onboarding: primary button on the last slide.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboarding_start;

  /// C4 Privacy & consent: title.
  ///
  /// In en, this message translates to:
  /// **'Your privacy'**
  String get consent_title;

  /// C4: first line.
  ///
  /// In en, this message translates to:
  /// **'We only collect what we need to send you help.'**
  String get consent_intro;

  /// C4: what is collected.
  ///
  /// In en, this message translates to:
  /// **'Your phone number, name, vehicles and any photos you add.'**
  String get consent_point_collect;

  /// C4: purpose limitation for location.
  ///
  /// In en, this message translates to:
  /// **'Your location, only while you book and while help is on the way.'**
  String get consent_point_location;

  /// C4: user rights.
  ///
  /// In en, this message translates to:
  /// **'You can see, correct or delete your data at any time.'**
  String get consent_point_delete;

  /// C4: required age confirmation (DPDP).
  ///
  /// In en, this message translates to:
  /// **'I am 18 or older'**
  String get consent_age;

  /// C4: required agreement.
  ///
  /// In en, this message translates to:
  /// **'I agree to the privacy notice'**
  String get consent_notice;

  /// C4: primary button, enabled when both boxes are ticked.
  ///
  /// In en, this message translates to:
  /// **'Agree and continue'**
  String get consent_agree;

  /// C4: opens the privacy notice.
  ///
  /// In en, this message translates to:
  /// **'Read the full notice'**
  String get consent_read_notice;

  /// Full privacy notice. Draft until the policy (#55) is final.
  ///
  /// In en, this message translates to:
  /// **'Privacy notice'**
  String get privacy_title;

  /// Privacy notice section title.
  ///
  /// In en, this message translates to:
  /// **'What we collect'**
  String get privacy_collect_title;

  /// Privacy notice section body.
  ///
  /// In en, this message translates to:
  /// **'Your phone number, name and language, the vehicles you add, photos you attach to a booking, and your location while you book or a mechanic is on the way.'**
  String get privacy_collect_body;

  /// Privacy notice section title.
  ///
  /// In en, this message translates to:
  /// **'Why we use it'**
  String get privacy_use_title;

  /// Privacy notice section body.
  ///
  /// In en, this message translates to:
  /// **'Only to find you a mechanic, show them where you are and keep both of you safe. We don\'t show ads or sell your data.'**
  String get privacy_use_body;

  /// Privacy notice section title.
  ///
  /// In en, this message translates to:
  /// **'How long we keep it'**
  String get privacy_keep_title;

  /// Privacy notice section body (PLAN §12.10).
  ///
  /// In en, this message translates to:
  /// **'Live location: 24 hours after the job. Chat: 90 days. Booking records: 3 years for tax, anonymised if you delete your account.'**
  String get privacy_keep_body;

  /// Privacy notice section title.
  ///
  /// In en, this message translates to:
  /// **'Your rights'**
  String get privacy_rights_title;

  /// Privacy notice section body.
  ///
  /// In en, this message translates to:
  /// **'See and correct your details in the app, withdraw your consent, or delete your account from Settings.'**
  String get privacy_rights_body;

  /// Privacy notice section title.
  ///
  /// In en, this message translates to:
  /// **'Questions or complaints'**
  String get privacy_contact_title;

  /// Privacy notice section body. Named contact comes with #55.
  ///
  /// In en, this message translates to:
  /// **'Contact our grievance officer from Help & FAQ.'**
  String get privacy_contact_body;

  /// Temporary home: opens C9 until U1 (#12) has its menu.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get home_help;

  /// C7: location explainer title.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get permission_location_title;

  /// C7: why location (purpose limitation, PLAN §12.12).
  ///
  /// In en, this message translates to:
  /// **'So the mechanic can find you. We only use your location while you book and while help is on the way.'**
  String get permission_location_body;

  /// C7: camera explainer title.
  ///
  /// In en, this message translates to:
  /// **'Allow camera'**
  String get permission_camera_title;

  /// C7: why camera.
  ///
  /// In en, this message translates to:
  /// **'To add photos of the problem. Only the photos you choose are shared with your mechanic.'**
  String get permission_camera_body;

  /// C7: notifications explainer title.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get permission_notifications_title;

  /// C7: why notifications.
  ///
  /// In en, this message translates to:
  /// **'So we can tell you when a mechanic accepts, is on the way and arrives.'**
  String get permission_notifications_body;

  /// C7: permission denied forever.
  ///
  /// In en, this message translates to:
  /// **'It\'s turned off in your phone\'s settings. Open Settings, tap Permissions and allow it.'**
  String get permission_blocked_body;

  /// C7: primary button; shows the system prompt.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get permission_allow;

  /// C7: primary button when blocked.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get permission_open_settings;

  /// C7: secondary button.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get permission_not_now;

  /// C9: title.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help_title;

  /// C9: search field label.
  ///
  /// In en, this message translates to:
  /// **'Search questions'**
  String get help_search_label;

  /// C9: search hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. price, start code'**
  String get help_search_hint;

  /// C9: search found nothing.
  ///
  /// In en, this message translates to:
  /// **'No matching questions'**
  String get help_no_results_title;

  /// C9: search found nothing.
  ///
  /// In en, this message translates to:
  /// **'Try other words, or call us.'**
  String get help_no_results_body;

  /// C9: call button.
  ///
  /// In en, this message translates to:
  /// **'Call support'**
  String get help_call_support;

  /// C9: WhatsApp button (brand name, not translated).
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get help_whatsapp;

  /// C9: DPDP grievance contact heading.
  ///
  /// In en, this message translates to:
  /// **'Grievance officer'**
  String get help_grievance_title;

  /// C9: DPDP grievance contact (PLAN §12.12). Named person comes with #55.
  ///
  /// In en, this message translates to:
  /// **'For complaints about your data or privacy, write to our grievance officer. We reply within 7 days.'**
  String get help_grievance_body;

  /// C9 FAQ.
  ///
  /// In en, this message translates to:
  /// **'How much will it cost?'**
  String get help_faq_price_q;

  /// C9 FAQ.
  ///
  /// In en, this message translates to:
  /// **'You see a price range before you book. The mechanic sets the final amount in the app after the job, and you pay them directly by UPI.'**
  String get help_faq_price_a;

  /// C9 FAQ.
  ///
  /// In en, this message translates to:
  /// **'Are the mechanics verified?'**
  String get help_faq_verified_q;

  /// C9 FAQ.
  ///
  /// In en, this message translates to:
  /// **'Yes. We check every mechanic\'s ID before they get jobs. Mechanics without a workshop also do a verification call.'**
  String get help_faq_verified_a;

  /// C9 FAQ.
  ///
  /// In en, this message translates to:
  /// **'What is the start code?'**
  String get help_faq_code_q;

  /// C9 FAQ.
  ///
  /// In en, this message translates to:
  /// **'A 4-digit code in your app. Share it only when the mechanic is standing with you; the job starts when they enter it.'**
  String get help_faq_code_a;

  /// C9 FAQ.
  ///
  /// In en, this message translates to:
  /// **'How do I pay?'**
  String get help_faq_pay_q;

  /// C9 FAQ.
  ///
  /// In en, this message translates to:
  /// **'By UPI, straight to the mechanic: open your UPI app from ours or scan the QR, then tap \"I have paid\". We never ask for card or bank details.'**
  String get help_faq_pay_a;

  /// C9 FAQ.
  ///
  /// In en, this message translates to:
  /// **'Can I cancel?'**
  String get help_faq_cancel_q;

  /// C9 FAQ.
  ///
  /// In en, this message translates to:
  /// **'Yes, any time before the job starts. Tell us why in one tap so we can improve.'**
  String get help_faq_cancel_a;

  /// C9 FAQ.
  ///
  /// In en, this message translates to:
  /// **'Where does it work?'**
  String get help_faq_area_q;

  /// C9 FAQ.
  ///
  /// In en, this message translates to:
  /// **'Ahmedabad, Ankleshwar and Bharuch for now, including highway stretches nearby. More cities are coming.'**
  String get help_faq_area_a;

  /// Temporary home: opens U3.
  ///
  /// In en, this message translates to:
  /// **'My vehicles'**
  String get home_my_vehicles;

  /// U3: title.
  ///
  /// In en, this message translates to:
  /// **'My vehicles'**
  String get vehicles_title;

  /// U3: add button.
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get vehicles_add;

  /// U3: empty state title.
  ///
  /// In en, this message translates to:
  /// **'No vehicles yet'**
  String get vehicles_empty_title;

  /// U3: empty state body.
  ///
  /// In en, this message translates to:
  /// **'Add your vehicle once, and booking help takes one tap.'**
  String get vehicles_empty_body;

  /// U3: marks the default vehicle.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get vehicles_default_label;

  /// U3: swipe background and screen-reader action.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get vehicles_delete;

  /// U3: toast after delete.
  ///
  /// In en, this message translates to:
  /// **'Vehicle removed'**
  String get vehicles_removed;

  /// U3: toast action.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get vehicles_undo;

  /// U2: step label above the lane.
  ///
  /// In en, this message translates to:
  /// **'New vehicle'**
  String get vehicle_add_step;

  /// U2: title.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle'**
  String get vehicle_add_title;

  /// U2: vehicle type tiles label.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get vehicle_type_label;

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

  /// U2: field label.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get vehicle_brand_label;

  /// U2: field hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Maruti Suzuki'**
  String get vehicle_brand_hint;

  /// U2: field label.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get vehicle_model_label;

  /// U2: field hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Swift'**
  String get vehicle_model_hint;

  /// U2: field label.
  ///
  /// In en, this message translates to:
  /// **'Registration number'**
  String get vehicle_reg_label;

  /// U2: field hint (a plate, not translated).
  ///
  /// In en, this message translates to:
  /// **'GJ 01 AB 1234'**
  String get vehicle_reg_hint;

  /// U2: fuel chips label.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get vehicle_fuel_label;

  /// Fuel.
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get fuel_petrol;

  /// Fuel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get fuel_diesel;

  /// Fuel.
  ///
  /// In en, this message translates to:
  /// **'CNG'**
  String get fuel_cng;

  /// Fuel.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get fuel_electric;

  /// U2: switch, shown when other vehicles exist.
  ///
  /// In en, this message translates to:
  /// **'Make this my default'**
  String get vehicle_make_default;

  /// U2: primary button.
  ///
  /// In en, this message translates to:
  /// **'Save vehicle'**
  String get vehicle_save;

  /// Validation: empty required field.
  ///
  /// In en, this message translates to:
  /// **'Please fill this in'**
  String get error_field_required;

  /// Validation: text over the limit.
  ///
  /// In en, this message translates to:
  /// **'That is too long'**
  String get error_field_too_long;

  /// Validation: any other problem.
  ///
  /// In en, this message translates to:
  /// **'Please check this'**
  String get error_field_invalid;

  /// Validation: registration number (Indian or BH series).
  ///
  /// In en, this message translates to:
  /// **'Check the number, e.g. GJ 01 AB 1234 or 22 BH 1234 AA'**
  String get error_reg_no_invalid;
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
