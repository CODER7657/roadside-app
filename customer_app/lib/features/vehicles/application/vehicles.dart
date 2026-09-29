import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/vehicle_repository.dart';

/// In memory until sign-in (#96): then `FirestoreVehicleRepository(RoadsideRefs(
/// FirebaseFirestore.instance), uid)`.
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) => InMemoryVehicleRepository());

/// The customer's vehicles, oldest first.
final vehiclesProvider = StreamProvider<List<SavedVehicle>>(
  (ref) => ref.watch(vehicleRepositoryProvider).watch(),
);

/// The default vehicle (U1 Home's vehicle chip), or null when there are none.
final defaultVehicleProvider = Provider<SavedVehicle?>((ref) {
  final list = ref.watch(vehiclesProvider).value ?? const [];
  for (final v in list) {
    if (v.vehicle.isDefault) return v;
  }
  return list.isEmpty ? null : list.first;
});
