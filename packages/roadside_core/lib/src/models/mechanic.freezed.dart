// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mechanic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Mechanic {

 String get name; String get profilePhotoUrl; MechanicType get mechanicType; String? get shopName; String? get shopAddress; String? get shopPhotoUrl; BaseArea? get baseArea; int? get experienceYears; List<String>? get toolkitPhotoUrls; TravelVehicle? get travelVehicle;/// Chosen at registration, changed only by admin.
 CityId get cityId; List<VehicleType> get vehicleTypes; List<ProblemType> get services;/// 🔒
 MechanicStatus get status;/// 🔒
 double get rating;/// 🔒
 int get ratingCount;/// 🔒
 int get jobsCompleted; String? get fcmToken;/// 🔒 Set by `requestAccountDeletion`; kept on the reduced profile after the purge, so the KYC
/// retention job knows when the mechanic left (PLAN §8, §12.10). Null (and left out of
/// `toJson()`) for everyone else, since the rules reject it from clients.
@TimestampConverter() DateTime? get deletionRequestedAt;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt; int get schemaVersion;
/// Create a copy of Mechanic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MechanicCopyWith<Mechanic> get copyWith => _$MechanicCopyWithImpl<Mechanic>(this as Mechanic, _$identity);

  /// Serializes this Mechanic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Mechanic;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Mechanic&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.profilePhotoUrl, _this.profilePhotoUrl) || other.profilePhotoUrl == _this.profilePhotoUrl)&&(identical(other.mechanicType, _this.mechanicType) || other.mechanicType == _this.mechanicType)&&(identical(other.shopName, _this.shopName) || other.shopName == _this.shopName)&&(identical(other.shopAddress, _this.shopAddress) || other.shopAddress == _this.shopAddress)&&(identical(other.shopPhotoUrl, _this.shopPhotoUrl) || other.shopPhotoUrl == _this.shopPhotoUrl)&&(identical(other.baseArea, _this.baseArea) || other.baseArea == _this.baseArea)&&(identical(other.experienceYears, _this.experienceYears) || other.experienceYears == _this.experienceYears)&&const DeepCollectionEquality().equals(other.toolkitPhotoUrls, _this.toolkitPhotoUrls)&&(identical(other.travelVehicle, _this.travelVehicle) || other.travelVehicle == _this.travelVehicle)&&(identical(other.cityId, _this.cityId) || other.cityId == _this.cityId)&&const DeepCollectionEquality().equals(other.vehicleTypes, _this.vehicleTypes)&&const DeepCollectionEquality().equals(other.services, _this.services)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.ratingCount, _this.ratingCount) || other.ratingCount == _this.ratingCount)&&(identical(other.jobsCompleted, _this.jobsCompleted) || other.jobsCompleted == _this.jobsCompleted)&&(identical(other.fcmToken, _this.fcmToken) || other.fcmToken == _this.fcmToken)&&(identical(other.deletionRequestedAt, _this.deletionRequestedAt) || other.deletionRequestedAt == _this.deletionRequestedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Mechanic;
  return Object.hashAll([runtimeType,_this.name,_this.profilePhotoUrl,_this.mechanicType,_this.shopName,_this.shopAddress,_this.shopPhotoUrl,_this.baseArea,_this.experienceYears,const DeepCollectionEquality().hash(_this.toolkitPhotoUrls),_this.travelVehicle,_this.cityId,const DeepCollectionEquality().hash(_this.vehicleTypes),const DeepCollectionEquality().hash(_this.services),_this.status,_this.rating,_this.ratingCount,_this.jobsCompleted,_this.fcmToken,_this.deletionRequestedAt,_this.createdAt,_this.updatedAt,_this.schemaVersion]);
}

@override
String toString() {
  final _this = this as Mechanic;
  return 'Mechanic(name: ${_this.name}, profilePhotoUrl: ${_this.profilePhotoUrl}, mechanicType: ${_this.mechanicType}, shopName: ${_this.shopName}, shopAddress: ${_this.shopAddress}, shopPhotoUrl: ${_this.shopPhotoUrl}, baseArea: ${_this.baseArea}, experienceYears: ${_this.experienceYears}, toolkitPhotoUrls: ${_this.toolkitPhotoUrls}, travelVehicle: ${_this.travelVehicle}, cityId: ${_this.cityId}, vehicleTypes: ${_this.vehicleTypes}, services: ${_this.services}, status: ${_this.status}, rating: ${_this.rating}, ratingCount: ${_this.ratingCount}, jobsCompleted: ${_this.jobsCompleted}, fcmToken: ${_this.fcmToken}, deletionRequestedAt: ${_this.deletionRequestedAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, schemaVersion: ${_this.schemaVersion})';
}


}

/// @nodoc
abstract mixin class $MechanicCopyWith<$Res>  {
  factory $MechanicCopyWith(Mechanic value, $Res Function(Mechanic) _then) = _$MechanicCopyWithImpl;
@useResult
$Res call({
 String name, String profilePhotoUrl, MechanicType mechanicType, String? shopName, String? shopAddress, String? shopPhotoUrl, BaseArea? baseArea, int? experienceYears, List<String>? toolkitPhotoUrls, TravelVehicle? travelVehicle, CityId cityId, List<VehicleType> vehicleTypes, List<ProblemType> services, MechanicStatus status, double rating, int ratingCount, int jobsCompleted, String? fcmToken,@TimestampConverter() DateTime? deletionRequestedAt,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});


$BaseAreaCopyWith<$Res>? get baseArea;$TravelVehicleCopyWith<$Res>? get travelVehicle;

}
/// @nodoc
class _$MechanicCopyWithImpl<$Res>
    implements $MechanicCopyWith<$Res> {
  _$MechanicCopyWithImpl(this._self, this._then);

  final Mechanic _self;
  final $Res Function(Mechanic) _then;

/// Create a copy of Mechanic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? profilePhotoUrl = null,Object? mechanicType = null,Object? shopName = freezed,Object? shopAddress = freezed,Object? shopPhotoUrl = freezed,Object? baseArea = freezed,Object? experienceYears = freezed,Object? toolkitPhotoUrls = freezed,Object? travelVehicle = freezed,Object? cityId = null,Object? vehicleTypes = null,Object? services = null,Object? status = null,Object? rating = null,Object? ratingCount = null,Object? jobsCompleted = null,Object? fcmToken = freezed,Object? deletionRequestedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(Mechanic(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profilePhotoUrl: null == profilePhotoUrl ? _self.profilePhotoUrl : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
as String,mechanicType: null == mechanicType ? _self.mechanicType : mechanicType // ignore: cast_nullable_to_non_nullable
as MechanicType,shopName: freezed == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String?,shopAddress: freezed == shopAddress ? _self.shopAddress : shopAddress // ignore: cast_nullable_to_non_nullable
as String?,shopPhotoUrl: freezed == shopPhotoUrl ? _self.shopPhotoUrl : shopPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,baseArea: freezed == baseArea ? _self.baseArea : baseArea // ignore: cast_nullable_to_non_nullable
as BaseArea?,experienceYears: freezed == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int?,toolkitPhotoUrls: freezed == toolkitPhotoUrls ? _self.toolkitPhotoUrls : toolkitPhotoUrls // ignore: cast_nullable_to_non_nullable
as List<String>?,travelVehicle: freezed == travelVehicle ? _self.travelVehicle : travelVehicle // ignore: cast_nullable_to_non_nullable
as TravelVehicle?,cityId: null == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as CityId,vehicleTypes: null == vehicleTypes ? _self.vehicleTypes : vehicleTypes // ignore: cast_nullable_to_non_nullable
as List<VehicleType>,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<ProblemType>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MechanicStatus,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,jobsCompleted: null == jobsCompleted ? _self.jobsCompleted : jobsCompleted // ignore: cast_nullable_to_non_nullable
as int,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,deletionRequestedAt: freezed == deletionRequestedAt ? _self.deletionRequestedAt : deletionRequestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Mechanic
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BaseAreaCopyWith<$Res>? get baseArea {
    if (_self.baseArea == null) {
    return null;
  }

  return $BaseAreaCopyWith<$Res>(_self.baseArea!, (value) {
    return _then(_self.copyWith(baseArea: value));
  });
}/// Create a copy of Mechanic
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TravelVehicleCopyWith<$Res>? get travelVehicle {
    if (_self.travelVehicle == null) {
    return null;
  }

  return $TravelVehicleCopyWith<$Res>(_self.travelVehicle!, (value) {
    return _then(_self.copyWith(travelVehicle: value));
  });
}
}


/// Adds pattern-matching-related methods to [Mechanic].
extension MechanicPatterns on Mechanic {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Mechanic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Mechanic() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Mechanic value)  $default,){
final _that = this;
switch (_that) {
case _Mechanic():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Mechanic value)?  $default,){
final _that = this;
switch (_that) {
case _Mechanic() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String profilePhotoUrl,  MechanicType mechanicType,  String? shopName,  String? shopAddress,  String? shopPhotoUrl,  BaseArea? baseArea,  int? experienceYears,  List<String>? toolkitPhotoUrls,  TravelVehicle? travelVehicle,  CityId cityId,  List<VehicleType> vehicleTypes,  List<ProblemType> services,  MechanicStatus status,  double rating,  int ratingCount,  int jobsCompleted,  String? fcmToken, @TimestampConverter()  DateTime? deletionRequestedAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Mechanic() when $default != null:
return $default(_that.name,_that.profilePhotoUrl,_that.mechanicType,_that.shopName,_that.shopAddress,_that.shopPhotoUrl,_that.baseArea,_that.experienceYears,_that.toolkitPhotoUrls,_that.travelVehicle,_that.cityId,_that.vehicleTypes,_that.services,_that.status,_that.rating,_that.ratingCount,_that.jobsCompleted,_that.fcmToken,_that.deletionRequestedAt,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String profilePhotoUrl,  MechanicType mechanicType,  String? shopName,  String? shopAddress,  String? shopPhotoUrl,  BaseArea? baseArea,  int? experienceYears,  List<String>? toolkitPhotoUrls,  TravelVehicle? travelVehicle,  CityId cityId,  List<VehicleType> vehicleTypes,  List<ProblemType> services,  MechanicStatus status,  double rating,  int ratingCount,  int jobsCompleted,  String? fcmToken, @TimestampConverter()  DateTime? deletionRequestedAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _Mechanic():
return $default(_that.name,_that.profilePhotoUrl,_that.mechanicType,_that.shopName,_that.shopAddress,_that.shopPhotoUrl,_that.baseArea,_that.experienceYears,_that.toolkitPhotoUrls,_that.travelVehicle,_that.cityId,_that.vehicleTypes,_that.services,_that.status,_that.rating,_that.ratingCount,_that.jobsCompleted,_that.fcmToken,_that.deletionRequestedAt,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String profilePhotoUrl,  MechanicType mechanicType,  String? shopName,  String? shopAddress,  String? shopPhotoUrl,  BaseArea? baseArea,  int? experienceYears,  List<String>? toolkitPhotoUrls,  TravelVehicle? travelVehicle,  CityId cityId,  List<VehicleType> vehicleTypes,  List<ProblemType> services,  MechanicStatus status,  double rating,  int ratingCount,  int jobsCompleted,  String? fcmToken, @TimestampConverter()  DateTime? deletionRequestedAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _Mechanic() when $default != null:
return $default(_that.name,_that.profilePhotoUrl,_that.mechanicType,_that.shopName,_that.shopAddress,_that.shopPhotoUrl,_that.baseArea,_that.experienceYears,_that.toolkitPhotoUrls,_that.travelVehicle,_that.cityId,_that.vehicleTypes,_that.services,_that.status,_that.rating,_that.ratingCount,_that.jobsCompleted,_that.fcmToken,_that.deletionRequestedAt,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _Mechanic implements Mechanic {
  const _Mechanic({required this.name, required this.profilePhotoUrl, required this.mechanicType, this.shopName, this.shopAddress, this.shopPhotoUrl, this.baseArea, this.experienceYears,  List<String>? toolkitPhotoUrls, this.travelVehicle, required this.cityId, required  List<VehicleType> vehicleTypes, required  List<ProblemType> services, this.status = MechanicStatus.pending, this.rating = 0, this.ratingCount = 0, this.jobsCompleted = 0, this.fcmToken, @TimestampConverter() this.deletionRequestedAt, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, this.schemaVersion = kSchemaVersion}): _toolkitPhotoUrls = toolkitPhotoUrls,_vehicleTypes = vehicleTypes,_services = services;
  factory _Mechanic.fromJson(Map<String, dynamic> json) => _$MechanicFromJson(json);

@override final  String name;
@override final  String profilePhotoUrl;
@override final  MechanicType mechanicType;
@override final  String? shopName;
@override final  String? shopAddress;
@override final  String? shopPhotoUrl;
@override final  BaseArea? baseArea;
@override final  int? experienceYears;
 final  List<String>? _toolkitPhotoUrls;
@override List<String>? get toolkitPhotoUrls {
  final value = _toolkitPhotoUrls;
  if (value == null) return null;
  if (_toolkitPhotoUrls is EqualUnmodifiableListView) return _toolkitPhotoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  TravelVehicle? travelVehicle;
/// Chosen at registration, changed only by admin.
@override final  CityId cityId;
 final  List<VehicleType> _vehicleTypes;
@override List<VehicleType> get vehicleTypes {
  if (_vehicleTypes is EqualUnmodifiableListView) return _vehicleTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vehicleTypes);
}

 final  List<ProblemType> _services;
@override List<ProblemType> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}

/// 🔒
@override@JsonKey() final  MechanicStatus status;
/// 🔒
@override@JsonKey() final  double rating;
/// 🔒
@override@JsonKey() final  int ratingCount;
/// 🔒
@override@JsonKey() final  int jobsCompleted;
@override final  String? fcmToken;
/// 🔒 Set by `requestAccountDeletion`; kept on the reduced profile after the purge, so the KYC
/// retention job knows when the mechanic left (PLAN §8, §12.10). Null (and left out of
/// `toJson()`) for everyone else, since the rules reject it from clients.
@override@TimestampConverter() final  DateTime? deletionRequestedAt;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@JsonKey() final  int schemaVersion;

/// Create a copy of Mechanic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MechanicCopyWith<_Mechanic> get copyWith => __$MechanicCopyWithImpl<_Mechanic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MechanicToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Mechanic&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePhotoUrl, profilePhotoUrl) || other.profilePhotoUrl == profilePhotoUrl)&&(identical(other.mechanicType, mechanicType) || other.mechanicType == mechanicType)&&(identical(other.shopName, shopName) || other.shopName == shopName)&&(identical(other.shopAddress, shopAddress) || other.shopAddress == shopAddress)&&(identical(other.shopPhotoUrl, shopPhotoUrl) || other.shopPhotoUrl == shopPhotoUrl)&&(identical(other.baseArea, baseArea) || other.baseArea == baseArea)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&const DeepCollectionEquality().equals(other.toolkitPhotoUrls, _toolkitPhotoUrls)&&(identical(other.travelVehicle, travelVehicle) || other.travelVehicle == travelVehicle)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&const DeepCollectionEquality().equals(other.vehicleTypes, _vehicleTypes)&&const DeepCollectionEquality().equals(other.services, _services)&&(identical(other.status, status) || other.status == status)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.jobsCompleted, jobsCompleted) || other.jobsCompleted == jobsCompleted)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.deletionRequestedAt, deletionRequestedAt) || other.deletionRequestedAt == deletionRequestedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,name,profilePhotoUrl,mechanicType,shopName,shopAddress,shopPhotoUrl,baseArea,experienceYears,const DeepCollectionEquality().hash(_toolkitPhotoUrls),travelVehicle,cityId,const DeepCollectionEquality().hash(_vehicleTypes),const DeepCollectionEquality().hash(_services),status,rating,ratingCount,jobsCompleted,fcmToken,deletionRequestedAt,createdAt,updatedAt,schemaVersion]);
}

@override
String toString() {
    return 'Mechanic(name: $name, profilePhotoUrl: $profilePhotoUrl, mechanicType: $mechanicType, shopName: $shopName, shopAddress: $shopAddress, shopPhotoUrl: $shopPhotoUrl, baseArea: $baseArea, experienceYears: $experienceYears, toolkitPhotoUrls: $toolkitPhotoUrls, travelVehicle: $travelVehicle, cityId: $cityId, vehicleTypes: $vehicleTypes, services: $services, status: $status, rating: $rating, ratingCount: $ratingCount, jobsCompleted: $jobsCompleted, fcmToken: $fcmToken, deletionRequestedAt: $deletionRequestedAt, createdAt: $createdAt, updatedAt: $updatedAt, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$MechanicCopyWith<$Res> implements $MechanicCopyWith<$Res> {
  factory _$MechanicCopyWith(_Mechanic value, $Res Function(_Mechanic) _then) = __$MechanicCopyWithImpl;
@override @useResult
$Res call({
 String name, String profilePhotoUrl, MechanicType mechanicType, String? shopName, String? shopAddress, String? shopPhotoUrl, BaseArea? baseArea, int? experienceYears, List<String>? toolkitPhotoUrls, TravelVehicle? travelVehicle, CityId cityId, List<VehicleType> vehicleTypes, List<ProblemType> services, MechanicStatus status, double rating, int ratingCount, int jobsCompleted, String? fcmToken,@TimestampConverter() DateTime? deletionRequestedAt,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});


@override $BaseAreaCopyWith<$Res>? get baseArea;@override $TravelVehicleCopyWith<$Res>? get travelVehicle;

}
/// @nodoc
class __$MechanicCopyWithImpl<$Res>
    implements _$MechanicCopyWith<$Res> {
  __$MechanicCopyWithImpl(this._self, this._then);

  final _Mechanic _self;
  final $Res Function(_Mechanic) _then;

/// Create a copy of Mechanic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? profilePhotoUrl = null,Object? mechanicType = null,Object? shopName = freezed,Object? shopAddress = freezed,Object? shopPhotoUrl = freezed,Object? baseArea = freezed,Object? experienceYears = freezed,Object? toolkitPhotoUrls = freezed,Object? travelVehicle = freezed,Object? cityId = null,Object? vehicleTypes = null,Object? services = null,Object? status = null,Object? rating = null,Object? ratingCount = null,Object? jobsCompleted = null,Object? fcmToken = freezed,Object? deletionRequestedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(_Mechanic(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profilePhotoUrl: null == profilePhotoUrl ? _self.profilePhotoUrl : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
as String,mechanicType: null == mechanicType ? _self.mechanicType : mechanicType // ignore: cast_nullable_to_non_nullable
as MechanicType,shopName: freezed == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String?,shopAddress: freezed == shopAddress ? _self.shopAddress : shopAddress // ignore: cast_nullable_to_non_nullable
as String?,shopPhotoUrl: freezed == shopPhotoUrl ? _self.shopPhotoUrl : shopPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,baseArea: freezed == baseArea ? _self.baseArea : baseArea // ignore: cast_nullable_to_non_nullable
as BaseArea?,experienceYears: freezed == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int?,toolkitPhotoUrls: freezed == toolkitPhotoUrls ? _self._toolkitPhotoUrls : toolkitPhotoUrls // ignore: cast_nullable_to_non_nullable
as List<String>?,travelVehicle: freezed == travelVehicle ? _self.travelVehicle : travelVehicle // ignore: cast_nullable_to_non_nullable
as TravelVehicle?,cityId: null == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as CityId,vehicleTypes: null == vehicleTypes ? _self._vehicleTypes : vehicleTypes // ignore: cast_nullable_to_non_nullable
as List<VehicleType>,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<ProblemType>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MechanicStatus,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,jobsCompleted: null == jobsCompleted ? _self.jobsCompleted : jobsCompleted // ignore: cast_nullable_to_non_nullable
as int,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,deletionRequestedAt: freezed == deletionRequestedAt ? _self.deletionRequestedAt : deletionRequestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Mechanic
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BaseAreaCopyWith<$Res>? get baseArea {
    if (_self.baseArea == null) {
    return null;
  }

  return $BaseAreaCopyWith<$Res>(_self.baseArea!, (value) {
    return _then(_self.copyWith(baseArea: value));
  });
}/// Create a copy of Mechanic
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TravelVehicleCopyWith<$Res>? get travelVehicle {
    if (_self.travelVehicle == null) {
    return null;
  }

  return $TravelVehicleCopyWith<$Res>(_self.travelVehicle!, (value) {
    return _then(_self.copyWith(travelVehicle: value));
  });
}
}


/// @nodoc
mixin _$BaseArea {

 String get locality;@GeoPointConverter() GeoPoint get geopoint;
/// Create a copy of BaseArea
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BaseAreaCopyWith<BaseArea> get copyWith => _$BaseAreaCopyWithImpl<BaseArea>(this as BaseArea, _$identity);

  /// Serializes this BaseArea to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BaseArea;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BaseArea&&(identical(other.locality, _this.locality) || other.locality == _this.locality)&&(identical(other.geopoint, _this.geopoint) || other.geopoint == _this.geopoint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BaseArea;
  return Object.hash(runtimeType,_this.locality,_this.geopoint);
}

@override
String toString() {
  final _this = this as BaseArea;
  return 'BaseArea(locality: ${_this.locality}, geopoint: ${_this.geopoint})';
}


}

/// @nodoc
abstract mixin class $BaseAreaCopyWith<$Res>  {
  factory $BaseAreaCopyWith(BaseArea value, $Res Function(BaseArea) _then) = _$BaseAreaCopyWithImpl;
@useResult
$Res call({
 String locality,@GeoPointConverter() GeoPoint geopoint
});




}
/// @nodoc
class _$BaseAreaCopyWithImpl<$Res>
    implements $BaseAreaCopyWith<$Res> {
  _$BaseAreaCopyWithImpl(this._self, this._then);

  final BaseArea _self;
  final $Res Function(BaseArea) _then;

/// Create a copy of BaseArea
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locality = null,Object? geopoint = null,}) {
  return _then(BaseArea(
locality: null == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String,geopoint: null == geopoint ? _self.geopoint : geopoint // ignore: cast_nullable_to_non_nullable
as GeoPoint,
  ));
}

}


/// Adds pattern-matching-related methods to [BaseArea].
extension BaseAreaPatterns on BaseArea {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BaseArea value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BaseArea() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BaseArea value)  $default,){
final _that = this;
switch (_that) {
case _BaseArea():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BaseArea value)?  $default,){
final _that = this;
switch (_that) {
case _BaseArea() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String locality, @GeoPointConverter()  GeoPoint geopoint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BaseArea() when $default != null:
return $default(_that.locality,_that.geopoint);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String locality, @GeoPointConverter()  GeoPoint geopoint)  $default,) {final _that = this;
switch (_that) {
case _BaseArea():
return $default(_that.locality,_that.geopoint);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String locality, @GeoPointConverter()  GeoPoint geopoint)?  $default,) {final _that = this;
switch (_that) {
case _BaseArea() when $default != null:
return $default(_that.locality,_that.geopoint);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BaseArea implements BaseArea {
  const _BaseArea({required this.locality, @GeoPointConverter() required this.geopoint});
  factory _BaseArea.fromJson(Map<String, dynamic> json) => _$BaseAreaFromJson(json);

@override final  String locality;
@override@GeoPointConverter() final  GeoPoint geopoint;

/// Create a copy of BaseArea
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BaseAreaCopyWith<_BaseArea> get copyWith => __$BaseAreaCopyWithImpl<_BaseArea>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BaseAreaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BaseArea&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.geopoint, geopoint) || other.geopoint == geopoint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,locality,geopoint);
}

@override
String toString() {
    return 'BaseArea(locality: $locality, geopoint: $geopoint)';
}


}

/// @nodoc
abstract mixin class _$BaseAreaCopyWith<$Res> implements $BaseAreaCopyWith<$Res> {
  factory _$BaseAreaCopyWith(_BaseArea value, $Res Function(_BaseArea) _then) = __$BaseAreaCopyWithImpl;
@override @useResult
$Res call({
 String locality,@GeoPointConverter() GeoPoint geopoint
});




}
/// @nodoc
class __$BaseAreaCopyWithImpl<$Res>
    implements _$BaseAreaCopyWith<$Res> {
  __$BaseAreaCopyWithImpl(this._self, this._then);

  final _BaseArea _self;
  final $Res Function(_BaseArea) _then;

/// Create a copy of BaseArea
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locality = null,Object? geopoint = null,}) {
  return _then(_BaseArea(
locality: null == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String,geopoint: null == geopoint ? _self.geopoint : geopoint // ignore: cast_nullable_to_non_nullable
as GeoPoint,
  ));
}


}


/// @nodoc
mixin _$TravelVehicle {

 VehicleType get type; String get regNo;
/// Create a copy of TravelVehicle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TravelVehicleCopyWith<TravelVehicle> get copyWith => _$TravelVehicleCopyWithImpl<TravelVehicle>(this as TravelVehicle, _$identity);

  /// Serializes this TravelVehicle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TravelVehicle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TravelVehicle&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.regNo, _this.regNo) || other.regNo == _this.regNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TravelVehicle;
  return Object.hash(runtimeType,_this.type,_this.regNo);
}

@override
String toString() {
  final _this = this as TravelVehicle;
  return 'TravelVehicle(type: ${_this.type}, regNo: ${_this.regNo})';
}


}

/// @nodoc
abstract mixin class $TravelVehicleCopyWith<$Res>  {
  factory $TravelVehicleCopyWith(TravelVehicle value, $Res Function(TravelVehicle) _then) = _$TravelVehicleCopyWithImpl;
@useResult
$Res call({
 VehicleType type, String regNo
});




}
/// @nodoc
class _$TravelVehicleCopyWithImpl<$Res>
    implements $TravelVehicleCopyWith<$Res> {
  _$TravelVehicleCopyWithImpl(this._self, this._then);

  final TravelVehicle _self;
  final $Res Function(TravelVehicle) _then;

/// Create a copy of TravelVehicle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? regNo = null,}) {
  return _then(TravelVehicle(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as VehicleType,regNo: null == regNo ? _self.regNo : regNo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TravelVehicle].
extension TravelVehiclePatterns on TravelVehicle {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TravelVehicle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TravelVehicle() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TravelVehicle value)  $default,){
final _that = this;
switch (_that) {
case _TravelVehicle():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TravelVehicle value)?  $default,){
final _that = this;
switch (_that) {
case _TravelVehicle() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VehicleType type,  String regNo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TravelVehicle() when $default != null:
return $default(_that.type,_that.regNo);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VehicleType type,  String regNo)  $default,) {final _that = this;
switch (_that) {
case _TravelVehicle():
return $default(_that.type,_that.regNo);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VehicleType type,  String regNo)?  $default,) {final _that = this;
switch (_that) {
case _TravelVehicle() when $default != null:
return $default(_that.type,_that.regNo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TravelVehicle implements TravelVehicle {
  const _TravelVehicle({required this.type, required this.regNo});
  factory _TravelVehicle.fromJson(Map<String, dynamic> json) => _$TravelVehicleFromJson(json);

@override final  VehicleType type;
@override final  String regNo;

/// Create a copy of TravelVehicle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TravelVehicleCopyWith<_TravelVehicle> get copyWith => __$TravelVehicleCopyWithImpl<_TravelVehicle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TravelVehicleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TravelVehicle&&(identical(other.type, type) || other.type == type)&&(identical(other.regNo, regNo) || other.regNo == regNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,regNo);
}

@override
String toString() {
    return 'TravelVehicle(type: $type, regNo: $regNo)';
}


}

/// @nodoc
abstract mixin class _$TravelVehicleCopyWith<$Res> implements $TravelVehicleCopyWith<$Res> {
  factory _$TravelVehicleCopyWith(_TravelVehicle value, $Res Function(_TravelVehicle) _then) = __$TravelVehicleCopyWithImpl;
@override @useResult
$Res call({
 VehicleType type, String regNo
});




}
/// @nodoc
class __$TravelVehicleCopyWithImpl<$Res>
    implements _$TravelVehicleCopyWith<$Res> {
  __$TravelVehicleCopyWithImpl(this._self, this._then);

  final _TravelVehicle _self;
  final $Res Function(_TravelVehicle) _then;

/// Create a copy of TravelVehicle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? regNo = null,}) {
  return _then(_TravelVehicle(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as VehicleType,regNo: null == regNo ? _self.regNo : regNo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MechanicKyc {

/// 🔒 From Auth (E.164).
 String get phone;/// Storage path (`mechanics/{uid}/kyc/…`), never a URL.
 String get idProofPath; String get upiId; String get upiName;/// 🔒
 String? get kycCheckedBy;/// 🔒
@TimestampConverter() DateTime? get kycCheckedAt; String? get selfieWithIdPath; String? get addressProofPath; Contact? get referenceContact;/// 🔒 Set only by the admin callable after the call.
 VerificationCall? get verificationCall;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt; int get schemaVersion;
/// Create a copy of MechanicKyc
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MechanicKycCopyWith<MechanicKyc> get copyWith => _$MechanicKycCopyWithImpl<MechanicKyc>(this as MechanicKyc, _$identity);

  /// Serializes this MechanicKyc to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MechanicKyc;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MechanicKyc&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.idProofPath, _this.idProofPath) || other.idProofPath == _this.idProofPath)&&(identical(other.upiId, _this.upiId) || other.upiId == _this.upiId)&&(identical(other.upiName, _this.upiName) || other.upiName == _this.upiName)&&(identical(other.kycCheckedBy, _this.kycCheckedBy) || other.kycCheckedBy == _this.kycCheckedBy)&&(identical(other.kycCheckedAt, _this.kycCheckedAt) || other.kycCheckedAt == _this.kycCheckedAt)&&(identical(other.selfieWithIdPath, _this.selfieWithIdPath) || other.selfieWithIdPath == _this.selfieWithIdPath)&&(identical(other.addressProofPath, _this.addressProofPath) || other.addressProofPath == _this.addressProofPath)&&(identical(other.referenceContact, _this.referenceContact) || other.referenceContact == _this.referenceContact)&&(identical(other.verificationCall, _this.verificationCall) || other.verificationCall == _this.verificationCall)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MechanicKyc;
  return Object.hash(runtimeType,_this.phone,_this.idProofPath,_this.upiId,_this.upiName,_this.kycCheckedBy,_this.kycCheckedAt,_this.selfieWithIdPath,_this.addressProofPath,_this.referenceContact,_this.verificationCall,_this.createdAt,_this.updatedAt,_this.schemaVersion);
}

@override
String toString() {
  final _this = this as MechanicKyc;
  return 'MechanicKyc(phone: ${_this.phone}, idProofPath: ${_this.idProofPath}, upiId: ${_this.upiId}, upiName: ${_this.upiName}, kycCheckedBy: ${_this.kycCheckedBy}, kycCheckedAt: ${_this.kycCheckedAt}, selfieWithIdPath: ${_this.selfieWithIdPath}, addressProofPath: ${_this.addressProofPath}, referenceContact: ${_this.referenceContact}, verificationCall: ${_this.verificationCall}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, schemaVersion: ${_this.schemaVersion})';
}


}

/// @nodoc
abstract mixin class $MechanicKycCopyWith<$Res>  {
  factory $MechanicKycCopyWith(MechanicKyc value, $Res Function(MechanicKyc) _then) = _$MechanicKycCopyWithImpl;
@useResult
$Res call({
 String phone, String idProofPath, String upiId, String upiName, String? kycCheckedBy,@TimestampConverter() DateTime? kycCheckedAt, String? selfieWithIdPath, String? addressProofPath, Contact? referenceContact, VerificationCall? verificationCall,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});


$ContactCopyWith<$Res>? get referenceContact;$VerificationCallCopyWith<$Res>? get verificationCall;

}
/// @nodoc
class _$MechanicKycCopyWithImpl<$Res>
    implements $MechanicKycCopyWith<$Res> {
  _$MechanicKycCopyWithImpl(this._self, this._then);

  final MechanicKyc _self;
  final $Res Function(MechanicKyc) _then;

/// Create a copy of MechanicKyc
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phone = null,Object? idProofPath = null,Object? upiId = null,Object? upiName = null,Object? kycCheckedBy = freezed,Object? kycCheckedAt = freezed,Object? selfieWithIdPath = freezed,Object? addressProofPath = freezed,Object? referenceContact = freezed,Object? verificationCall = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(MechanicKyc(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,idProofPath: null == idProofPath ? _self.idProofPath : idProofPath // ignore: cast_nullable_to_non_nullable
as String,upiId: null == upiId ? _self.upiId : upiId // ignore: cast_nullable_to_non_nullable
as String,upiName: null == upiName ? _self.upiName : upiName // ignore: cast_nullable_to_non_nullable
as String,kycCheckedBy: freezed == kycCheckedBy ? _self.kycCheckedBy : kycCheckedBy // ignore: cast_nullable_to_non_nullable
as String?,kycCheckedAt: freezed == kycCheckedAt ? _self.kycCheckedAt : kycCheckedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,selfieWithIdPath: freezed == selfieWithIdPath ? _self.selfieWithIdPath : selfieWithIdPath // ignore: cast_nullable_to_non_nullable
as String?,addressProofPath: freezed == addressProofPath ? _self.addressProofPath : addressProofPath // ignore: cast_nullable_to_non_nullable
as String?,referenceContact: freezed == referenceContact ? _self.referenceContact : referenceContact // ignore: cast_nullable_to_non_nullable
as Contact?,verificationCall: freezed == verificationCall ? _self.verificationCall : verificationCall // ignore: cast_nullable_to_non_nullable
as VerificationCall?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of MechanicKyc
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactCopyWith<$Res>? get referenceContact {
    if (_self.referenceContact == null) {
    return null;
  }

  return $ContactCopyWith<$Res>(_self.referenceContact!, (value) {
    return _then(_self.copyWith(referenceContact: value));
  });
}/// Create a copy of MechanicKyc
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerificationCallCopyWith<$Res>? get verificationCall {
    if (_self.verificationCall == null) {
    return null;
  }

  return $VerificationCallCopyWith<$Res>(_self.verificationCall!, (value) {
    return _then(_self.copyWith(verificationCall: value));
  });
}
}


/// Adds pattern-matching-related methods to [MechanicKyc].
extension MechanicKycPatterns on MechanicKyc {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MechanicKyc value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MechanicKyc() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MechanicKyc value)  $default,){
final _that = this;
switch (_that) {
case _MechanicKyc():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MechanicKyc value)?  $default,){
final _that = this;
switch (_that) {
case _MechanicKyc() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String phone,  String idProofPath,  String upiId,  String upiName,  String? kycCheckedBy, @TimestampConverter()  DateTime? kycCheckedAt,  String? selfieWithIdPath,  String? addressProofPath,  Contact? referenceContact,  VerificationCall? verificationCall, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MechanicKyc() when $default != null:
return $default(_that.phone,_that.idProofPath,_that.upiId,_that.upiName,_that.kycCheckedBy,_that.kycCheckedAt,_that.selfieWithIdPath,_that.addressProofPath,_that.referenceContact,_that.verificationCall,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String phone,  String idProofPath,  String upiId,  String upiName,  String? kycCheckedBy, @TimestampConverter()  DateTime? kycCheckedAt,  String? selfieWithIdPath,  String? addressProofPath,  Contact? referenceContact,  VerificationCall? verificationCall, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _MechanicKyc():
return $default(_that.phone,_that.idProofPath,_that.upiId,_that.upiName,_that.kycCheckedBy,_that.kycCheckedAt,_that.selfieWithIdPath,_that.addressProofPath,_that.referenceContact,_that.verificationCall,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String phone,  String idProofPath,  String upiId,  String upiName,  String? kycCheckedBy, @TimestampConverter()  DateTime? kycCheckedAt,  String? selfieWithIdPath,  String? addressProofPath,  Contact? referenceContact,  VerificationCall? verificationCall, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _MechanicKyc() when $default != null:
return $default(_that.phone,_that.idProofPath,_that.upiId,_that.upiName,_that.kycCheckedBy,_that.kycCheckedAt,_that.selfieWithIdPath,_that.addressProofPath,_that.referenceContact,_that.verificationCall,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _MechanicKyc implements MechanicKyc {
  const _MechanicKyc({required this.phone, required this.idProofPath, required this.upiId, required this.upiName, this.kycCheckedBy, @TimestampConverter() this.kycCheckedAt, this.selfieWithIdPath, this.addressProofPath, this.referenceContact, this.verificationCall, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, this.schemaVersion = kSchemaVersion});
  factory _MechanicKyc.fromJson(Map<String, dynamic> json) => _$MechanicKycFromJson(json);

/// 🔒 From Auth (E.164).
@override final  String phone;
/// Storage path (`mechanics/{uid}/kyc/…`), never a URL.
@override final  String idProofPath;
@override final  String upiId;
@override final  String upiName;
/// 🔒
@override final  String? kycCheckedBy;
/// 🔒
@override@TimestampConverter() final  DateTime? kycCheckedAt;
@override final  String? selfieWithIdPath;
@override final  String? addressProofPath;
@override final  Contact? referenceContact;
/// 🔒 Set only by the admin callable after the call.
@override final  VerificationCall? verificationCall;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@JsonKey() final  int schemaVersion;

/// Create a copy of MechanicKyc
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MechanicKycCopyWith<_MechanicKyc> get copyWith => __$MechanicKycCopyWithImpl<_MechanicKyc>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MechanicKycToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MechanicKyc&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.idProofPath, idProofPath) || other.idProofPath == idProofPath)&&(identical(other.upiId, upiId) || other.upiId == upiId)&&(identical(other.upiName, upiName) || other.upiName == upiName)&&(identical(other.kycCheckedBy, kycCheckedBy) || other.kycCheckedBy == kycCheckedBy)&&(identical(other.kycCheckedAt, kycCheckedAt) || other.kycCheckedAt == kycCheckedAt)&&(identical(other.selfieWithIdPath, selfieWithIdPath) || other.selfieWithIdPath == selfieWithIdPath)&&(identical(other.addressProofPath, addressProofPath) || other.addressProofPath == addressProofPath)&&(identical(other.referenceContact, referenceContact) || other.referenceContact == referenceContact)&&(identical(other.verificationCall, verificationCall) || other.verificationCall == verificationCall)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,phone,idProofPath,upiId,upiName,kycCheckedBy,kycCheckedAt,selfieWithIdPath,addressProofPath,referenceContact,verificationCall,createdAt,updatedAt,schemaVersion);
}

@override
String toString() {
    return 'MechanicKyc(phone: $phone, idProofPath: $idProofPath, upiId: $upiId, upiName: $upiName, kycCheckedBy: $kycCheckedBy, kycCheckedAt: $kycCheckedAt, selfieWithIdPath: $selfieWithIdPath, addressProofPath: $addressProofPath, referenceContact: $referenceContact, verificationCall: $verificationCall, createdAt: $createdAt, updatedAt: $updatedAt, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$MechanicKycCopyWith<$Res> implements $MechanicKycCopyWith<$Res> {
  factory _$MechanicKycCopyWith(_MechanicKyc value, $Res Function(_MechanicKyc) _then) = __$MechanicKycCopyWithImpl;
@override @useResult
$Res call({
 String phone, String idProofPath, String upiId, String upiName, String? kycCheckedBy,@TimestampConverter() DateTime? kycCheckedAt, String? selfieWithIdPath, String? addressProofPath, Contact? referenceContact, VerificationCall? verificationCall,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});


@override $ContactCopyWith<$Res>? get referenceContact;@override $VerificationCallCopyWith<$Res>? get verificationCall;

}
/// @nodoc
class __$MechanicKycCopyWithImpl<$Res>
    implements _$MechanicKycCopyWith<$Res> {
  __$MechanicKycCopyWithImpl(this._self, this._then);

  final _MechanicKyc _self;
  final $Res Function(_MechanicKyc) _then;

/// Create a copy of MechanicKyc
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phone = null,Object? idProofPath = null,Object? upiId = null,Object? upiName = null,Object? kycCheckedBy = freezed,Object? kycCheckedAt = freezed,Object? selfieWithIdPath = freezed,Object? addressProofPath = freezed,Object? referenceContact = freezed,Object? verificationCall = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(_MechanicKyc(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,idProofPath: null == idProofPath ? _self.idProofPath : idProofPath // ignore: cast_nullable_to_non_nullable
as String,upiId: null == upiId ? _self.upiId : upiId // ignore: cast_nullable_to_non_nullable
as String,upiName: null == upiName ? _self.upiName : upiName // ignore: cast_nullable_to_non_nullable
as String,kycCheckedBy: freezed == kycCheckedBy ? _self.kycCheckedBy : kycCheckedBy // ignore: cast_nullable_to_non_nullable
as String?,kycCheckedAt: freezed == kycCheckedAt ? _self.kycCheckedAt : kycCheckedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,selfieWithIdPath: freezed == selfieWithIdPath ? _self.selfieWithIdPath : selfieWithIdPath // ignore: cast_nullable_to_non_nullable
as String?,addressProofPath: freezed == addressProofPath ? _self.addressProofPath : addressProofPath // ignore: cast_nullable_to_non_nullable
as String?,referenceContact: freezed == referenceContact ? _self.referenceContact : referenceContact // ignore: cast_nullable_to_non_nullable
as Contact?,verificationCall: freezed == verificationCall ? _self.verificationCall : verificationCall // ignore: cast_nullable_to_non_nullable
as VerificationCall?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of MechanicKyc
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactCopyWith<$Res>? get referenceContact {
    if (_self.referenceContact == null) {
    return null;
  }

  return $ContactCopyWith<$Res>(_self.referenceContact!, (value) {
    return _then(_self.copyWith(referenceContact: value));
  });
}/// Create a copy of MechanicKyc
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerificationCallCopyWith<$Res>? get verificationCall {
    if (_self.verificationCall == null) {
    return null;
  }

  return $VerificationCallCopyWith<$Res>(_self.verificationCall!, (value) {
    return _then(_self.copyWith(verificationCall: value));
  });
}
}


/// @nodoc
mixin _$VerificationCall {

 String get doneBy;@TimestampConverter() DateTime get at; String get notes;
/// Create a copy of VerificationCall
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationCallCopyWith<VerificationCall> get copyWith => _$VerificationCallCopyWithImpl<VerificationCall>(this as VerificationCall, _$identity);

  /// Serializes this VerificationCall to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VerificationCall;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationCall&&(identical(other.doneBy, _this.doneBy) || other.doneBy == _this.doneBy)&&(identical(other.at, _this.at) || other.at == _this.at)&&(identical(other.notes, _this.notes) || other.notes == _this.notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VerificationCall;
  return Object.hash(runtimeType,_this.doneBy,_this.at,_this.notes);
}

@override
String toString() {
  final _this = this as VerificationCall;
  return 'VerificationCall(doneBy: ${_this.doneBy}, at: ${_this.at}, notes: ${_this.notes})';
}


}

/// @nodoc
abstract mixin class $VerificationCallCopyWith<$Res>  {
  factory $VerificationCallCopyWith(VerificationCall value, $Res Function(VerificationCall) _then) = _$VerificationCallCopyWithImpl;
@useResult
$Res call({
 String doneBy,@TimestampConverter() DateTime at, String notes
});




}
/// @nodoc
class _$VerificationCallCopyWithImpl<$Res>
    implements $VerificationCallCopyWith<$Res> {
  _$VerificationCallCopyWithImpl(this._self, this._then);

  final VerificationCall _self;
  final $Res Function(VerificationCall) _then;

/// Create a copy of VerificationCall
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? doneBy = null,Object? at = null,Object? notes = null,}) {
  return _then(VerificationCall(
doneBy: null == doneBy ? _self.doneBy : doneBy // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationCall].
extension VerificationCallPatterns on VerificationCall {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerificationCall value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerificationCall() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerificationCall value)  $default,){
final _that = this;
switch (_that) {
case _VerificationCall():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerificationCall value)?  $default,){
final _that = this;
switch (_that) {
case _VerificationCall() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String doneBy, @TimestampConverter()  DateTime at,  String notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationCall() when $default != null:
return $default(_that.doneBy,_that.at,_that.notes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String doneBy, @TimestampConverter()  DateTime at,  String notes)  $default,) {final _that = this;
switch (_that) {
case _VerificationCall():
return $default(_that.doneBy,_that.at,_that.notes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String doneBy, @TimestampConverter()  DateTime at,  String notes)?  $default,) {final _that = this;
switch (_that) {
case _VerificationCall() when $default != null:
return $default(_that.doneBy,_that.at,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerificationCall implements VerificationCall {
  const _VerificationCall({required this.doneBy, @TimestampConverter() required this.at, required this.notes});
  factory _VerificationCall.fromJson(Map<String, dynamic> json) => _$VerificationCallFromJson(json);

@override final  String doneBy;
@override@TimestampConverter() final  DateTime at;
@override final  String notes;

/// Create a copy of VerificationCall
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationCallCopyWith<_VerificationCall> get copyWith => __$VerificationCallCopyWithImpl<_VerificationCall>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerificationCallToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationCall&&(identical(other.doneBy, doneBy) || other.doneBy == doneBy)&&(identical(other.at, at) || other.at == at)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,doneBy,at,notes);
}

@override
String toString() {
    return 'VerificationCall(doneBy: $doneBy, at: $at, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$VerificationCallCopyWith<$Res> implements $VerificationCallCopyWith<$Res> {
  factory _$VerificationCallCopyWith(_VerificationCall value, $Res Function(_VerificationCall) _then) = __$VerificationCallCopyWithImpl;
@override @useResult
$Res call({
 String doneBy,@TimestampConverter() DateTime at, String notes
});




}
/// @nodoc
class __$VerificationCallCopyWithImpl<$Res>
    implements _$VerificationCallCopyWith<$Res> {
  __$VerificationCallCopyWithImpl(this._self, this._then);

  final _VerificationCall _self;
  final $Res Function(_VerificationCall) _then;

/// Create a copy of VerificationCall
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? doneBy = null,Object? at = null,Object? notes = null,}) {
  return _then(_VerificationCall(
doneBy: null == doneBy ? _self.doneBy : doneBy // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Presence {

 bool get isOnline; GeoLocation get location;@TimestampConverter() DateTime? get updatedAt;/// 🔒 Copied from the profile by Functions.
 CityId get cityId;/// 🔒 Null when free.
 String? get activeBookingId;
/// Create a copy of Presence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresenceCopyWith<Presence> get copyWith => _$PresenceCopyWithImpl<Presence>(this as Presence, _$identity);

  /// Serializes this Presence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Presence;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Presence&&(identical(other.isOnline, _this.isOnline) || other.isOnline == _this.isOnline)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.cityId, _this.cityId) || other.cityId == _this.cityId)&&(identical(other.activeBookingId, _this.activeBookingId) || other.activeBookingId == _this.activeBookingId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Presence;
  return Object.hash(runtimeType,_this.isOnline,_this.location,_this.updatedAt,_this.cityId,_this.activeBookingId);
}

@override
String toString() {
  final _this = this as Presence;
  return 'Presence(isOnline: ${_this.isOnline}, location: ${_this.location}, updatedAt: ${_this.updatedAt}, cityId: ${_this.cityId}, activeBookingId: ${_this.activeBookingId})';
}


}

/// @nodoc
abstract mixin class $PresenceCopyWith<$Res>  {
  factory $PresenceCopyWith(Presence value, $Res Function(Presence) _then) = _$PresenceCopyWithImpl;
@useResult
$Res call({
 bool isOnline, GeoLocation location,@TimestampConverter() DateTime? updatedAt, CityId cityId, String? activeBookingId
});


$GeoLocationCopyWith<$Res> get location;

}
/// @nodoc
class _$PresenceCopyWithImpl<$Res>
    implements $PresenceCopyWith<$Res> {
  _$PresenceCopyWithImpl(this._self, this._then);

  final Presence _self;
  final $Res Function(Presence) _then;

/// Create a copy of Presence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isOnline = null,Object? location = null,Object? updatedAt = freezed,Object? cityId = null,Object? activeBookingId = freezed,}) {
  return _then(Presence(
isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoLocation,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cityId: null == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as CityId,activeBookingId: freezed == activeBookingId ? _self.activeBookingId : activeBookingId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Presence
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoLocationCopyWith<$Res> get location {
  
  return $GeoLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [Presence].
extension PresencePatterns on Presence {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Presence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Presence() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Presence value)  $default,){
final _that = this;
switch (_that) {
case _Presence():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Presence value)?  $default,){
final _that = this;
switch (_that) {
case _Presence() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isOnline,  GeoLocation location, @TimestampConverter()  DateTime? updatedAt,  CityId cityId,  String? activeBookingId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Presence() when $default != null:
return $default(_that.isOnline,_that.location,_that.updatedAt,_that.cityId,_that.activeBookingId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isOnline,  GeoLocation location, @TimestampConverter()  DateTime? updatedAt,  CityId cityId,  String? activeBookingId)  $default,) {final _that = this;
switch (_that) {
case _Presence():
return $default(_that.isOnline,_that.location,_that.updatedAt,_that.cityId,_that.activeBookingId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isOnline,  GeoLocation location, @TimestampConverter()  DateTime? updatedAt,  CityId cityId,  String? activeBookingId)?  $default,) {final _that = this;
switch (_that) {
case _Presence() when $default != null:
return $default(_that.isOnline,_that.location,_that.updatedAt,_that.cityId,_that.activeBookingId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Presence implements Presence {
  const _Presence({required this.isOnline, required this.location, @TimestampConverter() this.updatedAt, required this.cityId, this.activeBookingId});
  factory _Presence.fromJson(Map<String, dynamic> json) => _$PresenceFromJson(json);

@override final  bool isOnline;
@override final  GeoLocation location;
@override@TimestampConverter() final  DateTime? updatedAt;
/// 🔒 Copied from the profile by Functions.
@override final  CityId cityId;
/// 🔒 Null when free.
@override final  String? activeBookingId;

/// Create a copy of Presence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresenceCopyWith<_Presence> get copyWith => __$PresenceCopyWithImpl<_Presence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresenceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Presence&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.location, location) || other.location == location)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.activeBookingId, activeBookingId) || other.activeBookingId == activeBookingId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,isOnline,location,updatedAt,cityId,activeBookingId);
}

@override
String toString() {
    return 'Presence(isOnline: $isOnline, location: $location, updatedAt: $updatedAt, cityId: $cityId, activeBookingId: $activeBookingId)';
}


}

/// @nodoc
abstract mixin class _$PresenceCopyWith<$Res> implements $PresenceCopyWith<$Res> {
  factory _$PresenceCopyWith(_Presence value, $Res Function(_Presence) _then) = __$PresenceCopyWithImpl;
@override @useResult
$Res call({
 bool isOnline, GeoLocation location,@TimestampConverter() DateTime? updatedAt, CityId cityId, String? activeBookingId
});


@override $GeoLocationCopyWith<$Res> get location;

}
/// @nodoc
class __$PresenceCopyWithImpl<$Res>
    implements _$PresenceCopyWith<$Res> {
  __$PresenceCopyWithImpl(this._self, this._then);

  final _Presence _self;
  final $Res Function(_Presence) _then;

/// Create a copy of Presence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isOnline = null,Object? location = null,Object? updatedAt = freezed,Object? cityId = null,Object? activeBookingId = freezed,}) {
  return _then(_Presence(
isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoLocation,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cityId: null == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as CityId,activeBookingId: freezed == activeBookingId ? _self.activeBookingId : activeBookingId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Presence
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoLocationCopyWith<$Res> get location {
  
  return $GeoLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}

// dart format on
