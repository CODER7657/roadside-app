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
