// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Roadside';

  @override
  String get home_placeholder_title => 'Help on the road, in minutes';

  @override
  String get home_placeholder_body =>
      'We\'re getting everything ready. Booking a mechanic arrives in the next update.';
}
