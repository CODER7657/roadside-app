// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Contact _$ContactFromJson(Map<String, dynamic> json) => $checkedCreate('_Contact', json, ($checkedConvert) {
  final val = _Contact(
    name: $checkedConvert('name', (v) => v as String),
    phone: $checkedConvert('phone', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ContactToJson(_Contact instance) => <String, dynamic>{
  'name': instance.name,
  'phone': instance.phone,
};

_GeoLocation _$GeoLocationFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_GeoLocation', json, ($checkedConvert) {
      final val = _GeoLocation(
        geopoint: $checkedConvert('geopoint', (v) => const GeoPointConverter().fromJson(v as Object)),
        geohash: $checkedConvert('geohash', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$GeoLocationToJson(_GeoLocation instance) => <String, dynamic>{
  'geopoint': const GeoPointConverter().toJson(instance.geopoint),
  'geohash': instance.geohash,
};

_PriceRange _$PriceRangeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_PriceRange', json, ($checkedConvert) {
      final val = _PriceRange(
        min: $checkedConvert('min', (v) => (v as num).toInt()),
        max: $checkedConvert('max', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$PriceRangeToJson(_PriceRange instance) => <String, dynamic>{
  'min': instance.min,
  'max': instance.max,
};

_LocalizedText _$LocalizedTextFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_LocalizedText', json, ($checkedConvert) {
      final val = _LocalizedText(
        en: $checkedConvert('en', (v) => v as String),
        hi: $checkedConvert('hi', (v) => v as String),
        gu: $checkedConvert('gu', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$LocalizedTextToJson(_LocalizedText instance) => <String, dynamic>{
  'en': instance.en,
  'hi': instance.hi,
  'gu': instance.gu,
};
