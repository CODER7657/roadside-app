import 'package:roadside_core/roadside_core.dart';

import '../../../l10n/app_localizations.dart';

/// Localised problem names (PLAN §8 `problemType`).
extension BookingLabels on AppLocalizations {
  String problemType(ProblemType p) => switch (p) {
    ProblemType.flatTyre => problem_type_flat_tyre,
    ProblemType.battery => problem_type_battery,
    ProblemType.wontStart => problem_type_wont_start,
    ProblemType.overheating => problem_type_overheating,
    ProblemType.accident => problem_type_accident,
    ProblemType.fuel => problem_type_fuel,
    ProblemType.other => problem_type_other,
  };
}
