import 'package:flutter_test/flutter_test.dart';
import 'package:roadside_core/fakes.dart';
import 'package:roadside_core/roadside_core.dart';

void main() {
  test('a booking in every status, with consistent history', () {
    RoadsideFakes.bookingsByStatus.forEach((status, b) {
      expect(b.status, status);
      expect(b.statusHistory.last.status, status, reason: '$status');
      for (var i = 0; i < b.statusHistory.length - 1; i++) {
        final from = b.statusHistory[i].status;
        final to = b.statusHistory[i + 1].status;
        expect(Actor.values.any((a) => canTransition(from, to, a)), isTrue, reason: '$status: $from → $to');
      }
    });
  });

  test('cards and ids appear only after accept', () {
    final requested = RoadsideFakes.booking(status: BookingStatus.requested);
    expect(requested.mechanicId, isNull);
    expect(requested.mechanicCard, isNull);
    expect(requested.customerCard, isNull);
    final arriving = RoadsideFakes.booking(independent: false);
    expect(arriving.mechanicCard!.mechanicType, MechanicType.workshop);
    expect(arriving.mechanicCard!.shopName, 'Shaikh Auto Works');
    final independent = RoadsideFakes.booking();
    expect(independent.mechanicCard!.travelVehicleRegNo, 'GJ01EF4321');
    expect(independent.mechanicCard!.experienceYears, 6);
  });

  test('fake data passes the validators', () {
    for (final v in RoadsideFakes.vehicles) {
      expect(isValidRegNo(v.regNo), isTrue, reason: v.regNo);
    }
    expect(isIndianMobile(RoadsideFakes.customer.phone), isTrue);
    for (final c in RoadsideFakes.customer.emergencyContacts) {
      expect(isE164(c.phone), isTrue);
    }
    expect(RoadsideFakes.customer.emergencyContacts.length, lessThanOrEqualTo(kMaxEmergencyContacts));
  });

  test('prices cover every vehicle × problem with min < max', () {
    final prices = RoadsideFakes.prices;
    expect(prices.length, VehicleType.values.length * ProblemType.values.length);
    for (final p in prices) {
      expect(p.min, lessThan(p.max));
    }
  });

  test('the pickup and mechanic are in Ahmedabad', () {
    final b = RoadsideFakes.booking();
    expect(
      resolveCity(b.pickup.geopoint.latitude, b.pickup.geopoint.longitude, RoadsideFakes.serviceAreas),
      CityId.ahmedabad,
    );
  });
}
