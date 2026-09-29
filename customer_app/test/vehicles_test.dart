// #13: U2 Add vehicle, U3 My vehicles, and the vehicle repositories.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
import 'package:customer_app/features/vehicles/application/vehicles.dart';
import 'package:customer_app/features/vehicles/data/vehicle_repository.dart';
import 'package:customer_app/features/vehicles/presentation/add_vehicle_screen.dart';
import 'package:customer_app/features/vehicles/presentation/my_vehicles_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

const swift = VehicleDraft(
  type: VehicleType.car,
  brand: 'Maruti Suzuki',
  model: 'Swift',
  regNo: 'gj 1 ab 1234',
  fuel: Fuel.petrol,
);
const activa = VehicleDraft(
  type: VehicleType.scooter,
  brand: 'Honda',
  model: 'Activa',
  regNo: 'GJ05CD5678',
  fuel: Fuel.petrol,
);
const nexon = VehicleDraft(
  type: VehicleType.ev,
  brand: 'Tata',
  model: 'Nexon EV',
  regNo: '22BH1234AA',
  fuel: Fuel.electric,
);

/// The field set `firestore.rules` (#99) accepts for users/{uid}/vehicles.
const rulesKeys = {
  'type',
  'brand',
  'model',
  'regNo',
  'fuel',
  'isDefault',
  'createdAt',
  'updatedAt',
  'schemaVersion',
};
final rulesRegNo = RegExp(r'^([A-Z]{2}[0-9]{1,2}[A-Z]{0,3}[0-9]{4}|[0-9]{2}BH[0-9]{4}[A-Z]{1,2})$');

void main() {
  // The same behaviour from both repositories.
  final makers = <String, VehicleRepository Function()>{
    'in memory': () {
      var t = DateTime.utc(2026, 9, 29);
      return InMemoryVehicleRepository(clock: () => t = t.add(const Duration(seconds: 1)));
    },
    'Firestore': () => FirestoreVehicleRepository(RoadsideRefs(FakeFirebaseFirestore()), 'cust-1'),
  };

  for (final MapEntry(key: name, value: make) in makers.entries) {
    group('$name repository', () {
      late VehicleRepository repo;
      setUp(() => repo = make());

      Future<List<SavedVehicle>> all() => repo.watch().first;
      Future<List<String>> defaults() async => [
        for (final v in await all())
          if (v.vehicle.isDefault) v.vehicle.model,
      ];

      test('the first vehicle is the default; later ones are not unless asked', () async {
        await repo.add(swift);
        await repo.add(activa);
        expect(await defaults(), ['Swift']);
        await repo.add(
          const VehicleDraft(
            type: VehicleType.ev,
            brand: 'Tata',
            model: 'Nexon EV',
            regNo: '22BH1234AA',
            fuel: Fuel.electric,
            makeDefault: true,
          ),
        );
        expect(await defaults(), ['Nexon EV'], reason: 'exactly one default');
      });

      test('registration numbers are stored normalised; text is trimmed', () async {
        await repo.add(
          const VehicleDraft(
            type: VehicleType.car,
            brand: '  Maruti ',
            model: ' Swift ',
            regNo: 'gj-1-ab-23',
            fuel: Fuel.cng,
          ),
        );
        final v = (await all()).single.vehicle;
        expect(v.regNo, 'GJ01AB0023');
        expect((v.brand, v.model), ('Maruti', 'Swift'));
      });

      test('setDefault moves the default', () async {
        await repo.add(swift);
        final id = await repo.add(activa);
        await repo.setDefault(id);
        expect(await defaults(), ['Activa']);
      });

      test('deleting the default hands it to the oldest remaining vehicle', () async {
        final first = await repo.add(swift);
        await repo.add(activa);
        await repo.add(nexon);
        await repo.delete(first);
        final list = await all();
        expect([for (final v in list) v.vehicle.model], ['Activa', 'Nexon EV']);
        expect(await defaults(), ['Activa']);
      });

      test('restore puts a deleted default back as the default', () async {
        final first = await repo.add(swift);
        await repo.add(activa);
        final deleted = (await all()).firstWhere((v) => v.id == first);
        await repo.delete(first);
        await repo.restore(deleted);
        expect([for (final v in await all()) v.vehicle.model], containsAll(['Swift', 'Activa']));
        expect(await defaults(), ['Swift']);
      });
    });
  }

  test('Firestore writes exactly what the rules accept', () async {
    final db = FakeFirebaseFirestore();
    final repo = FirestoreVehicleRepository(RoadsideRefs(db), 'cust-1');
    await repo.add(swift);
    final second = await repo.add(activa);
    await repo.setDefault(second);
    for (final doc in (await db.collection('users/cust-1/vehicles').get()).docs) {
      final d = doc.data();
      expect(d.keys.toSet(), rulesKeys, reason: 'no extra or missing fields');
      expect(rulesRegNo.hasMatch(d['regNo'] as String), isTrue);
      expect(d['type'], isIn(['car', 'bike', 'scooter', 'ev']));
      expect(d['fuel'], isIn(['petrol', 'diesel', 'cng', 'electric']));
      expect(d['schemaVersion'], 1);
      expect(d['createdAt'], isA<Timestamp>(), reason: 'server timestamp, as the rules require');
      expect((d['brand'] as String).length, lessThanOrEqualTo(40));
    }
  });

  group('screens', () {
    late InMemoryVehicleRepository repo;

    Future<Widget> app({String language = 'en'}) async {
      SharedPreferences.setMockInitialValues({
        'first_run.language': language,
        'first_run.onboarded': true,
        'first_run.consent_version': kConsentVersion,
        'first_run.consent_at': '2026-09-29T10:15:00.000Z',
      });
      final prefs = await SharedPreferences.getInstance();
      return ProviderScope(
        overrides: [
          flavorProvider.overrideWithValue(AppFlavor.dev),
          sharedPreferencesProvider.overrideWithValue(prefs),
          vehicleRepositoryProvider.overrideWithValue(repo),
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 29, 6, 30)),
        ],
        child: const RoadsideApp(),
      );
    }

    Future<void> openVehicles(WidgetTester tester, {String language = 'en'}) async {
      await tester.pumpWidget(await app(language: language));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(LaneButton).first); // "My vehicles"
      await tester.pumpAndSettle();
      expect(find.byType(MyVehiclesScreen), findsOneWidget);
    }

    setUp(() => repo = InMemoryVehicleRepository());

    testWidgets('empty list offers Add; adding validates, then shows the vehicle as default', (tester) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await openVehicles(tester);
      expect(find.text('No vehicles yet'), findsOneWidget);
      await tester.tap(find.text('Add vehicle'));
      await tester.pumpAndSettle();
      expect(find.byType(AddVehicleScreen), findsOneWidget);

      // Nothing filled in: every field says so, nothing is saved.
      await tester.tap(find.text('Save vehicle'));
      await tester.pumpAndSettle();
      expect(find.text('Please fill this in'), findsNWidgets(3));
      expect(await repo.watch().first, isEmpty);

      await tester.enterText(find.widgetWithText(LaneTextField, 'Brand'), 'Maruti Suzuki');
      await tester.enterText(find.widgetWithText(LaneTextField, 'Model'), 'Swift');
      await tester.enterText(find.widgetWithText(LaneTextField, 'Registration number'), 'GJ 1 A');
      await tester.pumpAndSettle();
      expect(find.textContaining('Check the number'), findsOneWidget);

      await tester.enterText(find.widgetWithText(LaneTextField, 'Registration number'), 'gj 01 ab 1234');
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(PlateChip), matching: find.text('GJ 01 AB 1234')),
        findsOneWidget,
        reason: 'plate preview',
      );
      await tester.tap(find.text('Save vehicle'));
      await tester.pumpAndSettle();

      expect(find.byType(MyVehiclesScreen), findsOneWidget);
      expect(find.text('Maruti Suzuki Swift'), findsOneWidget);
      expect(find.text('Petrol · Default'), findsOneWidget);
    });

    testWidgets('choosing EV picks electric', (tester) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await openVehicles(tester);
      await tester.tap(find.text('Add vehicle'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('EV'));
      await tester.pumpAndSettle();
      final electric = tester.widget<LaneChip>(find.widgetWithText(LaneChip, 'Electric'));
      expect(electric.selected, isTrue);
    });

    testWidgets('tap makes a vehicle the default; the home shows it', (tester) async {
      await repo.add(swift);
      await repo.add(activa);
      await openVehicles(tester);
      await tester.tap(find.text('Honda Activa'));
      await tester.pumpAndSettle();
      expect(find.text('Petrol · Default'), findsOneWidget);
      expect(tester.widget<VehicleTile>(find.widgetWithText(VehicleTile, 'Honda Activa')).selected, isTrue);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Honda Activa'), findsOneWidget, reason: 'home shows the default vehicle');
    });

    testWidgets('swipe deletes with Undo; TalkBack gets a Delete action', (tester) async {
      await repo.add(swift);
      await repo.add(activa);
      await openVehicles(tester);
      await tester.drag(find.text('Maruti Suzuki Swift'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('Maruti Suzuki Swift'), findsNothing);
      expect(find.text('Vehicle removed'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Maruti Suzuki Swift'), findsOneWidget);
      expect(
        tester.widget<VehicleTile>(find.widgetWithText(VehicleTile, 'Maruti Suzuki Swift')).selected,
        isTrue,
      );

      // The row offers Delete to screen readers; run that action.
      final row = tester.widget<Semantics>(
        find
            .ancestor(of: find.widgetWithText(VehicleTile, 'Honda Activa'), matching: find.byType(Semantics))
            .first,
      );
      row.properties.customSemanticsActions![const CustomSemanticsAction(label: 'Delete')]!();
      await tester.pumpAndSettle();
      expect(find.text('Honda Activa'), findsNothing, reason: 'the Delete action removed it');
      await tester.pump(LaneToast.visibleFor); // let the Undo toast go
    });

    for (final (name, add) in [('list', false), ('add form', true)]) {
      testWidgets('$name fits at 320 px, 200% text, Hindi', (tester) async {
        await repo.add(swift);
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await openVehicles(tester, language: 'hi');
        if (add) {
          await tester.tap(find.byType(LaneButton).last);
          await tester.pumpAndSettle();
          expect(find.byType(AddVehicleScreen), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      });
    }
  });
}
