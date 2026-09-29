// Value types shared by several documents (PLAN.md §8).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../converters.dart';
import '../enums.dart';

part 'common.freezed.dart';
part 'common.g.dart';

/// `{ name, phone }`: emergency contacts, `customerCard`, a mechanic's reference.
@freezed
abstract class Contact with _$Contact {
  const factory Contact({
    required String name,

    /// E.164, e.g. `+919876543210`.
    required String phone,
  }) = _Contact;

  factory Contact.fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);
}

/// `{ geopoint, geohash }`, as used by `presence.location`.
@freezed
abstract class GeoLocation with _$GeoLocation {
  const factory GeoLocation({@GeoPointConverter() required GeoPoint geopoint, required String geohash}) =
      _GeoLocation;

  factory GeoLocation.fromJson(Map<String, dynamic> json) => _$GeoLocationFromJson(json);
}

/// `{ min, max }` in whole rupees.
@freezed
abstract class PriceRange with _$PriceRange {
  const factory PriceRange({required int min, required int max}) = _PriceRange;

  factory PriceRange.fromJson(Map<String, dynamic> json) => _$PriceRangeFromJson(json);
}

/// Text in the three app languages, e.g. `serviceAreas.name`.
@freezed
abstract class LocalizedText with _$LocalizedText {
  const factory LocalizedText({required String en, required String hi, required String gu}) = _LocalizedText;

  const LocalizedText._();

  factory LocalizedText.fromJson(Map<String, dynamic> json) => _$LocalizedTextFromJson(json);

  String of(Language language) => switch (language) {
    Language.en => en,
    Language.hi => hi,
    Language.gu => gu,
  };
}
