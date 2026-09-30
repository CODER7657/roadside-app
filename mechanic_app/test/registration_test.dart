// #26: M1 registration (workshop + independent) and M2 approval pending.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:mechanic_app/app/app.dart';
import 'package:mechanic_app/app/flavor.dart';
import 'package:mechanic_app/app/router.dart';
import 'package:mechanic_app/app/secure_window.dart';
import 'package:mechanic_app/features/first_run/application/first_run.dart';
import 'package:mechanic_app/features/help/presentation/help_screen.dart';
import 'package:mechanic_app/features/permissions/application/permission_service.dart';
import 'package:mechanic_app/features/permissions/presentation/permission_explainer_screen.dart';
import 'package:mechanic_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:mechanic_app/features/registration/application/registration.dart';
import 'package:mechanic_app/features/registration/data/mechanic_photos.dart';
import 'package:mechanic_app/features/registration/data/registration_repository.dart';
import 'package:mechanic_app/features/registration/presentation/pending_screen.dart';
import 'package:mechanic_app/features/registration/presentation/registration_screen.dart';
import 'package:roadside_core/roadside_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

/// A photo uploaded under a unique name, e.g. `mechanics/mech-1/kyc/id-proof-<ms>-<salt>.jpg`.
Matcher photoPath(String folder, String base) => matches(
  RegExp(
    '^mechanics/mech-1/$folder/$base-'
    r'\d+-[0-9a-z]+\.jpg$',
  ),
);

/// Camera permission as the phone has it; asking grants it.
class _FakePermissions implements PermissionService {
  PermissionAccess camera = PermissionAccess.granted;
  final requested = <AppPermission>[];

  @override
  Future<PermissionAccess> status(AppPermission permission) async =>
      permission == AppPermission.camera ? camera : PermissionAccess.granted;

  @override
  Future<PermissionAccess> request(AppPermission permission) async {
    requested.add(permission);
    if (permission == AppPermission.camera) camera = PermissionAccess.granted;
    return PermissionAccess.granted;
  }

  @override
  Future<bool> openSettings() async => true;
}

class _FakeSecureWindow implements SecureWindow {
  final calls = <bool>[];

  @override
  Future<void> setSecure(bool secure) async => calls.add(secure);
}

class _FakePicker implements PhotoPicker {
  _FakePicker({this.cancel = false});

  final bool cancel;
  int picks = 0;

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    if (cancel) return null;
    picks++;
    return tinyPng;
  }
}

class _FakeSession implements AuthSession {
  int refreshes = 0;

  @override
  String get uid => 'mech-1';

  @override
  String get phone => '+919876543210';

  @override
  Future<void> refreshClaims() async => refreshes++;
}

/// A real 1×1 PNG, so Image.memory can decode what the fake picker returns.
final tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

final identityCompressor = PhotoCompressor(encode: (bytes, quality) async => bytes);

/// A draft that passes every step for [type].
RegistrationDraft completeDraft(MechanicType type) {
  final photo = tinyPng;
  final independent = type == MechanicType.independent;
  return RegistrationDraft(
    mechanicType: type,
    cityId: CityId.ankleshwar,
    name: ' Ramesh Patel ',
    shopName: 'Shree Auto',
    shopAddress: 'Station Road',
    experienceYears: '6',
    baseLocality: 'GIDC Ankleshwar',
    travelVehicleType: VehicleType.scooter,
    travelRegNo: 'gj 16 ck 4471',
    vehicleTypes: {VehicleType.car, VehicleType.bike},
    services: {ProblemType.flatTyre, ProblemType.battery},
    upiId: 'ramesh@okaxis',
    upiName: 'Ramesh Patel',
    photos: {
      RegistrationPhoto.profile: photo,
      RegistrationPhoto.idProof: photo,
      if (independent) ...{
        RegistrationPhoto.selfieWithId: photo,
        RegistrationPhoto.addressProof: photo,
      } else
        RegistrationPhoto.shop: photo,
    },
    toolkitPhotos: independent ? [photo, photo] : const [],
  );
}

void main() {
  group('RegistrationDraft', () {
    test('a complete draft has no errors on any step, for both types', () {
      for (final type in MechanicType.values) {
        for (final step in RegistrationStep.values) {
          expect(completeDraft(type).errorsFor(step), isEmpty, reason: '$type $step');
        }
      }
    });

    test('step 1 needs the type and the city', () {
      expect(const RegistrationDraft().errorsFor(RegistrationStep.type).keys, {'mechanicType', 'cityId'});
    });

    test('workshop: shop fields required; independent fields not asked', () {
      final d = completeDraft(MechanicType.workshop).copyWith(shopName: ' ', photos: {});
      expect(d.errorsFor(RegistrationStep.aboutYou).keys.toSet(), {
        'shopName',
        'profilePhotoUrl',
        'shopPhotoUrl',
      });
    });

    test('independent: experience, base area, travel plate, ≥ 2 toolkit photos', () {
      final full = completeDraft(MechanicType.independent);
      expect(full.copyWith(experienceYears: '70').errorsFor(RegistrationStep.aboutYou), {
        'experienceYears': ValidationError.experienceInvalid,
      });
      expect(full.copyWith(baseLocality: '').errorsFor(RegistrationStep.aboutYou).keys, ['baseArea']);
      expect(full.copyWith(travelRegNo: 'NOT A PLATE').errorsFor(RegistrationStep.aboutYou), {
        'travelVehicle': ValidationError.regNoInvalid,
      });
      expect(full.copyWith(toolkitPhotos: [Uint8List(1)]).errorsFor(RegistrationStep.aboutYou), {
        'toolkitPhotoUrls': ValidationError.toolkitPhotosTooFew,
      });
    });

    test('step 3 needs at least one vehicle type and one service', () {
      final d = completeDraft(MechanicType.workshop).copyWith(vehicleTypes: {}, services: {});
      expect(d.errorsFor(RegistrationStep.work).keys.toSet(), {'vehicleTypes', 'services'});
    });

    test('step 4: UPI checked; independents also need selfie and address proof', () {
      final w = completeDraft(MechanicType.workshop).copyWith(upiId: 'not-upi');
      expect(w.errorsFor(RegistrationStep.idAndPay), {'upiId': ValidationError.upiInvalid});
      final i = completeDraft(MechanicType.independent);
      final noDocs = i.copyWith(photos: {...i.photos}..remove(RegistrationPhoto.selfieWithId));
      expect(noDocs.errorsFor(RegistrationStep.idAndPay).keys, ['selfieWithIdPath']);
    });

    test('a reference is optional, but half of one is an error', () {
      final i = completeDraft(MechanicType.independent);
      expect(i.copyWith(referencePhone: '+919812345678').errorsFor(RegistrationStep.idAndPay).keys, [
        'referenceContact',
      ]);
      expect(
        i.copyWith(referenceName: 'Mahesh', referencePhone: '123').errorsFor(RegistrationStep.idAndPay),
        {'referenceContact': ValidationError.phoneInvalid},
      );
      expect(
        i
            .copyWith(referenceName: 'Mahesh', referencePhone: '+919812345678')
            .errorsFor(RegistrationStep.idAndPay),
        isEmpty,
      );
    });

    test('each type writes only its own fields (the rules reject the other type’s)', () {
      final w = completeDraft(MechanicType.workshop).toMechanic().toJson();
      expect(w.keys, containsAll(['shopName', 'shopAddress', 'shopPhotoUrl']));
      expect(w.keys, isNot(contains('baseArea')));
      expect(w.keys, isNot(contains('travelVehicle')));
      expect(w['name'], 'Ramesh Patel', reason: 'trimmed');

      final draft = completeDraft(MechanicType.independent);
      final i = draft.toMechanic().toJson();
      expect(i.keys, isNot(contains('shopName')));
      expect((i['travelVehicle'] as Map)['regNo'], 'GJ16CK4471', reason: 'normalised plate');
      expect((i['baseArea'] as Map)['locality'], 'GIDC Ankleshwar');

      expect(completeDraft(MechanicType.workshop).toKyc().toJson().keys, isNot(contains('selfieWithIdPath')));
      expect(draft.toKyc().toJson().keys, containsAll(['selfieWithIdPath', 'addressProofPath']));
    });

    test('city centres match the seeded service areas', () {
      final seed = jsonDecode(
        File('../firebase/seed/data/serviceAreas.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      for (final city in CityId.values) {
        final centre = (seed[city.value] as Map<String, dynamic>)['center'] as List<dynamic>;
        expect(kCityCentres[city], (centre[0], centre[1]), reason: city.value);
      }
    });
  });

  group('RegistrationController.submit', () {
    late ProviderContainer container;
    late FakeMechanicPhotoUploader uploader;
    late InMemoryRegistrationRepository repo;

    ProviderContainer make() => ProviderContainer(
      overrides: [
        mechanicPhotoUploaderProvider.overrideWithValue(uploader),
        registrationRepositoryProvider.overrideWithValue(repo),
        photoCompressorProvider.overrideWithValue(identityCompressor),
      ],
    );

    setUp(() {
      uploader = FakeMechanicPhotoUploader(uid: 'mech-1');
      repo = InMemoryRegistrationRepository();
      container = make();
      addTearDown(container.dispose);
    });

    void fill(MechanicType type) =>
        container.read(registrationProvider.notifier).update((_) => completeDraft(type));

    test('workshop: profile + shop photos to shop/, ID to kyc/ (as a path), then saved', () async {
      fill(MechanicType.workshop);
      expect(await container.read(registrationProvider.notifier).submit(), isTrue);
      expect(uploader.uploaded, [
        photoPath('shop', 'profile'),
        photoPath('kyc', 'id-proof'),
        photoPath('shop', 'shop'),
      ]);
      expect(repo.profile!.shopPhotoUrl, startsWith('https://firebasestorage.googleapis.com/'));
      expect(repo.kyc!.idProofPath, photoPath('kyc', 'id-proof'));
      expect(repo.profile!.status, MechanicStatus.pending);
      expect(repo.claimRefreshes, 1);
      expect(container.read(registrationProvider).submitted, isTrue);
    });

    test('independent: toolkit to shop/, selfie and address proof to kyc/', () async {
      fill(MechanicType.independent);
      await container.read(registrationProvider.notifier).submit();
      expect(uploader.uploaded, [
        photoPath('shop', 'profile'),
        photoPath('kyc', 'id-proof'),
        photoPath('shop', 'toolkit-1'),
        photoPath('shop', 'toolkit-2'),
        photoPath('kyc', 'selfie-with-id'),
        photoPath('kyc', 'address-proof'),
      ]);
      expect(repo.profile!.toolkitPhotoUrls, hasLength(2));
      expect(repo.kyc!.selfieWithIdPath, photoPath('kyc', 'selfie-with-id'));
    });

    test('an upload failure keeps what worked; the retry only sends the rest', () async {
      // The 2nd upload (the ID proof) fails once.
      var calls = 0;
      final flaky = _CountingUploader(uploader, failOnCall: 2, onCall: () => calls++);
      container.dispose();
      container = ProviderContainer(
        overrides: [
          mechanicPhotoUploaderProvider.overrideWithValue(flaky),
          registrationRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      fill(MechanicType.workshop);
      final c = container.read(registrationProvider.notifier);

      expect(await c.submit(), isFalse);
      expect(container.read(registrationProvider).submitError, SubmitError.upload);
      expect(repo.profile, isNull, reason: 'nothing saved without every photo');

      expect(await c.submit(), isTrue);
      expect(
        uploader.uploaded.where((p) => p.contains('/shop/profile-')),
        hasLength(1),
        reason: 'not sent twice',
      );
      expect(calls, 4, reason: 'profile, ID (failed), ID again, shop');
    });

    test('backing out of the camera or gallery changes nothing', () async {
      container.dispose();
      container = ProviderContainer(
        overrides: [
          photoPickerProvider.overrideWithValue(_FakePicker(cancel: true)),
          photoCompressorProvider.overrideWithValue(identityCompressor),
        ],
      );
      addTearDown(container.dispose);
      final c = container.read(registrationProvider.notifier);
      expect(await c.pickPhoto(RegistrationPhoto.profile, PhotoSource.camera), isFalse);
      expect(await c.addToolkitPhoto(PhotoSource.gallery), isFalse);
      final d = container.read(registrationProvider).draft;
      expect(d.photos, isEmpty);
      expect(d.toolkitPhotos, isEmpty);
    });

    test('a save failure can be retried', () async {
      repo.failNext = 1;
      fill(MechanicType.workshop);
      final c = container.read(registrationProvider.notifier);
      expect(await c.submit(), isFalse);
      expect(container.read(registrationProvider).submitError, SubmitError.save);
      expect(await c.submit(), isTrue);
      expect(uploader.uploaded, hasLength(3), reason: 'photos were uploaded once');
    });

    // P1's #145 review: KYC paths are write-once (storage.rules), and the fake refuses a
    // second write to the same path, like the rules.
    test('a save failure, then a new ID photo: the retry uploads it under a new name', () async {
      container.dispose();
      container = ProviderContainer(
        overrides: [
          mechanicPhotoUploaderProvider.overrideWithValue(uploader),
          registrationRepositoryProvider.overrideWithValue(repo),
          photoCompressorProvider.overrideWithValue(identityCompressor),
          photoPickerProvider.overrideWithValue(_FakePicker()),
        ],
      );
      addTearDown(container.dispose);
      repo.failNext = 1;
      fill(MechanicType.workshop);
      final c = container.read(registrationProvider.notifier);
      expect(await c.submit(), isFalse);
      expect(await c.pickPhoto(RegistrationPhoto.idProof, PhotoSource.camera), isTrue);
      expect(await c.submit(), isTrue);
      final ids = uploader.uploaded.where((p) => p.contains('/kyc/id-proof-')).toList();
      expect(ids, hasLength(2));
      expect(ids.toSet(), hasLength(2), reason: 'never the same KYC path twice');
      expect(repo.kyc!.idProofPath, ids.last);
    });

    test('the app restarts mid-submit: KYC is uploaded again under new names', () async {
      repo.failNext = 1;
      fill(MechanicType.independent);
      expect(await container.read(registrationProvider.notifier).submit(), isFalse);

      // A fresh start: the controller has no record of what was uploaded.
      container.dispose();
      container = make();
      addTearDown(container.dispose);
      fill(MechanicType.independent);
      expect(await container.read(registrationProvider.notifier).submit(), isTrue);
      final kyc = uploader.uploaded.where((p) => p.contains('/kyc/')).toList();
      expect(kyc, hasLength(6));
      expect(kyc.toSet(), hasLength(6));
    });

    test('the fake refuses a second write to a KYC path, like the rules', () async {
      await uploader.uploadKycDocument(fileName: 'id-proof.jpg', bytes: tinyPng);
      expect(() => uploader.uploadKycDocument(fileName: 'id-proof.jpg', bytes: tinyPng), throwsException);
    });

    test("photo names are unique and pass the rules' file-name check", () {
      final now = DateTime.utc(2026, 9, 30, 12);
      final a = uniquePhotoName('id-proof', now: now);
      final b = uniquePhotoName('id-proof', now: now);
      expect(a, matches(RegExp(r'^id-proof-\d+-[0-9a-z]+\.jpg$')));
      expect(a, matches(RegExp(r'^[A-Za-z0-9._-]{1,100}$')), reason: 'storage.rules isFileName');
      expect(a, isNot(b), reason: 'unique even within the same millisecond');
    });

    test('submit with a missing field jumps to that step instead', () async {
      container
          .read(registrationProvider.notifier)
          .update((_) => completeDraft(MechanicType.workshop).copyWith(upiId: ''));
      expect(await container.read(registrationProvider.notifier).submit(), isFalse);
      final s = container.read(registrationProvider);
      expect(s.step, RegistrationStep.idAndPay);
      expect(s.errors.keys, ['upiId']);
      expect(uploader.uploaded, isEmpty);
    });
  });

  group('FirestoreRegistrationRepository', () {
    test('writes profile and KYC in one batch, phone from Auth, then refreshes claims', () async {
      final db = FakeFirebaseFirestore();
      final session = _FakeSession();
      final repo = FirestoreRegistrationRepository(db, session);
      final draft = completeDraft(MechanicType.independent);
      await repo.submit(
        draft.toMechanic(
          urls: {RegistrationPhoto.profile: 'https://x/p.jpg'},
          toolkitUrls: ['https://x/t1.jpg', 'https://x/t2.jpg'],
        ),
        draft.toKyc(
          paths: {
            RegistrationPhoto.idProof: 'mechanics/mech-1/kyc/id-proof.jpg',
            RegistrationPhoto.selfieWithId: 'mechanics/mech-1/kyc/selfie-with-id.jpg',
            RegistrationPhoto.addressProof: 'mechanics/mech-1/kyc/address-proof.jpg',
          },
          phone: '+910000000000',
        ),
      );

      final profile = (await db.doc('mechanics/mech-1').get()).data()!;
      expect(profile['mechanicType'], 'independent');
      expect(profile['status'], 'pending');
      expect(profile['cityId'], 'ankleshwar');
      expect(profile.keys, containsAll(['createdAt', 'updatedAt', 'schemaVersion']));
      expect(profile.keys, isNot(contains('shopName')));

      final kyc = (await db.doc('mechanics/mech-1/private/kyc').get()).data()!;
      expect(kyc['phone'], '+919876543210', reason: 'always the Auth phone');
      expect(kyc['idProofPath'], 'mechanics/mech-1/kyc/id-proof.jpg');
      expect(kyc['upiId'], 'ramesh@okaxis');
      expect(session.refreshes, 1);

      expect((await repo.watchProfile().first)!.status, MechanicStatus.pending);
    });

    test('watchProfile is null before registering', () async {
      final repo = FirestoreRegistrationRepository(FakeFirebaseFirestore(), _FakeSession());
      expect(await repo.watchProfile().first, isNull);
    });
  });

  group('registrationRedirect', () {
    const loading = AsyncValue<MechanicStatus?>.loading();
    test('routes by status after first run; waits while loading', () {
      expect(registrationRedirect(const AsyncData(null), AppRoutes.home), AppRoutes.register);
      expect(
        registrationRedirect(const AsyncData(MechanicStatus.pending), AppRoutes.home),
        AppRoutes.pending,
      );
      expect(
        registrationRedirect(const AsyncData(MechanicStatus.blocked), AppRoutes.register),
        AppRoutes.pending,
      );
      expect(
        registrationRedirect(const AsyncData(MechanicStatus.approved), AppRoutes.pending),
        AppRoutes.home,
      );
      expect(registrationRedirect(const AsyncData(MechanicStatus.approved), AppRoutes.home), isNull);
      expect(registrationRedirect(loading, AppRoutes.home), isNull);
    });

    test('help, privacy and permission explainers stay reachable', () {
      for (final open in [AppRoutes.help, AppRoutes.privacy, '/permission/camera']) {
        expect(registrationRedirect(const AsyncData(null), open), isNull, reason: open);
      }
    });
  });

  group('M1 / M2 screens', () {
    late InMemoryRegistrationRepository repo;
    late _FakePicker picker;
    late _FakePermissions permissions;
    late _FakeSecureWindow secure;

    Future<Widget> app({InMemoryRegistrationRepository? registration, String language = 'en'}) async {
      SharedPreferences.setMockInitialValues({
        'first_run.language': language,
        'first_run.onboarded': true,
        'first_run.consent_version': kConsentVersion,
        'first_run.consent_at': '2026-09-30T10:15:00.000Z',
      });
      final prefs = await SharedPreferences.getInstance();
      return ProviderScope(
        overrides: [
          flavorProvider.overrideWithValue(AppFlavor.dev),
          sharedPreferencesProvider.overrideWithValue(prefs),
          registrationRepositoryProvider.overrideWithValue(registration ?? repo),
          photoPickerProvider.overrideWithValue(picker),
          photoCompressorProvider.overrideWithValue(identityCompressor),
          mechanicPhotoUploaderProvider.overrideWithValue(FakeMechanicPhotoUploader(uid: 'mech-1')),
          permissionServiceProvider.overrideWithValue(permissions),
          secureWindowProvider.overrideWithValue(secure),
          supportContactsProvider.overrideWithValue((phone: '+917900000000', grievanceEmail: '')),
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 30, 6, 30)),
        ],
        child: const MechanicApp(),
      );
    }

    Future<void> pastSplash(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }

    Future<void> tapText(WidgetTester tester, String text) async {
      await tester.ensureVisible(find.text(text).first);
      await tester.tap(find.text(text).first);
      await tester.pumpAndSettle();
    }

    Future<void> type(WidgetTester tester, String key, String value) async {
      final field = find.descendant(of: find.byKey(ValueKey(key)), matching: find.byType(TextField));
      await tester.ensureVisible(field);
      await tester.enterText(field, value);
      await tester.pumpAndSettle();
    }

    Future<void> addPhoto(WidgetTester tester, String slotLabel) async {
      await tapText(tester, slotLabel);
      await tapText(tester, 'Take a photo');
    }

    setUp(() {
      repo = InMemoryRegistrationRepository();
      picker = _FakePicker();
      permissions = _FakePermissions();
      secure = _FakeSecureWindow();
    });

    testWidgets('Take a photo: the C7 camera explainer comes before the camera', (tester) async {
      permissions.camera = PermissionAccess.askable;
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      await tapText(tester, 'Yes, I have a workshop');
      await tapText(tester, 'Bharuch');
      await tapText(tester, 'Next');

      await addPhoto(tester, 'Your photo (customers see it)');
      expect(find.byType(PermissionExplainerScreen), findsOneWidget);
      expect(picker.picks, 0, reason: 'no camera before the explainer');
      await tester.tap(find.widgetWithText(LaneButton, 'Allow'));
      await tester.pumpAndSettle();
      expect(permissions.requested, [AppPermission.camera]);
      expect(picker.picks, 1);
      expect(find.text('Step 2 of 4'), findsOneWidget);

      // Allowed now: the next photo goes straight to the camera.
      await addPhoto(tester, 'Shop photo');
      expect(permissions.requested, hasLength(1));
      expect(picker.picks, 2);
    });

    testWidgets('name fields use the name keyboard (no autocorrect)', (tester) async {
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      await tapText(tester, 'Yes, I have a workshop');
      await tapText(tester, 'Bharuch');
      await tapText(tester, 'Next');
      TextInputType keyboardOf(String key) => tester
          .widget<TextField>(find.descendant(of: find.byKey(ValueKey(key)), matching: find.byType(TextField)))
          .keyboardType;
      expect(keyboardOf('name'), TextInputType.name);
      expect(keyboardOf('shopName'), TextInputType.name);
    });

    testWidgets('Not now on the camera explainer: no camera, back on the form', (tester) async {
      permissions.camera = PermissionAccess.askable;
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      await tapText(tester, 'Yes, I have a workshop');
      await tapText(tester, 'Bharuch');
      await tapText(tester, 'Next');
      await addPhoto(tester, 'Your photo (customers see it)');
      await tapText(tester, 'Not now');
      expect(picker.picks, 0);
      expect(find.text('Step 2 of 4'), findsOneWidget);
    });

    testWidgets('an unregistered mechanic lands on M1 step 1', (tester) async {
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      expect(find.byType(RegistrationScreen), findsOneWidget);
      expect(find.text('Do you have a workshop?'), findsOneWidget);
      expect(find.text('Step 1 of 4'), findsOneWidget);
    });

    testWidgets('Next without answers shows what is missing and stays', (tester) async {
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      await tapText(tester, 'Next');
      expect(find.text('Step 1 of 4'), findsOneWidget);
      expect(find.text('Please fill this in'), findsNWidgets(2));
    });

    testWidgets('workshop path end to end → M2 with workshop wording', (tester) async {
      await tester.pumpWidget(await app());
      await pastSplash(tester);

      await tapText(tester, 'Yes, I have a workshop');
      await tapText(tester, 'Bharuch');
      await tapText(tester, 'Next');

      expect(find.text('Step 2 of 4'), findsOneWidget);
      await type(tester, 'name', 'Ramesh Patel');
      await addPhoto(tester, 'Your photo (customers see it)');
      await type(tester, 'shopName', 'Shree Auto');
      await type(tester, 'shopAddress', 'Station Road, Bharuch');
      await addPhoto(tester, 'Shop photo');
      expect(find.text('Years of experience'), findsNothing, reason: 'no independent fields');
      await tapText(tester, 'Next');

      expect(find.text('Step 3 of 4'), findsOneWidget);
      await tapText(tester, 'Car');
      await tapText(tester, 'Flat tyre');
      await tapText(tester, 'Next');

      expect(find.text('Step 4 of 4'), findsOneWidget);
      expect(secure.calls, [true], reason: 'ID and UPI: no screenshots (PLAN §12.7)');
      expect(find.text('Selfie holding your ID'), findsNothing);
      await addPhoto(tester, 'ID proof');
      await type(tester, 'upiId', 'ramesh@okaxis');
      await type(tester, 'upiName', 'Ramesh Patel');
      await tapText(tester, 'Send for approval');

      expect(find.byType(PendingScreen), findsOneWidget);
      expect(secure.calls.last, isFalse, reason: 'secure only on the ID step');
      expect(find.text("We're checking your details"), findsOneWidget);
      expect(find.text('Usually within 24 hours. We\'ll let you know.'), findsOneWidget);
      expect(find.text('Shop details'), findsOneWidget);
      expect(find.text('Verification call'), findsNothing);

      expect(repo.profile!.mechanicType, MechanicType.workshop);
      expect(repo.profile!.cityId, CityId.bharuch);
      expect(repo.kyc!.upiId, 'ramesh@okaxis');
    });

    testWidgets('independent path end to end → M2 with the verification-call wording', (tester) async {
      await tester.pumpWidget(await app());
      await pastSplash(tester);

      await tapText(tester, 'No, I work independently');
      await tapText(tester, 'Ankleshwar');
      await tapText(tester, 'Next');

      await type(tester, 'name', 'Suresh');
      await addPhoto(tester, 'Your photo (customers see it)');
      expect(find.text('Shop name'), findsNothing, reason: 'no workshop fields');
      await type(tester, 'experience', '6');
      await type(tester, 'baseArea', 'GIDC Ankleshwar');
      await tapText(tester, 'Scooter');
      await type(tester, 'travelRegNo', 'GJ 16 CK 4471');
      await addPhoto(tester, 'Tools 1');
      // Only one toolkit photo: not enough.
      await tapText(tester, 'Next');
      expect(find.text('Add at least 2 photos of your tools'), findsOneWidget);
      await addPhoto(tester, 'Tools 2');
      await tapText(tester, 'Next');

      await tapText(tester, 'Bike');
      await tapText(tester, 'Battery');
      await tapText(tester, 'Next');

      await addPhoto(tester, 'ID proof');
      await addPhoto(tester, 'Selfie holding your ID');
      await addPhoto(tester, 'Address proof');
      await type(tester, 'upiId', 'suresh@okicici');
      await type(tester, 'upiName', 'Suresh');
      await tapText(tester, 'Send for approval');

      expect(find.byType(PendingScreen), findsOneWidget);
      expect(find.textContaining('call you for a short verification'), findsOneWidget);
      expect(find.text('Verification call'), findsOneWidget);
      expect(repo.profile!.mechanicType, MechanicType.independent);
      expect(repo.profile!.toolkitPhotoUrls, hasLength(2));
      expect(repo.profile!.travelVehicle!.regNo, 'GJ16CK4471');
    });

    testWidgets('Back goes to the previous step and keeps the answers', (tester) async {
      await tester.pumpWidget(await app());
      await pastSplash(tester);
      await tapText(tester, 'Yes, I have a workshop');
      await tapText(tester, 'Ahmedabad');
      await tapText(tester, 'Next');
      await type(tester, 'name', 'Ramesh');
      await tester.tap(find.byType(LaneBackButton));
      await tester.pumpAndSettle();
      expect(find.text('Step 1 of 4'), findsOneWidget);
      await tapText(tester, 'Next');
      expect(find.text('Ramesh'), findsOneWidget);
    });

    testWidgets('approval moves a pending mechanic to home', (tester) async {
      final pending = InMemoryRegistrationRepository(profile: workshopProfile);
      await tester.pumpWidget(await app(registration: pending));
      await pastSplash(tester);
      expect(find.byType(PendingScreen), findsOneWidget);

      pending.setStatus(MechanicStatus.approved);
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('a blocked mechanic sees the on-hold wording with Call support', (tester) async {
      final blocked = InMemoryRegistrationRepository(
        profile: workshopProfile.copyWith(status: MechanicStatus.blocked),
      );
      await tester.pumpWidget(await app(registration: blocked));
      await pastSplash(tester);
      expect(find.text('Your account is on hold'), findsOneWidget);
      expect(find.text('Shop details'), findsNothing);
      expect(find.widgetWithText(LaneButton, 'CALL SUPPORT'), findsOneWidget);
    });

    for (final (name, draft) in [
      ('step 1', const RegistrationDraft()),
      ('step 2 independent', completeDraft(MechanicType.independent)),
    ]) {
      testWidgets('$name fits at 320 px and 200% text in Gujarati', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(await app(language: 'gu'));
        await pastSplash(tester);
        if (draft.mechanicType != null) {
          final element = tester.element(find.byType(RegistrationScreen));
          ProviderScope.containerOf(element).read(registrationProvider.notifier)
            ..update((_) => draft)
            ..next();
          await tester.pumpAndSettle();
          expect(find.text('ઓજારો 1'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('M2 fits at 320 px and 200% text in Hindi (independent)', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final pending = InMemoryRegistrationRepository(
        profile: completeDraft(MechanicType.independent)
            .toMechanic()
            .copyWith(status: MechanicStatus.pending),
      );
      await tester.pumpWidget(await app(registration: pending, language: 'hi'));
      await pastSplash(tester);
      expect(find.text('जाँच कॉल'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Wraps an uploader and fails exactly one call (by 1-based number).
class _CountingUploader implements MechanicPhotoUploader {
  _CountingUploader(this.inner, {required this.failOnCall, required this.onCall});

  final MechanicPhotoUploader inner;
  final int failOnCall;
  final void Function() onCall;
  int _n = 0;

  Future<String> _call(Future<String> Function() f) async {
    onCall();
    _n++;
    if (_n == failOnCall) throw Exception('upload failed');
    return f();
  }

  @override
  Future<String> uploadShopPhoto({required String fileName, required Uint8List bytes}) =>
      _call(() => inner.uploadShopPhoto(fileName: fileName, bytes: bytes));

  @override
  Future<String> uploadKycDocument({required String fileName, required Uint8List bytes}) =>
      _call(() => inner.uploadKycDocument(fileName: fileName, bytes: bytes));
}
