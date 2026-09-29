// users/{uid} and users/{uid}/vehicles/{vehicleId} (PLAN.md §8).

import 'package:freezed_annotation/freezed_annotation.dart';

import '../converters.dart';
import '../enums.dart';
import 'common.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// `users/{uid}`: a customer.
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String name,

    /// 🔒 From Auth (E.164). Rules require it to equal the signed-in phone number.
    required String phone,
    required Language language,

    /// Max 3, E.164 phones.
    @Default(<Contact>[]) List<Contact> emergencyContacts,
    String? fcmToken,
    Consent? consent,

    /// 🔒 Set by `requestAccountDeletion`.
    @TimestampConverter() DateTime? deletionRequestedAt,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @Default(kSchemaVersion) int schemaVersion,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}

/// The privacy-notice version the user agreed to (PLAN §12.12).
@freezed
abstract class Consent with _$Consent {
  const factory Consent({required String version, @TimestampConverter() required DateTime acceptedAt}) =
      _Consent;

  factory Consent.fromJson(Map<String, dynamic> json) => _$ConsentFromJson(json);
}

/// `users/{uid}/vehicles/{vehicleId}`.
@freezed
abstract class Vehicle with _$Vehicle {
  const factory Vehicle({
    required VehicleType type,
    required String brand,
    required String model,

    /// Normalised with `normalizeRegNo` (upper case, no spaces), Indian or BH series.
    required String regNo,
    required Fuel fuel,
    @Default(false) bool isDefault,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @Default(kSchemaVersion) int schemaVersion,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
}
