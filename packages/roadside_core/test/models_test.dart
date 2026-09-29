import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:roadside_core/fakes.dart';
import 'package:roadside_core/roadside_core.dart';

/// What Firestore hands back: the written map, with nested models already maps.
Map<String, dynamic> _stored(Map<String, Object?> json) => Map<String, dynamic>.from(json);

void main() {
  group('every fake survives a Firestore round trip', () {
    void roundTrip<T>(
      String name,
      T value,
      Map<String, Object?> Function(T) toJson,
      T Function(Map<String, dynamic>) fromJson,
    ) {
      test(name, () => expect(fromJson(_stored(toJson(value))), value));
    }

    roundTrip('AppUser', RoadsideFakes.customer, (v) => v.toJson(), AppUser.fromJson);
    for (final v in RoadsideFakes.vehicles) {
      roundTrip('Vehicle ${v.regNo}', v, (v) => v.toJson(), Vehicle.fromJson);
    }
    for (final m in [
      RoadsideFakes.workshopMechanic,
      RoadsideFakes.independentMechanic,
      RoadsideFakes.pendingMechanic,
    ]) {
      roundTrip('Mechanic ${m.name}', m, (v) => v.toJson(), Mechanic.fromJson);
    }
    for (final k in [RoadsideFakes.workshopKyc, RoadsideFakes.independentKyc, RoadsideFakes.pendingKyc]) {
      roundTrip('MechanicKyc ${k.upiId}', k, (v) => v.toJson(), MechanicKyc.fromJson);
    }
    roundTrip(
      'Presence',
      RoadsideFakes.presence(activeBookingId: 'b1'),
      (v) => v.toJson(),
      Presence.fromJson,
    );
    roundTrip('Offer', RoadsideFakes.offer(), (v) => v.toJson(), Offer.fromJson);
    RoadsideFakes.bookingsByStatus.forEach((status, b) {
      roundTrip('Booking ${status.value}', b, (v) => v.toJson(), Booking.fromJson);
    });
    roundTrip('BookingOtp', RoadsideFakes.otpLocked, (v) => v.toJson(), BookingOtp.fromJson);
    roundTrip('ChatMessage', RoadsideFakes.messages.first, (v) => v.toJson(), ChatMessage.fromJson);
    roundTrip('LiveLocation', RoadsideFakes.liveLocation, (v) => v.toJson(), LiveLocation.fromJson);
    roundTrip('ShareLink', RoadsideFakes.shareLink, (v) => v.toJson(), ShareLink.fromJson);
    for (final p in RoadsideFakes.prices) {
      roundTrip('Price ${Price.idFor(p.vehicleType, p.problemType)}', p, (v) => v.toJson(), Price.fromJson);
    }
    RoadsideFakes.serviceAreas.forEach((id, a) {
      roundTrip('ServiceArea ${id.value}', a, (v) => v.toJson(), ServiceArea.fromJson);
    });
    roundTrip('Review', RoadsideFakes.review, (v) => v.toJson(), Review.fromJson);
    roundTrip('Complaint', RoadsideFakes.complaint, (v) => v.toJson(), Complaint.fromJson);
    roundTrip('InboxItem', RoadsideFakes.inbox.first, (v) => v.toJson(), InboxItem.fromJson);
    roundTrip('AppConfig', RoadsideFakes.appConfigMaintenance, (v) => v.toJson(), AppConfig.fromJson);
    roundTrip('AuditLog', RoadsideFakes.auditLog, (v) => v.toJson(), AuditLog.fromJson);
  });

  group('Firestore types', () {
    test('dates are written as Timestamps and read back in UTC', () {
      final json = RoadsideFakes.car.toJson();
      expect(json['createdAt'], isA<Timestamp>());
      final local = DateTime(2026, 9, 29, 10, 30);
      final read = Vehicle.fromJson({...json, 'createdAt': Timestamp.fromDate(local)});
      expect(read.createdAt!.isUtc, isTrue);
      expect(read.createdAt, local.toUtc());
    });

    test('dates can also come from ISO strings and epoch millis (fixtures)', () {
      final base = RoadsideFakes.car.toJson();
      expect(Vehicle.fromJson({...base, 'createdAt': '2026-09-29T05:00:00Z'}).createdAt, RoadsideFakes.now);
      expect(
        Vehicle.fromJson({...base, 'createdAt': RoadsideFakes.now.millisecondsSinceEpoch}).createdAt,
        RoadsideFakes.now,
      );
    });

    test('geopoints stay GeoPoints and can come from {latitude, longitude}', () {
      final json = RoadsideFakes.liveLocation.toJson();
      expect(json['mechanicGeopoint'], isA<GeoPoint>());
      final read = LiveLocation.fromJson({
        ...json,
        'mechanicGeopoint': {'latitude': 23.04, 'longitude': 72.5},
      });
      expect(read.mechanicGeopoint, const GeoPoint(23.04, 72.5));
    });

    test('pending server timestamps (null) read fine', () {
      final json = {...RoadsideFakes.car.toJson(), 'createdAt': null, 'updatedAt': null};
      expect(Vehicle.fromJson(json).createdAt, isNull);
    });

    test('a wrong type names the field', () {
      final json = {...RoadsideFakes.car.toJson(), 'type': 'truck'};
      expect(() => Vehicle.fromJson(json), throwsA(isA<CheckedFromJsonException>()));
    });
  });

  group('wire values', () {
    test('enums are written as the §8 strings', () {
      final b = RoadsideFakes.booking(status: BookingStatus.inProgress).toJson();
      expect(b['status'], 'in_progress');
      expect(b['problemType'], 'flat_tyre');
      expect(b['cityId'], 'ahmedabad');
      expect(
        RoadsideFakes.booking(status: BookingStatus.completed).toJson()['paymentStatus'],
        'customer_marked_paid',
      );
      expect(BookingStatus.fromValue('no_mechanic_found'), BookingStatus.noMechanicFound);
      expect(() => BookingStatus.fromValue('done'), throwsArgumentError);
    });

    test('nested models are plain maps', () {
      final b = RoadsideFakes.booking().toJson();
      expect(b['pickup'], isA<Map<String, dynamic>>());
      expect(b['mechanicCard'], isA<Map<String, dynamic>>());
      expect((b['statusHistory'] as List).first, isA<Map<String, dynamic>>());
    });

    test("a mechanic's map holds only its own type's fields (the rules use hasOnly)", () {
      final workshop = RoadsideFakes.workshopMechanic.toJson().keys;
      expect(workshop, containsAll(['shopName', 'shopAddress', 'shopPhotoUrl']));
      expect(
        workshop,
        isNot(anyOf(contains('baseArea'), contains('experienceYears'), contains('travelVehicle'))),
      );
      final independent = RoadsideFakes.independentMechanic.toJson().keys;
      expect(independent, containsAll(['baseArea', 'experienceYears', 'toolkitPhotoUrls', 'travelVehicle']));
      expect(
        independent,
        isNot(anyOf(contains('shopName'), contains('shopAddress'), contains('shopPhotoUrl'))),
      );
    });

    test('a pending KYC has no admin-only fields', () {
      final keys = RoadsideFakes.pendingKyc.toJson().keys;
      expect(
        keys,
        isNot(anyOf(contains('kycCheckedBy'), contains('kycCheckedAt'), contains('verificationCall'))),
      );
    });

    test('booking timestamps leave out stops not reached', () {
      final t = RoadsideFakes.booking(status: BookingStatus.accepted).toJson()['timestamps'] as Map;
      expect(t.keys, ['requested', 'accepted']);
    });
  });

  group('helpers', () {
    test('Price.idFor and rangeFor', () {
      final p = RoadsideFakes.price(VehicleType.car, ProblemType.flatTyre);
      expect(Price.idFor(VehicleType.car, ProblemType.flatTyre), 'car_flat_tyre');
      expect(p.rangeFor(CityId.ahmedabad), const PriceRange(min: 350, max: 600));
      expect(p.rangeFor(CityId.bharuch), const PriceRange(min: 400, max: 700));
    });

    test('LocalizedText.of', () {
      final name = RoadsideFakes.serviceAreas[CityId.bharuch]!.name;
      expect(name.of(Language.gu), 'ભરૂચ');
      expect(name.of(Language.hi), 'भरूच');
    });

    test('RoleClaims.fromTokenClaims', () {
      final c = RoleClaims.fromTokenClaims({
        'role': 'mechanic',
        'mechanicStatus': 'approved',
        'phone_number': 'x',
      });
      expect(c.isApprovedMechanic, isTrue);
      expect(c.isAdmin, isFalse);
      expect(RoleClaims.fromTokenClaims({'role': 'superuser'}).role, isNull);
      expect(RoleClaims.fromTokenClaims(null), const RoleClaims());
    });

    test('stampNew and stampUpdate use server timestamps', () {
      final created = stampNew(RoadsideFakes.car.toJson());
      expect(created['createdAt'], isA<FieldValue>());
      expect(created['updatedAt'], isA<FieldValue>());
      expect(created['schemaVersion'], kSchemaVersion);
      expect(stampCreated(RoadsideFakes.review.toJson())['createdAt'], isA<FieldValue>());
      final updated = stampUpdate({'language': 'gu'});
      expect(updated.keys, ['language', 'updatedAt']);
    });
  });
}
