// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mechanic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Mechanic _$MechanicFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Mechanic', json, ($checkedConvert) {
      final val = _Mechanic(
        name: $checkedConvert('name', (v) => v as String),
        profilePhotoUrl: $checkedConvert('profilePhotoUrl', (v) => v as String),
        mechanicType: $checkedConvert('mechanicType', (v) => $enumDecode(_$MechanicTypeEnumMap, v)),
        shopName: $checkedConvert('shopName', (v) => v as String?),
        shopAddress: $checkedConvert('shopAddress', (v) => v as String?),
        shopPhotoUrl: $checkedConvert('shopPhotoUrl', (v) => v as String?),
        baseArea: $checkedConvert(
          'baseArea',
          (v) => v == null ? null : BaseArea.fromJson(v as Map<String, dynamic>),
        ),
        experienceYears: $checkedConvert('experienceYears', (v) => (v as num?)?.toInt()),
        toolkitPhotoUrls: $checkedConvert(
          'toolkitPhotoUrls',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        travelVehicle: $checkedConvert(
          'travelVehicle',
          (v) => v == null ? null : TravelVehicle.fromJson(v as Map<String, dynamic>),
        ),
        cityId: $checkedConvert('cityId', (v) => $enumDecode(_$CityIdEnumMap, v)),
        vehicleTypes: $checkedConvert(
          'vehicleTypes',
          (v) => (v as List<dynamic>).map((e) => $enumDecode(_$VehicleTypeEnumMap, e)).toList(),
        ),
        services: $checkedConvert(
          'services',
          (v) => (v as List<dynamic>).map((e) => $enumDecode(_$ProblemTypeEnumMap, e)).toList(),
        ),
        status: $checkedConvert(
          'status',
          (v) => $enumDecodeNullable(_$MechanicStatusEnumMap, v) ?? MechanicStatus.pending,
        ),
        rating: $checkedConvert('rating', (v) => (v as num?)?.toDouble() ?? 0),
        ratingCount: $checkedConvert('ratingCount', (v) => (v as num?)?.toInt() ?? 0),
        jobsCompleted: $checkedConvert('jobsCompleted', (v) => (v as num?)?.toInt() ?? 0),
        fcmToken: $checkedConvert('fcmToken', (v) => v as String?),
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

Map<String, dynamic> _$MechanicToJson(_Mechanic instance) => <String, dynamic>{
  'name': instance.name,
  'profilePhotoUrl': instance.profilePhotoUrl,
  'mechanicType': _$MechanicTypeEnumMap[instance.mechanicType]!,
  'shopName': ?instance.shopName,
  'shopAddress': ?instance.shopAddress,
  'shopPhotoUrl': ?instance.shopPhotoUrl,
  'baseArea': ?instance.baseArea?.toJson(),
  'experienceYears': ?instance.experienceYears,
  'toolkitPhotoUrls': ?instance.toolkitPhotoUrls,
  'travelVehicle': ?instance.travelVehicle?.toJson(),
  'cityId': _$CityIdEnumMap[instance.cityId]!,
  'vehicleTypes': instance.vehicleTypes.map((e) => _$VehicleTypeEnumMap[e]!).toList(),
  'services': instance.services.map((e) => _$ProblemTypeEnumMap[e]!).toList(),
  'status': _$MechanicStatusEnumMap[instance.status]!,
  'rating': instance.rating,
  'ratingCount': instance.ratingCount,
  'jobsCompleted': instance.jobsCompleted,
  'fcmToken': ?instance.fcmToken,
  'createdAt': ?_$JsonConverterToJson<Object, DateTime>(
    instance.createdAt,
    const TimestampConverter().toJson,
  ),
  'updatedAt': ?_$JsonConverterToJson<Object, DateTime>(
    instance.updatedAt,
    const TimestampConverter().toJson,
  ),
  'schemaVersion': instance.schemaVersion,
};

const _$MechanicTypeEnumMap = {MechanicType.workshop: 'workshop', MechanicType.independent: 'independent'};

const _$CityIdEnumMap = {
  CityId.ahmedabad: 'ahmedabad',
  CityId.ankleshwar: 'ankleshwar',
  CityId.bharuch: 'bharuch',
};

const _$VehicleTypeEnumMap = {
  VehicleType.car: 'car',
  VehicleType.bike: 'bike',
  VehicleType.scooter: 'scooter',
  VehicleType.ev: 'ev',
};

const _$ProblemTypeEnumMap = {
  ProblemType.flatTyre: 'flat_tyre',
  ProblemType.battery: 'battery',
  ProblemType.wontStart: 'wont_start',
  ProblemType.overheating: 'overheating',
  ProblemType.accident: 'accident',
  ProblemType.fuel: 'fuel',
  ProblemType.other: 'other',
};

const _$MechanicStatusEnumMap = {
  MechanicStatus.pending: 'pending',
  MechanicStatus.approved: 'approved',
  MechanicStatus.blocked: 'blocked',
};

Value? _$JsonConverterFromJson<Json, Value>(Object? json, Value? Function(Json json) fromJson) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(Value? value, Json? Function(Value value) toJson) =>
    value == null ? null : toJson(value);

_BaseArea _$BaseAreaFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_BaseArea', json, ($checkedConvert) {
      final val = _BaseArea(
        locality: $checkedConvert('locality', (v) => v as String),
        geopoint: $checkedConvert('geopoint', (v) => const GeoPointConverter().fromJson(v as Object)),
      );
      return val;
    });

Map<String, dynamic> _$BaseAreaToJson(_BaseArea instance) => <String, dynamic>{
  'locality': instance.locality,
  'geopoint': const GeoPointConverter().toJson(instance.geopoint),
};

_TravelVehicle _$TravelVehicleFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TravelVehicle', json, ($checkedConvert) {
      final val = _TravelVehicle(
        type: $checkedConvert('type', (v) => $enumDecode(_$VehicleTypeEnumMap, v)),
        regNo: $checkedConvert('regNo', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$TravelVehicleToJson(_TravelVehicle instance) => <String, dynamic>{
  'type': _$VehicleTypeEnumMap[instance.type]!,
  'regNo': instance.regNo,
};

_MechanicKyc _$MechanicKycFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_MechanicKyc', json, ($checkedConvert) {
      final val = _MechanicKyc(
        phone: $checkedConvert('phone', (v) => v as String),
        idProofPath: $checkedConvert('idProofPath', (v) => v as String),
        upiId: $checkedConvert('upiId', (v) => v as String),
        upiName: $checkedConvert('upiName', (v) => v as String),
        kycCheckedBy: $checkedConvert('kycCheckedBy', (v) => v as String?),
        kycCheckedAt: $checkedConvert(
          'kycCheckedAt',
          (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
        ),
        selfieWithIdPath: $checkedConvert('selfieWithIdPath', (v) => v as String?),
        addressProofPath: $checkedConvert('addressProofPath', (v) => v as String?),
        referenceContact: $checkedConvert(
          'referenceContact',
          (v) => v == null ? null : Contact.fromJson(v as Map<String, dynamic>),
        ),
        verificationCall: $checkedConvert(
          'verificationCall',
          (v) => v == null ? null : VerificationCall.fromJson(v as Map<String, dynamic>),
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

Map<String, dynamic> _$MechanicKycToJson(_MechanicKyc instance) => <String, dynamic>{
  'phone': instance.phone,
  'idProofPath': instance.idProofPath,
  'upiId': instance.upiId,
  'upiName': instance.upiName,
  'kycCheckedBy': ?instance.kycCheckedBy,
  'kycCheckedAt': ?_$JsonConverterToJson<Object, DateTime>(
    instance.kycCheckedAt,
    const TimestampConverter().toJson,
  ),
  'selfieWithIdPath': ?instance.selfieWithIdPath,
  'addressProofPath': ?instance.addressProofPath,
  'referenceContact': ?instance.referenceContact?.toJson(),
  'verificationCall': ?instance.verificationCall?.toJson(),
  'createdAt': ?_$JsonConverterToJson<Object, DateTime>(
    instance.createdAt,
    const TimestampConverter().toJson,
  ),
  'updatedAt': ?_$JsonConverterToJson<Object, DateTime>(
    instance.updatedAt,
    const TimestampConverter().toJson,
  ),
  'schemaVersion': instance.schemaVersion,
};

_VerificationCall _$VerificationCallFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_VerificationCall', json, ($checkedConvert) {
      final val = _VerificationCall(
        doneBy: $checkedConvert('doneBy', (v) => v as String),
        at: $checkedConvert('at', (v) => const TimestampConverter().fromJson(v as Object)),
        notes: $checkedConvert('notes', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$VerificationCallToJson(_VerificationCall instance) => <String, dynamic>{
  'doneBy': instance.doneBy,
  'at': const TimestampConverter().toJson(instance.at),
  'notes': instance.notes,
};

_Presence _$PresenceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Presence', json, ($checkedConvert) {
      final val = _Presence(
        isOnline: $checkedConvert('isOnline', (v) => v as bool),
        location: $checkedConvert('location', (v) => GeoLocation.fromJson(v as Map<String, dynamic>)),
        updatedAt: $checkedConvert(
          'updatedAt',
          (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
        ),
        cityId: $checkedConvert('cityId', (v) => $enumDecode(_$CityIdEnumMap, v)),
        activeBookingId: $checkedConvert('activeBookingId', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PresenceToJson(_Presence instance) => <String, dynamic>{
  'isOnline': instance.isOnline,
  'location': instance.location.toJson(),
  'updatedAt': _$JsonConverterToJson<Object, DateTime>(instance.updatedAt, const TimestampConverter().toJson),
  'cityId': _$CityIdEnumMap[instance.cityId]!,
  'activeBookingId': instance.activeBookingId,
};
