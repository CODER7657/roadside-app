import 'package:roadside_core/roadside_core.dart';

import '../l10n/app_localizations.dart';

/// Turns a `roadside_core` validator result (an ARB key) into text in the app's language.
String? validationMessage(AppLocalizations l10n, String? errorKey) => switch (errorKey) {
  null => null,
  ValidationError.required => l10n.error_field_required,
  ValidationError.tooLong => l10n.error_field_too_long,
  ValidationError.regNoInvalid => l10n.error_reg_no_invalid,
  _ => l10n.error_field_invalid,
};
