// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Roadside Mechanic';

  @override
  String get home_placeholder_title => 'Jobs near you, when you\'re ready';

  @override
  String get home_placeholder_body =>
      'We\'re getting everything ready. Registration and going online arrive in the next update.';
}
