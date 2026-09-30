import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'lane_localizations_en.dart';
import 'lane_localizations_gu.dart';
import 'lane_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of LaneLocalizations
/// returned by `LaneLocalizations.of(context)`.
///
/// Applications need to include `LaneLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/lane_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: LaneLocalizations.localizationsDelegates,
///   supportedLocales: LaneLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the LaneLocalizations.supportedLocales
/// property.
abstract class LaneLocalizations {
  LaneLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static LaneLocalizations? of(BuildContext context) {
    return Localizations.of<LaneLocalizations>(context, LaneLocalizations);
  }

  static const LocalizationsDelegate<LaneLocalizations> delegate = _LaneLocalizationsDelegate();

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

  /// OfflineStrip: says the connection is gone and what still works (PLAN §6.5 ⑩). Calm, not alarming.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Calls and SMS still work.'**
  String get offline_strip_message;

  /// ErrorState: default title when the screen gives none.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error_state_title;

  /// ErrorState: default retry button.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get error_state_retry;

  /// Screen-reader label for a group of skeleton placeholders.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get skeleton_loading;

  /// JourneyRail: what TalkBack reads, e.g. "Step 3 of 6: On the way".
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}: {stop}'**
  String journey_rail_step(int step, int total, String stop);

  /// JourneyRail: the booking ended without the job, e.g. "Ended: Cancelled".
  ///
  /// In en, this message translates to:
  /// **'Ended: {stop}'**
  String journey_rail_cancelled(String stop);

  /// TrustPass: badge for approved, KYC-checked mechanics.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get trust_verified;

  /// TrustPass: workshop mechanic line.
  ///
  /// In en, this message translates to:
  /// **'Verified workshop'**
  String get trust_verified_workshop;

  /// TrustPass: independent mechanic line (PLAN §10.0).
  ///
  /// In en, this message translates to:
  /// **'Verified independent mechanic · {years} yrs'**
  String trust_verified_independent(int years);

  /// TrustPass: completed jobs next to the rating.
  ///
  /// In en, this message translates to:
  /// **'{count} jobs'**
  String trust_jobs(int count);

  /// TrustPass: caps label above the 4-digit code.
  ///
  /// In en, this message translates to:
  /// **'Start code'**
  String get trust_start_code;

  /// TrustPass: safety line under the code.
  ///
  /// In en, this message translates to:
  /// **'Share this code only when the mechanic is standing with you.'**
  String get trust_start_code_hint;

  /// LaneOtpDisplay: tap hint (opens the code full screen).
  ///
  /// In en, this message translates to:
  /// **'Show large'**
  String get otp_show_big;

  /// LaneOtpDisplay: closes the full-screen code.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get otp_close;

  /// LaneOtpInput: field label for screen readers.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get otp_input_label;

  /// CountdownRing: what TalkBack reads.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds left'**
  String countdown_seconds_left(int seconds);

  /// AccuracyBadge: before the first fix.
  ///
  /// In en, this message translates to:
  /// **'Finding your location'**
  String get accuracy_locating;

  /// AccuracyBadge: accuracy in metres.
  ///
  /// In en, this message translates to:
  /// **'±{meters} m'**
  String accuracy_meters(int meters);

  /// AccuracyBadge: accuracy over 50 m; asks to move the pin.
  ///
  /// In en, this message translates to:
  /// **'±{meters} m · Adjust pin'**
  String accuracy_adjust(int meters);

  /// AccuracyBadge: what TalkBack reads.
  ///
  /// In en, this message translates to:
  /// **'Location accurate to {meters} metres'**
  String accuracy_semantics(int meters);

  /// PriceRange: what TalkBack reads, e.g. "₹350 to ₹600".
  ///
  /// In en, this message translates to:
  /// **'{min} to {max}'**
  String price_range_semantics(String min, String max);
}

class _LaneLocalizationsDelegate extends LocalizationsDelegate<LaneLocalizations> {
  const _LaneLocalizationsDelegate();

  @override
  Future<LaneLocalizations> load(Locale locale) {
    return SynchronousFuture<LaneLocalizations>(lookupLaneLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_LaneLocalizationsDelegate old) => false;
}

LaneLocalizations lookupLaneLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LaneLocalizationsEn();
    case 'gu':
      return LaneLocalizationsGu();
    case 'hi':
      return LaneLocalizationsHi();
  }

  throw FlutterError(
    'LaneLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
