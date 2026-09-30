// #106: U4 Problem picker, U5 Photos and details, the booking draft and the photo pipeline.
import 'dart:async';
import 'dart:typed_data';

import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/flavor.dart';
import 'package:customer_app/features/booking/application/booking_draft.dart';
import 'package:customer_app/features/booking/application/pickup.dart';
import 'package:customer_app/features/booking/data/photo_pipeline.dart';
import 'package:customer_app/features/booking/presentation/confirm_location_screen.dart';
import 'package:customer_app/features/booking/presentation/photos_screen.dart';
import 'package:customer_app/features/booking/presentation/problem_screen.dart';
import 'package:customer_app/features/first_run/application/first_run.dart';
import 'package:customer_app/features/permissions/application/permission_service.dart';
import 'package:customer_app/features/vehicles/application/vehicles.dart';
import 'package:customer_app/features/vehicles/data/vehicle_repository.dart';
import 'package:customer_app/features/vehicles/presentation/add_vehicle_screen.dart';
import 'package:customer_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lane_ui/lane_ui.dart';
import 'package:roadside_core/roadside_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_location.dart';

class _NoBattery implements LaneBatterySource {
  @override
  Stream<LaneBatteryStatus> watch() => const Stream.empty();
}

/// A 1×1 PNG: real image bytes so `Image.memory` decodes in tests.
final png = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0xF0,
  0x1F, 0x00, 0x05, 0x00, 0x01, 0xFF, 0x89, 0x99, 0x3D, 0x1D, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45,
  0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _SlowPicker implements PhotoPicker {
  _SlowPicker(this.result);

  final Completer<Uint8List?> result;

  @override
  Future<Uint8List?> pick(PhotoSource source) => result.future;
}

class FakePicker implements PhotoPicker {
  final sources = <PhotoSource>[];
  Uint8List? next;
  Object? error;

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    sources.add(source);
    if (error != null) throw error!;
    return next;
  }
}

/// Uploads that the test finishes or fails by hand.
class ManualUploader implements PhotoUploader {
  final pending = <Completer<String>>[];
  final names = <String>[];

  @override
  Future<String> upload({required String draftId, required String fileName, required Uint8List bytes}) {
    names.add('$draftId/$fileName');
    final c = Completer<String>();
    pending.add(c);
    return c.future;
  }

  void finishAll() {
    for (final c in pending) {
      if (!c.isCompleted) {
        c.complete('https://firebasestorage.googleapis.com/v0/b/demo/o/${pending.indexOf(c)}');
      }
    }
  }
}

class FakePermissions implements PermissionService {
  PermissionAccess access = PermissionAccess.granted;
  final asked = <AppPermission>[];

  @override
  Future<PermissionAccess> status(AppPermission permission) async {
    asked.add(permission);
    return access;
  }

  @override
  Future<PermissionAccess> request(AppPermission permission) async => access;

  @override
  Future<bool> openSettings() async => true;
}

const swift = VehicleDraft(
  type: VehicleType.car,
  brand: 'Maruti Suzuki',
  model: 'Swift',
  regNo: 'GJ01AB1234',
  fuel: Fuel.petrol,
);

void main() {
  group('newDraftToken', () {
    test('fits the createBooking idempotencyKey pattern and does not repeat', () {
      final pattern = RegExp(r'^[A-Za-z0-9_-]{16,64}$');
      final tokens = {for (var i = 0; i < 200; i++) newDraftToken()};
      expect(tokens, hasLength(200));
      expect(tokens, everyElement(matches(pattern)));
    });
  });

  group('PhotoCompressor', () {
    test('steps quality down until the photo fits in 500 KB', () async {
      final tried = <int>[];
      final c = PhotoCompressor(
        encode: (bytes, q) async {
          tried.add(q);
          return Uint8List(q > 60 ? PhotoLimits.maxBytes + 1 : PhotoLimits.maxBytes);
        },
      );
      expect((await c.compress(png)).lengthInBytes, PhotoLimits.maxBytes);
      expect(tried, [85, 75, 65, 55]);
    });

    test('gives up with PhotoTooLargeException', () async {
      final c = PhotoCompressor(encode: (bytes, q) async => Uint8List(PhotoLimits.maxBytes + 1));
      expect(c.compress(png), throwsA(isA<PhotoTooLargeException>()));
    });
  });

  group('BookingDraftNotifier', () {
    late FakePicker picker;
    late ManualUploader uploader;
    late ProviderContainer container;

    BookingDraft draft() => container.read(bookingDraftProvider);
    BookingDraftNotifier notifier() => container.read(bookingDraftProvider.notifier);

    setUp(() {
      picker = FakePicker()..next = png;
      uploader = ManualUploader();
      container = ProviderContainer(
        overrides: [
          photoPickerProvider.overrideWithValue(picker),
          photoCompressorProvider.overrideWithValue(PhotoCompressor(encode: (b, q) async => b)),
          photoUploaderProvider.overrideWithValue(uploader),
        ],
      );
      addTearDown(container.dispose);
    });

    test('start gives a fresh draft with new ids and the vehicle', () {
      final first = draft();
      notifier().setProblem(ProblemType.battery);
      notifier().start(vehicleId: 'v1');
      expect(draft().draftId, isNot(first.draftId));
      expect(draft().idempotencyKey, isNot(first.idempotencyKey));
      expect(draft().vehicleId, 'v1');
      expect(draft().problem, isNull);
    });

    test('the idempotency key stays the same while the draft is edited', () {
      final key = draft().idempotencyKey;
      notifier()
        ..setProblem(ProblemType.fuel)
        ..setDescription('x');
      expect(draft().idempotencyKey, key);
    });

    test('a photo uploads under the draft, then its URL is ready', () async {
      final adding = notifier().addPhoto(PhotoSource.gallery);
      await pumpEventQueue();
      expect(draft().uploading, isTrue);
      expect(draft().photoUrls, isEmpty);
      expect(uploader.names.single, startsWith('${draft().draftId}/'));
      expect(uploader.names.single, endsWith('.jpg'));
      uploader.finishAll();
      expect(await adding, isNull);
      expect(draft().uploading, isFalse);
      expect(draft().photoUrls, hasLength(1));
    });

    test('backing out of the picker adds nothing', () async {
      picker.next = null;
      expect(await notifier().addPhoto(PhotoSource.camera), isNull);
      expect(draft().photos, isEmpty);
    });

    test('at most 4 photos', () async {
      for (var i = 0; i < 4; i++) {
        unawaited(notifier().addPhoto(PhotoSource.gallery));
        await pumpEventQueue();
      }
      expect(draft().canAddPhoto, isFalse);
      expect(await notifier().addPhoto(PhotoSource.gallery), PhotoAddError.limit);
      expect(picker.sources, hasLength(4), reason: 'the picker never opened for the 5th');
      uploader.finishAll();
    });

    test('too large and picker errors are reported, not thrown', () async {
      container = ProviderContainer(
        overrides: [
          photoPickerProvider.overrideWithValue(picker),
          photoCompressorProvider.overrideWithValue(
            PhotoCompressor(encode: (b, q) async => Uint8List(PhotoLimits.maxBytes + 1)),
          ),
          photoUploaderProvider.overrideWithValue(uploader),
        ],
      );
      expect(await notifier().addPhoto(PhotoSource.gallery), PhotoAddError.tooLarge);
      picker.error = StateError('camera busy');
      expect(await notifier().addPhoto(PhotoSource.camera), PhotoAddError.failed);
      expect(draft().photos, isEmpty);
      container.dispose();
    });

    test('a failed upload can be retried or removed', () async {
      final adding = notifier().addPhoto(PhotoSource.gallery);
      await pumpEventQueue();
      uploader.pending.single.completeError(Exception('network'));
      await adding;
      expect(draft().hasFailedUpload, isTrue);

      final id = draft().photos.single.id;
      final retry = notifier().retryUpload(id);
      expect(draft().photos.single.state, PhotoUploadState.uploading);
      await pumpEventQueue();
      uploader.pending.last.complete('https://firebasestorage.googleapis.com/v0/b/demo/o/p');
      await retry;
      expect(draft().photos.single.state, PhotoUploadState.done);

      notifier().removePhoto(id);
      expect(draft().photos, isEmpty);
    });

    test('a photo picked while a new draft started is dropped, not added to it', () async {
      final slowPick = Completer<Uint8List?>();
      container = ProviderContainer(
        overrides: [
          photoPickerProvider.overrideWithValue(_SlowPicker(slowPick)),
          photoCompressorProvider.overrideWithValue(PhotoCompressor(encode: (b, q) async => b)),
          photoUploaderProvider.overrideWithValue(uploader),
        ],
      );
      final adding = notifier().addPhoto(PhotoSource.gallery);
      notifier().start(vehicleId: 'v2');
      slowPick.complete(png);
      expect(await adding, isNull);
      expect(draft().photos, isEmpty);
      expect(uploader.names, isEmpty, reason: 'nothing uploaded under either draft');
      container.dispose();
    });

    test('the uploaded file name fits the storage rules pattern', () async {
      unawaited(notifier().addPhoto(PhotoSource.gallery));
      await pumpEventQueue();
      final file = uploader.names.single.split('/').last;
      expect(file, matches(RegExp(r'^[A-Za-z0-9._-]{1,100}$')));
      uploader.finishAll();
    });

    test('an upload finishing after a new draft started does not leak into it', () async {
      final adding = notifier().addPhoto(PhotoSource.gallery);
      await pumpEventQueue();
      notifier().start();
      uploader.finishAll();
      await adding;
      expect(draft().photos, isEmpty);
    });
  });

  group('screens', () {
    late InMemoryVehicleRepository repo;
    late FakePicker picker;
    late ManualUploader uploader;
    late FakePermissions permissions;

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
          photoPickerProvider.overrideWithValue(picker),
          photoCompressorProvider.overrideWithValue(PhotoCompressor(encode: (b, q) async => b)),
          photoUploaderProvider.overrideWithValue(uploader),
          permissionServiceProvider.overrideWithValue(permissions),
          locationServiceProvider.overrideWithValue(FakeLocationService()),
          reverseGeocoderProvider.overrideWithValue(FakeGeocoder()),
          laneBatterySourceProvider.overrideWithValue(_NoBattery()),
          laneClockProvider.overrideWithValue(() => DateTime.utc(2026, 9, 29, 6, 30)),
        ],
        child: const RoadsideApp(),
      );
    }

    Future<void> openProblem(WidgetTester tester, {String language = 'en'}) async {
      await tester.pumpWidget(await app(language: language));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(LaneButton, language == 'en' ? 'Get help' : 'मदद लें'));
      await tester.pumpAndSettle();
      expect(find.byType(ProblemScreen), findsOneWidget);
    }

    /// [settle] false while an upload runs: the loading Next button animates until it ends.
    Future<void> tapText(WidgetTester tester, String text, {bool settle = true}) async {
      await tester.ensureVisible(find.text(text));
      await tester.pumpAndSettle();
      await tester.tap(find.text(text));
      if (settle) {
        await tester.pumpAndSettle();
      } else {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    void tall(WidgetTester tester) {
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    setUp(() {
      repo = InMemoryVehicleRepository();
      picker = FakePicker()..next = png;
      uploader = ManualUploader();
      permissions = FakePermissions();
    });

    testWidgets('Home → U4: the default vehicle and 7 problems; Next waits for a problem', (tester) async {
      tall(tester);
      await repo.add(swift);
      await openProblem(tester);
      expect(find.text('Step 1 of 4'), findsOneWidget);
      expect(find.text('Maruti Suzuki Swift'), findsOneWidget);
      expect(find.byType(ProblemTile), findsNWidgets(7));
      LaneButton next() => tester.widget<LaneButton>(find.widgetWithText(LaneButton, 'Next'));
      expect(next().onPressed, isNull);

      await tapText(tester, 'Battery');
      expect(tester.widget<ProblemTile>(find.widgetWithText(ProblemTile, 'Battery')).selected, isTrue);
      expect(next().onPressed, isNotNull);
      await tapText(tester, 'Next');
      expect(find.byType(PhotosScreen), findsOneWidget);
    });

    testWidgets('U4 with no vehicle asks to add one first', (tester) async {
      tall(tester);
      await openProblem(tester);
      expect(find.text('Add your vehicle first'), findsOneWidget);
      await tapText(tester, 'Flat tyre');
      expect(tester.widget<LaneButton>(find.widgetWithText(LaneButton, 'Next')).onPressed, isNull);
      await tapText(tester, 'Add vehicle');
      expect(find.byType(AddVehicleScreen), findsOneWidget);
    });

    testWidgets('U5: skip with nothing added; photos upload with a status; Next waits', (tester) async {
      tall(tester);
      await repo.add(swift);
      await openProblem(tester);
      await tapText(tester, 'Out of fuel');
      await tapText(tester, 'Next');
      expect(find.text('Step 2 of 4'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      await tapText(tester, 'Choose from gallery', settle: false);
      expect(picker.sources, [PhotoSource.gallery]);
      expect(
        permissions.asked,
        isNot(contains(AppPermission.camera)),
        reason: 'the gallery needs no permission',
      );
      expect(find.text('Uploading photo 1'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
      expect(tester.widget<LaneButton>(find.widgetWithText(LaneButton, 'Next')).loading, isTrue);

      uploader.finishAll();
      await tester.pumpAndSettle();
      expect(find.text('Photo 1'), findsOneWidget);
      expect(find.text('1 of 4 photos'), findsOneWidget);

      await tapText(tester, 'Next');
      expect(find.byType(ConfirmLocationScreen), findsOneWidget);
      await tester.pump(const Duration(seconds: 16)); // let U6's GPS wait time out
    });

    testWidgets('U5: camera asks for permission first; a failed upload blocks Next until retried', (
      tester,
    ) async {
      tall(tester);
      await repo.add(swift);
      await openProblem(tester);
      await tapText(tester, 'Accident');
      await tapText(tester, 'Next');

      await tapText(tester, 'TAKE PHOTO', settle: false);
      expect(permissions.asked.last, AppPermission.camera);
      expect(picker.sources, [PhotoSource.camera]);
      uploader.pending.single.completeError(Exception('offline'));
      await tester.pumpAndSettle();
      expect(find.text('Photo 1 did not upload. Try again'), findsOneWidget);
      expect(find.textContaining('Some photos did not upload'), findsOneWidget);
      expect(tester.widget<LaneButton>(find.widgetWithText(LaneButton, 'Next')).onPressed, isNull);

      await tapText(tester, 'Photo 1 did not upload. Try again', settle: false);
      uploader.pending.last.complete('https://firebasestorage.googleapis.com/v0/b/demo/o/p');
      await tester.pumpAndSettle();
      expect(find.text('Photo 1'), findsOneWidget);
      expect(tester.widget<LaneButton>(find.widgetWithText(LaneButton, 'Next')).onPressed, isNotNull);

      await tester.tap(find.byTooltip('Remove photo 1'));
      await tester.pumpAndSettle();
      expect(find.text('Photo 1'), findsNothing);
    });

    testWidgets('U5: a too-large photo shows a toast', (tester) async {
      tall(tester);
      await repo.add(swift);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            photoPickerProvider.overrideWithValue(picker),
            photoCompressorProvider.overrideWithValue(
              PhotoCompressor(encode: (b, q) async => Uint8List(PhotoLimits.maxBytes + 1)),
            ),
            photoUploaderProvider.overrideWithValue(uploader),
            permissionServiceProvider.overrideWithValue(permissions),
          ],
          child: const LaneApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: PhotosScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tapText(tester, 'Choose from gallery');
      expect(find.text('That photo is too large. Try another one.'), findsOneWidget);
      await tester.pump(LaneToast.visibleFor);
      await tester.pumpAndSettle();
    });

    testWidgets('the description is kept in the draft', (tester) async {
      tall(tester);
      await repo.add(swift);
      await openProblem(tester);
      await tapText(tester, 'Something else');
      await tapText(tester, 'Next');
      await tester.enterText(find.byType(TextField), 'Clutch cable snapped');
      await tester.pump();
      final container = ProviderScope.containerOf(tester.element(find.byType(PhotosScreen)));
      expect(container.read(bookingDraftProvider).description, 'Clutch cable snapped');
      expect(container.read(bookingDraftProvider).problem, ProblemType.other);
      expect(find.text('Skip'), findsNothing);
    });

    for (final screen in ['U4', 'U5']) {
      testWidgets('$screen fits at 320 px, 200% text, Hindi', (tester) async {
        await repo.add(swift);
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await openProblem(tester, language: 'hi');
        expect(find.text('क्या खराबी है?'), findsOneWidget);
        if (screen == 'U5') {
          // At 200% the grid runs past the screen and the list builds lazily: pick in the draft.
          ProviderScope.containerOf(tester.element(find.byType(ProblemScreen)))
              .read(bookingDraftProvider.notifier)
              .setProblem(ProblemType.battery);
          await tester.pumpAndSettle();
          await tapText(tester, 'आगे');
          expect(find.byType(PhotosScreen), findsOneWidget);
          await tester.scrollUntilVisible(
            find.text('गैलरी से चुनें'),
            200,
            scrollable: find
                .descendant(of: find.byType(PhotosScreen), matching: find.byType(Scrollable))
                .first,
          );
          await tapText(tester, 'गैलरी से चुनें', settle: false);
          uploader.finishAll();
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      });
    }
  });
}
