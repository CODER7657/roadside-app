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

  /// Temporary home screen until M3 Dashboard (#27) lands.
  ///
  /// In en, this message translates to:
  /// **'Jobs near you, when you\'re ready'**
  String get home_placeholder_title;

  /// Temporary home screen body until M3 Dashboard (#27) lands.
  ///
  /// In en, this message translates to:
  /// **'We\'re getting everything ready. Registration and going online arrive in the next update.'**
  String get home_placeholder_body;

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
