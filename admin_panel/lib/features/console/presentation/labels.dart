import 'package:roadside_core/roadside_core.dart';

import '../../../l10n/app_localizations.dart';

/// Display names for the shared enums, used across the console's screens.

String cityLabel(AppLocalizations l10n, CityId? city) => switch (city) {
  null => l10n.console_city_all,
  CityId.ahmedabad => l10n.console_city_ahmedabad,
  CityId.ankleshwar => l10n.console_city_ankleshwar,
  CityId.bharuch => l10n.console_city_bharuch,
};

String vehicleLabel(AppLocalizations l10n, VehicleType vehicle) => switch (vehicle) {
  VehicleType.car => l10n.vehicle_type_car,
  VehicleType.bike => l10n.vehicle_type_bike,
  VehicleType.scooter => l10n.vehicle_type_scooter,
  VehicleType.ev => l10n.vehicle_type_ev,
};

String problemLabel(AppLocalizations l10n, ProblemType problem) => switch (problem) {
  ProblemType.flatTyre => l10n.problem_type_flat_tyre,
  ProblemType.battery => l10n.problem_type_battery,
  ProblemType.wontStart => l10n.problem_type_wont_start,
  ProblemType.overheating => l10n.problem_type_overheating,
  ProblemType.accident => l10n.problem_type_accident,
  ProblemType.fuel => l10n.problem_type_fuel,
  ProblemType.other => l10n.problem_type_other,
};
