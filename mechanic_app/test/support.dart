// Shared test data. Not a test file.
import 'package:mechanic_app/features/registration/data/registration_repository.dart';
import 'package:roadside_core/roadside_core.dart';

/// A complete workshop profile, as M1 would save it.
const workshopProfile = Mechanic(
  name: 'Ramesh Patel',
  profilePhotoUrl: 'https://firebasestorage.googleapis.com/v0/b/demo/o/p.jpg',
  mechanicType: MechanicType.workshop,
  shopName: 'Shree Auto',
  shopAddress: 'Station Road, Bharuch',
  shopPhotoUrl: 'https://firebasestorage.googleapis.com/v0/b/demo/o/s.jpg',
  cityId: CityId.bharuch,
  vehicleTypes: [VehicleType.car],
  services: [ProblemType.flatTyre],
);

/// A mechanic the admin has approved: the app opens on home.
InMemoryRegistrationRepository approvedMechanic() =>
    InMemoryRegistrationRepository(profile: workshopProfile.copyWith(status: MechanicStatus.approved));
