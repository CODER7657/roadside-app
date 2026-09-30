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

  /// After createBooking, until U8 Searching (#16).
  ///
  /// In en, this message translates to:
  /// **'Booking sent'**
  String get searching_title;

  /// Under searching_title.
  ///
  /// In en, this message translates to:
  /// **'We\'re finding the nearest mechanic.'**
  String get searching_body;
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
