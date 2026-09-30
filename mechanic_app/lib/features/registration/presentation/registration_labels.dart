import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';

import '../../../l10n/app_localizations.dart';

/// Localised names for M1 choices and roadside_core validator keys.
extension RegistrationLabels on AppLocalizations {
  String city(CityId c) => switch (c) {
    CityId.ahmedabad => city_ahmedabad,
    CityId.ankleshwar => city_ankleshwar,
    CityId.bharuch => city_bharuch,
  };

  String vehicleType(VehicleType t) => switch (t) {
    VehicleType.car => vehicle_type_car,
    VehicleType.bike => vehicle_type_bike,
    VehicleType.scooter => vehicle_type_scooter,
    VehicleType.ev => vehicle_type_ev,
  };

  String problemType(ProblemType p) => switch (p) {
    ProblemType.flatTyre => problem_type_flat_tyre,
    ProblemType.battery => problem_type_battery,
    ProblemType.wontStart => problem_type_wont_start,
    ProblemType.overheating => problem_type_overheating,
    ProblemType.accident => problem_type_accident,
    ProblemType.fuel => problem_type_fuel,
    ProblemType.other => problem_type_other,
  };

  /// A roadside_core `ValidationError` key as text in the app's language.
  String? error(String? key) => switch (key) {
    null => null,
    ValidationError.required => error_field_required,
    ValidationError.tooLong => error_field_too_long,
    ValidationError.phoneInvalid => error_phone_invalid,
    ValidationError.regNoInvalid => error_reg_no_invalid,
    ValidationError.upiInvalid => error_upi_invalid,
    ValidationError.experienceInvalid => error_experience_invalid,
    ValidationError.toolkitPhotosTooFew => error_toolkit_photos_too_few,
    _ => error_field_invalid,
  };
}

LaneIcons vehicleIcon(VehicleType t) => switch (t) {
  VehicleType.car => LaneIcons.car,
  VehicleType.bike => LaneIcons.bike,
  VehicleType.scooter => LaneIcons.scooter,
  VehicleType.ev => LaneIcons.ev,
};

LaneIcons problemIcon(ProblemType p) => switch (p) {
  ProblemType.flatTyre => LaneIcons.flatTyre,
  ProblemType.battery => LaneIcons.battery,
  ProblemType.wontStart => LaneIcons.wontStart,
  ProblemType.overheating => LaneIcons.overheating,
  ProblemType.accident => LaneIcons.accident,
  ProblemType.fuel => LaneIcons.fuel,
  ProblemType.other => LaneIcons.other,
};
