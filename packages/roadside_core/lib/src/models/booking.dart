// bookings/{id} and its sub-collections, offers, liveLocations, shareLinks (PLAN.md §8).
// All of these are written only by Cloud Functions, except chat messages and live locations.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../converters.dart';
import '../enums.dart';
import 'common.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

/// `offers/{offerId}` 🔒: what a mechanic sees before accepting. No exact address, no phone.
@freezed
abstract class Offer with _$Offer {
  const factory Offer({
    required String bookingId,
    required String mechanicId,
    required VehicleType vehicleType,
    required ProblemType problemType,
    required String regNo,
    required double distanceKm,

    /// Locality only.
    required String areaName,
    required PriceRange priceEstimate,
    @TimestampConverter() required DateTime expiresAt,
    required OfferState state,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @Default(kSchemaVersion) int schemaVersion,
  }) = _Offer;

  factory Offer.fromJson(Map<String, dynamic> json) => _$OfferFromJson(json);
}

/// Snapshot of the mechanic set at accept, shown on the TrustPass.
@freezed
abstract class MechanicCard with _$MechanicCard {
  const factory MechanicCard({
    required String name,
    required String photoUrl,
    required MechanicType mechanicType,

    /// Workshop only.
    String? shopName,

    /// Independent only.
    int? experienceYears,

    /// Independent only.
    String? travelVehicleRegNo,
    required double rating,
    required int jobsCompleted,
    required String phone,
    required String upiId,
    required String upiName,
  }) = _MechanicCard;

  factory MechanicCard.fromJson(Map<String, dynamic> json) => _$MechanicCardFromJson(json);
}

@freezed
abstract class StatusHistoryEntry with _$StatusHistoryEntry {
  const factory StatusHistoryEntry({
    required BookingStatus status,
    @TimestampConverter() required DateTime at,

    /// The uid that made the change, or `system`.
    required String by,
  }) = _StatusHistoryEntry;

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) => _$StatusHistoryEntryFromJson(json);
}

/// `bookings/{id}.vehicle`: a snapshot of the customer's vehicle.
@freezed
abstract class BookingVehicle with _$BookingVehicle {
  const factory BookingVehicle({
    required VehicleType type,
    required String brand,
    required String model,
    required String regNo,
  }) = _BookingVehicle;

  factory BookingVehicle.fromJson(Map<String, dynamic> json) => _$BookingVehicleFromJson(json);
}

@freezed
abstract class Pickup with _$Pickup {
  const factory Pickup({
    @GeoPointConverter() required GeoPoint geopoint,
    required String geohash,
    required String address,
    @Default('') String landmark,
    @Default('') String plusCode,
    required double accuracyMeters,
  }) = _Pickup;

  factory Pickup.fromJson(Map<String, dynamic> json) => _$PickupFromJson(json);
}

/// When each stop on the Journey Rail was reached. Missing until reached.
@freezed
abstract class BookingTimestamps with _$BookingTimestamps {
  @JsonSerializable(includeIfNull: false)
  const factory BookingTimestamps({
    @TimestampConverter() DateTime? requested,
    @TimestampConverter() DateTime? accepted,
    @TimestampConverter() DateTime? arriving,
    @TimestampConverter() DateTime? arrived,
    @TimestampConverter() DateTime? started,
    @TimestampConverter() DateTime? completed,
    @TimestampConverter() DateTime? cancelled,
  }) = _BookingTimestamps;

  factory BookingTimestamps.fromJson(Map<String, dynamic> json) => _$BookingTimestampsFromJson(json);
}

@freezed
abstract class CancelReason with _$CancelReason {
  @JsonSerializable(includeIfNull: false)
  const factory CancelReason({required String code, String? text}) = _CancelReason;

  factory CancelReason.fromJson(Map<String, dynamic> json) => _$CancelReasonFromJson(json);
}

/// `bookings/{bookingId}` 🔒: clients read (customer, assigned mechanic, admin); only Functions write.
@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String customerId,

    /// Null until accepted.
    String? mechanicId,
    required CityId cityId,
    required BookingVehicle vehicle,
    required ProblemType problemType,
    @Default('') String description,
    @Default(<String>[]) List<String> photoUrls,
    required Pickup pickup,
    required BookingStatus status,
    @Default(<StatusHistoryEntry>[]) List<StatusHistoryEntry> statusHistory,
    String? currentOfferId,
    @Default(<String>[]) List<String> triedMechanicIds,

    /// 3 → 5 → 10.
    required int searchRadiusKm,

    /// Computed by the server from `prices`.
    required PriceRange priceEstimate,
    int? finalAmount,

    /// Set at accept.
    MechanicCard? mechanicCard,

    /// Set at accept.
    Contact? customerCard,
    @Default(PaymentStatus.pending) PaymentStatus paymentStatus,
    @Default(<String>[]) List<String> beforePhotoUrls,
    @Default(<String>[]) List<String> afterPhotoUrls,
    @Default(BookingTimestamps()) BookingTimestamps timestamps,
    Actor? cancelledBy,
    CancelReason? cancelReason,
    required String idempotencyKey,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @Default(kSchemaVersion) int schemaVersion,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
}

/// `bookings/{bookingId}/private/otp` 🔒: readable only by the booking's customer.
@freezed
abstract class BookingOtp with _$BookingOtp {
  const factory BookingOtp({
    /// 4 digits.
    required String code,
    @Default(0) int attempts,
    @TimestampConverter() DateTime? lockedUntil,
  }) = _BookingOtp;

  factory BookingOtp.fromJson(Map<String, dynamic> json) => _$BookingOtpFromJson(json);
}

/// `bookings/{bookingId}/messages/{messageId}`.
@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String senderId,

    /// ≤ 500 characters (`kMaxChatLength`).
    @Default('') String text,

    /// Storage path under `bookings/{bookingId}/chat/`.
    String? imagePath,
    @TimestampConverter() DateTime? createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
}

/// `liveLocations/{bookingId}`: the assigned mechanic writes, the booking's customer reads.
@freezed
abstract class LiveLocation with _$LiveLocation {
  const factory LiveLocation({
    @GeoPointConverter() required GeoPoint mechanicGeopoint,
    required double heading,
    required double speed,
    required int etaMinutes,
    @TimestampConverter() DateTime? updatedAt,

    /// TTL: deleted 24 h after the job ends.
    @TimestampConverter() required DateTime expireAt,
  }) = _LiveLocation;

  factory LiveLocation.fromJson(Map<String, dynamic> json) => _$LiveLocationFromJson(json);
}

/// `shareLinks/{token}` 🔒.
@freezed
abstract class ShareLink with _$ShareLink {
  const factory ShareLink({
    required String bookingId,
    required String createdBy,
    @TimestampConverter() required DateTime expiresAt,
  }) = _ShareLink;

  factory ShareLink.fromJson(Map<String, dynamic> json) => _$ShareLinkFromJson(json);
}
