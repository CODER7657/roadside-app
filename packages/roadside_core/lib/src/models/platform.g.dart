// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Price _$PriceFromJson(Map<String, dynamic> json) => $checkedCreate('_Price', json, ($checkedConvert) {
  final val = _Price(
    vehicleType: $checkedConvert('vehicleType', (v) => $enumDecode(_$VehicleTypeEnumMap, v)),
    problemType: $checkedConvert('problemType', (v) => $enumDecode(_$ProblemTypeEnumMap, v)),
    min: $checkedConvert('min', (v) => (v as num).toInt()),
    max: $checkedConvert('max', (v) => (v as num).toInt()),
    includes: $checkedConvert('includes', (v) => v as String),
    cityOverrides: $checkedConvert(
      'cityOverrides',
      (v) => (v as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry($enumDecode(_$CityIdEnumMap, k), PriceRange.fromJson(e as Map<String, dynamic>)),
      ),
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

Map<String, dynamic> _$PriceToJson(_Price instance) => <String, dynamic>{
  'vehicleType': _$VehicleTypeEnumMap[instance.vehicleType]!,
  'problemType': _$ProblemTypeEnumMap[instance.problemType]!,
  'min': instance.min,
  'max': instance.max,
  'includes': instance.includes,
  'cityOverrides': ?instance.cityOverrides?.map((k, e) => MapEntry(_$CityIdEnumMap[k]!, e.toJson())),
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

const _$CityIdEnumMap = {
  CityId.ahmedabad: 'ahmedabad',
  CityId.ankleshwar: 'ankleshwar',
  CityId.bharuch: 'bharuch',
};

Value? _$JsonConverterFromJson<Json, Value>(Object? json, Value? Function(Json json) fromJson) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(Value? value, Json? Function(Value value) toJson) =>
    value == null ? null : toJson(value);

_ServiceArea _$ServiceAreaFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ServiceArea', json, ($checkedConvert) {
      final val = _ServiceArea(
        name: $checkedConvert('name', (v) => LocalizedText.fromJson(v as Map<String, dynamic>)),
        center: $checkedConvert('center', (v) => const GeoPointConverter().fromJson(v as Object)),
        radiusKm: $checkedConvert('radiusKm', (v) => (v as num).toDouble()),
        active: $checkedConvert('active', (v) => v as bool),
        supportPhone: $checkedConvert('supportPhone', (v) => v as String),
        launchedAt: $checkedConvert(
          'launchedAt',
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

Map<String, dynamic> _$ServiceAreaToJson(_ServiceArea instance) => <String, dynamic>{
  'name': instance.name.toJson(),
  'center': const GeoPointConverter().toJson(instance.center),
  'radiusKm': instance.radiusKm,
  'active': instance.active,
  'supportPhone': instance.supportPhone,
  'launchedAt': _$JsonConverterToJson<Object, DateTime>(
    instance.launchedAt,
    const TimestampConverter().toJson,
  ),
  'createdAt': _$JsonConverterToJson<Object, DateTime>(instance.createdAt, const TimestampConverter().toJson),
  'updatedAt': _$JsonConverterToJson<Object, DateTime>(instance.updatedAt, const TimestampConverter().toJson),
  'schemaVersion': instance.schemaVersion,
};

_Review _$ReviewFromJson(Map<String, dynamic> json) => $checkedCreate('_Review', json, ($checkedConvert) {
  final val = _Review(
    customerId: $checkedConvert('customerId', (v) => v as String),
    mechanicId: $checkedConvert('mechanicId', (v) => v as String),
    stars: $checkedConvert('stars', (v) => (v as num).toInt()),
    tags: $checkedConvert(
      'tags',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
    ),
    comment: $checkedConvert('comment', (v) => v as String? ?? ''),
    createdAt: $checkedConvert(
      'createdAt',
      (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
    ),
  );
  return val;
});

Map<String, dynamic> _$ReviewToJson(_Review instance) => <String, dynamic>{
  'customerId': instance.customerId,
  'mechanicId': instance.mechanicId,
  'stars': instance.stars,
  'tags': instance.tags,
  'comment': instance.comment,
  'createdAt': _$JsonConverterToJson<Object, DateTime>(instance.createdAt, const TimestampConverter().toJson),
};

_Complaint _$ComplaintFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Complaint', json, ($checkedConvert) {
      final val = _Complaint(
        bookingId: $checkedConvert('bookingId', (v) => v as String),
        raisedBy: $checkedConvert('raisedBy', (v) => v as String),
        category: $checkedConvert('category', (v) => v as String),
        text: $checkedConvert('text', (v) => v as String),
        status: $checkedConvert(
          'status',
          (v) => $enumDecodeNullable(_$ComplaintStatusEnumMap, v) ?? ComplaintStatus.open,
        ),
        resolution: $checkedConvert('resolution', (v) => v as String?),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ComplaintToJson(_Complaint instance) => <String, dynamic>{
  'bookingId': instance.bookingId,
  'raisedBy': instance.raisedBy,
  'category': instance.category,
  'text': instance.text,
  'status': _$ComplaintStatusEnumMap[instance.status]!,
  'resolution': instance.resolution,
  'createdAt': _$JsonConverterToJson<Object, DateTime>(instance.createdAt, const TimestampConverter().toJson),
};

const _$ComplaintStatusEnumMap = {ComplaintStatus.open: 'open', ComplaintStatus.resolved: 'resolved'};

_InboxItem _$InboxItemFromJson(Map<String, dynamic> json) => $checkedCreate('_InboxItem', json, (
  $checkedConvert,
) {
  final val = _InboxItem(
    type: $checkedConvert('type', (v) => v as String),
    titleKey: $checkedConvert('titleKey', (v) => v as String),
    bodyKey: $checkedConvert('bodyKey', (v) => v as String),
    args: $checkedConvert(
      'args',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as String)) ?? const <String, String>{},
    ),
    bookingId: $checkedConvert('bookingId', (v) => v as String?),
    read: $checkedConvert('read', (v) => v as bool? ?? false),
  );
  return val;
});

Map<String, dynamic> _$InboxItemToJson(_InboxItem instance) => <String, dynamic>{
  'type': instance.type,
  'titleKey': instance.titleKey,
  'bodyKey': instance.bodyKey,
  'args': instance.args,
  'bookingId': instance.bookingId,
  'read': instance.read,
};

_AppConfig _$AppConfigFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AppConfig', json, ($checkedConvert) {
      final val = _AppConfig(
        minSupportedBuild: $checkedConvert('minSupportedBuild', (v) => (v as num).toInt()),
        maintenanceMessage: $checkedConvert('maintenanceMessage', (v) => v as String?),
        supportPhone: $checkedConvert('supportPhone', (v) => v as String),
        dispatchEnabled: $checkedConvert('dispatchEnabled', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$AppConfigToJson(_AppConfig instance) => <String, dynamic>{
  'minSupportedBuild': instance.minSupportedBuild,
  'maintenanceMessage': instance.maintenanceMessage,
  'supportPhone': instance.supportPhone,
  'dispatchEnabled': instance.dispatchEnabled,
};

_AuditLog _$AuditLogFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AuditLog', json, ($checkedConvert) {
      final val = _AuditLog(
        actorUid: $checkedConvert('actorUid', (v) => v as String),
        action: $checkedConvert('action', (v) => v as String),
        target: $checkedConvert('target', (v) => v as String),
        before: $checkedConvert('before', (v) => v),
        after: $checkedConvert('after', (v) => v),
        at: $checkedConvert(
          'at',
          (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AuditLogToJson(_AuditLog instance) => <String, dynamic>{
  'actorUid': instance.actorUid,
  'action': instance.action,
  'target': instance.target,
  'before': instance.before,
  'after': instance.after,
  'at': _$JsonConverterToJson<Object, DateTime>(instance.at, const TimestampConverter().toJson),
};

_RoleClaims _$RoleClaimsFromJson(Map<String, dynamic> json) => $checkedCreate('_RoleClaims', json, (
  $checkedConvert,
) {
  final val = _RoleClaims(
    role: $checkedConvert('role', (v) => $enumDecodeNullable(_$RoleEnumMap, v)),
    mechanicStatus: $checkedConvert('mechanicStatus', (v) => $enumDecodeNullable(_$MechanicStatusEnumMap, v)),
  );
  return val;
});

Map<String, dynamic> _$RoleClaimsToJson(_RoleClaims instance) => <String, dynamic>{
  'role': _$RoleEnumMap[instance.role],
  'mechanicStatus': _$MechanicStatusEnumMap[instance.mechanicStatus],
};

const _$RoleEnumMap = {Role.customer: 'customer', Role.mechanic: 'mechanic', Role.admin: 'admin'};

const _$MechanicStatusEnumMap = {
  MechanicStatus.pending: 'pending',
  MechanicStatus.approved: 'approved',
  MechanicStatus.blocked: 'blocked',
};
