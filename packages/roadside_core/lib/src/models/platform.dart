// prices, serviceAreas, reviews, complaints, inbox, appConfig, auditLogs and role claims
// (PLAN.md §8).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../converters.dart';
import '../enums.dart';
import 'common.dart';

part 'platform.freezed.dart';
part 'platform.g.dart';

/// `prices/{vehicleType_problemType}`: signed-in users read; admins write.
@freezed
abstract class Price with _$Price {
  @JsonSerializable(includeIfNull: false)
  const factory Price({
    required VehicleType vehicleType,
    required ProblemType problemType,
    required int min,
    required int max,

    /// Short text shown under the PriceRange.
    required String includes,
    Map<CityId, PriceRange>? cityOverrides,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @Default(kSchemaVersion) int schemaVersion,
  }) = _Price;

  const Price._();

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);

  /// Document id, e.g. `car_flat_tyre`.
  static String idFor(VehicleType vehicleType, ProblemType problemType) =>
      '${vehicleType.value}_${problemType.value}';

  /// The range for [cityId]: its override if there is one, else the default. Same as
  /// `priceFor()` in Functions, which computes the booking's `priceEstimate`.
  PriceRange rangeFor(CityId cityId) => cityOverrides?[cityId] ?? PriceRange(min: min, max: max);
}

/// `serviceAreas/{cityId}`: readable by everyone; admins write.
@freezed
abstract class ServiceArea with _$ServiceArea {
  const factory ServiceArea({
    required LocalizedText name,
    @GeoPointConverter() required GeoPoint center,
    required double radiusKm,
    required bool active,
    required String supportPhone,
    @TimestampConverter() DateTime? launchedAt,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @Default(kSchemaVersion) int schemaVersion,
  }) = _ServiceArea;

  factory ServiceArea.fromJson(Map<String, dynamic> json) => _$ServiceAreaFromJson(json);
}

/// `reviews/{bookingId}`: one per completed booking, created by its customer.
@freezed
abstract class Review with _$Review {
  const factory Review({
    required String customerId,
    required String mechanicId,

    /// 1–5.
    required int stars,
    @Default(<String>[]) List<String> tags,

    /// ≤ 500 characters.
    @Default('') String comment,
    @TimestampConverter() DateTime? createdAt,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}

/// `complaints/{complaintId}`.
@freezed
abstract class Complaint with _$Complaint {
  const factory Complaint({
    required String bookingId,
    required String raisedBy,
    required String category,
    required String text,
    @Default(ComplaintStatus.open) ComplaintStatus status,
    String? resolution,
    @TimestampConverter() DateTime? createdAt,
  }) = _Complaint;

  factory Complaint.fromJson(Map<String, dynamic> json) => _$ComplaintFromJson(json);
}

/// `inbox/{uid}/items/{itemId}` 🔒: the owner may flip only `read`.
@freezed
abstract class InboxItem with _$InboxItem {
  const factory InboxItem({
    required String type,

    /// ARB keys, resolved in the app with [args].
    required String titleKey,
    required String bodyKey,
    @Default(<String, String>{}) Map<String, String> args,
    String? bookingId,
    @Default(false) bool read,
  }) = _InboxItem;

  factory InboxItem.fromJson(Map<String, dynamic> json) => _$InboxItemFromJson(json);
}

/// `appConfig/public`: readable by everyone; admins write.
@freezed
abstract class AppConfig with _$AppConfig {
  const factory AppConfig({
    /// Builds below this see the force-update screen.
    required int minSupportedBuild,
    String? maintenanceMessage,
    required String supportPhone,

    /// Kill switch for new bookings.
    required bool dispatchEnabled,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map<String, dynamic> json) => _$AppConfigFromJson(json);
}

/// `auditLogs/{id}` 🔒: one per admin action.
@freezed
abstract class AuditLog with _$AuditLog {
  const factory AuditLog({
    required String actorUid,

    /// e.g. `mechanic.approve`, `price.update`.
    required String action,

    /// Document path, e.g. `mechanics/abc`.
    required String target,
    Object? before,
    Object? after,
    @TimestampConverter() DateTime? at,
  }) = _AuditLog;

  factory AuditLog.fromJson(Map<String, dynamic> json) => _$AuditLogFromJson(json);
}

/// Custom claims on the ID token, set only by Functions (PLAN §8 Roles, §12.2).
@freezed
abstract class RoleClaims with _$RoleClaims {
  const factory RoleClaims({Role? role, MechanicStatus? mechanicStatus}) = _RoleClaims;

  const RoleClaims._();

  factory RoleClaims.fromJson(Map<String, dynamic> json) => _$RoleClaimsFromJson(json);

  /// Reads the claims from `IdTokenResult.claims`, ignoring unknown values.
  factory RoleClaims.fromTokenClaims(Map<String, dynamic>? claims) {
    Role? role;
    MechanicStatus? status;
    try {
      if (claims?['role'] case final String r) role = Role.fromValue(r);
    } on ArgumentError {
      role = null;
    }
    try {
      if (claims?['mechanicStatus'] case final String s) status = MechanicStatus.fromValue(s);
    } on ArgumentError {
      status = null;
    }
    return RoleClaims(role: role, mechanicStatus: status);
  }

  bool get isAdmin => role == Role.admin;
  bool get isApprovedMechanic => role == Role.mechanic && mechanicStatus == MechanicStatus.approved;
}
