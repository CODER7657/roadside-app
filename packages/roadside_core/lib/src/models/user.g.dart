// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => $checkedCreate('_AppUser', json, ($checkedConvert) {
  final val = _AppUser(
    name: $checkedConvert('name', (v) => v as String),
    phone: $checkedConvert('phone', (v) => v as String),
    language: $checkedConvert('language', (v) => $enumDecode(_$LanguageEnumMap, v)),
    emergencyContacts: $checkedConvert(
      'emergencyContacts',
      (v) =>
          (v as List<dynamic>?)?.map((e) => Contact.fromJson(e as Map<String, dynamic>)).toList() ??
          const <Contact>[],
    ),
    fcmToken: $checkedConvert('fcmToken', (v) => v as String?),
    consent: $checkedConvert(
      'consent',
      (v) => v == null ? null : Consent.fromJson(v as Map<String, dynamic>),
    ),
    deletionRequestedAt: $checkedConvert(
      'deletionRequestedAt',
      (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
    ),
    createdAt: $checkedConvert(
      'createdAt',
      (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
    ),
    updatedAt: $checkedConvert(
      'updatedAt',
      (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
    ),
    schemaVersion: $checkedConvert('schemaVersion', (v) => (v as num?)?.toInt() ?? kSchemaVersion),
  );
  return val;
});

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'name': instance.name,
  'phone': instance.phone,
  'language': _$LanguageEnumMap[instance.language]!,
  'emergencyContacts': instance.emergencyContacts.map((e) => e.toJson()).toList(),
  'fcmToken': instance.fcmToken,
  'consent': instance.consent?.toJson(),
  'deletionRequestedAt': _$JsonConverterToJson<Object, DateTime>(
    instance.deletionRequestedAt,
    const TimestampConverter().toJson,
  ),
  'createdAt': _$JsonConverterToJson<Object, DateTime>(instance.createdAt, const TimestampConverter().toJson),
  'updatedAt': _$JsonConverterToJson<Object, DateTime>(instance.updatedAt, const TimestampConverter().toJson),
  'schemaVersion': instance.schemaVersion,
};

const _$LanguageEnumMap = {Language.en: 'en', Language.hi: 'hi', Language.gu: 'gu'};

Value? _$JsonConverterFromJson<Json, Value>(Object? json, Value? Function(Json json) fromJson) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(Value? value, Json? Function(Value value) toJson) =>
    value == null ? null : toJson(value);

_Consent _$ConsentFromJson(Map<String, dynamic> json) => $checkedCreate('_Consent', json, ($checkedConvert) {
  final val = _Consent(
    version: $checkedConvert('version', (v) => v as String),
    acceptedAt: $checkedConvert('acceptedAt', (v) => const TimestampConverter().fromJson(v as Object)),
  );
  return val;
});

Map<String, dynamic> _$ConsentToJson(_Consent instance) => <String, dynamic>{
  'version': instance.version,
  'acceptedAt': const TimestampConverter().toJson(instance.acceptedAt),
};

_Vehicle _$VehicleFromJson(Map<String, dynamic> json) => $checkedCreate('_Vehicle', json, ($checkedConvert) {
  final val = _Vehicle(
    type: $checkedConvert('type', (v) => $enumDecode(_$VehicleTypeEnumMap, v)),
    brand: $checkedConvert('brand', (v) => v as String),
    model: $checkedConvert('model', (v) => v as String),
    regNo: $checkedConvert('regNo', (v) => v as String),
    fuel: $checkedConvert('fuel', (v) => $enumDecode(_$FuelEnumMap, v)),
    isDefault: $checkedConvert('isDefault', (v) => v as bool? ?? false),
    createdAt: $checkedConvert(
      'createdAt',
      (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
    ),
    updatedAt: $checkedConvert(
      'updatedAt',
      (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
    ),
    schemaVersion: $checkedConvert('schemaVersion', (v) => (v as num?)?.toInt() ?? kSchemaVersion),
  );
  return val;
});

Map<String, dynamic> _$VehicleToJson(_Vehicle instance) => <String, dynamic>{
  'type': _$VehicleTypeEnumMap[instance.type]!,
  'brand': instance.brand,
  'model': instance.model,
  'regNo': instance.regNo,
  'fuel': _$FuelEnumMap[instance.fuel]!,
  'isDefault': instance.isDefault,
  'createdAt': _$JsonConverterToJson<Object, DateTime>(instance.createdAt, const TimestampConverter().toJson),
  'updatedAt': _$JsonConverterToJson<Object, DateTime>(instance.updatedAt, const TimestampConverter().toJson),
  'schemaVersion': instance.schemaVersion,
};

const _$VehicleTypeEnumMap = {
  VehicleType.car: 'car',
  VehicleType.bike: 'bike',
  VehicleType.scooter: 'scooter',
  VehicleType.ev: 'ev',
};

const _$FuelEnumMap = {
  Fuel.petrol: 'petrol',
  Fuel.diesel: 'diesel',
  Fuel.cng: 'cng',
  Fuel.electric: 'electric',
};
