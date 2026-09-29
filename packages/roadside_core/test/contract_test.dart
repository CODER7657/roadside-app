// Keeps the Dart models in lock-step with the TypeScript mirror in firebase/functions/src/models
// (PLAN §8: "Both change in the same PR"). Fails when an enum value, a transition or a document
// field exists on one side only.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roadside_core/fakes.dart';
import 'package:roadside_core/roadside_core.dart';

const String _modelsDir = '../../firebase/functions/src/models';

String _ts(String file) => File('$_modelsDir/$file').readAsStringSync();

/// `export const NAME = [ 'a', 'b' ] as const;` → ['a', 'b'].
List<String> _tsConstArray(String source, String name) {
  final m = RegExp('export const $name = \\[([^\\]]*)\\] as const', multiLine: true).firstMatch(source);
  expect(m, isNotNull, reason: '$name not found in enums.ts');
  return RegExp("'([^']+)'").allMatches(m![1]!).map((x) => x[1]!).toList();
}

/// Top-level field names of `export interface NAME` (plus BaseDoc's when it extends it).
Set<String> _tsFields(String source, String name) {
  final m = RegExp('export interface $name( extends BaseDoc)? \\{\\n([\\s\\S]*?)\\n\\}').firstMatch(source);
  expect(m, isNotNull, reason: 'interface $name not found in documents.ts');
  final fields = RegExp(r'^  (\w+)\??:', multiLine: true).allMatches(m![2]!).map((x) => x[1]!).toSet();
  if (m[1] != null) fields.addAll(['createdAt', 'updatedAt', 'schemaVersion']);
  return fields;
}

void main() {
  final enumsTs = _ts('enums.ts');
  final statusTs = _ts('status.ts');
  final docsTs = _ts('documents.ts');

  group('enums match enums.ts', () {
    final cases = <String, List<String>>{
      'CITY_IDS': CityId.values.map((e) => e.value).toList(),
      'ROLES': Role.values.map((e) => e.value).toList(),
      'MECHANIC_STATUSES': MechanicStatus.values.map((e) => e.value).toList(),
      'MECHANIC_TYPES': MechanicType.values.map((e) => e.value).toList(),
      'LANGUAGES': Language.values.map((e) => e.value).toList(),
      'VEHICLE_TYPES': VehicleType.values.map((e) => e.value).toList(),
      'FUELS': Fuel.values.map((e) => e.value).toList(),
      'PROBLEM_TYPES': ProblemType.values.map((e) => e.value).toList(),
      'BOOKING_STATUSES': BookingStatus.values.map((e) => e.value).toList(),
      'PAYMENT_STATUSES': PaymentStatus.values.map((e) => e.value).toList(),
      'OFFER_STATES': OfferState.values.map((e) => e.value).toList(),
      'ACTORS': Actor.values.map((e) => e.value).toList(),
      'COMPLAINT_STATUSES': ComplaintStatus.values.map((e) => e.value).toList(),
    };
    cases.forEach((name, dart) {
      test(name, () => expect(dart, _tsConstArray(enumsTs, name)));
    });

    test('SCHEMA_VERSION', () {
      expect(enumsTs, contains('export const SCHEMA_VERSION = $kSchemaVersion;'));
    });
  });

  test('transition table matches status.ts', () {
    final ts = RegExp(r"\{ from: '(\w+)', to: '(\w+)', by: \[([^\]]*)\] \}")
        .allMatches(statusTs)
        .map((m) => '${m[1]}→${m[2]} by ${RegExp("'(\\w+)'").allMatches(m[3]!).map((x) => x[1]).join(',')}')
        .toList();
    final dart = kTransitions
        .map((t) => '${t.from.value}→${t.to.value} by ${t.by.map((a) => a.value).join(',')}')
        .toList();
    expect(ts, isNotEmpty);
    expect(dart, ts);
  });

  test('active statuses match status.ts', () {
    final m = RegExp(r'export const ACTIVE_STATUSES[^=]*= \[([^\]]*)\]').firstMatch(statusTs);
    expect(m, isNotNull);
    final ts = RegExp("'(\\w+)'").allMatches(m![1]!).map((x) => x[1]).toList();
    expect(kActiveStatuses.map((s) => s.value).toList(), ts);
  });

  group('document fields match documents.ts', () {
    Set<String> keys(Map<String, Object?> json) => json.keys.toSet();
    final booking = RoadsideFakes.booking(status: BookingStatus.completed);

    final cases = <String, Set<String>>{
      'Contact': keys(RoadsideFakes.customer.emergencyContacts.first.toJson()),
      'GeoLocation': keys(RoadsideFakes.presence().location.toJson()),
      'PriceRange': keys(booking.priceEstimate.toJson()),
      'UserDoc': keys(
        RoadsideFakes.customer.copyWith(fcmToken: 't', deletionRequestedAt: RoadsideFakes.now).toJson(),
      ),
      'VehicleDoc': keys(RoadsideFakes.car.toJson()),
      'MechanicDoc': {
        ...keys(RoadsideFakes.workshopMechanic.copyWith(fcmToken: 't').toJson()),
        ...keys(RoadsideFakes.independentMechanic.toJson()),
      },
      'MechanicKycDoc': keys(RoadsideFakes.independentKyc.toJson()),
      'PresenceDoc': keys(RoadsideFakes.presence().toJson()),
      'OfferDoc': keys(RoadsideFakes.offer().toJson()),
      'MechanicCard': keys(booking.mechanicCard!.toJson()),
      'StatusHistoryEntry': keys(booking.statusHistory.first.toJson()),
      'BookingDoc': keys(booking.toJson()),
      'BookingOtpDoc': keys(RoadsideFakes.otpLocked.toJson()),
      'MessageDoc': keys(RoadsideFakes.messages.first.toJson()),
      'LiveLocationDoc': keys(RoadsideFakes.liveLocation.toJson()),
      'ShareLinkDoc': keys(RoadsideFakes.shareLink.toJson()),
      'PriceDoc': keys(RoadsideFakes.price(VehicleType.car, ProblemType.flatTyre).toJson()),
      'ServiceAreaDoc': keys(RoadsideFakes.serviceAreas[CityId.ahmedabad]!.toJson()),
      'ReviewDoc': keys(RoadsideFakes.review.toJson()),
      'ComplaintDoc': keys(RoadsideFakes.complaint.toJson()),
      'InboxItemDoc': keys(RoadsideFakes.inbox.first.toJson()),
      'AppConfigDoc': keys(RoadsideFakes.appConfig.toJson()),
      'AuditLogDoc': keys(RoadsideFakes.auditLog.toJson()),
      'RoleClaims': keys(const RoleClaims().toJson()),
    };
    cases.forEach((name, dart) {
      test(name, () => expect(dart, _tsFields(docsTs, name)));
    });
  });
}
