import 'package:flutter_test/flutter_test.dart';
import 'package:roadside_core/fakes.dart';
import 'package:roadside_core/roadside_core.dart';

void main() {
  final areas = RoadsideFakes.serviceAreas;

  test('distanceKm', () {
    // Ankleshwar and Bharuch centres are about 9 km apart across the Narmada.
    expect(distanceKm(21.6264, 73.0152, 21.7051, 72.9959), closeTo(8.96, 0.1));
    expect(distanceKm(23.0225, 72.5714, 23.0225, 72.5714), 0);
  });

  test('geohash matches the reference implementation', () {
    expect(encodeGeohash(57.64911, 10.40744, precision: 11), 'u4pruydqqvj');
    // Same output as geohash() in firebase/functions/src/lib/geo.ts.
    expect(encodeGeohash(23.0497, 72.5117), 'ts5e4h16jp');
    expect(encodeGeohash(23.0497, 72.5117, precision: 5), 'ts5e4');
  });

  group('resolveCity', () {
    test('Thaltej is in Ahmedabad', () {
      expect(resolveCity(23.0497, 72.5117, areas), CityId.ahmedabad);
    });

    test('where the circles overlap, the nearer centre wins', () {
      expect(resolveCity(21.63, 73.01, areas), CityId.ankleshwar);
      expect(resolveCity(21.70, 72.99, areas), CityId.bharuch);
    });

    test('outside every circle → null (not in your area yet)', () {
      expect(resolveCity(22.3072, 73.1812, areas), isNull); // Vadodara
    });

    test('an inactive city → null, even when a neighbour covers the point', () {
      final off = {...areas, CityId.bharuch: areas[CityId.bharuch]!.copyWith(active: false)};
      expect(resolveCity(21.70, 72.99, off), isNull);
    });
  });
}
