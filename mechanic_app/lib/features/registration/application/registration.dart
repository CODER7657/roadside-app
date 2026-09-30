import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadside_core/roadside_core.dart';

import '../data/mechanic_photos.dart';
import '../data/registration_repository.dart';

/// M1 steps (wireframe: "Step n of 4").
enum RegistrationStep { type, aboutYou, work, idAndPay }

/// Which photo a slot holds. Toolkit photos are a list (2–5, PLAN §8).
enum RegistrationPhoto { profile, shop, idProof, selfieWithId, addressProof }

/// City centres from `firebase/seed/data/serviceAreas.json` (a test keeps them in step). An
/// independent mechanic's `baseArea.geopoint` uses their city's centre for now; the locality
/// text says where exactly. Dispatch always uses the live location, never this (PLAN §10.0).
const kCityCentres = <CityId, (double, double)>{
  CityId.ahmedabad: (23.0225, 72.5714),
  CityId.ankleshwar: (21.6264, 73.0152),
  CityId.bharuch: (21.7051, 72.9959),
};

/// Vehicles an independent mechanic can travel on (shown to customers as a PlateChip).
const kTravelVehicleTypes = [VehicleType.bike, VehicleType.scooter, VehicleType.car];

/// Everything M1 collects. Photos are already compressed JPEG bytes.
@immutable
class RegistrationDraft {
  const RegistrationDraft({
    this.mechanicType,
    this.cityId,
    this.name = '',
    this.shopName = '',
    this.shopAddress = '',
    this.experienceYears = '',
    this.baseLocality = '',
    this.travelVehicleType,
    this.travelRegNo = '',
    this.vehicleTypes = const {},
    this.services = const {},
    this.upiId = '',
    this.upiName = '',
    this.referenceName = '',
    this.referencePhone = '',
    this.photos = const {},
    this.toolkitPhotos = const [],
  });

  final MechanicType? mechanicType;
  final CityId? cityId;
  final String name;
  final String shopName;
  final String shopAddress;
  final String experienceYears;
  final String baseLocality;
  final VehicleType? travelVehicleType;
  final String travelRegNo;
  final Set<VehicleType> vehicleTypes;
  final Set<ProblemType> services;
  final String upiId;
  final String upiName;
  final String referenceName;
  final String referencePhone;
  final Map<RegistrationPhoto, Uint8List> photos;
  final List<Uint8List> toolkitPhotos;

  bool get isIndependent => mechanicType == MechanicType.independent;

  RegistrationDraft copyWith({
    MechanicType? mechanicType,
    CityId? cityId,
    String? name,
    String? shopName,
    String? shopAddress,
    String? experienceYears,
    String? baseLocality,
    VehicleType? travelVehicleType,
    String? travelRegNo,
    Set<VehicleType>? vehicleTypes,
    Set<ProblemType>? services,
    String? upiId,
    String? upiName,
    String? referenceName,
    String? referencePhone,
    Map<RegistrationPhoto, Uint8List>? photos,
    List<Uint8List>? toolkitPhotos,
  }) => RegistrationDraft(
    mechanicType: mechanicType ?? this.mechanicType,
    cityId: cityId ?? this.cityId,
    name: name ?? this.name,
    shopName: shopName ?? this.shopName,
    shopAddress: shopAddress ?? this.shopAddress,
    experienceYears: experienceYears ?? this.experienceYears,
    baseLocality: baseLocality ?? this.baseLocality,
    travelVehicleType: travelVehicleType ?? this.travelVehicleType,
    travelRegNo: travelRegNo ?? this.travelRegNo,
    vehicleTypes: vehicleTypes ?? this.vehicleTypes,
    services: services ?? this.services,
    upiId: upiId ?? this.upiId,
    upiName: upiName ?? this.upiName,
    referenceName: referenceName ?? this.referenceName,
    referencePhone: referencePhone ?? this.referencePhone,
    photos: photos ?? this.photos,
    toolkitPhotos: toolkitPhotos ?? this.toolkitPhotos,
  );

  bool get _hasReference => referenceName.trim().isNotEmpty || referencePhone.trim().isNotEmpty;

  /// The profile as the rules will see it. Photo fields hold [urls] once uploaded, or a
  /// placeholder when only picked (so validation can run before uploading).
  Mechanic toMechanic({Map<RegistrationPhoto, String> urls = const {}, List<String>? toolkitUrls}) {
    String photo(RegistrationPhoto p) => urls[p] ?? (photos.containsKey(p) ? 'picked' : '');
    final type = mechanicType ?? MechanicType.workshop;
    final city = cityId ?? CityId.ahmedabad;
    final independent = type == MechanicType.independent;
    final (lat, lng) = kCityCentres[city]!;
    return Mechanic(
      name: name.trim(),
      profilePhotoUrl: photo(RegistrationPhoto.profile),
      mechanicType: type,
      shopName: independent ? null : shopName.trim(),
      shopAddress: independent ? null : shopAddress.trim(),
      shopPhotoUrl: independent ? null : photo(RegistrationPhoto.shop),
      baseArea: independent && baseLocality.trim().isNotEmpty
          ? BaseArea(locality: baseLocality.trim(), geopoint: GeoPoint(lat, lng))
          : null,
      experienceYears: independent ? int.tryParse(experienceYears.trim()) : null,
      toolkitPhotoUrls: independent ? (toolkitUrls ?? [for (final _ in toolkitPhotos) 'picked']) : null,
      travelVehicle: independent && travelVehicleType != null
          ? TravelVehicle(type: travelVehicleType!, regNo: normalizeRegNo(travelRegNo))
          : null,
      cityId: city,
      vehicleTypes: [...vehicleTypes],
      services: [...services],
    );
  }

  /// The KYC doc. [phone] is overwritten from Auth by the repository.
  MechanicKyc toKyc({Map<RegistrationPhoto, String> paths = const {}, String phone = ''}) {
    String doc(RegistrationPhoto p) => paths[p] ?? (photos.containsKey(p) ? 'picked' : '');
    return MechanicKyc(
      phone: phone,
      idProofPath: doc(RegistrationPhoto.idProof),
      upiId: upiId.trim(),
      upiName: upiName.trim(),
      selfieWithIdPath: isIndependent ? doc(RegistrationPhoto.selfieWithId) : null,
      addressProofPath: isIndependent ? doc(RegistrationPhoto.addressProof) : null,
      referenceContact: isIndependent && _hasReference
          ? Contact(name: referenceName.trim(), phone: referencePhone.trim())
          : null,
    );
  }

  /// Problems on [step] as `{field: errorKey}`, using the same validators as the rules
  /// (roadside_core). Field names are the §8 field names.
  Map<String, String> errorsFor(RegistrationStep step) {
    final profile = mechanicProfileErrors(toMechanic());
    final kyc = mechanicKycErrors(toKyc(), mechanicType ?? MechanicType.workshop);
    Map<String, String> only(Map<String, String> all, Set<String> keys) => {
      for (final e in all.entries)
        if (keys.contains(e.key)) e.key: e.value,
    };
    switch (step) {
      case RegistrationStep.type:
        return {
          if (mechanicType == null) 'mechanicType': ValidationError.required,
          if (cityId == null) 'cityId': ValidationError.required,
        };
      case RegistrationStep.aboutYou:
        final errors = only(profile, {
          'name',
          'profilePhotoUrl',
          'shopName',
          'shopAddress',
          'shopPhotoUrl',
          'baseArea',
          'experienceYears',
          'toolkitPhotoUrls',
          'travelVehicle',
        });
        if (isIndependent &&
            experienceYears.trim().isNotEmpty &&
            int.tryParse(experienceYears.trim()) == null) {
          errors['experienceYears'] = ValidationError.experienceInvalid;
        }
        return errors;
      case RegistrationStep.work:
        return only(profile, {'vehicleTypes', 'services'});
      case RegistrationStep.idAndPay:
        final errors = only(kyc, {
          'idProofPath',
          'upiId',
          'upiName',
          'selfieWithIdPath',
          'addressProofPath',
          'referenceContact',
        });
        // A reference is optional, but half of one isn't.
        if (isIndependent && _hasReference && referenceName.trim().isEmpty) {
          errors['referenceContact'] = ValidationError.required;
        }
        return errors;
    }
  }
}

/// Why the last submit didn't go through.
enum SubmitError { upload, save }

@immutable
class RegistrationState {
  const RegistrationState({
    this.draft = const RegistrationDraft(),
    this.step = RegistrationStep.type,
    this.errors = const {},
    this.submitting = false,
    this.submitError,
    this.submitted = false,
  });

  final RegistrationDraft draft;
  final RegistrationStep step;

  /// Shown after the user tries to leave [step]; cleared as they fix things.
  final Map<String, String> errors;
  final bool submitting;
  final SubmitError? submitError;
  final bool submitted;

  RegistrationState copyWith({
    RegistrationDraft? draft,
    RegistrationStep? step,
    Map<String, String>? errors,
    bool? submitting,
    SubmitError? submitError,
    bool clearSubmitError = false,
    bool? submitted,
  }) => RegistrationState(
    draft: draft ?? this.draft,
    step: step ?? this.step,
    errors: errors ?? this.errors,
    submitting: submitting ?? this.submitting,
    submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    submitted: submitted ?? this.submitted,
  );
}

// Data seams. The fakes are the defaults until Firebase is wired (#120 storage, #123 auth);
// swap in FirestoreRegistrationRepository and a Storage uploader there.
final photoPickerProvider = Provider<PhotoPicker>((ref) => ImagePickerPhotoPicker());
final photoCompressorProvider = Provider<PhotoCompressor>((ref) => PhotoCompressor());
final mechanicPhotoUploaderProvider = Provider<MechanicPhotoUploader>((ref) => FakeMechanicPhotoUploader());
final registrationRepositoryProvider = Provider<RegistrationRepository>(
  (ref) => InMemoryRegistrationRepository(),
);

/// The saved profile: null until M1 is submitted.
final mechanicProfileProvider = StreamProvider<Mechanic?>(
  (ref) => ref.watch(registrationRepositoryProvider).watchProfile(),
);

/// Where the mechanic stands: null (not registered), pending, approved or blocked.
/// Loading counts as "don't know yet" (also null); the router waits for data.
final registrationStatusProvider = Provider<AsyncValue<MechanicStatus?>>(
  (ref) => ref.watch(mechanicProfileProvider).whenData((p) => p?.status),
);

final registrationProvider = NotifierProvider<RegistrationController, RegistrationState>(
  RegistrationController.new,
);

class RegistrationController extends Notifier<RegistrationState> {
  // Uploads that already worked, so a retry after a failure doesn't send them again.
  final _shopUrls = <RegistrationPhoto, String>{};
  final _kycPaths = <RegistrationPhoto, String>{};
  final _toolkitUrls = <int, String>{};

  @override
  RegistrationState build() => const RegistrationState();

  void update(RegistrationDraft Function(RegistrationDraft d) change) {
    final draft = change(state.draft);
    // Errors on this step update as the user fixes them.
    final errors = state.errors.isEmpty ? const <String, String>{} : draft.errorsFor(state.step);
    state = state.copyWith(draft: draft, errors: errors, clearSubmitError: true);
  }

  /// Validates the current step; moves on if it's complete. Returns whether it moved.
  bool next() {
    final errors = state.draft.errorsFor(state.step);
    if (errors.isNotEmpty) {
      state = state.copyWith(errors: errors);
      return false;
    }
    final i = state.step.index;
    if (i + 1 < RegistrationStep.values.length) {
      state = state.copyWith(step: RegistrationStep.values[i + 1], errors: const {});
    }
    return true;
  }

  /// Back one step; false on the first step (the screen then leaves).
  bool back() {
    if (state.step.index == 0) return false;
    state = state.copyWith(step: RegistrationStep.values[state.step.index - 1], errors: const {});
    return true;
  }

  /// Picks, compresses and stores a photo. False if the user backed out; throws
  /// [PhotoTooLargeException] if it can't be made small enough.
  Future<bool> pickPhoto(RegistrationPhoto slot, PhotoSource source) async {
    final bytes = await _pick(source);
    if (bytes == null) return false;
    _shopUrls.remove(slot);
    _kycPaths.remove(slot);
    update((d) => d.copyWith(photos: {...d.photos, slot: bytes}));
    return true;
  }

  Future<bool> addToolkitPhoto(PhotoSource source) async {
    if (state.draft.toolkitPhotos.length >= kMaxToolkitPhotos) return false;
    final bytes = await _pick(source);
    if (bytes == null) return false;
    update((d) => d.copyWith(toolkitPhotos: [...d.toolkitPhotos, bytes]));
    return true;
  }

  void removeToolkitPhoto(int index) {
    _toolkitUrls.clear(); // indexes shift; re-upload is cheap and rare
    update((d) => d.copyWith(toolkitPhotos: [...d.toolkitPhotos]..removeAt(index)));
  }

  Future<Uint8List?> _pick(PhotoSource source) async {
    final raw = await ref.read(photoPickerProvider).pick(source);
    if (raw == null) return null;
    return ref.read(photoCompressorProvider).compress(raw);
  }

  /// Uploads the photos (skipping ones already uploaded), then saves the profile and KYC
  /// together. True on success.
  Future<bool> submit() async {
    if (state.submitting) return false;
    for (final step in RegistrationStep.values) {
      final errors = state.draft.errorsFor(step);
      if (errors.isNotEmpty) {
        state = state.copyWith(step: step, errors: errors);
        return false;
      }
    }
    state = state.copyWith(submitting: true, clearSubmitError: true);
    final draft = state.draft;
    final uploader = ref.read(mechanicPhotoUploaderProvider);

    try {
      // Every upload gets a new name: KYC paths are write-once (see uniquePhotoName).
      Future<void> shop(RegistrationPhoto p, String base) async {
        final bytes = draft.photos[p];
        if (bytes == null || _shopUrls.containsKey(p)) return;
        _shopUrls[p] = await uploader.uploadShopPhoto(fileName: uniquePhotoName(base), bytes: bytes);
      }

      Future<void> kyc(RegistrationPhoto p, String base) async {
        final bytes = draft.photos[p];
        if (bytes == null || _kycPaths.containsKey(p)) return;
        _kycPaths[p] = await uploader.uploadKycDocument(fileName: uniquePhotoName(base), bytes: bytes);
      }

      await shop(RegistrationPhoto.profile, 'profile');
      await kyc(RegistrationPhoto.idProof, 'id-proof');
      if (draft.isIndependent) {
        for (final (i, bytes) in draft.toolkitPhotos.indexed) {
          if (_toolkitUrls.containsKey(i)) continue;
          _toolkitUrls[i] = await uploader.uploadShopPhoto(
            fileName: uniquePhotoName('toolkit-${i + 1}'),
            bytes: bytes,
          );
        }
        await kyc(RegistrationPhoto.selfieWithId, 'selfie-with-id');
        await kyc(RegistrationPhoto.addressProof, 'address-proof');
      } else {
        await shop(RegistrationPhoto.shop, 'shop');
      }
    } catch (_) {
      state = state.copyWith(submitting: false, submitError: SubmitError.upload);
      return false;
    }

    try {
      await ref
          .read(registrationRepositoryProvider)
          .submit(
            draft.toMechanic(
              urls: _shopUrls,
              toolkitUrls: [for (var i = 0; i < draft.toolkitPhotos.length; i++) _toolkitUrls[i]!],
            ),
            draft.toKyc(paths: _kycPaths),
          );
    } catch (_) {
      state = state.copyWith(submitting: false, submitError: SubmitError.save);
      return false;
    }
    state = state.copyWith(submitting: false, submitted: true);
    return true;
  }
}
