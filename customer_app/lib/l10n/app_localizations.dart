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

  /// Home: the Beacon button that starts a booking (U4).
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get home_get_help;

  /// Booking flow U4–U7: step label above the title.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String booking_step(int step, int total);

  /// Booking flow: primary button to the next step.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get booking_next;

  /// U4 Problem picker: title.
  ///
  /// In en, this message translates to:
  /// **'What\'s wrong?'**
  String get problem_title;

  /// U4: label above the vehicle being fixed (tap to change).
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get problem_vehicle_label;

  /// U4: shown when the customer has no vehicle yet.
  ///
  /// In en, this message translates to:
  /// **'Add your vehicle first'**
  String get problem_no_vehicle_title;

  /// U4: under problem_no_vehicle_title.
  ///
  /// In en, this message translates to:
  /// **'The mechanic needs to know what they are fixing.'**
  String get problem_no_vehicle_body;

  /// U4: button to U2 when there is no vehicle.
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get problem_add_vehicle;

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

  /// U5: title (the step is optional).
  ///
  /// In en, this message translates to:
  /// **'Photos and details'**
  String get photos_title;

  /// U5: explainer under the title.
  ///
  /// In en, this message translates to:
  /// **'Optional. Photos help the mechanic bring the right parts. We remove the location from every photo.'**
  String get photos_body;

  /// U5: opens the camera.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get photos_take;

  /// U5: opens the photo picker.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get photos_gallery;

  /// U5: how many photos are added.
  ///
  /// In en, this message translates to:
  /// **'{count} of {max} photos'**
  String photos_count(int count, int max);

  /// U5: remove button on a thumbnail (screen reader).
  ///
  /// In en, this message translates to:
  /// **'Remove photo {n}'**
  String photos_remove(int n);

  /// U5: thumbnail while uploading (screen reader).
  ///
  /// In en, this message translates to:
  /// **'Uploading photo {n}'**
  String photos_uploading(int n);

  /// U5: failed thumbnail, tap to retry.
  ///
  /// In en, this message translates to:
  /// **'Photo {n} did not upload. Try again'**
  String photos_retry(int n);

  /// U5: toast at the photo limit.
  ///
  /// In en, this message translates to:
  /// **'You can add up to 4 photos.'**
  String get photos_error_limit;

  /// U5: toast when a photo cannot be compressed under 500 KB.
  ///
  /// In en, this message translates to:
  /// **'That photo is too large. Try another one.'**
  String get photos_error_too_large;

  /// U5: toast when picking or compressing fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add that photo. Try again.'**
  String get photos_error_failed;

  /// U5: shown when Next is blocked by a failed upload.
  ///
  /// In en, this message translates to:
  /// **'Some photos did not upload. Retry them or remove them to continue.'**
  String get photos_error_upload;

  /// U5: description field label.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get description_label;

  /// U5: description hint.
  ///
  /// In en, this message translates to:
  /// **'For example: rear tyre went flat near the toll plaza'**
  String get description_hint;

  /// U5: continue without photos or details.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get photos_skip;

  /// U5: an uploaded photo in the list.
  ///
  /// In en, this message translates to:
  /// **'Photo {n}'**
  String photos_item(int n);

  /// Returns to Home from a booking step that is not ready yet.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get booking_back_home;

  /// U6 Confirm location: title in the dock.
  ///
  /// In en, this message translates to:
  /// **'Where are you?'**
  String get location_title;

  /// U6: instruction under the title.
  ///
  /// In en, this message translates to:
  /// **'Drag the map so the pin is on your vehicle.'**
  String get location_hint;

  /// U6: no location permission.
  ///
  /// In en, this message translates to:
  /// **'Location is off for this app. Drag the map to your spot, or allow location.'**
  String get location_no_permission;

  /// U6: opens the C7 explainer for location.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get location_allow;

  /// U6: GPS is off.
  ///
  /// In en, this message translates to:
  /// **'Your phone\'s location is switched off.'**
  String get location_gps_off;

  /// U6: opens the phone location settings.
  ///
  /// In en, this message translates to:
  /// **'Turn on location'**
  String get location_turn_on;

  /// U6: no GPS reading in 15 s.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find you. Drag the map to your spot.'**
  String get location_no_fix;

  /// U6: while reverse geocoding.
  ///
  /// In en, this message translates to:
  /// **'Finding the address…'**
  String get location_finding_address;

  /// U6: no address for the pin.
  ///
  /// In en, this message translates to:
  /// **'No street address here. The mechanic will use the Plus Code.'**
  String get location_no_address;

  /// U6: the pin as a Plus Code.
  ///
  /// In en, this message translates to:
  /// **'Plus Code {code}'**
  String location_plus_code(String code);

  /// U6: landmark field label.
  ///
  /// In en, this message translates to:
  /// **'Landmark (optional)'**
  String get location_landmark_label;

  /// U6: landmark hint.
  ///
  /// In en, this message translates to:
  /// **'For example: opposite the petrol pump'**
  String get location_landmark_hint;

  /// U6: pin far from the GPS reading.
  ///
  /// In en, this message translates to:
  /// **'The pin is more than 2 km from where your phone is.'**
  String get location_far_warning;

  /// U6: switch needed when the pin is far away.
  ///
  /// In en, this message translates to:
  /// **'I\'m booking for someone else'**
  String get location_someone_else;

  /// U6: primary button.
  ///
  /// In en, this message translates to:
  /// **'Confirm pickup'**
  String get location_confirm;

  /// U6: map button that moves the pin back to the GPS reading.
  ///
  /// In en, this message translates to:
  /// **'Go to my location'**
  String get location_recenter;

  /// U6: look for the phone's location again after no reading.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get location_retry;

  /// U7 Price estimate: title.
  ///
  /// In en, this message translates to:
  /// **'Your estimate'**
  String get price_title;

  /// U7: primary button (calls createBooking).
  ///
  /// In en, this message translates to:
  /// **'Book mechanic'**
  String get price_book;

  /// U7: under the price range.
  ///
  /// In en, this message translates to:
  /// **'You pay the mechanic directly after the job, by UPI or cash. The amount can change if parts are needed.'**
  String get price_note;

  /// U7: pickup outside every active service area.
  ///
  /// In en, this message translates to:
  /// **'We\'re not in this area yet. We serve Ahmedabad, Ankleshwar and Bharuch.'**
  String get price_error_out_of_area;

  /// U7: back to U6.
  ///
  /// In en, this message translates to:
  /// **'Change pickup'**
  String get price_change_pickup;

  /// U7: createBooking found an active booking.
  ///
  /// In en, this message translates to:
  /// **'You already have a booking in progress.'**
  String get price_error_active_booking;

  /// U7: goes to the active booking.
  ///
  /// In en, this message translates to:
  /// **'Open my booking'**
  String get price_open_booking;

  /// U7: dispatch switched off by admin.
  ///
  /// In en, this message translates to:
  /// **'Bookings are paused for a short while. Please try again in a few minutes.'**
  String get price_error_paused;

  /// U7: no prices doc for this vehicle and problem.
  ///
  /// In en, this message translates to:
  /// **'We can\'t price this problem yet. Our support team can help.'**
  String get price_error_unavailable;

  /// U7: opens Help & FAQ.
  ///
  /// In en, this message translates to:
  /// **'Get support'**
  String get price_get_support;

  /// U7: the draft vehicle no longer exists.
  ///
  /// In en, this message translates to:
  /// **'This vehicle was removed. Choose another one.'**
  String get price_error_vehicle;

  /// U7: opens My vehicles.
  ///
  /// In en, this message translates to:
  /// **'Choose vehicle'**
  String get price_choose_vehicle;

  /// U7: createBooking rate limit.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Please wait a few minutes and try again.'**
  String get price_error_rate_limited;

  /// U7: network or unknown error; Book retries with the same key.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t book. Check your connection and try again.'**
  String get price_error_network;

  /// U8 Searching: title.
  ///
  /// In en, this message translates to:
  /// **'Finding a mechanic'**
  String get searching_title;

  /// Under searching_title.
  ///
  /// In en, this message translates to:
  /// **'We\'re finding the nearest mechanic.'**
  String get searching_body;

  /// U8: the booking's real search radius.
  ///
  /// In en, this message translates to:
  /// **'We\'re asking mechanics within {km} km of you.'**
  String searching_radius(int km);

  /// U8/U9: opens the cancel confirm sheet.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancel_booking;

  /// Cancel sheet: title.
  ///
  /// In en, this message translates to:
  /// **'Cancel this booking?'**
  String get cancel_title;

  /// Cancel sheet while searching.
  ///
  /// In en, this message translates to:
  /// **'We stop looking for a mechanic straight away.'**
  String get cancel_body_searching;

  /// Cancel sheet once a mechanic is assigned.
  ///
  /// In en, this message translates to:
  /// **'Your mechanic is told straight away. Please pick a reason.'**
  String get cancel_body_assigned;

  /// Cancel sheet: the red confirm button.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancel_confirm;

  /// Cancel sheet: keep it.
  ///
  /// In en, this message translates to:
  /// **'Keep booking'**
  String get cancel_keep;

  /// Cancel reason found_help.
  ///
  /// In en, this message translates to:
  /// **'Found help elsewhere'**
  String get cancel_reason_found_help;

  /// Cancel reason fixed_myself.
  ///
  /// In en, this message translates to:
  /// **'Fixed it myself'**
  String get cancel_reason_fixed_myself;

  /// Cancel reason too_slow.
  ///
  /// In en, this message translates to:
  /// **'Taking too long'**
  String get cancel_reason_too_slow;

  /// Cancel reason wrong_details.
  ///
  /// In en, this message translates to:
  /// **'Wrong vehicle or place'**
  String get cancel_reason_wrong_details;

  /// Cancel reason other (asks for text).
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get cancel_reason_other;

  /// Cancel sheet: text for "Something else".
  ///
  /// In en, this message translates to:
  /// **'Tell us more (optional)'**
  String get cancel_reason_text;

  /// Toast: cancelBooking error_invalid_status.
  ///
  /// In en, this message translates to:
  /// **'It can\'t be cancelled now: the work has started.'**
  String get cancel_error_too_late;

  /// Toast: cancelBooking failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t cancel. Check your connection and try again.'**
  String get cancel_error_network;

  /// no_mechanic_found: title.
  ///
  /// In en, this message translates to:
  /// **'No mechanic free right now'**
  String get no_mechanic_title;

  /// no_mechanic_found: message.
  ///
  /// In en, this message translates to:
  /// **'Everyone nearby is busy. Try again in a few minutes, or talk to us.'**
  String get no_mechanic_body;

  /// no_mechanic_found: book the same again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get no_mechanic_try_again;

  /// Cancelled: title.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled'**
  String get cancelled_title;

  /// Cancelled by the customer.
  ///
  /// In en, this message translates to:
  /// **'You cancelled this booking.'**
  String get cancelled_by_you;

  /// Cancelled by the mechanic after arrival.
  ///
  /// In en, this message translates to:
  /// **'The mechanic had to cancel. You were not charged.'**
  String get cancelled_by_mechanic;

  /// Cancelled by admin or the system.
  ///
  /// In en, this message translates to:
  /// **'Our support team cancelled this booking.'**
  String get cancelled_by_support;

  /// Booking missing or not the customer's.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this booking.'**
  String get live_not_found;

  /// U9: accepted.
  ///
  /// In en, this message translates to:
  /// **'A mechanic is coming'**
  String get assigned_title;

  /// U9: arriving.
  ///
  /// In en, this message translates to:
  /// **'Your mechanic is on the way'**
  String get assigned_on_the_way;

  /// U9: arrived.
  ///
  /// In en, this message translates to:
  /// **'Your mechanic has arrived'**
  String get assigned_arrived;

  /// JourneyRail stop.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get stop_requested;

  /// JourneyRail stop.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get stop_accepted;

  /// JourneyRail stop.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get stop_on_the_way;

  /// JourneyRail stop.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get stop_arrived;

  /// JourneyRail stop.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get stop_working;

  /// JourneyRail stop.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get stop_done;

  /// Push/inbox: verifyStartOtp locked after 5 wrong codes (#124).
  ///
  /// In en, this message translates to:
  /// **'Someone tried your start code'**
  String get notif_start_code_locked_title;

  /// Push/inbox body for start_code_locked.
  ///
  /// In en, this message translates to:
  /// **'Someone tried your start code 5 times. Only read it out to your mechanic in person.'**
  String get notif_start_code_locked_body;

  /// U10: arriving.
  ///
  /// In en, this message translates to:
  /// **'{name} is on the way'**
  String tracking_on_the_way(String name);

  /// U10: arrived.
  ///
  /// In en, this message translates to:
  /// **'{name} has arrived'**
  String tracking_arrived(String name);

  /// U10: ETA, rolls as it changes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String tracking_eta(int minutes);

  /// U10: after the ETA ("6 min away").
  ///
  /// In en, this message translates to:
  /// **'away'**
  String get tracking_away;

  /// U10: no reading yet.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name}\'s location…'**
  String tracking_waiting(String name);

  /// U10: reading older than 30 s.
  ///
  /// In en, this message translates to:
  /// **'Location last updated {minutes} min ago. It may be out of signal.'**
  String tracking_stale(int minutes);

  /// U10: opens the phone dialer.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String tracking_call(String name);

  /// U10: dialer failed to open.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the phone app.'**
  String get tracking_call_failed;

  /// U10: label above the code.
  ///
  /// In en, this message translates to:
  /// **'Start code'**
  String get tracking_start_code;

  /// U10: under the code.
  ///
  /// In en, this message translates to:
  /// **'Share this code only when the mechanic is standing with you.'**
  String get tracking_start_code_hint;

  /// U12 Job in progress: title.
  ///
  /// In en, this message translates to:
  /// **'{name} is working on it'**
  String working_title(String name);

  /// U12: when the work started and for how long.
  ///
  /// In en, this message translates to:
  /// **'Started at {time} · {minutes} min so far'**
  String working_since(String time, int minutes);

  /// U12: no start time yet.
  ///
  /// In en, this message translates to:
  /// **'Work has started.'**
  String get working_started;

  /// U13 Payment: title.
  ///
  /// In en, this message translates to:
  /// **'Pay {name}'**
  String payment_title(String name);

  /// U13: under the final amount.
  ///
  /// In en, this message translates to:
  /// **'The estimate was {min}–{max}'**
  String payment_estimate_was(String min, String max);

  /// U13: finalAmount missing.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the mechanic to enter the final amount.'**
  String get payment_no_amount;

  /// U13: primary; opens the upi://pay link.
  ///
  /// In en, this message translates to:
  /// **'Pay with UPI app'**
  String get payment_pay_upi;

  /// U13: TalkBack label of the QR.
  ///
  /// In en, this message translates to:
  /// **'QR code to pay {amount} to {name}'**
  String payment_qr_label(String amount, String name);

  /// U13: under the QR.
  ///
  /// In en, this message translates to:
  /// **'Or scan this with any UPI app'**
  String get payment_qr_hint;

  /// U13: copies the mechanic UPI ID.
  ///
  /// In en, this message translates to:
  /// **'Copy UPI ID'**
  String get payment_copy_upi;

  /// U13: toast after copying.
  ///
  /// In en, this message translates to:
  /// **'UPI ID copied'**
  String get payment_upi_copied;

  /// U13: the deep link found no app.
  ///
  /// In en, this message translates to:
  /// **'No UPI app opened. Scan the QR with another phone, or pay in cash.'**
  String get payment_no_upi_app;

  /// U13: no valid UPI ID on the card.
  ///
  /// In en, this message translates to:
  /// **'Pay {name} in cash, or ask them for their UPI ID.'**
  String payment_cash(String name);

  /// U13: markPaid.
  ///
  /// In en, this message translates to:
  /// **'I have paid'**
  String get payment_i_have_paid;

  /// U13: opens the dispute sheet.
  ///
  /// In en, this message translates to:
  /// **'Something\'s wrong'**
  String get payment_problem;

  /// U13: markPaid / disputePayment failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the payment. Check your connection and try again.'**
  String get payment_error_network;

  /// U13 after "I have paid".
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to confirm'**
  String payment_waiting_title(String name);

  /// U13 after "I have paid".
  ///
  /// In en, this message translates to:
  /// **'They check that {amount} arrived in their UPI app.'**
  String payment_waiting_body(String amount);

  /// Payment confirmed: title.
  ///
  /// In en, this message translates to:
  /// **'Paid {amount}'**
  String payment_confirmed_title(String amount);

  /// Payment confirmed without an amount.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed'**
  String get payment_confirmed_title_plain;

  /// Payment confirmed: message.
  ///
  /// In en, this message translates to:
  /// **'Thank you! {name} confirmed your payment.'**
  String payment_confirmed_body(String name);

  /// Payment disputed: title.
  ///
  /// In en, this message translates to:
  /// **'We\'re looking into it'**
  String get payment_disputed_title;

  /// Payment disputed: message.
  ///
  /// In en, this message translates to:
  /// **'Our team will contact you about this payment.'**
  String get payment_disputed_body;

  /// Dispute sheet: title.
  ///
  /// In en, this message translates to:
  /// **'What\'s wrong with the payment?'**
  String get payment_dispute_title;

  /// Dispute sheet: text field.
  ///
  /// In en, this message translates to:
  /// **'Tell us what happened'**
  String get payment_dispute_label;

  /// Dispute sheet: hint.
  ///
  /// In en, this message translates to:
  /// **'For example: asked for more than the amount shown'**
  String get payment_dispute_hint;

  /// Dispute sheet: confirm.
  ///
  /// In en, this message translates to:
  /// **'Report problem'**
  String get payment_dispute_send;

  /// Toast after a dispute.
  ///
  /// In en, this message translates to:
  /// **'Thanks. We\'ll look into it.'**
  String get payment_dispute_sent;

  /// Sheet: close without doing anything.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get cancel_keep_open;

  /// Payment confirmed: opens U14.
  ///
  /// In en, this message translates to:
  /// **'Rate {name}'**
  String review_rate(String name);

  /// U14: step label.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get review_step;

  /// U14: title.
  ///
  /// In en, this message translates to:
  /// **'How was {name}?'**
  String review_title(String name);

  /// U14: StarRating label for TalkBack.
  ///
  /// In en, this message translates to:
  /// **'Rating for {name}'**
  String review_stars_label(String name);

  /// U14: tags for 4–5 stars.
  ///
  /// In en, this message translates to:
  /// **'What went well?'**
  String get review_tags_good;

  /// U14: tags for 1–3 stars.
  ///
  /// In en, this message translates to:
  /// **'What went wrong?'**
  String get review_tags_bad;

  /// Tag on_time.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get review_tag_on_time;

  /// Tag friendly.
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get review_tag_friendly;

  /// Tag fixed_fast.
  ///
  /// In en, this message translates to:
  /// **'Fixed it fast'**
  String get review_tag_fixed_fast;

  /// Tag fair_price.
  ///
  /// In en, this message translates to:
  /// **'Fair price'**
  String get review_tag_fair_price;

  /// Tag late.
  ///
  /// In en, this message translates to:
  /// **'Came late'**
  String get review_tag_late;

  /// Tag rude.
  ///
  /// In en, this message translates to:
  /// **'Rude'**
  String get review_tag_rude;

  /// Tag overcharged.
  ///
  /// In en, this message translates to:
  /// **'Charged too much'**
  String get review_tag_overcharged;

  /// Tag not_fixed.
  ///
  /// In en, this message translates to:
  /// **'Not fixed'**
  String get review_tag_not_fixed;

  /// U14: comment field.
  ///
  /// In en, this message translates to:
  /// **'Anything else? (optional)'**
  String get review_comment_label;

  /// U14: primary.
  ///
  /// In en, this message translates to:
  /// **'Send review'**
  String get review_submit;

  /// Toast after sending.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your review!'**
  String get review_thanks;

  /// Toast: submit failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send your review. Check your connection and try again.'**
  String get review_error;

  /// Not completed, not theirs, or already reviewed.
  ///
  /// In en, this message translates to:
  /// **'This booking can’t be reviewed.'**
  String get review_not_allowed;

  /// U14: already reviewed.
  ///
  /// In en, this message translates to:
  /// **'You have rated this booking. Thank you!'**
  String get review_already;

  /// U1 chip when no service area covers the customer.
  ///
  /// In en, this message translates to:
  /// **'Outside our area'**
  String get home_city_outside;

  /// U1 while locating.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get home_locating;

  /// U1 before location is allowed.
  ///
  /// In en, this message translates to:
  /// **'Share your location to see help near you. You can still get help without it.'**
  String get home_no_location;

  /// U1: opens the C7 explainer for location.
  ///
  /// In en, this message translates to:
  /// **'Show my location'**
  String get home_show_location;

  /// U1: no GPS reading in 15 s.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find your location. You can still get help and place the pin yourself.'**
  String get home_no_fix;

  /// U1·Area: title.
  ///
  /// In en, this message translates to:
  /// **'We\'re not in your area yet'**
  String get home_outside_title;

  /// U1·Area: message.
  ///
  /// In en, this message translates to:
  /// **'We serve Ahmedabad, Ankleshwar and Bharuch. Send us your location by SMS and our team will help you find someone.'**
  String get home_outside_body;

  /// U1·Area: primary; opens the SMS app to the helpline.
  ///
  /// In en, this message translates to:
  /// **'Send my location by SMS'**
  String get home_sms_location;

  /// SMS body to the helpline.
  ///
  /// In en, this message translates to:
  /// **'I need roadside help. My location: {link} (Plus Code {code})'**
  String home_sms_body(String link, String code);

  /// U1·Area: SMS app failed to open.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the SMS app.'**
  String get home_sms_failed;

  /// U1: card for a booking still active.
  ///
  /// In en, this message translates to:
  /// **'Your booking is in progress'**
  String get home_booking_active;

  /// U1: under home_booking_active.
  ///
  /// In en, this message translates to:
  /// **'Tap to open it'**
  String get home_booking_open;

  /// U17: title.
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts'**
  String get contacts_title;

  /// U17: what the list is for.
  ///
  /// In en, this message translates to:
  /// **'SOS sends these people your live location. Up to 3.'**
  String get contacts_body;

  /// U17: shown when the list is empty.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet. Add someone who can help in an emergency.'**
  String get contacts_empty;

  /// U17: opens the phone's contact picker (no contacts permission).
  ///
  /// In en, this message translates to:
  /// **'Add from contacts'**
  String get contacts_add_picker;

  /// U17: type a contact in instead.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get contacts_add_manual;

  /// U17: shown when 3 are saved.
  ///
  /// In en, this message translates to:
  /// **'You can save up to 3 contacts.'**
  String get contacts_full;

  /// U17: remove button tooltip / TalkBack.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String contacts_remove(String name);

  /// U17: sticky save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get contacts_save;

  /// U17: toast after saving.
  ///
  /// In en, this message translates to:
  /// **'Contacts saved.'**
  String get contacts_saved;

  /// U17: toast when saving failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your contacts. Try again.'**
  String get contacts_save_failed;

  /// U17: the picked or typed number isn't a valid phone number.
  ///
  /// In en, this message translates to:
  /// **'That number can\'t be used. Use a mobile number.'**
  String get contacts_error_invalid;

  /// U17: the same number twice.
  ///
  /// In en, this message translates to:
  /// **'That number is already on the list.'**
  String get contacts_error_duplicate;

  /// U17: the picker is missing or failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open your contacts. Enter the number instead.'**
  String get contacts_picker_failed;

  /// U17: sheet title for typing a contact.
  ///
  /// In en, this message translates to:
  /// **'Add a contact'**
  String get contacts_manual_title;

  /// U17: name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contacts_name_label;

  /// U17: phone field.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get contacts_phone_label;

  /// U17: adds the typed contact.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get contacts_manual_add;

  /// U17: leaving with unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Discard your changes?'**
  String get contacts_discard_title;

  /// U17: leave without saving.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get contacts_discard;

  /// U17: stay on the screen.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get contacts_keep_editing;

  /// U17: error state.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your contacts.'**
  String get contacts_error;

  /// U17: error state action.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get contacts_retry;

  /// U10/U12: button that opens U11 Chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat_open;

  /// U11: title when the mechanic's name isn't known yet.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat_title;

  /// U11: empty state title.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get chat_empty_title;

  /// U11: empty state message.
  ///
  /// In en, this message translates to:
  /// **'Tell {name} anything that helps them find you or your vehicle.'**
  String chat_empty_body(String name);

  /// U11: shown instead of the composer once the booking has ended (PLAN §8: read for 30 days).
  ///
  /// In en, this message translates to:
  /// **'This chat has closed. You can still read it for 30 days.'**
  String get chat_closed;

  /// U11: TalkBack for one of my messages.
  ///
  /// In en, this message translates to:
  /// **'You: {text}'**
  String chat_you(String text);

  /// U11: TalkBack for the mechanic's message.
  ///
  /// In en, this message translates to:
  /// **'{name}: {text}'**
  String chat_from(String name, String text);

  /// U11: sheet title for choosing camera or gallery.
  ///
  /// In en, this message translates to:
  /// **'Send a photo'**
  String get chat_photo_title;

  /// U11: sheet option, opens the camera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get chat_photo_take;

  /// U11: sheet option, opens the gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chat_photo_gallery;

  /// U11: toast when a photo can't be made small enough.
  ///
  /// In en, this message translates to:
  /// **'That photo is too large. Try another one.'**
  String get chat_photo_too_large;

  /// U11: toast when picking or preparing a photo failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add that photo. Try again.'**
  String get chat_photo_failed;

  /// U11: error state.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the chat. Check your connection.'**
  String get chat_error;

  /// U11: error state action.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get chat_error_retry;

  /// U1: tooltip and screen-reader label of the map button that opens U18.
  ///
  /// In en, this message translates to:
  /// **'Profile & settings'**
  String get home_profile;

  /// U18: title.
  ///
  /// In en, this message translates to:
  /// **'Profile & settings'**
  String get profile_title;

  /// U18: error state for the name and number; the settings below are kept on the phone.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your profile. Your settings still work.'**
  String get profile_error;

  /// U18: row that opens the language choice.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profile_language;

  /// U18: title of the language sheet.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get profile_language_title;

  /// U18: row and sheet title for Auto / Day / Night / Glare.
  ///
  /// In en, this message translates to:
  /// **'Display mode'**
  String get profile_display_mode;

  /// U18: display mode chosen by the app.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get profile_display_auto;

  /// U18: explains Auto.
  ///
  /// In en, this message translates to:
  /// **'Day or Night by local sunset. Saver when the battery is low.'**
  String get profile_display_auto_hint;

  /// U18: display mode.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get profile_display_day;

  /// U18: explains Day.
  ///
  /// In en, this message translates to:
  /// **'A light screen, all the time.'**
  String get profile_display_day_hint;

  /// U18: display mode.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get profile_display_night;

  /// U18: explains Night.
  ///
  /// In en, this message translates to:
  /// **'A dark screen, all the time.'**
  String get profile_display_night_hint;

  /// U18: display mode for bright sunlight (the ☀ button on the map).
  ///
  /// In en, this message translates to:
  /// **'Glare'**
  String get profile_display_glare;

  /// U18: explains Glare.
  ///
  /// In en, this message translates to:
  /// **'Black on white with bigger text, for bright sun.'**
  String get profile_display_glare_hint;

  /// U18: switch for the one sound the app plays.
  ///
  /// In en, this message translates to:
  /// **'Arrival chime'**
  String get profile_chime;

  /// U18: explains the arrival chime.
  ///
  /// In en, this message translates to:
  /// **'A short sound when your mechanic arrives.'**
  String get profile_chime_hint;

  /// U18: row that opens U17.
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts'**
  String get profile_contacts;

  /// U18: how many emergency contacts are saved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None saved yet} =1{1 saved} other{{count} saved}}'**
  String profile_contacts_count(int count);

  /// U18: row that opens the privacy notice.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get profile_privacy;

  /// U18: row that opens the licenses page.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get profile_licenses;

  /// U1: opens U15 booking history.
  ///
  /// In en, this message translates to:
  /// **'Your bookings'**
  String get home_history;

  /// U15: title.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get history_title;

  /// U15: filter chip.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get history_filter_all;

  /// U15: filter chip, bookings still going on.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get history_filter_active;

  /// U15: filter chip, finished or cancelled bookings.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get history_filter_past;

  /// U15/U16: badge while a mechanic is being found.
  ///
  /// In en, this message translates to:
  /// **'Searching'**
  String get history_status_searching;

  /// U15/U16: badge for a cancelled booking (grey, never red).
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get history_status_cancelled;

  /// U15/U16: badge when no mechanic was found.
  ///
  /// In en, this message translates to:
  /// **'No mechanic'**
  String get history_status_no_mechanic;

  /// U15/U16: the day of a booking.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get history_today;

  /// U15/U16: the day of a booking.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get history_yesterday;

  /// U15: empty state title.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get history_empty_title;

  /// U15: empty state body.
  ///
  /// In en, this message translates to:
  /// **'When you get help, the booking and its receipt show up here.'**
  String get history_empty_body;

  /// U15: empty state action, back to Home.
  ///
  /// In en, this message translates to:
  /// **'Go to the map'**
  String get history_empty_action;

  /// U15: the Active filter has no bookings.
  ///
  /// In en, this message translates to:
  /// **'Nothing going on right now'**
  String get history_none_active;

  /// U15: the Past filter has no bookings.
  ///
  /// In en, this message translates to:
  /// **'No past bookings'**
  String get history_none_past;

  /// U15: action on an empty filter.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get history_show_all;

  /// U15/U16: error state.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your bookings. Check your connection.'**
  String get history_error;

  /// U16: title while the booking loads.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get detail_title;

  /// U16: the booking does not exist or is not yours.
  ///
  /// In en, this message translates to:
  /// **'This booking isn\'t available.'**
  String get detail_missing;

  /// U16: action when the booking is missing.
  ///
  /// In en, this message translates to:
  /// **'Back to bookings'**
  String get detail_back_to_history;

  /// U16: opens Help & FAQ (support and grievance officer).
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get detail_report;

  /// U16: under the rail when no mechanic was found.
  ///
  /// In en, this message translates to:
  /// **'No mechanic was free nearby. Nothing was charged.'**
  String get detail_no_mechanic;

  /// U16: under the rail.
  ///
  /// In en, this message translates to:
  /// **'You cancelled at {time}.'**
  String detail_cancelled_by_you(String time);

  /// U16: under the rail, cancelled by the mechanic or support.
  ///
  /// In en, this message translates to:
  /// **'Cancelled at {time}.'**
  String detail_cancelled_at(String time);

  /// U16: receipt row label.
  ///
  /// In en, this message translates to:
  /// **'Mechanic'**
  String get detail_mechanic;

  /// U16: receipt row label.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get detail_amount;

  /// U16: receipt row label.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get detail_paid_by;

  /// U16: how it was paid.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get detail_upi;

  /// U16: how it was paid and to whom (the name on their UPI account).
  ///
  /// In en, this message translates to:
  /// **'UPI to {name}'**
  String detail_upi_to(String name);

  /// U16: receipt row label.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get detail_payment;

  /// U16: payment state.
  ///
  /// In en, this message translates to:
  /// **'Not paid yet'**
  String get detail_payment_pending;

  /// U16: the customer marked it paid.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the mechanic to confirm'**
  String get detail_payment_marked;

  /// U16: payment state.
  ///
  /// In en, this message translates to:
  /// **'Paid, confirmed by the mechanic'**
  String get detail_payment_confirmed;

  /// U16: payment disputed; support is looking at it.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get detail_payment_disputed;

  /// U16: amount for a cancelled booking.
  ///
  /// In en, this message translates to:
  /// **'Nothing to pay'**
  String get detail_nothing_to_pay;
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
