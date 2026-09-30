// mechanics/{uid}, mechanics/{uid}/private/kyc and presence/{uid} (PLAN.md §8, §10.0).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../converters.dart';
import '../enums.dart';
import 'common.dart';

part 'mechanic.freezed.dart';
part 'mechanic.g.dart';

/// `mechanics/{uid}`: readable by the mechanic themself and admins.
///
/// Workshop mechanics fill `shopName`, `shopAddress` and `shopPhotoUrl`; independent mechanics
/// fill `baseArea`, `experienceYears`, `toolkitPhotoUrls` (≥ 2) and `travelVehicle`. The other
/// type's fields stay null and are left out of `toJson()`, because the rules only allow each
/// type to write its own fields. Check a profile with `mechanicProfileErrors()`.
@freezed
abstract class Mechanic with _$Mechanic {
  @JsonSerializable(includeIfNull: false)
  const factory Mechanic({
    required String name,
    required String profilePhotoUrl,
    required MechanicType mechanicType,

    // workshop only
    String? shopName,
    String? shopAddress,
    String? shopPhotoUrl,

    // independent only
    BaseArea? baseArea,
    int? experienceYears,
    List<String>? toolkitPhotoUrls,
    TravelVehicle? travelVehicle,

    /// Chosen at registration, changed only by admin.
    required CityId cityId,
    required List<VehicleType> vehicleTypes,
    required List<ProblemType> services,

    /// 🔒
    @Default(MechanicStatus.pending) MechanicStatus status,

    /// 🔒
    @Default(0) double rating,

    /// 🔒
    @Default(0) int ratingCount,

    /// 🔒
    @Default(0) int jobsCompleted,
    String? fcmToken,

    /// 🔒 Set by `requestAccountDeletion`; kept on the reduced profile after the purge, so the KYC
    /// retention job knows when the mechanic left (PLAN §8, §12.10). Null (and left out of
    /// `toJson()`) for everyone else, since the rules reject it from clients.
    @TimestampConverter() DateTime? deletionRequestedAt,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @Default(kSchemaVersion) int schemaVersion,
  }) = _Mechanic;

  factory Mechanic.fromJson(Map<String, dynamic> json) => _$MechanicFromJson(json);
}

/// Where an independent mechanic usually starts from.
@freezed
abstract class BaseArea with _$BaseArea {
  const factory BaseArea({required String locality, @GeoPointConverter() required GeoPoint geopoint}) =
      _BaseArea;

  factory BaseArea.fromJson(Map<String, dynamic> json) => _$BaseAreaFromJson(json);
}

/// The bike or scooter an independent mechanic arrives on (shown to the customer as a PlateChip).
@freezed
abstract class TravelVehicle with _$TravelVehicle {
  const factory TravelVehicle({required VehicleType type, required String regNo}) = _TravelVehicle;

  factory TravelVehicle.fromJson(Map<String, dynamic> json) => _$TravelVehicleFromJson(json);
}

/// `mechanics/{uid}/private/kyc`: the mechanic writes it once while `pending`; admins read it.
@freezed
abstract class MechanicKyc with _$MechanicKyc {
  @JsonSerializable(includeIfNull: false)
  const factory MechanicKyc({
    /// 🔒 From Auth (E.164).
    required String phone,

    /// Storage path (`mechanics/{uid}/kyc/…`), never a URL.
    required String idProofPath,
    required String upiId,
    required String upiName,

    /// 🔒
    String? kycCheckedBy,

    /// 🔒
    @TimestampConverter() DateTime? kycCheckedAt,

    // independent only
    String? selfieWithIdPath,
    String? addressProofPath,
    Contact? referenceContact,

    /// 🔒 Set only by the admin callable after the call.
    VerificationCall? verificationCall,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @Default(kSchemaVersion) int schemaVersion,
  }) = _MechanicKyc;

  factory MechanicKyc.fromJson(Map<String, dynamic> json) => _$MechanicKycFromJson(json);
}

@freezed
abstract class VerificationCall with _$VerificationCall {
  const factory VerificationCall({
    required String doneBy,
    @TimestampConverter() required DateTime at,
    required String notes,
  }) = _VerificationCall;

  factory VerificationCall.fromJson(Map<String, dynamic> json) => _$VerificationCallFromJson(json);
}

/// `presence/{uid}`: the mechanic updates `isOnline`, `location` and `updatedAt` only.
@freezed
abstract class Presence with _$Presence {
  const factory Presence({
    required bool isOnline,
    required GeoLocation location,
    @TimestampConverter() DateTime? updatedAt,

    /// 🔒 Copied from the profile by Functions.
    required CityId cityId,

    /// 🔒 Null when free.
    String? activeBookingId,
  }) = _Presence;

  factory Presence.fromJson(Map<String, dynamic> json) => _$PresenceFromJson(json);
}
