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

  /// App name in the task switcher. Placeholder until the client names the app (HANDOFF §4.6).
  ///
  /// In en, this message translates to:
  /// **'Roadside Mechanic'**
  String get app_title;

  /// Progress label on multi-step flows.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String flow_step_label(int step, int total);

  /// C1 Splash: brand line for mechanics.
  ///
  /// In en, this message translates to:
  /// **'Jobs near you, paid straight to you'**
  String get splash_tagline;

  /// C1 Splash: shown while the app starts.
  ///
  /// In en, this message translates to:
  /// **'Getting things ready'**
  String get splash_loading;

  /// C2 Language: title.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get language_title;

  /// C2 Language: note under the title.
  ///
  /// In en, this message translates to:
  /// **'You can change it later in Settings.'**
  String get language_body;

  /// C2 Language: primary button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get language_continue;

  /// C3 Onboarding slide 1 title (mechanic).
  ///
  /// In en, this message translates to:
  /// **'Jobs near you'**
  String get onboarding_slide1_title;

  /// C3 Onboarding slide 1 body.
  ///
  /// In en, this message translates to:
  /// **'Go online and we send you breakdowns close by. Slide to accept the ones you want.'**
  String get onboarding_slide1_body;

  /// C3 Onboarding slide 2 title.
  ///
  /// In en, this message translates to:
  /// **'Reach them, start with their code'**
  String get onboarding_slide2_title;

  /// C3 Onboarding slide 2 body.
  ///
  /// In en, this message translates to:
  /// **'Navigate to the customer. When you arrive, they read you a start code to begin the job.'**
  String get onboarding_slide2_body;

  /// C3 Onboarding slide 3 title.
  ///
  /// In en, this message translates to:
  /// **'Paid straight to your UPI'**
  String get onboarding_slide3_title;

  /// C3 Onboarding slide 3 body.
  ///
  /// In en, this message translates to:
  /// **'Customers pay you directly. The app never holds your money.'**
  String get onboarding_slide3_body;

  /// C3 Onboarding: next slide.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next;

  /// C3 Onboarding: skip to consent.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// C3 Onboarding: last slide button.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboarding_start;

  /// C4 Consent: title.
  ///
  /// In en, this message translates to:
  /// **'Your privacy'**
  String get consent_title;

  /// C4 Consent: first line (mechanic).
  ///
  /// In en, this message translates to:
  /// **'We only collect what we need to send you jobs and keep customers safe.'**
  String get consent_intro;

  /// C4 Consent: what is collected (mechanic).
  ///
  /// In en, this message translates to:
  /// **'Your phone number, name, photos, ID documents for verification and your UPI details.'**
  String get consent_point_collect;

  /// C4 Consent: location use (mechanic).
  ///
  /// In en, this message translates to:
  /// **'Your location, only while you\'re online or on a job. Never when you\'re offline.'**
  String get consent_point_location;

  /// C4 Consent: rights line.
  ///
  /// In en, this message translates to:
  /// **'You can see, correct or delete your data at any time.'**
  String get consent_point_delete;

  /// C4 Consent: age checkbox.
  ///
  /// In en, this message translates to:
  /// **'I am 18 or older'**
  String get consent_age;

  /// C4 Consent: agreement checkbox.
  ///
  /// In en, this message translates to:
  /// **'I agree to the privacy notice'**
  String get consent_notice;

  /// C4 Consent: primary button, enabled when both boxes are ticked.
  ///
  /// In en, this message translates to:
  /// **'Agree and continue'**
  String get consent_agree;

  /// C4 Consent: opens the full notice.
  ///
  /// In en, this message translates to:
  /// **'Read the full notice'**
  String get consent_read_notice;

  /// Full privacy notice: title.
  ///
  /// In en, this message translates to:
  /// **'Privacy notice'**
  String get privacy_title;

  /// Privacy notice section title.
  ///
  /// In en, this message translates to:
  /// **'What we collect'**
  String get privacy_collect_title;

  /// Privacy notice: what we collect (mechanic).
  ///
  /// In en, this message translates to:
  /// **'Your phone number, name and language; your profile and shop or toolkit photos; your ID proof (and, if you work without a shop, a selfie with it and an address proof) to verify you; your UPI ID and name; and your location while you\'re online or on a job.'**
  String get privacy_collect_body;

  /// Privacy notice section title.
  ///
  /// In en, this message translates to:
  /// **'Why we use it'**
  String get privacy_use_title;

  /// Privacy notice: why (mechanic).
  ///
  /// In en, this message translates to:
  /// **'To verify you, send you nearby jobs, show customers who is coming and where you are on the way, and let them pay you. We don\'t show ads or sell your data.'**
  String get privacy_use_body;

  /// Privacy notice section title.
  ///
  /// In en, this message translates to:
  /// **'How long we keep it'**
  String get privacy_keep_title;

  /// Privacy notice: retention (mechanic, PLAN §12.10).
  ///
  /// In en, this message translates to:
  /// **'Your online location is replaced as you move and cleared when you go offline. Live location during a job: 24 hours after it ends. Chat: 90 days. ID documents: until 180 days after you leave. Job records: 3 years for tax.'**
  String get privacy_keep_body;

  /// Privacy notice section title.
  ///
  /// In en, this message translates to:
  /// **'Your rights'**
  String get privacy_rights_title;

  /// Privacy notice: rights.
  ///
  /// In en, this message translates to:
  /// **'See and correct your details in the app, withdraw your consent, or delete your account from Settings.'**
  String get privacy_rights_body;

  /// Privacy notice section title.
  ///
  /// In en, this message translates to:
  /// **'Questions or complaints'**
  String get privacy_contact_title;

  /// Privacy notice: grievance contact.
  ///
  /// In en, this message translates to:
  /// **'Contact our grievance officer from Help & FAQ.'**
  String get privacy_contact_body;

  /// Home: opens C9 Help & FAQ.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get home_help;

  /// C7: location explainer title.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get permission_location_title;

  /// C7: why the mechanic app needs location (no background location).
  ///
  /// In en, this message translates to:
  /// **'So we can send you jobs nearby and show customers you\'re on the way. Only while you\'re online or on a job; during a job a notification shows it\'s on.'**
  String get permission_location_body;

  /// C7: camera explainer title.
  ///
  /// In en, this message translates to:
  /// **'Allow camera'**
  String get permission_camera_title;

  /// C7: why the mechanic app needs the camera.
  ///
  /// In en, this message translates to:
  /// **'To add your profile, shop or toolkit photos, your ID documents, and before and after photos of each job.'**
  String get permission_camera_body;

  /// C7: notifications explainer title.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get permission_notifications_title;

  /// C7: why the mechanic app needs notifications.
  ///
  /// In en, this message translates to:
  /// **'So you hear new job offers straight away, and get updates on your jobs even when the app is closed.'**
  String get permission_notifications_body;

  /// C7: full-screen offers explainer title (Android 14+ special access).
  ///
  /// In en, this message translates to:
  /// **'Show job offers on the lock screen'**
  String get permission_full_screen_title;

  /// C7: why full-screen offers; the next screen is the phone's settings page.
  ///
  /// In en, this message translates to:
  /// **'A new job fills the screen like an incoming call, so you never miss one. On the next screen, turn on full-screen notifications for this app.'**
  String get permission_full_screen_body;

  /// C7: shown when the permission was denied for good.
  ///
  /// In en, this message translates to:
  /// **'It\'s turned off in your phone\'s settings. Open Settings, tap Permissions and allow it.'**
  String get permission_blocked_body;

  /// C7: primary button.
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

  /// C9: search field hint (mechanic).
  ///
  /// In en, this message translates to:
  /// **'e.g. offers, start code, payment'**
  String get help_search_hint;

  /// C9: empty search title.
  ///
  /// In en, this message translates to:
  /// **'No matching questions'**
  String get help_no_results_title;

  /// C9: empty search body.
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

  /// C9: DPDP grievance section title.
  ///
  /// In en, this message translates to:
  /// **'Grievance officer'**
  String get help_grievance_title;

  /// C9: DPDP grievance section body.
  ///
  /// In en, this message translates to:
  /// **'For complaints about your data or privacy, write to our grievance officer. We reply within 7 days.'**
  String get help_grievance_body;

  /// C9 FAQ (mechanic).
  ///
  /// In en, this message translates to:
  /// **'How do I get jobs?'**
  String get help_faq_jobs_q;

  /// C9 FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'Once you\'re approved, go online on the home screen. Nearby breakdowns come to you as offers; slide to accept within 30 seconds.'**
  String get help_faq_jobs_a;

  /// C9 FAQ (mechanic).
  ///
  /// In en, this message translates to:
  /// **'Why am I not getting offers?'**
  String get help_faq_no_offers_q;

  /// C9 FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'Check that you\'re online, approved, and in your city, and that your vehicle types and services are set. Keep the app open with location on; offers only go to mechanics close by.'**
  String get help_faq_no_offers_a;

  /// C9 FAQ (mechanic).
  ///
  /// In en, this message translates to:
  /// **'How does verification work?'**
  String get help_faq_verify_q;

  /// C9 FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'We check your ID and photos before you get jobs. If you work without a workshop, we also call you for a short verification.'**
  String get help_faq_verify_a;

  /// C9 FAQ (mechanic).
  ///
  /// In en, this message translates to:
  /// **'What is the start code?'**
  String get help_faq_code_q;

  /// C9 FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'When you arrive, the customer reads you a 4-digit code. Enter it to start the job. After 5 wrong tries it locks for 10 minutes.'**
  String get help_faq_code_a;

  /// C9 FAQ (mechanic).
  ///
  /// In en, this message translates to:
  /// **'How do I get paid?'**
  String get help_faq_pay_q;

  /// C9 FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'The customer pays you directly by UPI. Check your UPI app, then tap Confirm. If the money hasn\'t arrived, tap Not received and we\'ll look into it.'**
  String get help_faq_pay_a;

  /// C9 FAQ (mechanic).
  ///
  /// In en, this message translates to:
  /// **'Can I cancel a job?'**
  String get help_faq_cancel_q;

  /// C9 FAQ answer.
  ///
  /// In en, this message translates to:
  /// **'Yes, but it counts against your reliability. Before you arrive, the job goes to another mechanic; after you arrive, tell us why.'**
  String get help_faq_cancel_a;

  /// M1 step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Join as a mechanic'**
  String get register_type_title;

  /// M1 step 2 title.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get register_about_title;

  /// M1 step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Your work'**
  String get register_work_title;

  /// M1 step 4 title.
  ///
  /// In en, this message translates to:
  /// **'ID and payment'**
  String get register_id_title;

  /// M1: next step.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get register_next;

  /// M1: last step, submits the registration.
  ///
  /// In en, this message translates to:
  /// **'Send for approval'**
  String get register_submit;

  /// M1: photo upload failed.
  ///
  /// In en, this message translates to:
  /// **'A photo didn\'t upload. Check your connection and send again; photos already sent won\'t upload twice.'**
  String get register_error_upload;

  /// M1: saving the profile failed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your details. Check your connection and send again.'**
  String get register_error_save;

  /// M1 step 1: the first question (PLAN §10.0).
  ///
  /// In en, this message translates to:
  /// **'Do you have a workshop?'**
  String get register_type_question;

  /// M1: workshop path.
  ///
  /// In en, this message translates to:
  /// **'Yes, I have a workshop'**
  String get register_type_workshop;

  /// M1: independent path (M1·Ind).
  ///
  /// In en, this message translates to:
  /// **'No, I work independently'**
  String get register_type_independent;

  /// M1: city heading.
  ///
  /// In en, this message translates to:
  /// **'Your city'**
  String get register_city_label;

  /// M1: city note (cityId is changed only by admin).
  ///
  /// In en, this message translates to:
  /// **'You get jobs in this city. Only our team can change it later.'**
  String get register_city_help;

  /// City name.
  ///
  /// In en, this message translates to:
  /// **'Ahmedabad'**
  String get city_ahmedabad;

  /// City name.
  ///
  /// In en, this message translates to:
  /// **'Ankleshwar'**
  String get city_ankleshwar;

  /// City name.
  ///
  /// In en, this message translates to:
  /// **'Bharuch'**
  String get city_bharuch;

  /// M1: camera or gallery sheet title.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get register_photo_source_title;

  /// M1: use the camera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get register_photo_camera;

  /// M1: pick from gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get register_photo_gallery;

  /// M1: photo can't be made small enough.
  ///
  /// In en, this message translates to:
  /// **'That photo is too large. Try another one.'**
  String get register_photo_too_large;

  /// M1: empty photo slot.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get register_photo_add;

  /// M1: remove a toolkit photo.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get register_photo_remove;

  /// M1: name field.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get register_name_label;

  /// M1: profile photo slot.
  ///
  /// In en, this message translates to:
  /// **'Your photo (customers see it)'**
  String get register_photo_profile;

  /// M1 workshop: heading.
  ///
  /// In en, this message translates to:
  /// **'Your shop'**
  String get register_shop_heading;

  /// M1 workshop: shop name.
  ///
  /// In en, this message translates to:
  /// **'Shop name'**
  String get register_shop_name_label;

  /// M1 workshop: shop address.
  ///
  /// In en, this message translates to:
  /// **'Shop address'**
  String get register_shop_address_label;

  /// M1 workshop: shop photo slot.
  ///
  /// In en, this message translates to:
  /// **'Shop photo'**
  String get register_photo_shop;

  /// M1·Ind: heading.
  ///
  /// In en, this message translates to:
  /// **'How you work'**
  String get register_independent_heading;

  /// M1·Ind: experience.
  ///
  /// In en, this message translates to:
  /// **'Years of experience'**
  String get register_experience_label;

  /// M1·Ind: base area locality.
  ///
  /// In en, this message translates to:
  /// **'Where you usually start from'**
  String get register_base_area_label;

  /// M1·Ind: base area hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. GIDC Ankleshwar'**
  String get register_base_area_hint;

  /// M1·Ind: travel vehicle heading (shown to customers).
  ///
  /// In en, this message translates to:
  /// **'What you travel on'**
  String get register_travel_heading;

  /// M1·Ind: travel vehicle plate.
  ///
  /// In en, this message translates to:
  /// **'Its number plate'**
  String get register_travel_reg_label;

  /// M1·Ind: plate hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. GJ 16 CK 4471'**
  String get register_travel_reg_hint;

  /// M1·Ind: toolkit photos heading.
  ///
  /// In en, this message translates to:
  /// **'Your tools'**
  String get register_toolkit_heading;

  /// M1·Ind: toolkit photos help (2–5).
  ///
  /// In en, this message translates to:
  /// **'Add at least 2 photos of the tools you carry.'**
  String get register_toolkit_help;

  /// M1·Ind: toolkit photo slot.
  ///
  /// In en, this message translates to:
  /// **'Tools {number}'**
  String register_photo_toolkit(int number);

  /// Vehicle type.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get vehicle_type_car;

  /// Vehicle type.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get vehicle_type_bike;

  /// Vehicle type.
  ///
  /// In en, this message translates to:
  /// **'Scooter'**
  String get vehicle_type_scooter;

  /// Vehicle type.
  ///
  /// In en, this message translates to:
  /// **'EV'**
  String get vehicle_type_ev;

  /// M1 step 3: vehicle types.
  ///
  /// In en, this message translates to:
  /// **'Vehicles you work on'**
  String get register_vehicles_label;

  /// M1 step 3: services.
  ///
  /// In en, this message translates to:
  /// **'What you can fix'**
  String get register_services_label;

  /// Problem type.
  ///
  /// In en, this message translates to:
  /// **'Flat tyre'**
  String get problem_type_flat_tyre;

  /// Problem type.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get problem_type_battery;

  /// Problem type.
  ///
  /// In en, this message translates to:
  /// **'Won\'t start'**
  String get problem_type_wont_start;

  /// Problem type.
  ///
  /// In en, this message translates to:
  /// **'Overheating'**
  String get problem_type_overheating;

  /// Problem type.
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get problem_type_accident;

  /// Problem type.
  ///
  /// In en, this message translates to:
  /// **'Out of fuel'**
  String get problem_type_fuel;

  /// Problem type.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get problem_type_other;

  /// M1 step 4: KYC privacy note.
  ///
  /// In en, this message translates to:
  /// **'Only our verification team sees these. Customers never do.'**
  String get register_id_private;

  /// M1: ID proof slot.
  ///
  /// In en, this message translates to:
  /// **'ID proof'**
  String get register_photo_id_proof;

  /// M1·Ind: selfie with ID slot.
  ///
  /// In en, this message translates to:
  /// **'Selfie holding your ID'**
  String get register_photo_selfie;

  /// M1·Ind: address proof slot.
  ///
  /// In en, this message translates to:
  /// **'Address proof'**
  String get register_photo_address_proof;

  /// M1: UPI heading.
  ///
  /// In en, this message translates to:
  /// **'Where customers pay you'**
  String get register_upi_heading;

  /// M1: UPI ID.
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get register_upi_id_label;

  /// M1: UPI ID hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. name@bank'**
  String get register_upi_id_hint;

  /// M1: UPI name.
  ///
  /// In en, this message translates to:
  /// **'Name on the UPI account'**
  String get register_upi_name_label;

  /// M1·Ind: reference heading.
  ///
  /// In en, this message translates to:
  /// **'Someone who knows your work (optional)'**
  String get register_reference_heading;

  /// M1·Ind: reference help.
  ///
  /// In en, this message translates to:
  /// **'For example a workshop you trained at.'**
  String get register_reference_help;

  /// M1·Ind: reference name.
  ///
  /// In en, this message translates to:
  /// **'Their name'**
  String get register_reference_name_label;

  /// M1·Ind: reference phone.
  ///
  /// In en, this message translates to:
  /// **'Their phone'**
  String get register_reference_phone_label;

  /// M1·Ind: phone hint (E.164).
  ///
  /// In en, this message translates to:
  /// **'+91…'**
  String get register_reference_phone_hint;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Please fill this in'**
  String get error_field_required;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'That is too long'**
  String get error_field_too_long;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Please check this'**
  String get error_field_invalid;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Check the number, e.g. GJ 01 AB 1234 or 22 BH 1234 AA'**
  String get error_reg_no_invalid;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Check the number, e.g. +91 98765 43210'**
  String get error_phone_invalid;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Check the UPI ID, e.g. name@bank'**
  String get error_upi_invalid;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Enter years as a number, 0 to 60'**
  String get error_experience_invalid;

  /// Validation.
  ///
  /// In en, this message translates to:
  /// **'Add at least 2 photos of your tools'**
  String get error_toolkit_photos_too_few;

  /// M2 title.
  ///
  /// In en, this message translates to:
  /// **'We\'re checking your details'**
  String get pending_title;

  /// M2 body, workshop.
  ///
  /// In en, this message translates to:
  /// **'Usually within 24 hours. We\'ll let you know.'**
  String get pending_body_workshop;

  /// M2 body, independent (PLAN §10.0).
  ///
  /// In en, this message translates to:
  /// **'We\'ll call you for a short verification, usually within 24 hours.'**
  String get pending_body_independent;

  /// M2 blocked title.
  ///
  /// In en, this message translates to:
  /// **'Your account is on hold'**
  String get pending_blocked_title;

  /// M2 blocked body.
  ///
  /// In en, this message translates to:
  /// **'Please call support to find out more.'**
  String get pending_blocked_body;

  /// M2 checklist, workshop.
  ///
  /// In en, this message translates to:
  /// **'Shop details'**
  String get pending_item_shop;

  /// M2 checklist, independent.
  ///
  /// In en, this message translates to:
  /// **'Your details and tools'**
  String get pending_item_details;

  /// M2 checklist.
  ///
  /// In en, this message translates to:
  /// **'ID proof'**
  String get pending_item_id;

  /// M2 checklist, independent.
  ///
  /// In en, this message translates to:
  /// **'ID, selfie and address proof'**
  String get pending_item_id_selfie;

  /// M2 checklist, independent.
  ///
  /// In en, this message translates to:
  /// **'Verification call'**
  String get pending_item_call;

  /// M2 checklist state.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get pending_received;

  /// M2 checklist state.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get pending_checking;

  /// M2 checklist state.
  ///
  /// In en, this message translates to:
  /// **'We\'ll call you'**
  String get pending_call_waiting;

  /// M3 title.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboard_title;

  /// M3 toggle label when online.
  ///
  /// In en, this message translates to:
  /// **'You\'re online'**
  String get dashboard_online;

  /// M3 toggle subtitle when online.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you jobs nearby.'**
  String get dashboard_online_body;

  /// M3: waiting for the first GPS fix.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get dashboard_finding_location;

  /// M3 toggle label when offline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get dashboard_offline;

  /// M3 toggle subtitle when offline.
  ///
  /// In en, this message translates to:
  /// **'Go online to get jobs. We only use your location while you\'re online.'**
  String get dashboard_offline_body;

  /// M3: GPS off.
  ///
  /// In en, this message translates to:
  /// **'Your phone\'s location is switched off. Turn it on to go online.'**
  String get dashboard_gps_off;

  /// M3: opens location settings.
  ///
  /// In en, this message translates to:
  /// **'Turn on location'**
  String get dashboard_turn_on_location;

  /// M3: presence went stale, so the app stopped.
  ///
  /// In en, this message translates to:
  /// **'You went offline: we couldn\'t update your location for 2 minutes. Check your connection and go online again.'**
  String get dashboard_lost_connection;

  /// M3 stat.
  ///
  /// In en, this message translates to:
  /// **'Jobs today'**
  String get dashboard_jobs_today;

  /// M3 stat.
  ///
  /// In en, this message translates to:
  /// **'Earned today'**
  String get dashboard_earned_today;

  /// M3 list heading.
  ///
  /// In en, this message translates to:
  /// **'Recent jobs'**
  String get dashboard_recent_jobs;

  /// M3 empty list.
  ///
  /// In en, this message translates to:
  /// **'No jobs yet today. Stay online and they\'ll come to you.'**
  String get dashboard_no_jobs_yet;

  /// M4 title.
  ///
  /// In en, this message translates to:
  /// **'New job'**
  String get offer_title;

  /// M4 row label.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get offer_distance;

  /// M4 distance; km is already formatted.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String offer_distance_value(String km);

  /// M4 row label (locality only, never the address).
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get offer_area;

  /// M4 slider.
  ///
  /// In en, this message translates to:
  /// **'Slide to accept'**
  String get offer_slide_accept;

  /// M4 decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get offer_decline;

  /// M4: network error, retry.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach us. Check your connection and slide again.'**
  String get offer_failed;

  /// M4 closed: expired.
  ///
  /// In en, this message translates to:
  /// **'This job has timed out'**
  String get offer_expired_title;

  /// M4 closed: expired.
  ///
  /// In en, this message translates to:
  /// **'Offers last 30 seconds. We\'ll send you the next one nearby.'**
  String get offer_expired_body;

  /// M4 closed: withdrawn.
  ///
  /// In en, this message translates to:
  /// **'This job was taken back'**
  String get offer_withdrawn_title;

  /// M4 closed: withdrawn.
  ///
  /// In en, this message translates to:
  /// **'The customer cancelled or no longer needs help.'**
  String get offer_withdrawn_body;

  /// M4 closed: taken or gone.
  ///
  /// In en, this message translates to:
  /// **'This job is no longer available'**
  String get offer_taken_title;

  /// M4 closed: taken or gone.
  ///
  /// In en, this message translates to:
  /// **'It went to another mechanic. Stay online for the next one.'**
  String get offer_taken_body;

  /// M4 closed: offline or already on a job.
  ///
  /// In en, this message translates to:
  /// **'You can\'t take this job right now'**
  String get offer_not_available_title;

  /// M4 closed: offline or busy.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline or already on a job.'**
  String get offer_not_available_body;

  /// M4 closed: the callable said the mechanic's profile or KYC is missing.
  ///
  /// In en, this message translates to:
  /// **'Finish your profile first'**
  String get offer_profile_incomplete_title;

  /// M4 closed: profile incomplete.
  ///
  /// In en, this message translates to:
  /// **'Some details are missing. Complete your profile to take jobs.'**
  String get offer_profile_incomplete_body;

  /// M4 closed: the callable said the mechanic isn't approved.
  ///
  /// In en, this message translates to:
  /// **'You\'re not approved yet'**
  String get offer_not_approved_title;

  /// M4 closed: not approved.
  ///
  /// In en, this message translates to:
  /// **'We\'re still checking your documents. You can take jobs once you\'re approved.'**
  String get offer_not_approved_body;

  /// M4 closed: back to M3.
  ///
  /// In en, this message translates to:
  /// **'Back to dashboard'**
  String get offer_back;

  /// Offers notification title (full screen, like a call).
  ///
  /// In en, this message translates to:
  /// **'New job nearby'**
  String get offer_notification_title;

  /// Offers notification body.
  ///
  /// In en, this message translates to:
  /// **'Open within 30 seconds to accept.'**
  String get offer_notification_body;

  /// After accept, until M5 Navigate.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got the job'**
  String get job_accepted_title;

  /// After accept, until M5 Navigate.
  ///
  /// In en, this message translates to:
  /// **'The route to the customer opens here.'**
  String get job_accepted_body;
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
