// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Offer _$OfferFromJson(Map<String, dynamic> json) => $checkedCreate('_Offer', json, ($checkedConvert) {
  final val = _Offer(
    bookingId: $checkedConvert('bookingId', (v) => v as String),
    mechanicId: $checkedConvert('mechanicId', (v) => v as String),
    vehicleType: $checkedConvert('vehicleType', (v) => $enumDecode(_$VehicleTypeEnumMap, v)),
    problemType: $checkedConvert('problemType', (v) => $enumDecode(_$ProblemTypeEnumMap, v)),
    regNo: $checkedConvert('regNo', (v) => v as String),
    distanceKm: $checkedConvert('distanceKm', (v) => (v as num).toDouble()),
    areaName: $checkedConvert('areaName', (v) => v as String),
    priceEstimate: $checkedConvert('priceEstimate', (v) => PriceRange.fromJson(v as Map<String, dynamic>)),
    expiresAt: $checkedConvert('expiresAt', (v) => const TimestampConverter().fromJson(v as Object)),
    state: $checkedConvert('state', (v) => $enumDecode(_$OfferStateEnumMap, v)),
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

Map<String, dynamic> _$OfferToJson(_Offer instance) => <String, dynamic>{
  'bookingId': instance.bookingId,
  'mechanicId': instance.mechanicId,
  'vehicleType': _$VehicleTypeEnumMap[instance.vehicleType]!,
  'problemType': _$ProblemTypeEnumMap[instance.problemType]!,
  'regNo': instance.regNo,
  'distanceKm': instance.distanceKm,
  'areaName': instance.areaName,
  'priceEstimate': instance.priceEstimate.toJson(),
  'expiresAt': const TimestampConverter().toJson(instance.expiresAt),
  'state': _$OfferStateEnumMap[instance.state]!,
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

const _$ProblemTypeEnumMap = {
  ProblemType.flatTyre: 'flat_tyre',
  ProblemType.battery: 'battery',
  ProblemType.wontStart: 'wont_start',
  ProblemType.overheating: 'overheating',
  ProblemType.accident: 'accident',
  ProblemType.fuel: 'fuel',
  ProblemType.other: 'other',
};

const _$OfferStateEnumMap = {
  OfferState.pending: 'pending',
  OfferState.accepted: 'accepted',
  OfferState.declined: 'declined',
  OfferState.expired: 'expired',
};

Value? _$JsonConverterFromJson<Json, Value>(Object? json, Value? Function(Json json) fromJson) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(Value? value, Json? Function(Value value) toJson) =>
    value == null ? null : toJson(value);

_MechanicCard _$MechanicCardFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_MechanicCard', json, ($checkedConvert) {
      final val = _MechanicCard(
        name: $checkedConvert('name', (v) => v as String),
        photoUrl: $checkedConvert('photoUrl', (v) => v as String),
        mechanicType: $checkedConvert('mechanicType', (v) => $enumDecode(_$MechanicTypeEnumMap, v)),
        shopName: $checkedConvert('shopName', (v) => v as String?),
        experienceYears: $checkedConvert('experienceYears', (v) => (v as num?)?.toInt()),
        travelVehicleRegNo: $checkedConvert('travelVehicleRegNo', (v) => v as String?),
        rating: $checkedConvert('rating', (v) => (v as num).toDouble()),
        jobsCompleted: $checkedConvert('jobsCompleted', (v) => (v as num).toInt()),
        phone: $checkedConvert('phone', (v) => v as String),
        upiId: $checkedConvert('upiId', (v) => v as String),
        upiName: $checkedConvert('upiName', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$MechanicCardToJson(_MechanicCard instance) => <String, dynamic>{
  'name': instance.name,
  'photoUrl': instance.photoUrl,
  'mechanicType': _$MechanicTypeEnumMap[instance.mechanicType]!,
  'shopName': instance.shopName,
  'experienceYears': instance.experienceYears,
  'travelVehicleRegNo': instance.travelVehicleRegNo,
  'rating': instance.rating,
  'jobsCompleted': instance.jobsCompleted,
  'phone': instance.phone,
  'upiId': instance.upiId,
  'upiName': instance.upiName,
};

const _$MechanicTypeEnumMap = {MechanicType.workshop: 'workshop', MechanicType.independent: 'independent'};

_StatusHistoryEntry _$StatusHistoryEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_StatusHistoryEntry', json, ($checkedConvert) {
      final val = _StatusHistoryEntry(
        status: $checkedConvert('status', (v) => $enumDecode(_$BookingStatusEnumMap, v)),
        at: $checkedConvert('at', (v) => const TimestampConverter().fromJson(v as Object)),
        by: $checkedConvert('by', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$StatusHistoryEntryToJson(_StatusHistoryEntry instance) => <String, dynamic>{
  'status': _$BookingStatusEnumMap[instance.status]!,
  'at': const TimestampConverter().toJson(instance.at),
  'by': instance.by,
};

const _$BookingStatusEnumMap = {
  BookingStatus.requested: 'requested',
  BookingStatus.accepted: 'accepted',
  BookingStatus.arriving: 'arriving',
  BookingStatus.arrived: 'arrived',
  BookingStatus.inProgress: 'in_progress',
  BookingStatus.completed: 'completed',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.noMechanicFound: 'no_mechanic_found',
};

_BookingVehicle _$BookingVehicleFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_BookingVehicle', json, ($checkedConvert) {
      final val = _BookingVehicle(
        type: $checkedConvert('type', (v) => $enumDecode(_$VehicleTypeEnumMap, v)),
        brand: $checkedConvert('brand', (v) => v as String),
        model: $checkedConvert('model', (v) => v as String),
        regNo: $checkedConvert('regNo', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$BookingVehicleToJson(_BookingVehicle instance) => <String, dynamic>{
  'type': _$VehicleTypeEnumMap[instance.type]!,
  'brand': instance.brand,
  'model': instance.model,
  'regNo': instance.regNo,
};

_Pickup _$PickupFromJson(Map<String, dynamic> json) => $checkedCreate('_Pickup', json, ($checkedConvert) {
  final val = _Pickup(
    geopoint: $checkedConvert('geopoint', (v) => const GeoPointConverter().fromJson(v as Object)),
    geohash: $checkedConvert('geohash', (v) => v as String),
    address: $checkedConvert('address', (v) => v as String),
    landmark: $checkedConvert('landmark', (v) => v as String? ?? ''),
    plusCode: $checkedConvert('plusCode', (v) => v as String? ?? ''),
    accuracyMeters: $checkedConvert('accuracyMeters', (v) => (v as num).toDouble()),
  );
  return val;
});

Map<String, dynamic> _$PickupToJson(_Pickup instance) => <String, dynamic>{
  'geopoint': const GeoPointConverter().toJson(instance.geopoint),
  'geohash': instance.geohash,
  'address': instance.address,
  'landmark': instance.landmark,
  'plusCode': instance.plusCode,
  'accuracyMeters': instance.accuracyMeters,
};

_BookingTimestamps _$BookingTimestampsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_BookingTimestamps', json, ($checkedConvert) {
      final val = _BookingTimestamps(
        requested: $checkedConvert(
          'requested',
          (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
        ),
        accepted: $checkedConvert(
          'accepted',
          (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
        ),
        arriving: $checkedConvert(
          'arriving',
          (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
        ),
        arrived: $checkedConvert(
          'arrived',
          (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
        ),
        started: $checkedConvert(
          'started',
          (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
        ),
        completed: $checkedConvert(
          'completed',
          (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
        ),
        cancelled: $checkedConvert(
          'cancelled',
          (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
        ),
      );
      return val;
    });

Map<String, dynamic> _$BookingTimestampsToJson(_BookingTimestamps instance) => <String, dynamic>{
  'requested': ?_$JsonConverterToJson<Object, DateTime>(
    instance.requested,
    const TimestampConverter().toJson,
  ),
  'accepted': ?_$JsonConverterToJson<Object, DateTime>(instance.accepted, const TimestampConverter().toJson),
  'arriving': ?_$JsonConverterToJson<Object, DateTime>(instance.arriving, const TimestampConverter().toJson),
  'arrived': ?_$JsonConverterToJson<Object, DateTime>(instance.arrived, const TimestampConverter().toJson),
  'started': ?_$JsonConverterToJson<Object, DateTime>(instance.started, const TimestampConverter().toJson),
  'completed': ?_$JsonConverterToJson<Object, DateTime>(
    instance.completed,
    const TimestampConverter().toJson,
  ),
  'cancelled': ?_$JsonConverterToJson<Object, DateTime>(
    instance.cancelled,
    const TimestampConverter().toJson,
  ),
};

_CancelReason _$CancelReasonFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CancelReason', json, ($checkedConvert) {
      final val = _CancelReason(
        code: $checkedConvert('code', (v) => v as String),
        text: $checkedConvert('text', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CancelReasonToJson(_CancelReason instance) => <String, dynamic>{
  'code': instance.code,
  'text': ?instance.text,
};

_Booking _$BookingFromJson(Map<String, dynamic> json) => $checkedCreate('_Booking', json, ($checkedConvert) {
  final val = _Booking(
    customerId: $checkedConvert('customerId', (v) => v as String),
    mechanicId: $checkedConvert('mechanicId', (v) => v as String?),
    cityId: $checkedConvert('cityId', (v) => $enumDecode(_$CityIdEnumMap, v)),
    vehicle: $checkedConvert('vehicle', (v) => BookingVehicle.fromJson(v as Map<String, dynamic>)),
    problemType: $checkedConvert('problemType', (v) => $enumDecode(_$ProblemTypeEnumMap, v)),
    description: $checkedConvert('description', (v) => v as String? ?? ''),
    photoUrls: $checkedConvert(
      'photoUrls',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
    ),
    pickup: $checkedConvert('pickup', (v) => Pickup.fromJson(v as Map<String, dynamic>)),
    status: $checkedConvert('status', (v) => $enumDecode(_$BookingStatusEnumMap, v)),
    statusHistory: $checkedConvert(
      'statusHistory',
      (v) =>
          (v as List<dynamic>?)
              ?.map((e) => StatusHistoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <StatusHistoryEntry>[],
    ),
    currentOfferId: $checkedConvert('currentOfferId', (v) => v as String?),
    triedMechanicIds: $checkedConvert(
      'triedMechanicIds',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
    ),
    searchRadiusKm: $checkedConvert('searchRadiusKm', (v) => (v as num).toInt()),
    priceEstimate: $checkedConvert('priceEstimate', (v) => PriceRange.fromJson(v as Map<String, dynamic>)),
    finalAmount: $checkedConvert('finalAmount', (v) => (v as num?)?.toInt()),
    mechanicCard: $checkedConvert(
      'mechanicCard',
      (v) => v == null ? null : MechanicCard.fromJson(v as Map<String, dynamic>),
    ),
    customerCard: $checkedConvert(
      'customerCard',
      (v) => v == null ? null : Contact.fromJson(v as Map<String, dynamic>),
    ),
    paymentStatus: $checkedConvert(
      'paymentStatus',
      (v) => $enumDecodeNullable(_$PaymentStatusEnumMap, v) ?? PaymentStatus.pending,
    ),
    beforePhotoUrls: $checkedConvert(
      'beforePhotoUrls',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
    ),
    afterPhotoUrls: $checkedConvert(
      'afterPhotoUrls',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
    ),
    timestamps: $checkedConvert(
      'timestamps',
      (v) => v == null ? const BookingTimestamps() : BookingTimestamps.fromJson(v as Map<String, dynamic>),
    ),
    cancelledBy: $checkedConvert('cancelledBy', (v) => $enumDecodeNullable(_$ActorEnumMap, v)),
    cancelReason: $checkedConvert(
      'cancelReason',
      (v) => v == null ? null : CancelReason.fromJson(v as Map<String, dynamic>),
    ),
    idempotencyKey: $checkedConvert('idempotencyKey', (v) => v as String),
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

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'customerId': instance.customerId,
  'mechanicId': instance.mechanicId,
  'cityId': _$CityIdEnumMap[instance.cityId]!,
  'vehicle': instance.vehicle.toJson(),
  'problemType': _$ProblemTypeEnumMap[instance.problemType]!,
  'description': instance.description,
  'photoUrls': instance.photoUrls,
  'pickup': instance.pickup.toJson(),
  'status': _$BookingStatusEnumMap[instance.status]!,
  'statusHistory': instance.statusHistory.map((e) => e.toJson()).toList(),
  'currentOfferId': instance.currentOfferId,
  'triedMechanicIds': instance.triedMechanicIds,
  'searchRadiusKm': instance.searchRadiusKm,
  'priceEstimate': instance.priceEstimate.toJson(),
  'finalAmount': instance.finalAmount,
  'mechanicCard': instance.mechanicCard?.toJson(),
  'customerCard': instance.customerCard?.toJson(),
  'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
  'beforePhotoUrls': instance.beforePhotoUrls,
  'afterPhotoUrls': instance.afterPhotoUrls,
  'timestamps': instance.timestamps.toJson(),
  'cancelledBy': _$ActorEnumMap[instance.cancelledBy],
  'cancelReason': instance.cancelReason?.toJson(),
  'idempotencyKey': instance.idempotencyKey,
  'createdAt': _$JsonConverterToJson<Object, DateTime>(instance.createdAt, const TimestampConverter().toJson),
  'updatedAt': _$JsonConverterToJson<Object, DateTime>(instance.updatedAt, const TimestampConverter().toJson),
  'schemaVersion': instance.schemaVersion,
};

const _$CityIdEnumMap = {
  CityId.ahmedabad: 'ahmedabad',
  CityId.ankleshwar: 'ankleshwar',
  CityId.bharuch: 'bharuch',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.customerMarkedPaid: 'customer_marked_paid',
  PaymentStatus.confirmed: 'confirmed',
  PaymentStatus.disputed: 'disputed',
};

const _$ActorEnumMap = {
  Actor.customer: 'customer',
  Actor.mechanic: 'mechanic',
  Actor.admin: 'admin',
  Actor.system: 'system',
};

_BookingOtp _$BookingOtpFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_BookingOtp', json, ($checkedConvert) {
      final val = _BookingOtp(
        code: $checkedConvert('code', (v) => v as String),
        attempts: $checkedConvert('attempts', (v) => (v as num?)?.toInt() ?? 0),
        lockedUntil: $checkedConvert(
          'lockedUntil',
          (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
        ),
      );
      return val;
    });

Map<String, dynamic> _$BookingOtpToJson(_BookingOtp instance) => <String, dynamic>{
  'code': instance.code,
  'attempts': instance.attempts,
  'lockedUntil': _$JsonConverterToJson<Object, DateTime>(
    instance.lockedUntil,
    const TimestampConverter().toJson,
  ),
};

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ChatMessage', json, ($checkedConvert) {
      final val = _ChatMessage(
        senderId: $checkedConvert('senderId', (v) => v as String),
        text: $checkedConvert('text', (v) => v as String? ?? ''),
        imagePath: $checkedConvert('imagePath', (v) => v as String?),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) => <String, dynamic>{
  'senderId': instance.senderId,
  'text': instance.text,
  'imagePath': instance.imagePath,
  'createdAt': _$JsonConverterToJson<Object, DateTime>(instance.createdAt, const TimestampConverter().toJson),
};

_LiveLocation _$LiveLocationFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_LiveLocation', json, ($checkedConvert) {
      final val = _LiveLocation(
        mechanicGeopoint: $checkedConvert(
          'mechanicGeopoint',
          (v) => const GeoPointConverter().fromJson(v as Object),
        ),
        heading: $checkedConvert('heading', (v) => (v as num).toDouble()),
        speed: $checkedConvert('speed', (v) => (v as num).toDouble()),
        etaMinutes: $checkedConvert('etaMinutes', (v) => (v as num).toInt()),
        updatedAt: $checkedConvert(
          'updatedAt',
          (v) => _$JsonConverterFromJson<Object, DateTime>(v, const TimestampConverter().fromJson),
        ),
        expireAt: $checkedConvert('expireAt', (v) => const TimestampConverter().fromJson(v as Object)),
      );
      return val;
    });

Map<String, dynamic> _$LiveLocationToJson(_LiveLocation instance) => <String, dynamic>{
  'mechanicGeopoint': const GeoPointConverter().toJson(instance.mechanicGeopoint),
  'heading': instance.heading,
  'speed': instance.speed,
  'etaMinutes': instance.etaMinutes,
  'updatedAt': _$JsonConverterToJson<Object, DateTime>(instance.updatedAt, const TimestampConverter().toJson),
  'expireAt': const TimestampConverter().toJson(instance.expireAt),
};

_ShareLink _$ShareLinkFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ShareLink', json, ($checkedConvert) {
      final val = _ShareLink(
        bookingId: $checkedConvert('bookingId', (v) => v as String),
        createdBy: $checkedConvert('createdBy', (v) => v as String),
        expiresAt: $checkedConvert('expiresAt', (v) => const TimestampConverter().fromJson(v as Object)),
      );
      return val;
    });

Map<String, dynamic> _$ShareLinkToJson(_ShareLink instance) => <String, dynamic>{
  'bookingId': instance.bookingId,
  'createdBy': instance.createdBy,
  'expiresAt': const TimestampConverter().toJson(instance.expiresAt),
};
