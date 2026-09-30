// A5 Complaints & reviews + A6 Settings (#54). "Done when: switching a city off blocks new
// bookings there": A6 writes serviceAreas/{city}.active = false, which createBooking's
// resolveCity() reads (also checked against the real function on the emulator).

import 'package:admin_panel/app/router.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/fakes.dart';
import 'package:roadside_core/roadside_core.dart';

import 'support.dart';

void main() {
  late FakeFirebaseFirestore db;

  Future<void> open(WidgetTester tester, String path) async {
    db = FakeFirebaseFirestore();
    // A payment dispute on a completed Ahmedabad booking (independent mechanic).
    await db
        .doc('bookings/bookingAAA001')
        .set(RoadsideFakes.booking(status: BookingStatus.completed).toJson());
    await db.doc('complaints/c1').set(RoadsideFakes.complaint.copyWith(bookingId: 'bookingAAA001').toJson());
    // A service complaint on a Bharuch booking (workshop mechanic).
    await db
        .doc('bookings/bookingBBB002')
        .set(
          RoadsideFakes.booking(
            status: BookingStatus.completed,
            independent: false,
          ).copyWith(cityId: CityId.bharuch).toJson(),
        );
    await db
        .doc('complaints/c2')
        .set(
          RoadsideFakes.complaint
              .copyWith(
                bookingId: 'bookingBBB002',
                category: 'service',
                text: 'Mechanic was rude.',
                createdAt: RoadsideFakes.now,
              )
              .toJson(),
        );
    await db
        .doc('complaints/c3')
        .set(
          RoadsideFakes.complaint
              .copyWith(
                bookingId: 'bookingAAA001',
                status: ComplaintStatus.resolved,
                resolution: 'Refunded by UPI.',
              )
              .toJson(),
        );
    await db.doc('reviews/bookingAAA001').set(RoadsideFakes.review.toJson());
    await db.doc('appConfig/public').set(RoadsideFakes.appConfig.toJson());
    for (final MapEntry(:key, :value) in RoadsideFakes.serviceAreas.entries) {
      // createdAt as firebase/seed writes it, so the test can check it survives a save.
      await db.doc('serviceAreas/${key.value}').set(value.copyWith(createdAt: RoadsideFakes.now).toJson());
    }
    await db.doc('admins/admin-1').set({'email': 'ops@example.com'});
    await pumpPanel(tester, firestore: db);
    auth.emit(admin);
    await settle(tester);
    container.read(routerProvider).go(path);
    await settle(tester);
  }

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f.first);
    await tester.tap(f.first);
    await settle(tester);
  }

  Finder field(String label) => find.descendant(
    of: find.byWidgetPredicate((w) => w is LaneTextField && w.label == label),
    matching: find.byType(EditableText),
  );

  Future<List<Map<String, dynamic>>> audit() async =>
      (await db.collection('auditLogs').get()).docs.map((d) => d.data()).toList();

  group('A5 complaints & reviews', () {
    testPanel('open complaints, newest first, with the booking facts', (tester) async {
      await open(tester, '/complaints');
      expect(find.text('Open (2)'), findsOneWidget);
      expect(find.text('Mechanic was rude.'), findsWidgets);
      await tap(tester, find.text('Customer marked paid ₹450, mechanic says not received.'));
      expect(find.text('Payment dispute · #AAA001'), findsOneWidget);
      expect(find.textContaining('Raised by the mechanic, Kiran Patel'), findsOneWidget);
      expect(find.textContaining('₹450'), findsWidgets);
    });

    testPanel('city and mechanic-type filters', (tester) async {
      await open(tester, '/complaints');
      await tap(tester, find.text('Bharuch'));
      expect(find.text('Mechanic was rude.'), findsWidgets);
      expect(find.textContaining('mechanic says not received'), findsNothing);
      await tap(tester, find.text('All cities'));
      await tap(tester, find.text('Independent'));
      expect(find.text('Mechanic was rude.'), findsNothing);
    });

    testPanel('resolving needs a note, then writes it with an audit entry', (tester) async {
      await open(tester, '/complaints');
      await tap(tester, find.textContaining('mechanic says not received'));
      await tap(tester, find.text('Resolve'));
      expect((await db.doc('complaints/c1').get()).get('status'), 'open');

      await tester.enterText(field('Resolution note'), 'Called both; UPI transfer found.');
      await settle(tester);
      await tap(tester, find.text('Resolve'));
      final c1 = (await db.doc('complaints/c1').get()).data()!;
      expect([c1['status'], c1['resolution']], ['resolved', 'Called both; UPI transfer found.']);
      final log = (await audit()).single;
      expect([log['action'], log['target'], log['actorUid']], ['complaint.resolve', 'complaints/c1', 'u1']);
      expect(find.text('Complaint resolved.'), findsOneWidget);
    });

    testPanel('resolved tab shows the resolution; reviews tab lists ratings', (tester) async {
      await open(tester, '/complaints');
      await tap(tester, find.text('Resolved'));
      expect(find.textContaining('Refunded by UPI.'), findsWidgets);
      await tap(tester, find.text('Reviews'));
      expect(find.text('5 stars'), findsOneWidget);
      expect(find.textContaining('Fixed the puncture'), findsOneWidget);
    });
  });

  group('A6 settings', () {
    testPanel('the kill switch saves appConfig with an audit entry', (tester) async {
      await open(tester, '/settings');
      expect(find.text('ops@example.com'), findsWidgets); // admins, read only
      await tap(tester, find.byWidgetPredicate((w) => w is LaneSwitch && w.label == 'Take new bookings'));
      await tap(tester, find.text('Save'));
      final config = AppConfig.fromJson((await db.doc('appConfig/public').get()).data()!);
      expect(config.dispatchEnabled, isFalse);
      expect(config.supportPhone, RoadsideFakes.supportPhone);
      expect((await audit()).single['action'], 'appConfig.update');
    });

    testPanel('a bad phone number blocks saving', (tester) async {
      await open(tester, '/settings');
      await tester.enterText(field('Support phone'), '12345');
      await settle(tester);
      expect(find.textContaining('country code'), findsOneWidget);
      await tap(tester, find.text('Save'));
      expect((await db.doc('appConfig/public').get()).get('supportPhone'), RoadsideFakes.supportPhone);
    });

    testPanel('switching a city off saves serviceAreas/{city}.active = false', (tester) async {
      await open(tester, '/settings');
      await tap(tester, find.byWidgetPredicate((w) => w is LaneSwitch && w.label == 'Bharuch'));
      expect(find.textContaining('not in your area yet'), findsOneWidget);
      await tap(tester, find.bySemanticsLabel('Save Bharuch')); // secondary buttons render in caps
      final area = ServiceArea.fromJson((await db.doc('serviceAreas/bharuch').get()).data()!);
      expect(area.active, isFalse);
      expect(area.radiusKm, 12);
      expect(area.createdAt, RoadsideFakes.now); // kept
      final log = (await audit()).single;
      expect([log['action'], (log['after'] as Map)['active']], ['serviceArea.update', false]);

      // What createBooking decides for a pickup in Bharuch now (resolveCity mirrors it).
      final areas = {
        for (final c in CityId.values)
          c: ServiceArea.fromJson((await db.doc('serviceAreas/${c.value}').get()).data()!),
      };
      expect(resolveCity(21.70, 72.99, areas), isNull);
      expect(resolveCity(23.0497, 72.5117, areas), CityId.ahmedabad);
    });

    testPanel('radius must be 1 to 100 km', (tester) async {
      await open(tester, '/settings');
      await tester.enterText(field('Ahmedabad radius (km)'), '500');
      await settle(tester);
      expect(find.text('Between 1 and 100 km'), findsOneWidget);
      expect(find.bySemanticsLabel('Save Ahmedabad'), findsNothing);
      await tester.enterText(field('Ahmedabad radius (km)'), '30');
      await settle(tester);
      await tap(tester, find.bySemanticsLabel('Save Ahmedabad')); // secondary buttons render in caps
      expect((await db.doc('serviceAreas/ahmedabad').get()).get('radiusKm'), 30);
    });
  });
}
