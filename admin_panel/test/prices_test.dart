// A4 Price editor (#51). "Done when: createBooking uses the edited prices": the saved documents
// must have the shape Functions' priceFor() reads, i.e. roadside_core's Price.rangeFor().

import 'package:admin_panel/app/firebase_providers.dart';
import 'package:admin_panel/app/router.dart';
import 'package:admin_panel/features/console/application/city_filter.dart';
import 'package:admin_panel/features/prices/application/price_editor.dart';
import 'package:admin_panel/features/prices/data/price_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadside_core/fakes.dart';
import 'package:roadside_core/roadside_core.dart';

import 'support.dart';

const carFlat = 'car_flat_tyre'; // default 350–600, overrides Ankleshwar + Bharuch 400–700
const bikeFuel = 'bike_fuel'; // default 150–300, no overrides

Future<FakeFirebaseFirestore> seededDb() async {
  final db = FakeFirebaseFirestore();
  for (final p in RoadsideFakes.prices) {
    await db.doc('prices/${Price.idFor(p.vehicleType, p.problemType)}').set(p.toJson());
  }
  return db;
}

Map<String, Price> fakePrices() => {
  for (final p in RoadsideFakes.prices) Price.idFor(p.vehicleType, p.problemType): p,
};

void main() {
  group('validateRange', () {
    test('defaults need both amounts, overrides may be blank', () {
      expect(validateRange((min: '', max: ''), optional: false), PriceError.required);
      expect(validateRange((min: '', max: ''), optional: true), isNull);
      expect(validateRange((min: '300', max: ''), optional: true), PriceError.required);
    });

    test('whole rupees, 1 to 1,00,000, min below max', () {
      expect(validateRange((min: '350', max: '600'), optional: false), isNull);
      expect(validateRange((min: '3.5', max: '600'), optional: false), PriceError.notANumber);
      expect(validateRange((min: '0', max: '600'), optional: false), PriceError.outOfRange);
      expect(validateRange((min: '350', max: '100001'), optional: false), PriceError.outOfRange);
      expect(validateRange((min: '600', max: '600'), optional: false), PriceError.minNotBelowMax);
      expect(validateRange((min: '700', max: '600'), optional: false), PriceError.minNotBelowMax);
    });
  });

  group('drafts → edits', () {
    final prices = fakePrices();

    test('an edit back to the stored value is not a change', () {
      const s = PriceEditorState(drafts: {(priceId: carFlat, city: null): (min: '350', max: '600')});
      expect(s.changedCells(prices), isEmpty);
      expect(s.edits(prices), isEmpty);
    });

    test('default and overrides of one price combine into one edit', () {
      const s = PriceEditorState(
        drafts: {
          (priceId: carFlat, city: null): (min: '380', max: '650'),
          (priceId: carFlat, city: CityId.bharuch): (min: '', max: ''), // back to default
          (priceId: carFlat, city: CityId.ahmedabad): (min: '360', max: '620'),
        },
      );
      final edits = s.edits(prices);
      expect(edits, hasLength(1));
      final e = edits.single;
      expect(e.range, const PriceRange(min: 380, max: 650));
      expect(e.cityOverrides, {
        CityId.ankleshwar: const PriceRange(min: 400, max: 700),
        CityId.ahmedabad: const PriceRange(min: 360, max: 620),
      });
    });

    test('a city price for a price without a default is refused', () {
      const s = PriceEditorState(
        drafts: {(priceId: 'car_other', city: CityId.bharuch): (min: '400', max: '800')},
      );
      final withoutCarOther = {...prices}..remove('car_other');
      expect(() => s.edits(withoutCarOther), throwsStateError);
    });

    test('errors are only reported for edited cells', () {
      const s = PriceEditorState(drafts: {(priceId: bikeFuel, city: null): (min: '300', max: '200')});
      expect(s.errorOf((priceId: bikeFuel, city: null), prices), PriceError.minNotBelowMax);
      expect(s.errorOf((priceId: carFlat, city: null), prices), isNull);
      expect(s.hasErrors(prices), isTrue);
    });
  });

  group('PriceRepository.save', () {
    test('updates the document, removes empty overrides, and audits each change', () async {
      final db = await seededDb();
      final repo = PriceRepository(db);
      final before = fakePrices();
      await repo.save([
        PriceEdit(
          vehicleType: VehicleType.car,
          problemType: ProblemType.flatTyre,
          before: before[carFlat],
          range: const PriceRange(min: 380, max: 650),
          cityOverrides: const {CityId.bharuch: PriceRange(min: 450, max: 750)},
        ),
        PriceEdit(
          vehicleType: VehicleType.bike,
          problemType: ProblemType.fuel,
          before: before[bikeFuel],
          range: const PriceRange(min: 180, max: 320),
          cityOverrides: const {},
        ),
      ], actorUid: 'admin-1');

      final car = Price.fromJson((await db.doc('prices/$carFlat').get()).data()!);
      // What createBooking (priceFor) charges per city:
      expect(car.rangeFor(CityId.ahmedabad), const PriceRange(min: 380, max: 650));
      expect(car.rangeFor(CityId.ankleshwar), const PriceRange(min: 380, max: 650)); // override removed
      expect(car.rangeFor(CityId.bharuch), const PriceRange(min: 450, max: 750));
      expect(car.includes, 'Puncture repair or spare fitting'); // untouched
      expect(car.schemaVersion, 1);

      final bike = (await db.doc('prices/$bikeFuel').get()).data()!;
      expect(bike.containsKey('cityOverrides'), isFalse);
      expect([bike['min'], bike['max']], [180, 320]);

      final audit = (await db.collection('auditLogs').get()).docs.map((d) => d.data()).toList();
      expect(audit, hasLength(2));
      final carLog = audit.firstWhere((a) => a['target'] == 'prices/$carFlat');
      expect(carLog['actorUid'], 'admin-1');
      expect(carLog['action'], 'price.update');
      expect((carLog['before'] as Map)['min'], 350);
      expect((carLog['after'] as Map)['cityOverrides'], {
        'bharuch': {'min': 450, 'max': 750},
      });
    });

    test('creates a missing price with every field the rules require', () async {
      final db = FakeFirebaseFirestore();
      await PriceRepository(db).save([
        const PriceEdit(
          vehicleType: VehicleType.ev,
          problemType: ProblemType.battery,
          before: null,
          range: PriceRange(min: 500, max: 1200),
          cityOverrides: {},
        ),
      ], actorUid: 'admin-1');
      final doc = (await db.doc('prices/ev_battery').get()).data()!;
      expect(doc.keys.toSet(), {
        'vehicleType', 'problemType', 'min', 'max', 'includes', 'createdAt', 'updatedAt', 'schemaVersion', //
      });
      expect(Price.fromJson(doc).rangeFor(CityId.ahmedabad), const PriceRange(min: 500, max: 1200));
    });
  });

  group('A4 screen', () {
    late FakeFirebaseFirestore db;

    Future<void> openPrices(WidgetTester tester) async {
      db = await seededDb();
      await pumpPanel(tester, overrides: [firestoreProvider.overrideWithValue(db)]);
      auth.emit(admin);
      await settle(tester);
      container.read(routerProvider).go('/prices');
      await settle(tester);
    }

    Finder minOf(String vehicle, String problem) => find.bySemanticsLabel('$vehicle, $problem: minimum');
    Finder maxOf(String vehicle, String problem) => find.bySemanticsLabel('$vehicle, $problem: maximum');
    Finder editable(Finder labelled) => find.descendant(of: labelled, matching: find.byType(EditableText));

    testPanel('shows the problem × vehicle grid with the stored defaults', (tester) async {
      await openPrices(tester);
      expect(find.text('Default prices, all cities'), findsOneWidget);
      for (final heading in ['Car', 'Bike', 'Scooter', 'EV', 'Flat tyre', "Won't start", 'Out of fuel']) {
        expect(find.text(heading), findsWidgets, reason: heading);
      }
      expect(find.text('No unsaved changes'), findsOneWidget);
      final car = tester.widget<EditableText>(editable(minOf('Car', 'Flat tyre')));
      expect(car.controller.text, '350');
    });

    testPanel('an invalid cell shows its error and blocks saving', (tester) async {
      await openPrices(tester);
      await tester.enterText(editable(maxOf('Bike', 'Out of fuel')), '100');
      await settle(tester);
      expect(find.text('Minimum must be less than maximum'), findsOneWidget);
      expect(find.text('1 unsaved change'), findsOneWidget);
      await tester.tap(find.text('Save changes'));
      await settle(tester);
      expect((await db.doc('prices/$bikeFuel').get()).get('max'), 300);
    });

    testPanel('save writes the change and its audit entry', (tester) async {
      await openPrices(tester);
      await tester.enterText(editable(minOf('Car', 'Flat tyre')), '380');
      await settle(tester);
      await tester.tap(find.text('Save changes'));
      await settle(tester);

      expect((await db.doc('prices/$carFlat').get()).get('min'), 380);
      expect((await db.collection('auditLogs').get()).docs, hasLength(1));
      expect(find.text('Prices saved. New bookings use them now.'), findsOneWidget);
      expect(find.text('No unsaved changes'), findsOneWidget);
    });

    testPanel('a city shows its overrides, with the default as a hint, and blank means default', (
      tester,
    ) async {
      await openPrices(tester);
      await tester.tap(find.text('Ankleshwar'));
      await settle(tester);
      expect(container.read(cityFilterProvider), CityId.ankleshwar);
      expect(find.text('Ankleshwar prices'), findsOneWidget);
      expect(tester.widget<EditableText>(editable(minOf('Car', 'Flat tyre'))).controller.text, '400');
      expect(tester.widget<EditableText>(editable(minOf('Bike', 'Out of fuel'))).controller.text, '');

      // Clear Ankleshwar's car flat-tyre override and add one for bike fuel.
      await tester.enterText(editable(minOf('Car', 'Flat tyre')), '');
      await tester.enterText(editable(maxOf('Car', 'Flat tyre')), '');
      await tester.enterText(editable(minOf('Bike', 'Out of fuel')), '200');
      await tester.enterText(editable(maxOf('Bike', 'Out of fuel')), '400');
      await settle(tester);
      expect(find.text('2 unsaved changes'), findsOneWidget); // per cell, not per field
      await tester.tap(find.text('Save changes'));
      await settle(tester);

      final car = Price.fromJson((await db.doc('prices/$carFlat').get()).data()!);
      expect(car.rangeFor(CityId.ankleshwar), const PriceRange(min: 350, max: 600));
      expect(car.rangeFor(CityId.bharuch), const PriceRange(min: 400, max: 700));
      final bike = Price.fromJson((await db.doc('prices/$bikeFuel').get()).data()!);
      expect(bike.rangeFor(CityId.ankleshwar), const PriceRange(min: 200, max: 400));
      expect(bike.rangeFor(CityId.ahmedabad), const PriceRange(min: 150, max: 300));
    });

    testPanel('discard drops unsaved edits', (tester) async {
      await openPrices(tester);
      await tester.enterText(editable(minOf('Car', 'Flat tyre')), '999');
      await settle(tester);
      await tester.tap(find.text('Discard'));
      await settle(tester);
      expect(find.text('No unsaved changes'), findsOneWidget);
      expect(tester.widget<EditableText>(editable(minOf('Car', 'Flat tyre'))).controller.text, '350');
      expect((await db.doc('prices/$carFlat').get()).get('min'), 350);
    });

    testPanel('a failed load offers a retry', (tester) async {
      await pumpPanel(
        tester,
        overrides: [
          pricesProvider.overrideWith(
            (ref) => Stream<Map<String, Price>>.error(FirebaseException(plugin: 'x')),
          ),
        ],
      );
      auth.emit(admin);
      await settle(tester);
      container.read(routerProvider).go('/prices');
      await settle(tester);
      expect(find.text("Couldn't load the prices."), findsOneWidget);
    });
  });
}
