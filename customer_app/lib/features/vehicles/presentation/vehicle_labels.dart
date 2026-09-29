import 'package:roadside_core/roadside_core.dart';

import '../../../l10n/app_localizations.dart';

/// Localised names for vehicle types and fuels.
extension VehicleLabels on AppLocalizations {
  String vehicleType(VehicleType t) => switch (t) {
    VehicleType.car => vehicle_type_car,
    VehicleType.bike => vehicle_type_bike,
    VehicleType.scooter => vehicle_type_scooter,
    VehicleType.ev => vehicle_type_ev,
  };

  String fuel(Fuel f) => switch (f) {
    Fuel.petrol => fuel_petrol,
    Fuel.diesel => fuel_diesel,
    Fuel.cng => fuel_cng,
    Fuel.electric => fuel_electric,
  };
}
