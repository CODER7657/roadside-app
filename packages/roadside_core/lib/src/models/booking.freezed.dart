// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Offer {

 String get bookingId; String get mechanicId; VehicleType get vehicleType; ProblemType get problemType; String get regNo; double get distanceKm;/// Locality only.
 String get areaName; PriceRange get priceEstimate;@TimestampConverter() DateTime get expiresAt; OfferState get state;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt; int get schemaVersion;
/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferCopyWith<Offer> get copyWith => _$OfferCopyWithImpl<Offer>(this as Offer, _$identity);

  /// Serializes this Offer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Offer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Offer&&(identical(other.bookingId, _this.bookingId) || other.bookingId == _this.bookingId)&&(identical(other.mechanicId, _this.mechanicId) || other.mechanicId == _this.mechanicId)&&(identical(other.vehicleType, _this.vehicleType) || other.vehicleType == _this.vehicleType)&&(identical(other.problemType, _this.problemType) || other.problemType == _this.problemType)&&(identical(other.regNo, _this.regNo) || other.regNo == _this.regNo)&&(identical(other.distanceKm, _this.distanceKm) || other.distanceKm == _this.distanceKm)&&(identical(other.areaName, _this.areaName) || other.areaName == _this.areaName)&&(identical(other.priceEstimate, _this.priceEstimate) || other.priceEstimate == _this.priceEstimate)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Offer;
  return Object.hash(runtimeType,_this.bookingId,_this.mechanicId,_this.vehicleType,_this.problemType,_this.regNo,_this.distanceKm,_this.areaName,_this.priceEstimate,_this.expiresAt,_this.state,_this.createdAt,_this.updatedAt,_this.schemaVersion);
}

@override
String toString() {
  final _this = this as Offer;
  return 'Offer(bookingId: ${_this.bookingId}, mechanicId: ${_this.mechanicId}, vehicleType: ${_this.vehicleType}, problemType: ${_this.problemType}, regNo: ${_this.regNo}, distanceKm: ${_this.distanceKm}, areaName: ${_this.areaName}, priceEstimate: ${_this.priceEstimate}, expiresAt: ${_this.expiresAt}, state: ${_this.state}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, schemaVersion: ${_this.schemaVersion})';
}


}

/// @nodoc
abstract mixin class $OfferCopyWith<$Res>  {
  factory $OfferCopyWith(Offer value, $Res Function(Offer) _then) = _$OfferCopyWithImpl;
@useResult
$Res call({
 String bookingId, String mechanicId, VehicleType vehicleType, ProblemType problemType, String regNo, double distanceKm, String areaName, PriceRange priceEstimate,@TimestampConverter() DateTime expiresAt, OfferState state,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});


$PriceRangeCopyWith<$Res> get priceEstimate;

}
/// @nodoc
class _$OfferCopyWithImpl<$Res>
    implements $OfferCopyWith<$Res> {
  _$OfferCopyWithImpl(this._self, this._then);

  final Offer _self;
  final $Res Function(Offer) _then;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingId = null,Object? mechanicId = null,Object? vehicleType = null,Object? problemType = null,Object? regNo = null,Object? distanceKm = null,Object? areaName = null,Object? priceEstimate = null,Object? expiresAt = null,Object? state = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(Offer(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,mechanicId: null == mechanicId ? _self.mechanicId : mechanicId // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,problemType: null == problemType ? _self.problemType : problemType // ignore: cast_nullable_to_non_nullable
as ProblemType,regNo: null == regNo ? _self.regNo : regNo // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,areaName: null == areaName ? _self.areaName : areaName // ignore: cast_nullable_to_non_nullable
as String,priceEstimate: null == priceEstimate ? _self.priceEstimate : priceEstimate // ignore: cast_nullable_to_non_nullable
as PriceRange,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfferState,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceRangeCopyWith<$Res> get priceEstimate {
  
  return $PriceRangeCopyWith<$Res>(_self.priceEstimate, (value) {
    return _then(_self.copyWith(priceEstimate: value));
  });
}
}


/// Adds pattern-matching-related methods to [Offer].
extension OfferPatterns on Offer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Offer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Offer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Offer value)  $default,){
final _that = this;
switch (_that) {
case _Offer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Offer value)?  $default,){
final _that = this;
switch (_that) {
case _Offer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bookingId,  String mechanicId,  VehicleType vehicleType,  ProblemType problemType,  String regNo,  double distanceKm,  String areaName,  PriceRange priceEstimate, @TimestampConverter()  DateTime expiresAt,  OfferState state, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Offer() when $default != null:
return $default(_that.bookingId,_that.mechanicId,_that.vehicleType,_that.problemType,_that.regNo,_that.distanceKm,_that.areaName,_that.priceEstimate,_that.expiresAt,_that.state,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bookingId,  String mechanicId,  VehicleType vehicleType,  ProblemType problemType,  String regNo,  double distanceKm,  String areaName,  PriceRange priceEstimate, @TimestampConverter()  DateTime expiresAt,  OfferState state, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _Offer():
return $default(_that.bookingId,_that.mechanicId,_that.vehicleType,_that.problemType,_that.regNo,_that.distanceKm,_that.areaName,_that.priceEstimate,_that.expiresAt,_that.state,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bookingId,  String mechanicId,  VehicleType vehicleType,  ProblemType problemType,  String regNo,  double distanceKm,  String areaName,  PriceRange priceEstimate, @TimestampConverter()  DateTime expiresAt,  OfferState state, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _Offer() when $default != null:
return $default(_that.bookingId,_that.mechanicId,_that.vehicleType,_that.problemType,_that.regNo,_that.distanceKm,_that.areaName,_that.priceEstimate,_that.expiresAt,_that.state,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Offer implements Offer {
  const _Offer({required this.bookingId, required this.mechanicId, required this.vehicleType, required this.problemType, required this.regNo, required this.distanceKm, required this.areaName, required this.priceEstimate, @TimestampConverter() required this.expiresAt, required this.state, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, this.schemaVersion = kSchemaVersion});
  factory _Offer.fromJson(Map<String, dynamic> json) => _$OfferFromJson(json);

@override final  String bookingId;
@override final  String mechanicId;
@override final  VehicleType vehicleType;
@override final  ProblemType problemType;
@override final  String regNo;
@override final  double distanceKm;
/// Locality only.
@override final  String areaName;
@override final  PriceRange priceEstimate;
@override@TimestampConverter() final  DateTime expiresAt;
@override final  OfferState state;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@JsonKey() final  int schemaVersion;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferCopyWith<_Offer> get copyWith => __$OfferCopyWithImpl<_Offer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Offer&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.mechanicId, mechanicId) || other.mechanicId == mechanicId)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.problemType, problemType) || other.problemType == problemType)&&(identical(other.regNo, regNo) || other.regNo == regNo)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.areaName, areaName) || other.areaName == areaName)&&(identical(other.priceEstimate, priceEstimate) || other.priceEstimate == priceEstimate)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.state, state) || other.state == state)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,bookingId,mechanicId,vehicleType,problemType,regNo,distanceKm,areaName,priceEstimate,expiresAt,state,createdAt,updatedAt,schemaVersion);
}

@override
String toString() {
    return 'Offer(bookingId: $bookingId, mechanicId: $mechanicId, vehicleType: $vehicleType, problemType: $problemType, regNo: $regNo, distanceKm: $distanceKm, areaName: $areaName, priceEstimate: $priceEstimate, expiresAt: $expiresAt, state: $state, createdAt: $createdAt, updatedAt: $updatedAt, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$OfferCopyWith<$Res> implements $OfferCopyWith<$Res> {
  factory _$OfferCopyWith(_Offer value, $Res Function(_Offer) _then) = __$OfferCopyWithImpl;
@override @useResult
$Res call({
 String bookingId, String mechanicId, VehicleType vehicleType, ProblemType problemType, String regNo, double distanceKm, String areaName, PriceRange priceEstimate,@TimestampConverter() DateTime expiresAt, OfferState state,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});


@override $PriceRangeCopyWith<$Res> get priceEstimate;

}
/// @nodoc
class __$OfferCopyWithImpl<$Res>
    implements _$OfferCopyWith<$Res> {
  __$OfferCopyWithImpl(this._self, this._then);

  final _Offer _self;
  final $Res Function(_Offer) _then;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingId = null,Object? mechanicId = null,Object? vehicleType = null,Object? problemType = null,Object? regNo = null,Object? distanceKm = null,Object? areaName = null,Object? priceEstimate = null,Object? expiresAt = null,Object? state = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(_Offer(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,mechanicId: null == mechanicId ? _self.mechanicId : mechanicId // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,problemType: null == problemType ? _self.problemType : problemType // ignore: cast_nullable_to_non_nullable
as ProblemType,regNo: null == regNo ? _self.regNo : regNo // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,areaName: null == areaName ? _self.areaName : areaName // ignore: cast_nullable_to_non_nullable
as String,priceEstimate: null == priceEstimate ? _self.priceEstimate : priceEstimate // ignore: cast_nullable_to_non_nullable
as PriceRange,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfferState,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceRangeCopyWith<$Res> get priceEstimate {
  
  return $PriceRangeCopyWith<$Res>(_self.priceEstimate, (value) {
    return _then(_self.copyWith(priceEstimate: value));
  });
}
}


/// @nodoc
mixin _$MechanicCard {

 String get name; String get photoUrl; MechanicType get mechanicType;/// Workshop only.
 String? get shopName;/// Independent only.
 int? get experienceYears;/// Independent only.
 String? get travelVehicleRegNo; double get rating; int get jobsCompleted; String get phone; String get upiId; String get upiName;
/// Create a copy of MechanicCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MechanicCardCopyWith<MechanicCard> get copyWith => _$MechanicCardCopyWithImpl<MechanicCard>(this as MechanicCard, _$identity);

  /// Serializes this MechanicCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MechanicCard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MechanicCard&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl)&&(identical(other.mechanicType, _this.mechanicType) || other.mechanicType == _this.mechanicType)&&(identical(other.shopName, _this.shopName) || other.shopName == _this.shopName)&&(identical(other.experienceYears, _this.experienceYears) || other.experienceYears == _this.experienceYears)&&(identical(other.travelVehicleRegNo, _this.travelVehicleRegNo) || other.travelVehicleRegNo == _this.travelVehicleRegNo)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.jobsCompleted, _this.jobsCompleted) || other.jobsCompleted == _this.jobsCompleted)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.upiId, _this.upiId) || other.upiId == _this.upiId)&&(identical(other.upiName, _this.upiName) || other.upiName == _this.upiName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MechanicCard;
  return Object.hash(runtimeType,_this.name,_this.photoUrl,_this.mechanicType,_this.shopName,_this.experienceYears,_this.travelVehicleRegNo,_this.rating,_this.jobsCompleted,_this.phone,_this.upiId,_this.upiName);
}

@override
String toString() {
  final _this = this as MechanicCard;
  return 'MechanicCard(name: ${_this.name}, photoUrl: ${_this.photoUrl}, mechanicType: ${_this.mechanicType}, shopName: ${_this.shopName}, experienceYears: ${_this.experienceYears}, travelVehicleRegNo: ${_this.travelVehicleRegNo}, rating: ${_this.rating}, jobsCompleted: ${_this.jobsCompleted}, phone: ${_this.phone}, upiId: ${_this.upiId}, upiName: ${_this.upiName})';
}


}

/// @nodoc
abstract mixin class $MechanicCardCopyWith<$Res>  {
  factory $MechanicCardCopyWith(MechanicCard value, $Res Function(MechanicCard) _then) = _$MechanicCardCopyWithImpl;
@useResult
$Res call({
 String name, String photoUrl, MechanicType mechanicType, String? shopName, int? experienceYears, String? travelVehicleRegNo, double rating, int jobsCompleted, String phone, String upiId, String upiName
});




}
/// @nodoc
class _$MechanicCardCopyWithImpl<$Res>
    implements $MechanicCardCopyWith<$Res> {
  _$MechanicCardCopyWithImpl(this._self, this._then);

  final MechanicCard _self;
  final $Res Function(MechanicCard) _then;

/// Create a copy of MechanicCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? photoUrl = null,Object? mechanicType = null,Object? shopName = freezed,Object? experienceYears = freezed,Object? travelVehicleRegNo = freezed,Object? rating = null,Object? jobsCompleted = null,Object? phone = null,Object? upiId = null,Object? upiName = null,}) {
  return _then(MechanicCard(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,mechanicType: null == mechanicType ? _self.mechanicType : mechanicType // ignore: cast_nullable_to_non_nullable
as MechanicType,shopName: freezed == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String?,experienceYears: freezed == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int?,travelVehicleRegNo: freezed == travelVehicleRegNo ? _self.travelVehicleRegNo : travelVehicleRegNo // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,jobsCompleted: null == jobsCompleted ? _self.jobsCompleted : jobsCompleted // ignore: cast_nullable_to_non_nullable
as int,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,upiId: null == upiId ? _self.upiId : upiId // ignore: cast_nullable_to_non_nullable
as String,upiName: null == upiName ? _self.upiName : upiName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MechanicCard].
extension MechanicCardPatterns on MechanicCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MechanicCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MechanicCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MechanicCard value)  $default,){
final _that = this;
switch (_that) {
case _MechanicCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MechanicCard value)?  $default,){
final _that = this;
switch (_that) {
case _MechanicCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String photoUrl,  MechanicType mechanicType,  String? shopName,  int? experienceYears,  String? travelVehicleRegNo,  double rating,  int jobsCompleted,  String phone,  String upiId,  String upiName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MechanicCard() when $default != null:
return $default(_that.name,_that.photoUrl,_that.mechanicType,_that.shopName,_that.experienceYears,_that.travelVehicleRegNo,_that.rating,_that.jobsCompleted,_that.phone,_that.upiId,_that.upiName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String photoUrl,  MechanicType mechanicType,  String? shopName,  int? experienceYears,  String? travelVehicleRegNo,  double rating,  int jobsCompleted,  String phone,  String upiId,  String upiName)  $default,) {final _that = this;
switch (_that) {
case _MechanicCard():
return $default(_that.name,_that.photoUrl,_that.mechanicType,_that.shopName,_that.experienceYears,_that.travelVehicleRegNo,_that.rating,_that.jobsCompleted,_that.phone,_that.upiId,_that.upiName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String photoUrl,  MechanicType mechanicType,  String? shopName,  int? experienceYears,  String? travelVehicleRegNo,  double rating,  int jobsCompleted,  String phone,  String upiId,  String upiName)?  $default,) {final _that = this;
switch (_that) {
case _MechanicCard() when $default != null:
return $default(_that.name,_that.photoUrl,_that.mechanicType,_that.shopName,_that.experienceYears,_that.travelVehicleRegNo,_that.rating,_that.jobsCompleted,_that.phone,_that.upiId,_that.upiName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MechanicCard implements MechanicCard {
  const _MechanicCard({required this.name, required this.photoUrl, required this.mechanicType, this.shopName, this.experienceYears, this.travelVehicleRegNo, required this.rating, required this.jobsCompleted, required this.phone, required this.upiId, required this.upiName});
  factory _MechanicCard.fromJson(Map<String, dynamic> json) => _$MechanicCardFromJson(json);

@override final  String name;
@override final  String photoUrl;
@override final  MechanicType mechanicType;
/// Workshop only.
@override final  String? shopName;
/// Independent only.
@override final  int? experienceYears;
/// Independent only.
@override final  String? travelVehicleRegNo;
@override final  double rating;
@override final  int jobsCompleted;
@override final  String phone;
@override final  String upiId;
@override final  String upiName;

/// Create a copy of MechanicCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MechanicCardCopyWith<_MechanicCard> get copyWith => __$MechanicCardCopyWithImpl<_MechanicCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MechanicCardToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MechanicCard&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.mechanicType, mechanicType) || other.mechanicType == mechanicType)&&(identical(other.shopName, shopName) || other.shopName == shopName)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&(identical(other.travelVehicleRegNo, travelVehicleRegNo) || other.travelVehicleRegNo == travelVehicleRegNo)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.jobsCompleted, jobsCompleted) || other.jobsCompleted == jobsCompleted)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.upiId, upiId) || other.upiId == upiId)&&(identical(other.upiName, upiName) || other.upiName == upiName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,photoUrl,mechanicType,shopName,experienceYears,travelVehicleRegNo,rating,jobsCompleted,phone,upiId,upiName);
}

@override
String toString() {
    return 'MechanicCard(name: $name, photoUrl: $photoUrl, mechanicType: $mechanicType, shopName: $shopName, experienceYears: $experienceYears, travelVehicleRegNo: $travelVehicleRegNo, rating: $rating, jobsCompleted: $jobsCompleted, phone: $phone, upiId: $upiId, upiName: $upiName)';
}


}

/// @nodoc
abstract mixin class _$MechanicCardCopyWith<$Res> implements $MechanicCardCopyWith<$Res> {
  factory _$MechanicCardCopyWith(_MechanicCard value, $Res Function(_MechanicCard) _then) = __$MechanicCardCopyWithImpl;
@override @useResult
$Res call({
 String name, String photoUrl, MechanicType mechanicType, String? shopName, int? experienceYears, String? travelVehicleRegNo, double rating, int jobsCompleted, String phone, String upiId, String upiName
});




}
/// @nodoc
class __$MechanicCardCopyWithImpl<$Res>
    implements _$MechanicCardCopyWith<$Res> {
  __$MechanicCardCopyWithImpl(this._self, this._then);

  final _MechanicCard _self;
  final $Res Function(_MechanicCard) _then;

/// Create a copy of MechanicCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? photoUrl = null,Object? mechanicType = null,Object? shopName = freezed,Object? experienceYears = freezed,Object? travelVehicleRegNo = freezed,Object? rating = null,Object? jobsCompleted = null,Object? phone = null,Object? upiId = null,Object? upiName = null,}) {
  return _then(_MechanicCard(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,mechanicType: null == mechanicType ? _self.mechanicType : mechanicType // ignore: cast_nullable_to_non_nullable
as MechanicType,shopName: freezed == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String?,experienceYears: freezed == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int?,travelVehicleRegNo: freezed == travelVehicleRegNo ? _self.travelVehicleRegNo : travelVehicleRegNo // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,jobsCompleted: null == jobsCompleted ? _self.jobsCompleted : jobsCompleted // ignore: cast_nullable_to_non_nullable
as int,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,upiId: null == upiId ? _self.upiId : upiId // ignore: cast_nullable_to_non_nullable
as String,upiName: null == upiName ? _self.upiName : upiName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$StatusHistoryEntry {

 BookingStatus get status;@TimestampConverter() DateTime get at;/// The uid that made the change, or `system`.
 String get by;
/// Create a copy of StatusHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusHistoryEntryCopyWith<StatusHistoryEntry> get copyWith => _$StatusHistoryEntryCopyWithImpl<StatusHistoryEntry>(this as StatusHistoryEntry, _$identity);

  /// Serializes this StatusHistoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StatusHistoryEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusHistoryEntry&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.at, _this.at) || other.at == _this.at)&&(identical(other.by, _this.by) || other.by == _this.by));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StatusHistoryEntry;
  return Object.hash(runtimeType,_this.status,_this.at,_this.by);
}

@override
String toString() {
  final _this = this as StatusHistoryEntry;
  return 'StatusHistoryEntry(status: ${_this.status}, at: ${_this.at}, by: ${_this.by})';
}


}

/// @nodoc
abstract mixin class $StatusHistoryEntryCopyWith<$Res>  {
  factory $StatusHistoryEntryCopyWith(StatusHistoryEntry value, $Res Function(StatusHistoryEntry) _then) = _$StatusHistoryEntryCopyWithImpl;
@useResult
$Res call({
 BookingStatus status,@TimestampConverter() DateTime at, String by
});




}
/// @nodoc
class _$StatusHistoryEntryCopyWithImpl<$Res>
    implements $StatusHistoryEntryCopyWith<$Res> {
  _$StatusHistoryEntryCopyWithImpl(this._self, this._then);

  final StatusHistoryEntry _self;
  final $Res Function(StatusHistoryEntry) _then;

/// Create a copy of StatusHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? at = null,Object? by = null,}) {
  return _then(StatusHistoryEntry(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,by: null == by ? _self.by : by // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusHistoryEntry].
extension StatusHistoryEntryPatterns on StatusHistoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusHistoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusHistoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _StatusHistoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusHistoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _StatusHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BookingStatus status, @TimestampConverter()  DateTime at,  String by)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusHistoryEntry() when $default != null:
return $default(_that.status,_that.at,_that.by);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BookingStatus status, @TimestampConverter()  DateTime at,  String by)  $default,) {final _that = this;
switch (_that) {
case _StatusHistoryEntry():
return $default(_that.status,_that.at,_that.by);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BookingStatus status, @TimestampConverter()  DateTime at,  String by)?  $default,) {final _that = this;
switch (_that) {
case _StatusHistoryEntry() when $default != null:
return $default(_that.status,_that.at,_that.by);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatusHistoryEntry implements StatusHistoryEntry {
  const _StatusHistoryEntry({required this.status, @TimestampConverter() required this.at, required this.by});
  factory _StatusHistoryEntry.fromJson(Map<String, dynamic> json) => _$StatusHistoryEntryFromJson(json);

@override final  BookingStatus status;
@override@TimestampConverter() final  DateTime at;
/// The uid that made the change, or `system`.
@override final  String by;

/// Create a copy of StatusHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusHistoryEntryCopyWith<_StatusHistoryEntry> get copyWith => __$StatusHistoryEntryCopyWithImpl<_StatusHistoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatusHistoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusHistoryEntry&&(identical(other.status, status) || other.status == status)&&(identical(other.at, at) || other.at == at)&&(identical(other.by, by) || other.by == by));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,at,by);
}

@override
String toString() {
    return 'StatusHistoryEntry(status: $status, at: $at, by: $by)';
}


}

/// @nodoc
abstract mixin class _$StatusHistoryEntryCopyWith<$Res> implements $StatusHistoryEntryCopyWith<$Res> {
  factory _$StatusHistoryEntryCopyWith(_StatusHistoryEntry value, $Res Function(_StatusHistoryEntry) _then) = __$StatusHistoryEntryCopyWithImpl;
@override @useResult
$Res call({
 BookingStatus status,@TimestampConverter() DateTime at, String by
});




}
/// @nodoc
class __$StatusHistoryEntryCopyWithImpl<$Res>
    implements _$StatusHistoryEntryCopyWith<$Res> {
  __$StatusHistoryEntryCopyWithImpl(this._self, this._then);

  final _StatusHistoryEntry _self;
  final $Res Function(_StatusHistoryEntry) _then;

/// Create a copy of StatusHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? at = null,Object? by = null,}) {
  return _then(_StatusHistoryEntry(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,by: null == by ? _self.by : by // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BookingVehicle {

 VehicleType get type; String get brand; String get model; String get regNo;
/// Create a copy of BookingVehicle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingVehicleCopyWith<BookingVehicle> get copyWith => _$BookingVehicleCopyWithImpl<BookingVehicle>(this as BookingVehicle, _$identity);

  /// Serializes this BookingVehicle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BookingVehicle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingVehicle&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.regNo, _this.regNo) || other.regNo == _this.regNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BookingVehicle;
  return Object.hash(runtimeType,_this.type,_this.brand,_this.model,_this.regNo);
}

@override
String toString() {
  final _this = this as BookingVehicle;
  return 'BookingVehicle(type: ${_this.type}, brand: ${_this.brand}, model: ${_this.model}, regNo: ${_this.regNo})';
}


}

/// @nodoc
abstract mixin class $BookingVehicleCopyWith<$Res>  {
  factory $BookingVehicleCopyWith(BookingVehicle value, $Res Function(BookingVehicle) _then) = _$BookingVehicleCopyWithImpl;
@useResult
$Res call({
 VehicleType type, String brand, String model, String regNo
});




}
/// @nodoc
class _$BookingVehicleCopyWithImpl<$Res>
    implements $BookingVehicleCopyWith<$Res> {
  _$BookingVehicleCopyWithImpl(this._self, this._then);

  final BookingVehicle _self;
  final $Res Function(BookingVehicle) _then;

/// Create a copy of BookingVehicle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? brand = null,Object? model = null,Object? regNo = null,}) {
  return _then(BookingVehicle(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as VehicleType,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,regNo: null == regNo ? _self.regNo : regNo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingVehicle].
extension BookingVehiclePatterns on BookingVehicle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingVehicle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingVehicle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingVehicle value)  $default,){
final _that = this;
switch (_that) {
case _BookingVehicle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingVehicle value)?  $default,){
final _that = this;
switch (_that) {
case _BookingVehicle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VehicleType type,  String brand,  String model,  String regNo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingVehicle() when $default != null:
return $default(_that.type,_that.brand,_that.model,_that.regNo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VehicleType type,  String brand,  String model,  String regNo)  $default,) {final _that = this;
switch (_that) {
case _BookingVehicle():
return $default(_that.type,_that.brand,_that.model,_that.regNo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VehicleType type,  String brand,  String model,  String regNo)?  $default,) {final _that = this;
switch (_that) {
case _BookingVehicle() when $default != null:
return $default(_that.type,_that.brand,_that.model,_that.regNo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingVehicle implements BookingVehicle {
  const _BookingVehicle({required this.type, required this.brand, required this.model, required this.regNo});
  factory _BookingVehicle.fromJson(Map<String, dynamic> json) => _$BookingVehicleFromJson(json);

@override final  VehicleType type;
@override final  String brand;
@override final  String model;
@override final  String regNo;

/// Create a copy of BookingVehicle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingVehicleCopyWith<_BookingVehicle> get copyWith => __$BookingVehicleCopyWithImpl<_BookingVehicle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingVehicleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingVehicle&&(identical(other.type, type) || other.type == type)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.regNo, regNo) || other.regNo == regNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,brand,model,regNo);
}

@override
String toString() {
    return 'BookingVehicle(type: $type, brand: $brand, model: $model, regNo: $regNo)';
}


}

/// @nodoc
abstract mixin class _$BookingVehicleCopyWith<$Res> implements $BookingVehicleCopyWith<$Res> {
  factory _$BookingVehicleCopyWith(_BookingVehicle value, $Res Function(_BookingVehicle) _then) = __$BookingVehicleCopyWithImpl;
@override @useResult
$Res call({
 VehicleType type, String brand, String model, String regNo
});




}
/// @nodoc
class __$BookingVehicleCopyWithImpl<$Res>
    implements _$BookingVehicleCopyWith<$Res> {
  __$BookingVehicleCopyWithImpl(this._self, this._then);

  final _BookingVehicle _self;
  final $Res Function(_BookingVehicle) _then;

/// Create a copy of BookingVehicle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? brand = null,Object? model = null,Object? regNo = null,}) {
  return _then(_BookingVehicle(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as VehicleType,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,regNo: null == regNo ? _self.regNo : regNo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Pickup {

@GeoPointConverter() GeoPoint get geopoint; String get geohash; String get address; String get landmark; String get plusCode; double get accuracyMeters;
/// Create a copy of Pickup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PickupCopyWith<Pickup> get copyWith => _$PickupCopyWithImpl<Pickup>(this as Pickup, _$identity);

  /// Serializes this Pickup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Pickup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pickup&&(identical(other.geopoint, _this.geopoint) || other.geopoint == _this.geopoint)&&(identical(other.geohash, _this.geohash) || other.geohash == _this.geohash)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.landmark, _this.landmark) || other.landmark == _this.landmark)&&(identical(other.plusCode, _this.plusCode) || other.plusCode == _this.plusCode)&&(identical(other.accuracyMeters, _this.accuracyMeters) || other.accuracyMeters == _this.accuracyMeters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Pickup;
  return Object.hash(runtimeType,_this.geopoint,_this.geohash,_this.address,_this.landmark,_this.plusCode,_this.accuracyMeters);
}

@override
String toString() {
  final _this = this as Pickup;
  return 'Pickup(geopoint: ${_this.geopoint}, geohash: ${_this.geohash}, address: ${_this.address}, landmark: ${_this.landmark}, plusCode: ${_this.plusCode}, accuracyMeters: ${_this.accuracyMeters})';
}


}

/// @nodoc
abstract mixin class $PickupCopyWith<$Res>  {
  factory $PickupCopyWith(Pickup value, $Res Function(Pickup) _then) = _$PickupCopyWithImpl;
@useResult
$Res call({
@GeoPointConverter() GeoPoint geopoint, String geohash, String address, String landmark, String plusCode, double accuracyMeters
});




}
/// @nodoc
class _$PickupCopyWithImpl<$Res>
    implements $PickupCopyWith<$Res> {
  _$PickupCopyWithImpl(this._self, this._then);

  final Pickup _self;
  final $Res Function(Pickup) _then;

/// Create a copy of Pickup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? geopoint = null,Object? geohash = null,Object? address = null,Object? landmark = null,Object? plusCode = null,Object? accuracyMeters = null,}) {
  return _then(Pickup(
geopoint: null == geopoint ? _self.geopoint : geopoint // ignore: cast_nullable_to_non_nullable
as GeoPoint,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,landmark: null == landmark ? _self.landmark : landmark // ignore: cast_nullable_to_non_nullable
as String,plusCode: null == plusCode ? _self.plusCode : plusCode // ignore: cast_nullable_to_non_nullable
as String,accuracyMeters: null == accuracyMeters ? _self.accuracyMeters : accuracyMeters // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Pickup].
extension PickupPatterns on Pickup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pickup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pickup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pickup value)  $default,){
final _that = this;
switch (_that) {
case _Pickup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pickup value)?  $default,){
final _that = this;
switch (_that) {
case _Pickup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@GeoPointConverter()  GeoPoint geopoint,  String geohash,  String address,  String landmark,  String plusCode,  double accuracyMeters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pickup() when $default != null:
return $default(_that.geopoint,_that.geohash,_that.address,_that.landmark,_that.plusCode,_that.accuracyMeters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@GeoPointConverter()  GeoPoint geopoint,  String geohash,  String address,  String landmark,  String plusCode,  double accuracyMeters)  $default,) {final _that = this;
switch (_that) {
case _Pickup():
return $default(_that.geopoint,_that.geohash,_that.address,_that.landmark,_that.plusCode,_that.accuracyMeters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@GeoPointConverter()  GeoPoint geopoint,  String geohash,  String address,  String landmark,  String plusCode,  double accuracyMeters)?  $default,) {final _that = this;
switch (_that) {
case _Pickup() when $default != null:
return $default(_that.geopoint,_that.geohash,_that.address,_that.landmark,_that.plusCode,_that.accuracyMeters);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Pickup implements Pickup {
  const _Pickup({@GeoPointConverter() required this.geopoint, required this.geohash, required this.address, this.landmark = '', this.plusCode = '', required this.accuracyMeters});
  factory _Pickup.fromJson(Map<String, dynamic> json) => _$PickupFromJson(json);

@override@GeoPointConverter() final  GeoPoint geopoint;
@override final  String geohash;
@override final  String address;
@override@JsonKey() final  String landmark;
@override@JsonKey() final  String plusCode;
@override final  double accuracyMeters;

/// Create a copy of Pickup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PickupCopyWith<_Pickup> get copyWith => __$PickupCopyWithImpl<_Pickup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PickupToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pickup&&(identical(other.geopoint, geopoint) || other.geopoint == geopoint)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&(identical(other.address, address) || other.address == address)&&(identical(other.landmark, landmark) || other.landmark == landmark)&&(identical(other.plusCode, plusCode) || other.plusCode == plusCode)&&(identical(other.accuracyMeters, accuracyMeters) || other.accuracyMeters == accuracyMeters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,geopoint,geohash,address,landmark,plusCode,accuracyMeters);
}

@override
String toString() {
    return 'Pickup(geopoint: $geopoint, geohash: $geohash, address: $address, landmark: $landmark, plusCode: $plusCode, accuracyMeters: $accuracyMeters)';
}


}

/// @nodoc
abstract mixin class _$PickupCopyWith<$Res> implements $PickupCopyWith<$Res> {
  factory _$PickupCopyWith(_Pickup value, $Res Function(_Pickup) _then) = __$PickupCopyWithImpl;
@override @useResult
$Res call({
@GeoPointConverter() GeoPoint geopoint, String geohash, String address, String landmark, String plusCode, double accuracyMeters
});




}
/// @nodoc
class __$PickupCopyWithImpl<$Res>
    implements _$PickupCopyWith<$Res> {
  __$PickupCopyWithImpl(this._self, this._then);

  final _Pickup _self;
  final $Res Function(_Pickup) _then;

/// Create a copy of Pickup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? geopoint = null,Object? geohash = null,Object? address = null,Object? landmark = null,Object? plusCode = null,Object? accuracyMeters = null,}) {
  return _then(_Pickup(
geopoint: null == geopoint ? _self.geopoint : geopoint // ignore: cast_nullable_to_non_nullable
as GeoPoint,geohash: null == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,landmark: null == landmark ? _self.landmark : landmark // ignore: cast_nullable_to_non_nullable
as String,plusCode: null == plusCode ? _self.plusCode : plusCode // ignore: cast_nullable_to_non_nullable
as String,accuracyMeters: null == accuracyMeters ? _self.accuracyMeters : accuracyMeters // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$BookingTimestamps {

@TimestampConverter() DateTime? get requested;@TimestampConverter() DateTime? get accepted;@TimestampConverter() DateTime? get arriving;@TimestampConverter() DateTime? get arrived;@TimestampConverter() DateTime? get started;@TimestampConverter() DateTime? get completed;@TimestampConverter() DateTime? get cancelled;
/// Create a copy of BookingTimestamps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingTimestampsCopyWith<BookingTimestamps> get copyWith => _$BookingTimestampsCopyWithImpl<BookingTimestamps>(this as BookingTimestamps, _$identity);

  /// Serializes this BookingTimestamps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BookingTimestamps;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingTimestamps&&(identical(other.requested, _this.requested) || other.requested == _this.requested)&&(identical(other.accepted, _this.accepted) || other.accepted == _this.accepted)&&(identical(other.arriving, _this.arriving) || other.arriving == _this.arriving)&&(identical(other.arrived, _this.arrived) || other.arrived == _this.arrived)&&(identical(other.started, _this.started) || other.started == _this.started)&&(identical(other.completed, _this.completed) || other.completed == _this.completed)&&(identical(other.cancelled, _this.cancelled) || other.cancelled == _this.cancelled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BookingTimestamps;
  return Object.hash(runtimeType,_this.requested,_this.accepted,_this.arriving,_this.arrived,_this.started,_this.completed,_this.cancelled);
}

@override
String toString() {
  final _this = this as BookingTimestamps;
  return 'BookingTimestamps(requested: ${_this.requested}, accepted: ${_this.accepted}, arriving: ${_this.arriving}, arrived: ${_this.arrived}, started: ${_this.started}, completed: ${_this.completed}, cancelled: ${_this.cancelled})';
}


}

/// @nodoc
abstract mixin class $BookingTimestampsCopyWith<$Res>  {
  factory $BookingTimestampsCopyWith(BookingTimestamps value, $Res Function(BookingTimestamps) _then) = _$BookingTimestampsCopyWithImpl;
@useResult
$Res call({
@TimestampConverter() DateTime? requested,@TimestampConverter() DateTime? accepted,@TimestampConverter() DateTime? arriving,@TimestampConverter() DateTime? arrived,@TimestampConverter() DateTime? started,@TimestampConverter() DateTime? completed,@TimestampConverter() DateTime? cancelled
});




}
/// @nodoc
class _$BookingTimestampsCopyWithImpl<$Res>
    implements $BookingTimestampsCopyWith<$Res> {
  _$BookingTimestampsCopyWithImpl(this._self, this._then);

  final BookingTimestamps _self;
  final $Res Function(BookingTimestamps) _then;

/// Create a copy of BookingTimestamps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requested = freezed,Object? accepted = freezed,Object? arriving = freezed,Object? arrived = freezed,Object? started = freezed,Object? completed = freezed,Object? cancelled = freezed,}) {
  return _then(BookingTimestamps(
requested: freezed == requested ? _self.requested : requested // ignore: cast_nullable_to_non_nullable
as DateTime?,accepted: freezed == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as DateTime?,arriving: freezed == arriving ? _self.arriving : arriving // ignore: cast_nullable_to_non_nullable
as DateTime?,arrived: freezed == arrived ? _self.arrived : arrived // ignore: cast_nullable_to_non_nullable
as DateTime?,started: freezed == started ? _self.started : started // ignore: cast_nullable_to_non_nullable
as DateTime?,completed: freezed == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelled: freezed == cancelled ? _self.cancelled : cancelled // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingTimestamps].
extension BookingTimestampsPatterns on BookingTimestamps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingTimestamps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingTimestamps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingTimestamps value)  $default,){
final _that = this;
switch (_that) {
case _BookingTimestamps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingTimestamps value)?  $default,){
final _that = this;
switch (_that) {
case _BookingTimestamps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@TimestampConverter()  DateTime? requested, @TimestampConverter()  DateTime? accepted, @TimestampConverter()  DateTime? arriving, @TimestampConverter()  DateTime? arrived, @TimestampConverter()  DateTime? started, @TimestampConverter()  DateTime? completed, @TimestampConverter()  DateTime? cancelled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingTimestamps() when $default != null:
return $default(_that.requested,_that.accepted,_that.arriving,_that.arrived,_that.started,_that.completed,_that.cancelled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@TimestampConverter()  DateTime? requested, @TimestampConverter()  DateTime? accepted, @TimestampConverter()  DateTime? arriving, @TimestampConverter()  DateTime? arrived, @TimestampConverter()  DateTime? started, @TimestampConverter()  DateTime? completed, @TimestampConverter()  DateTime? cancelled)  $default,) {final _that = this;
switch (_that) {
case _BookingTimestamps():
return $default(_that.requested,_that.accepted,_that.arriving,_that.arrived,_that.started,_that.completed,_that.cancelled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@TimestampConverter()  DateTime? requested, @TimestampConverter()  DateTime? accepted, @TimestampConverter()  DateTime? arriving, @TimestampConverter()  DateTime? arrived, @TimestampConverter()  DateTime? started, @TimestampConverter()  DateTime? completed, @TimestampConverter()  DateTime? cancelled)?  $default,) {final _that = this;
switch (_that) {
case _BookingTimestamps() when $default != null:
return $default(_that.requested,_that.accepted,_that.arriving,_that.arrived,_that.started,_that.completed,_that.cancelled);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _BookingTimestamps implements BookingTimestamps {
  const _BookingTimestamps({@TimestampConverter() this.requested, @TimestampConverter() this.accepted, @TimestampConverter() this.arriving, @TimestampConverter() this.arrived, @TimestampConverter() this.started, @TimestampConverter() this.completed, @TimestampConverter() this.cancelled});
  factory _BookingTimestamps.fromJson(Map<String, dynamic> json) => _$BookingTimestampsFromJson(json);

@override@TimestampConverter() final  DateTime? requested;
@override@TimestampConverter() final  DateTime? accepted;
@override@TimestampConverter() final  DateTime? arriving;
@override@TimestampConverter() final  DateTime? arrived;
@override@TimestampConverter() final  DateTime? started;
@override@TimestampConverter() final  DateTime? completed;
@override@TimestampConverter() final  DateTime? cancelled;

/// Create a copy of BookingTimestamps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingTimestampsCopyWith<_BookingTimestamps> get copyWith => __$BookingTimestampsCopyWithImpl<_BookingTimestamps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingTimestampsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingTimestamps&&(identical(other.requested, requested) || other.requested == requested)&&(identical(other.accepted, accepted) || other.accepted == accepted)&&(identical(other.arriving, arriving) || other.arriving == arriving)&&(identical(other.arrived, arrived) || other.arrived == arrived)&&(identical(other.started, started) || other.started == started)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.cancelled, cancelled) || other.cancelled == cancelled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,requested,accepted,arriving,arrived,started,completed,cancelled);
}

@override
String toString() {
    return 'BookingTimestamps(requested: $requested, accepted: $accepted, arriving: $arriving, arrived: $arrived, started: $started, completed: $completed, cancelled: $cancelled)';
}


}

/// @nodoc
abstract mixin class _$BookingTimestampsCopyWith<$Res> implements $BookingTimestampsCopyWith<$Res> {
  factory _$BookingTimestampsCopyWith(_BookingTimestamps value, $Res Function(_BookingTimestamps) _then) = __$BookingTimestampsCopyWithImpl;
@override @useResult
$Res call({
@TimestampConverter() DateTime? requested,@TimestampConverter() DateTime? accepted,@TimestampConverter() DateTime? arriving,@TimestampConverter() DateTime? arrived,@TimestampConverter() DateTime? started,@TimestampConverter() DateTime? completed,@TimestampConverter() DateTime? cancelled
});




}
/// @nodoc
class __$BookingTimestampsCopyWithImpl<$Res>
    implements _$BookingTimestampsCopyWith<$Res> {
  __$BookingTimestampsCopyWithImpl(this._self, this._then);

  final _BookingTimestamps _self;
  final $Res Function(_BookingTimestamps) _then;

/// Create a copy of BookingTimestamps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requested = freezed,Object? accepted = freezed,Object? arriving = freezed,Object? arrived = freezed,Object? started = freezed,Object? completed = freezed,Object? cancelled = freezed,}) {
  return _then(_BookingTimestamps(
requested: freezed == requested ? _self.requested : requested // ignore: cast_nullable_to_non_nullable
as DateTime?,accepted: freezed == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as DateTime?,arriving: freezed == arriving ? _self.arriving : arriving // ignore: cast_nullable_to_non_nullable
as DateTime?,arrived: freezed == arrived ? _self.arrived : arrived // ignore: cast_nullable_to_non_nullable
as DateTime?,started: freezed == started ? _self.started : started // ignore: cast_nullable_to_non_nullable
as DateTime?,completed: freezed == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelled: freezed == cancelled ? _self.cancelled : cancelled // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CancelReason {

 String get code; String? get text;
/// Create a copy of CancelReason
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CancelReasonCopyWith<CancelReason> get copyWith => _$CancelReasonCopyWithImpl<CancelReason>(this as CancelReason, _$identity);

  /// Serializes this CancelReason to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CancelReason;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelReason&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.text, _this.text) || other.text == _this.text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CancelReason;
  return Object.hash(runtimeType,_this.code,_this.text);
}

@override
String toString() {
  final _this = this as CancelReason;
  return 'CancelReason(code: ${_this.code}, text: ${_this.text})';
}


}

/// @nodoc
abstract mixin class $CancelReasonCopyWith<$Res>  {
  factory $CancelReasonCopyWith(CancelReason value, $Res Function(CancelReason) _then) = _$CancelReasonCopyWithImpl;
@useResult
$Res call({
 String code, String? text
});




}
/// @nodoc
class _$CancelReasonCopyWithImpl<$Res>
    implements $CancelReasonCopyWith<$Res> {
  _$CancelReasonCopyWithImpl(this._self, this._then);

  final CancelReason _self;
  final $Res Function(CancelReason) _then;

/// Create a copy of CancelReason
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? text = freezed,}) {
  return _then(CancelReason(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CancelReason].
extension CancelReasonPatterns on CancelReason {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CancelReason value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CancelReason() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CancelReason value)  $default,){
final _that = this;
switch (_that) {
case _CancelReason():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CancelReason value)?  $default,){
final _that = this;
switch (_that) {
case _CancelReason() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String? text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CancelReason() when $default != null:
return $default(_that.code,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String? text)  $default,) {final _that = this;
switch (_that) {
case _CancelReason():
return $default(_that.code,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String? text)?  $default,) {final _that = this;
switch (_that) {
case _CancelReason() when $default != null:
return $default(_that.code,_that.text);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _CancelReason implements CancelReason {
  const _CancelReason({required this.code, this.text});
  factory _CancelReason.fromJson(Map<String, dynamic> json) => _$CancelReasonFromJson(json);

@override final  String code;
@override final  String? text;

/// Create a copy of CancelReason
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CancelReasonCopyWith<_CancelReason> get copyWith => __$CancelReasonCopyWithImpl<_CancelReason>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CancelReasonToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelReason&&(identical(other.code, code) || other.code == code)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,text);
}

@override
String toString() {
    return 'CancelReason(code: $code, text: $text)';
}


}

/// @nodoc
abstract mixin class _$CancelReasonCopyWith<$Res> implements $CancelReasonCopyWith<$Res> {
  factory _$CancelReasonCopyWith(_CancelReason value, $Res Function(_CancelReason) _then) = __$CancelReasonCopyWithImpl;
@override @useResult
$Res call({
 String code, String? text
});




}
/// @nodoc
class __$CancelReasonCopyWithImpl<$Res>
    implements _$CancelReasonCopyWith<$Res> {
  __$CancelReasonCopyWithImpl(this._self, this._then);

  final _CancelReason _self;
  final $Res Function(_CancelReason) _then;

/// Create a copy of CancelReason
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? text = freezed,}) {
  return _then(_CancelReason(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Booking {

 String get customerId;/// Null until accepted.
 String? get mechanicId; CityId get cityId; BookingVehicle get vehicle; ProblemType get problemType; String get description; List<String> get photoUrls; Pickup get pickup; BookingStatus get status; List<StatusHistoryEntry> get statusHistory; String? get currentOfferId; List<String> get triedMechanicIds;/// 3 → 5 → 10.
 int get searchRadiusKm;/// Computed by the server from `prices`.
 PriceRange get priceEstimate; int? get finalAmount;/// Set at accept.
 MechanicCard? get mechanicCard;/// Set at accept.
 Contact? get customerCard; PaymentStatus get paymentStatus; List<String> get beforePhotoUrls; List<String> get afterPhotoUrls; BookingTimestamps get timestamps; Actor? get cancelledBy; CancelReason? get cancelReason; String get idempotencyKey;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt; int get schemaVersion;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Booking;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.mechanicId, _this.mechanicId) || other.mechanicId == _this.mechanicId)&&(identical(other.cityId, _this.cityId) || other.cityId == _this.cityId)&&(identical(other.vehicle, _this.vehicle) || other.vehicle == _this.vehicle)&&(identical(other.problemType, _this.problemType) || other.problemType == _this.problemType)&&(identical(other.description, _this.description) || other.description == _this.description)&&const DeepCollectionEquality().equals(other.photoUrls, _this.photoUrls)&&(identical(other.pickup, _this.pickup) || other.pickup == _this.pickup)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.statusHistory, _this.statusHistory)&&(identical(other.currentOfferId, _this.currentOfferId) || other.currentOfferId == _this.currentOfferId)&&const DeepCollectionEquality().equals(other.triedMechanicIds, _this.triedMechanicIds)&&(identical(other.searchRadiusKm, _this.searchRadiusKm) || other.searchRadiusKm == _this.searchRadiusKm)&&(identical(other.priceEstimate, _this.priceEstimate) || other.priceEstimate == _this.priceEstimate)&&(identical(other.finalAmount, _this.finalAmount) || other.finalAmount == _this.finalAmount)&&(identical(other.mechanicCard, _this.mechanicCard) || other.mechanicCard == _this.mechanicCard)&&(identical(other.customerCard, _this.customerCard) || other.customerCard == _this.customerCard)&&(identical(other.paymentStatus, _this.paymentStatus) || other.paymentStatus == _this.paymentStatus)&&const DeepCollectionEquality().equals(other.beforePhotoUrls, _this.beforePhotoUrls)&&const DeepCollectionEquality().equals(other.afterPhotoUrls, _this.afterPhotoUrls)&&(identical(other.timestamps, _this.timestamps) || other.timestamps == _this.timestamps)&&(identical(other.cancelledBy, _this.cancelledBy) || other.cancelledBy == _this.cancelledBy)&&(identical(other.cancelReason, _this.cancelReason) || other.cancelReason == _this.cancelReason)&&(identical(other.idempotencyKey, _this.idempotencyKey) || other.idempotencyKey == _this.idempotencyKey)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Booking;
  return Object.hashAll([runtimeType,_this.customerId,_this.mechanicId,_this.cityId,_this.vehicle,_this.problemType,_this.description,const DeepCollectionEquality().hash(_this.photoUrls),_this.pickup,_this.status,const DeepCollectionEquality().hash(_this.statusHistory),_this.currentOfferId,const DeepCollectionEquality().hash(_this.triedMechanicIds),_this.searchRadiusKm,_this.priceEstimate,_this.finalAmount,_this.mechanicCard,_this.customerCard,_this.paymentStatus,const DeepCollectionEquality().hash(_this.beforePhotoUrls),const DeepCollectionEquality().hash(_this.afterPhotoUrls),_this.timestamps,_this.cancelledBy,_this.cancelReason,_this.idempotencyKey,_this.createdAt,_this.updatedAt,_this.schemaVersion]);
}

@override
String toString() {
  final _this = this as Booking;
  return 'Booking(customerId: ${_this.customerId}, mechanicId: ${_this.mechanicId}, cityId: ${_this.cityId}, vehicle: ${_this.vehicle}, problemType: ${_this.problemType}, description: ${_this.description}, photoUrls: ${_this.photoUrls}, pickup: ${_this.pickup}, status: ${_this.status}, statusHistory: ${_this.statusHistory}, currentOfferId: ${_this.currentOfferId}, triedMechanicIds: ${_this.triedMechanicIds}, searchRadiusKm: ${_this.searchRadiusKm}, priceEstimate: ${_this.priceEstimate}, finalAmount: ${_this.finalAmount}, mechanicCard: ${_this.mechanicCard}, customerCard: ${_this.customerCard}, paymentStatus: ${_this.paymentStatus}, beforePhotoUrls: ${_this.beforePhotoUrls}, afterPhotoUrls: ${_this.afterPhotoUrls}, timestamps: ${_this.timestamps}, cancelledBy: ${_this.cancelledBy}, cancelReason: ${_this.cancelReason}, idempotencyKey: ${_this.idempotencyKey}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, schemaVersion: ${_this.schemaVersion})';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String customerId, String? mechanicId, CityId cityId, BookingVehicle vehicle, ProblemType problemType, String description, List<String> photoUrls, Pickup pickup, BookingStatus status, List<StatusHistoryEntry> statusHistory, String? currentOfferId, List<String> triedMechanicIds, int searchRadiusKm, PriceRange priceEstimate, int? finalAmount, MechanicCard? mechanicCard, Contact? customerCard, PaymentStatus paymentStatus, List<String> beforePhotoUrls, List<String> afterPhotoUrls, BookingTimestamps timestamps, Actor? cancelledBy, CancelReason? cancelReason, String idempotencyKey,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});


$BookingVehicleCopyWith<$Res> get vehicle;$PickupCopyWith<$Res> get pickup;$PriceRangeCopyWith<$Res> get priceEstimate;$MechanicCardCopyWith<$Res>? get mechanicCard;$ContactCopyWith<$Res>? get customerCard;$BookingTimestampsCopyWith<$Res> get timestamps;$CancelReasonCopyWith<$Res>? get cancelReason;

}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = null,Object? mechanicId = freezed,Object? cityId = null,Object? vehicle = null,Object? problemType = null,Object? description = null,Object? photoUrls = null,Object? pickup = null,Object? status = null,Object? statusHistory = null,Object? currentOfferId = freezed,Object? triedMechanicIds = null,Object? searchRadiusKm = null,Object? priceEstimate = null,Object? finalAmount = freezed,Object? mechanicCard = freezed,Object? customerCard = freezed,Object? paymentStatus = null,Object? beforePhotoUrls = null,Object? afterPhotoUrls = null,Object? timestamps = null,Object? cancelledBy = freezed,Object? cancelReason = freezed,Object? idempotencyKey = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(Booking(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,mechanicId: freezed == mechanicId ? _self.mechanicId : mechanicId // ignore: cast_nullable_to_non_nullable
as String?,cityId: null == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as CityId,vehicle: null == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as BookingVehicle,problemType: null == problemType ? _self.problemType : problemType // ignore: cast_nullable_to_non_nullable
as ProblemType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,photoUrls: null == photoUrls ? _self.photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as Pickup,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,statusHistory: null == statusHistory ? _self.statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<StatusHistoryEntry>,currentOfferId: freezed == currentOfferId ? _self.currentOfferId : currentOfferId // ignore: cast_nullable_to_non_nullable
as String?,triedMechanicIds: null == triedMechanicIds ? _self.triedMechanicIds : triedMechanicIds // ignore: cast_nullable_to_non_nullable
as List<String>,searchRadiusKm: null == searchRadiusKm ? _self.searchRadiusKm : searchRadiusKm // ignore: cast_nullable_to_non_nullable
as int,priceEstimate: null == priceEstimate ? _self.priceEstimate : priceEstimate // ignore: cast_nullable_to_non_nullable
as PriceRange,finalAmount: freezed == finalAmount ? _self.finalAmount : finalAmount // ignore: cast_nullable_to_non_nullable
as int?,mechanicCard: freezed == mechanicCard ? _self.mechanicCard : mechanicCard // ignore: cast_nullable_to_non_nullable
as MechanicCard?,customerCard: freezed == customerCard ? _self.customerCard : customerCard // ignore: cast_nullable_to_non_nullable
as Contact?,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,beforePhotoUrls: null == beforePhotoUrls ? _self.beforePhotoUrls : beforePhotoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,afterPhotoUrls: null == afterPhotoUrls ? _self.afterPhotoUrls : afterPhotoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,timestamps: null == timestamps ? _self.timestamps : timestamps // ignore: cast_nullable_to_non_nullable
as BookingTimestamps,cancelledBy: freezed == cancelledBy ? _self.cancelledBy : cancelledBy // ignore: cast_nullable_to_non_nullable
as Actor?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as CancelReason?,idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingVehicleCopyWith<$Res> get vehicle {
  
  return $BookingVehicleCopyWith<$Res>(_self.vehicle, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PickupCopyWith<$Res> get pickup {
  
  return $PickupCopyWith<$Res>(_self.pickup, (value) {
    return _then(_self.copyWith(pickup: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceRangeCopyWith<$Res> get priceEstimate {
  
  return $PriceRangeCopyWith<$Res>(_self.priceEstimate, (value) {
    return _then(_self.copyWith(priceEstimate: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MechanicCardCopyWith<$Res>? get mechanicCard {
    if (_self.mechanicCard == null) {
    return null;
  }

  return $MechanicCardCopyWith<$Res>(_self.mechanicCard!, (value) {
    return _then(_self.copyWith(mechanicCard: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactCopyWith<$Res>? get customerCard {
    if (_self.customerCard == null) {
    return null;
  }

  return $ContactCopyWith<$Res>(_self.customerCard!, (value) {
    return _then(_self.copyWith(customerCard: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingTimestampsCopyWith<$Res> get timestamps {
  
  return $BookingTimestampsCopyWith<$Res>(_self.timestamps, (value) {
    return _then(_self.copyWith(timestamps: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CancelReasonCopyWith<$Res>? get cancelReason {
    if (_self.cancelReason == null) {
    return null;
  }

  return $CancelReasonCopyWith<$Res>(_self.cancelReason!, (value) {
    return _then(_self.copyWith(cancelReason: value));
  });
}
}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String customerId,  String? mechanicId,  CityId cityId,  BookingVehicle vehicle,  ProblemType problemType,  String description,  List<String> photoUrls,  Pickup pickup,  BookingStatus status,  List<StatusHistoryEntry> statusHistory,  String? currentOfferId,  List<String> triedMechanicIds,  int searchRadiusKm,  PriceRange priceEstimate,  int? finalAmount,  MechanicCard? mechanicCard,  Contact? customerCard,  PaymentStatus paymentStatus,  List<String> beforePhotoUrls,  List<String> afterPhotoUrls,  BookingTimestamps timestamps,  Actor? cancelledBy,  CancelReason? cancelReason,  String idempotencyKey, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.customerId,_that.mechanicId,_that.cityId,_that.vehicle,_that.problemType,_that.description,_that.photoUrls,_that.pickup,_that.status,_that.statusHistory,_that.currentOfferId,_that.triedMechanicIds,_that.searchRadiusKm,_that.priceEstimate,_that.finalAmount,_that.mechanicCard,_that.customerCard,_that.paymentStatus,_that.beforePhotoUrls,_that.afterPhotoUrls,_that.timestamps,_that.cancelledBy,_that.cancelReason,_that.idempotencyKey,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String customerId,  String? mechanicId,  CityId cityId,  BookingVehicle vehicle,  ProblemType problemType,  String description,  List<String> photoUrls,  Pickup pickup,  BookingStatus status,  List<StatusHistoryEntry> statusHistory,  String? currentOfferId,  List<String> triedMechanicIds,  int searchRadiusKm,  PriceRange priceEstimate,  int? finalAmount,  MechanicCard? mechanicCard,  Contact? customerCard,  PaymentStatus paymentStatus,  List<String> beforePhotoUrls,  List<String> afterPhotoUrls,  BookingTimestamps timestamps,  Actor? cancelledBy,  CancelReason? cancelReason,  String idempotencyKey, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.customerId,_that.mechanicId,_that.cityId,_that.vehicle,_that.problemType,_that.description,_that.photoUrls,_that.pickup,_that.status,_that.statusHistory,_that.currentOfferId,_that.triedMechanicIds,_that.searchRadiusKm,_that.priceEstimate,_that.finalAmount,_that.mechanicCard,_that.customerCard,_that.paymentStatus,_that.beforePhotoUrls,_that.afterPhotoUrls,_that.timestamps,_that.cancelledBy,_that.cancelReason,_that.idempotencyKey,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String customerId,  String? mechanicId,  CityId cityId,  BookingVehicle vehicle,  ProblemType problemType,  String description,  List<String> photoUrls,  Pickup pickup,  BookingStatus status,  List<StatusHistoryEntry> statusHistory,  String? currentOfferId,  List<String> triedMechanicIds,  int searchRadiusKm,  PriceRange priceEstimate,  int? finalAmount,  MechanicCard? mechanicCard,  Contact? customerCard,  PaymentStatus paymentStatus,  List<String> beforePhotoUrls,  List<String> afterPhotoUrls,  BookingTimestamps timestamps,  Actor? cancelledBy,  CancelReason? cancelReason,  String idempotencyKey, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.customerId,_that.mechanicId,_that.cityId,_that.vehicle,_that.problemType,_that.description,_that.photoUrls,_that.pickup,_that.status,_that.statusHistory,_that.currentOfferId,_that.triedMechanicIds,_that.searchRadiusKm,_that.priceEstimate,_that.finalAmount,_that.mechanicCard,_that.customerCard,_that.paymentStatus,_that.beforePhotoUrls,_that.afterPhotoUrls,_that.timestamps,_that.cancelledBy,_that.cancelReason,_that.idempotencyKey,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking implements Booking {
  const _Booking({required this.customerId, this.mechanicId, required this.cityId, required this.vehicle, required this.problemType, this.description = '',  List<String> photoUrls = const <String>[], required this.pickup, required this.status,  List<StatusHistoryEntry> statusHistory = const <StatusHistoryEntry>[], this.currentOfferId,  List<String> triedMechanicIds = const <String>[], required this.searchRadiusKm, required this.priceEstimate, this.finalAmount, this.mechanicCard, this.customerCard, this.paymentStatus = PaymentStatus.pending,  List<String> beforePhotoUrls = const <String>[],  List<String> afterPhotoUrls = const <String>[], this.timestamps = const BookingTimestamps(), this.cancelledBy, this.cancelReason, required this.idempotencyKey, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, this.schemaVersion = kSchemaVersion}): _photoUrls = photoUrls,_statusHistory = statusHistory,_triedMechanicIds = triedMechanicIds,_beforePhotoUrls = beforePhotoUrls,_afterPhotoUrls = afterPhotoUrls;
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override final  String customerId;
/// Null until accepted.
@override final  String? mechanicId;
@override final  CityId cityId;
@override final  BookingVehicle vehicle;
@override final  ProblemType problemType;
@override@JsonKey() final  String description;
 final  List<String> _photoUrls;
@override@JsonKey() List<String> get photoUrls {
  if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoUrls);
}

@override final  Pickup pickup;
@override final  BookingStatus status;
 final  List<StatusHistoryEntry> _statusHistory;
@override@JsonKey() List<StatusHistoryEntry> get statusHistory {
  if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statusHistory);
}

@override final  String? currentOfferId;
 final  List<String> _triedMechanicIds;
@override@JsonKey() List<String> get triedMechanicIds {
  if (_triedMechanicIds is EqualUnmodifiableListView) return _triedMechanicIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_triedMechanicIds);
}

/// 3 → 5 → 10.
@override final  int searchRadiusKm;
/// Computed by the server from `prices`.
@override final  PriceRange priceEstimate;
@override final  int? finalAmount;
/// Set at accept.
@override final  MechanicCard? mechanicCard;
/// Set at accept.
@override final  Contact? customerCard;
@override@JsonKey() final  PaymentStatus paymentStatus;
 final  List<String> _beforePhotoUrls;
@override@JsonKey() List<String> get beforePhotoUrls {
  if (_beforePhotoUrls is EqualUnmodifiableListView) return _beforePhotoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_beforePhotoUrls);
}

 final  List<String> _afterPhotoUrls;
@override@JsonKey() List<String> get afterPhotoUrls {
  if (_afterPhotoUrls is EqualUnmodifiableListView) return _afterPhotoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_afterPhotoUrls);
}

@override@JsonKey() final  BookingTimestamps timestamps;
@override final  Actor? cancelledBy;
@override final  CancelReason? cancelReason;
@override final  String idempotencyKey;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@JsonKey() final  int schemaVersion;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.mechanicId, mechanicId) || other.mechanicId == mechanicId)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle)&&(identical(other.problemType, problemType) || other.problemType == problemType)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.photoUrls, _photoUrls)&&(identical(other.pickup, pickup) || other.pickup == pickup)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.statusHistory, _statusHistory)&&(identical(other.currentOfferId, currentOfferId) || other.currentOfferId == currentOfferId)&&const DeepCollectionEquality().equals(other.triedMechanicIds, _triedMechanicIds)&&(identical(other.searchRadiusKm, searchRadiusKm) || other.searchRadiusKm == searchRadiusKm)&&(identical(other.priceEstimate, priceEstimate) || other.priceEstimate == priceEstimate)&&(identical(other.finalAmount, finalAmount) || other.finalAmount == finalAmount)&&(identical(other.mechanicCard, mechanicCard) || other.mechanicCard == mechanicCard)&&(identical(other.customerCard, customerCard) || other.customerCard == customerCard)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&const DeepCollectionEquality().equals(other.beforePhotoUrls, _beforePhotoUrls)&&const DeepCollectionEquality().equals(other.afterPhotoUrls, _afterPhotoUrls)&&(identical(other.timestamps, timestamps) || other.timestamps == timestamps)&&(identical(other.cancelledBy, cancelledBy) || other.cancelledBy == cancelledBy)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,customerId,mechanicId,cityId,vehicle,problemType,description,const DeepCollectionEquality().hash(_photoUrls),pickup,status,const DeepCollectionEquality().hash(_statusHistory),currentOfferId,const DeepCollectionEquality().hash(_triedMechanicIds),searchRadiusKm,priceEstimate,finalAmount,mechanicCard,customerCard,paymentStatus,const DeepCollectionEquality().hash(_beforePhotoUrls),const DeepCollectionEquality().hash(_afterPhotoUrls),timestamps,cancelledBy,cancelReason,idempotencyKey,createdAt,updatedAt,schemaVersion]);
}

@override
String toString() {
    return 'Booking(customerId: $customerId, mechanicId: $mechanicId, cityId: $cityId, vehicle: $vehicle, problemType: $problemType, description: $description, photoUrls: $photoUrls, pickup: $pickup, status: $status, statusHistory: $statusHistory, currentOfferId: $currentOfferId, triedMechanicIds: $triedMechanicIds, searchRadiusKm: $searchRadiusKm, priceEstimate: $priceEstimate, finalAmount: $finalAmount, mechanicCard: $mechanicCard, customerCard: $customerCard, paymentStatus: $paymentStatus, beforePhotoUrls: $beforePhotoUrls, afterPhotoUrls: $afterPhotoUrls, timestamps: $timestamps, cancelledBy: $cancelledBy, cancelReason: $cancelReason, idempotencyKey: $idempotencyKey, createdAt: $createdAt, updatedAt: $updatedAt, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String customerId, String? mechanicId, CityId cityId, BookingVehicle vehicle, ProblemType problemType, String description, List<String> photoUrls, Pickup pickup, BookingStatus status, List<StatusHistoryEntry> statusHistory, String? currentOfferId, List<String> triedMechanicIds, int searchRadiusKm, PriceRange priceEstimate, int? finalAmount, MechanicCard? mechanicCard, Contact? customerCard, PaymentStatus paymentStatus, List<String> beforePhotoUrls, List<String> afterPhotoUrls, BookingTimestamps timestamps, Actor? cancelledBy, CancelReason? cancelReason, String idempotencyKey,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});


@override $BookingVehicleCopyWith<$Res> get vehicle;@override $PickupCopyWith<$Res> get pickup;@override $PriceRangeCopyWith<$Res> get priceEstimate;@override $MechanicCardCopyWith<$Res>? get mechanicCard;@override $ContactCopyWith<$Res>? get customerCard;@override $BookingTimestampsCopyWith<$Res> get timestamps;@override $CancelReasonCopyWith<$Res>? get cancelReason;

}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = null,Object? mechanicId = freezed,Object? cityId = null,Object? vehicle = null,Object? problemType = null,Object? description = null,Object? photoUrls = null,Object? pickup = null,Object? status = null,Object? statusHistory = null,Object? currentOfferId = freezed,Object? triedMechanicIds = null,Object? searchRadiusKm = null,Object? priceEstimate = null,Object? finalAmount = freezed,Object? mechanicCard = freezed,Object? customerCard = freezed,Object? paymentStatus = null,Object? beforePhotoUrls = null,Object? afterPhotoUrls = null,Object? timestamps = null,Object? cancelledBy = freezed,Object? cancelReason = freezed,Object? idempotencyKey = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(_Booking(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,mechanicId: freezed == mechanicId ? _self.mechanicId : mechanicId // ignore: cast_nullable_to_non_nullable
as String?,cityId: null == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as CityId,vehicle: null == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as BookingVehicle,problemType: null == problemType ? _self.problemType : problemType // ignore: cast_nullable_to_non_nullable
as ProblemType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,photoUrls: null == photoUrls ? _self._photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as Pickup,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,statusHistory: null == statusHistory ? _self._statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<StatusHistoryEntry>,currentOfferId: freezed == currentOfferId ? _self.currentOfferId : currentOfferId // ignore: cast_nullable_to_non_nullable
as String?,triedMechanicIds: null == triedMechanicIds ? _self._triedMechanicIds : triedMechanicIds // ignore: cast_nullable_to_non_nullable
as List<String>,searchRadiusKm: null == searchRadiusKm ? _self.searchRadiusKm : searchRadiusKm // ignore: cast_nullable_to_non_nullable
as int,priceEstimate: null == priceEstimate ? _self.priceEstimate : priceEstimate // ignore: cast_nullable_to_non_nullable
as PriceRange,finalAmount: freezed == finalAmount ? _self.finalAmount : finalAmount // ignore: cast_nullable_to_non_nullable
as int?,mechanicCard: freezed == mechanicCard ? _self.mechanicCard : mechanicCard // ignore: cast_nullable_to_non_nullable
as MechanicCard?,customerCard: freezed == customerCard ? _self.customerCard : customerCard // ignore: cast_nullable_to_non_nullable
as Contact?,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,beforePhotoUrls: null == beforePhotoUrls ? _self._beforePhotoUrls : beforePhotoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,afterPhotoUrls: null == afterPhotoUrls ? _self._afterPhotoUrls : afterPhotoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,timestamps: null == timestamps ? _self.timestamps : timestamps // ignore: cast_nullable_to_non_nullable
as BookingTimestamps,cancelledBy: freezed == cancelledBy ? _self.cancelledBy : cancelledBy // ignore: cast_nullable_to_non_nullable
as Actor?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as CancelReason?,idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingVehicleCopyWith<$Res> get vehicle {
  
  return $BookingVehicleCopyWith<$Res>(_self.vehicle, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PickupCopyWith<$Res> get pickup {
  
  return $PickupCopyWith<$Res>(_self.pickup, (value) {
    return _then(_self.copyWith(pickup: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceRangeCopyWith<$Res> get priceEstimate {
  
  return $PriceRangeCopyWith<$Res>(_self.priceEstimate, (value) {
    return _then(_self.copyWith(priceEstimate: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MechanicCardCopyWith<$Res>? get mechanicCard {
    if (_self.mechanicCard == null) {
    return null;
  }

  return $MechanicCardCopyWith<$Res>(_self.mechanicCard!, (value) {
    return _then(_self.copyWith(mechanicCard: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactCopyWith<$Res>? get customerCard {
    if (_self.customerCard == null) {
    return null;
  }

  return $ContactCopyWith<$Res>(_self.customerCard!, (value) {
    return _then(_self.copyWith(customerCard: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingTimestampsCopyWith<$Res> get timestamps {
  
  return $BookingTimestampsCopyWith<$Res>(_self.timestamps, (value) {
    return _then(_self.copyWith(timestamps: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CancelReasonCopyWith<$Res>? get cancelReason {
    if (_self.cancelReason == null) {
    return null;
  }

  return $CancelReasonCopyWith<$Res>(_self.cancelReason!, (value) {
    return _then(_self.copyWith(cancelReason: value));
  });
}
}


/// @nodoc
mixin _$BookingOtp {

/// 4 digits.
 String get code; int get attempts;@TimestampConverter() DateTime? get lockedUntil;
/// Create a copy of BookingOtp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingOtpCopyWith<BookingOtp> get copyWith => _$BookingOtpCopyWithImpl<BookingOtp>(this as BookingOtp, _$identity);

  /// Serializes this BookingOtp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BookingOtp;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingOtp&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.lockedUntil, _this.lockedUntil) || other.lockedUntil == _this.lockedUntil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BookingOtp;
  return Object.hash(runtimeType,_this.code,_this.attempts,_this.lockedUntil);
}

@override
String toString() {
  final _this = this as BookingOtp;
  return 'BookingOtp(code: ${_this.code}, attempts: ${_this.attempts}, lockedUntil: ${_this.lockedUntil})';
}


}

/// @nodoc
abstract mixin class $BookingOtpCopyWith<$Res>  {
  factory $BookingOtpCopyWith(BookingOtp value, $Res Function(BookingOtp) _then) = _$BookingOtpCopyWithImpl;
@useResult
$Res call({
 String code, int attempts,@TimestampConverter() DateTime? lockedUntil
});




}
/// @nodoc
class _$BookingOtpCopyWithImpl<$Res>
    implements $BookingOtpCopyWith<$Res> {
  _$BookingOtpCopyWithImpl(this._self, this._then);

  final BookingOtp _self;
  final $Res Function(BookingOtp) _then;

/// Create a copy of BookingOtp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? attempts = null,Object? lockedUntil = freezed,}) {
  return _then(BookingOtp(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,lockedUntil: freezed == lockedUntil ? _self.lockedUntil : lockedUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingOtp].
extension BookingOtpPatterns on BookingOtp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingOtp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingOtp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingOtp value)  $default,){
final _that = this;
switch (_that) {
case _BookingOtp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingOtp value)?  $default,){
final _that = this;
switch (_that) {
case _BookingOtp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  int attempts, @TimestampConverter()  DateTime? lockedUntil)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingOtp() when $default != null:
return $default(_that.code,_that.attempts,_that.lockedUntil);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  int attempts, @TimestampConverter()  DateTime? lockedUntil)  $default,) {final _that = this;
switch (_that) {
case _BookingOtp():
return $default(_that.code,_that.attempts,_that.lockedUntil);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  int attempts, @TimestampConverter()  DateTime? lockedUntil)?  $default,) {final _that = this;
switch (_that) {
case _BookingOtp() when $default != null:
return $default(_that.code,_that.attempts,_that.lockedUntil);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingOtp implements BookingOtp {
  const _BookingOtp({required this.code, this.attempts = 0, @TimestampConverter() this.lockedUntil});
  factory _BookingOtp.fromJson(Map<String, dynamic> json) => _$BookingOtpFromJson(json);

/// 4 digits.
@override final  String code;
@override@JsonKey() final  int attempts;
@override@TimestampConverter() final  DateTime? lockedUntil;

/// Create a copy of BookingOtp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingOtpCopyWith<_BookingOtp> get copyWith => __$BookingOtpCopyWithImpl<_BookingOtp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingOtpToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingOtp&&(identical(other.code, code) || other.code == code)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.lockedUntil, lockedUntil) || other.lockedUntil == lockedUntil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,attempts,lockedUntil);
}

@override
String toString() {
    return 'BookingOtp(code: $code, attempts: $attempts, lockedUntil: $lockedUntil)';
}


}

/// @nodoc
abstract mixin class _$BookingOtpCopyWith<$Res> implements $BookingOtpCopyWith<$Res> {
  factory _$BookingOtpCopyWith(_BookingOtp value, $Res Function(_BookingOtp) _then) = __$BookingOtpCopyWithImpl;
@override @useResult
$Res call({
 String code, int attempts,@TimestampConverter() DateTime? lockedUntil
});




}
/// @nodoc
class __$BookingOtpCopyWithImpl<$Res>
    implements _$BookingOtpCopyWith<$Res> {
  __$BookingOtpCopyWithImpl(this._self, this._then);

  final _BookingOtp _self;
  final $Res Function(_BookingOtp) _then;

/// Create a copy of BookingOtp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? attempts = null,Object? lockedUntil = freezed,}) {
  return _then(_BookingOtp(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,lockedUntil: freezed == lockedUntil ? _self.lockedUntil : lockedUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ChatMessage {

 String get senderId;/// ≤ 500 characters (`kMaxChatLength`).
 String get text;/// Storage path under `bookings/{bookingId}/chat/`.
 String? get imagePath;@TimestampConverter() DateTime? get createdAt;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChatMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.senderId, _this.senderId) || other.senderId == _this.senderId)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.imagePath, _this.imagePath) || other.imagePath == _this.imagePath)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChatMessage;
  return Object.hash(runtimeType,_this.senderId,_this.text,_this.imagePath,_this.createdAt);
}

@override
String toString() {
  final _this = this as ChatMessage;
  return 'ChatMessage(senderId: ${_this.senderId}, text: ${_this.text}, imagePath: ${_this.imagePath}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 String senderId, String text, String? imagePath,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? senderId = null,Object? text = null,Object? imagePath = freezed,Object? createdAt = freezed,}) {
  return _then(ChatMessage(
senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String senderId,  String text,  String? imagePath, @TimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.senderId,_that.text,_that.imagePath,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String senderId,  String text,  String? imagePath, @TimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.senderId,_that.text,_that.imagePath,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String senderId,  String text,  String? imagePath, @TimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.senderId,_that.text,_that.imagePath,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessage implements ChatMessage {
  const _ChatMessage({required this.senderId, this.text = '', this.imagePath, @TimestampConverter() this.createdAt});
  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

@override final  String senderId;
/// ≤ 500 characters (`kMaxChatLength`).
@override@JsonKey() final  String text;
/// Storage path under `bookings/{bookingId}/chat/`.
@override final  String? imagePath;
@override@TimestampConverter() final  DateTime? createdAt;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.text, text) || other.text == text)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,senderId,text,imagePath,createdAt);
}

@override
String toString() {
    return 'ChatMessage(senderId: $senderId, text: $text, imagePath: $imagePath, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String senderId, String text, String? imagePath,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? senderId = null,Object? text = null,Object? imagePath = freezed,Object? createdAt = freezed,}) {
  return _then(_ChatMessage(
senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$LiveLocation {

@GeoPointConverter() GeoPoint get mechanicGeopoint; double get heading; double get speed; int get etaMinutes;@TimestampConverter() DateTime? get updatedAt;/// TTL: deleted 24 h after the job ends.
@TimestampConverter() DateTime get expireAt;
/// Create a copy of LiveLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveLocationCopyWith<LiveLocation> get copyWith => _$LiveLocationCopyWithImpl<LiveLocation>(this as LiveLocation, _$identity);

  /// Serializes this LiveLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LiveLocation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveLocation&&(identical(other.mechanicGeopoint, _this.mechanicGeopoint) || other.mechanicGeopoint == _this.mechanicGeopoint)&&(identical(other.heading, _this.heading) || other.heading == _this.heading)&&(identical(other.speed, _this.speed) || other.speed == _this.speed)&&(identical(other.etaMinutes, _this.etaMinutes) || other.etaMinutes == _this.etaMinutes)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.expireAt, _this.expireAt) || other.expireAt == _this.expireAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LiveLocation;
  return Object.hash(runtimeType,_this.mechanicGeopoint,_this.heading,_this.speed,_this.etaMinutes,_this.updatedAt,_this.expireAt);
}

@override
String toString() {
  final _this = this as LiveLocation;
  return 'LiveLocation(mechanicGeopoint: ${_this.mechanicGeopoint}, heading: ${_this.heading}, speed: ${_this.speed}, etaMinutes: ${_this.etaMinutes}, updatedAt: ${_this.updatedAt}, expireAt: ${_this.expireAt})';
}


}

/// @nodoc
abstract mixin class $LiveLocationCopyWith<$Res>  {
  factory $LiveLocationCopyWith(LiveLocation value, $Res Function(LiveLocation) _then) = _$LiveLocationCopyWithImpl;
@useResult
$Res call({
@GeoPointConverter() GeoPoint mechanicGeopoint, double heading, double speed, int etaMinutes,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime expireAt
});




}
/// @nodoc
class _$LiveLocationCopyWithImpl<$Res>
    implements $LiveLocationCopyWith<$Res> {
  _$LiveLocationCopyWithImpl(this._self, this._then);

  final LiveLocation _self;
  final $Res Function(LiveLocation) _then;

/// Create a copy of LiveLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mechanicGeopoint = null,Object? heading = null,Object? speed = null,Object? etaMinutes = null,Object? updatedAt = freezed,Object? expireAt = null,}) {
  return _then(LiveLocation(
mechanicGeopoint: null == mechanicGeopoint ? _self.mechanicGeopoint : mechanicGeopoint // ignore: cast_nullable_to_non_nullable
as GeoPoint,heading: null == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,etaMinutes: null == etaMinutes ? _self.etaMinutes : etaMinutes // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expireAt: null == expireAt ? _self.expireAt : expireAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveLocation].
extension LiveLocationPatterns on LiveLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveLocation value)  $default,){
final _that = this;
switch (_that) {
case _LiveLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveLocation value)?  $default,){
final _that = this;
switch (_that) {
case _LiveLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@GeoPointConverter()  GeoPoint mechanicGeopoint,  double heading,  double speed,  int etaMinutes, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime expireAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveLocation() when $default != null:
return $default(_that.mechanicGeopoint,_that.heading,_that.speed,_that.etaMinutes,_that.updatedAt,_that.expireAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@GeoPointConverter()  GeoPoint mechanicGeopoint,  double heading,  double speed,  int etaMinutes, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime expireAt)  $default,) {final _that = this;
switch (_that) {
case _LiveLocation():
return $default(_that.mechanicGeopoint,_that.heading,_that.speed,_that.etaMinutes,_that.updatedAt,_that.expireAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@GeoPointConverter()  GeoPoint mechanicGeopoint,  double heading,  double speed,  int etaMinutes, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime expireAt)?  $default,) {final _that = this;
switch (_that) {
case _LiveLocation() when $default != null:
return $default(_that.mechanicGeopoint,_that.heading,_that.speed,_that.etaMinutes,_that.updatedAt,_that.expireAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveLocation implements LiveLocation {
  const _LiveLocation({@GeoPointConverter() required this.mechanicGeopoint, required this.heading, required this.speed, required this.etaMinutes, @TimestampConverter() this.updatedAt, @TimestampConverter() required this.expireAt});
  factory _LiveLocation.fromJson(Map<String, dynamic> json) => _$LiveLocationFromJson(json);

@override@GeoPointConverter() final  GeoPoint mechanicGeopoint;
@override final  double heading;
@override final  double speed;
@override final  int etaMinutes;
@override@TimestampConverter() final  DateTime? updatedAt;
/// TTL: deleted 24 h after the job ends.
@override@TimestampConverter() final  DateTime expireAt;

/// Create a copy of LiveLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveLocationCopyWith<_LiveLocation> get copyWith => __$LiveLocationCopyWithImpl<_LiveLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveLocationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveLocation&&(identical(other.mechanicGeopoint, mechanicGeopoint) || other.mechanicGeopoint == mechanicGeopoint)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.etaMinutes, etaMinutes) || other.etaMinutes == etaMinutes)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.expireAt, expireAt) || other.expireAt == expireAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,mechanicGeopoint,heading,speed,etaMinutes,updatedAt,expireAt);
}

@override
String toString() {
    return 'LiveLocation(mechanicGeopoint: $mechanicGeopoint, heading: $heading, speed: $speed, etaMinutes: $etaMinutes, updatedAt: $updatedAt, expireAt: $expireAt)';
}


}

/// @nodoc
abstract mixin class _$LiveLocationCopyWith<$Res> implements $LiveLocationCopyWith<$Res> {
  factory _$LiveLocationCopyWith(_LiveLocation value, $Res Function(_LiveLocation) _then) = __$LiveLocationCopyWithImpl;
@override @useResult
$Res call({
@GeoPointConverter() GeoPoint mechanicGeopoint, double heading, double speed, int etaMinutes,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime expireAt
});




}
/// @nodoc
class __$LiveLocationCopyWithImpl<$Res>
    implements _$LiveLocationCopyWith<$Res> {
  __$LiveLocationCopyWithImpl(this._self, this._then);

  final _LiveLocation _self;
  final $Res Function(_LiveLocation) _then;

/// Create a copy of LiveLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mechanicGeopoint = null,Object? heading = null,Object? speed = null,Object? etaMinutes = null,Object? updatedAt = freezed,Object? expireAt = null,}) {
  return _then(_LiveLocation(
mechanicGeopoint: null == mechanicGeopoint ? _self.mechanicGeopoint : mechanicGeopoint // ignore: cast_nullable_to_non_nullable
as GeoPoint,heading: null == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,etaMinutes: null == etaMinutes ? _self.etaMinutes : etaMinutes // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expireAt: null == expireAt ? _self.expireAt : expireAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ShareLink {

 String get bookingId; String get createdBy;@TimestampConverter() DateTime get expiresAt;
/// Create a copy of ShareLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShareLinkCopyWith<ShareLink> get copyWith => _$ShareLinkCopyWithImpl<ShareLink>(this as ShareLink, _$identity);

  /// Serializes this ShareLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ShareLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShareLink&&(identical(other.bookingId, _this.bookingId) || other.bookingId == _this.bookingId)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ShareLink;
  return Object.hash(runtimeType,_this.bookingId,_this.createdBy,_this.expiresAt);
}

@override
String toString() {
  final _this = this as ShareLink;
  return 'ShareLink(bookingId: ${_this.bookingId}, createdBy: ${_this.createdBy}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $ShareLinkCopyWith<$Res>  {
  factory $ShareLinkCopyWith(ShareLink value, $Res Function(ShareLink) _then) = _$ShareLinkCopyWithImpl;
@useResult
$Res call({
 String bookingId, String createdBy,@TimestampConverter() DateTime expiresAt
});




}
/// @nodoc
class _$ShareLinkCopyWithImpl<$Res>
    implements $ShareLinkCopyWith<$Res> {
  _$ShareLinkCopyWithImpl(this._self, this._then);

  final ShareLink _self;
  final $Res Function(ShareLink) _then;

/// Create a copy of ShareLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingId = null,Object? createdBy = null,Object? expiresAt = null,}) {
  return _then(ShareLink(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ShareLink].
extension ShareLinkPatterns on ShareLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShareLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShareLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShareLink value)  $default,){
final _that = this;
switch (_that) {
case _ShareLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShareLink value)?  $default,){
final _that = this;
switch (_that) {
case _ShareLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bookingId,  String createdBy, @TimestampConverter()  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShareLink() when $default != null:
return $default(_that.bookingId,_that.createdBy,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bookingId,  String createdBy, @TimestampConverter()  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _ShareLink():
return $default(_that.bookingId,_that.createdBy,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bookingId,  String createdBy, @TimestampConverter()  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _ShareLink() when $default != null:
return $default(_that.bookingId,_that.createdBy,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShareLink implements ShareLink {
  const _ShareLink({required this.bookingId, required this.createdBy, @TimestampConverter() required this.expiresAt});
  factory _ShareLink.fromJson(Map<String, dynamic> json) => _$ShareLinkFromJson(json);

@override final  String bookingId;
@override final  String createdBy;
@override@TimestampConverter() final  DateTime expiresAt;

/// Create a copy of ShareLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShareLinkCopyWith<_ShareLink> get copyWith => __$ShareLinkCopyWithImpl<_ShareLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShareLinkToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShareLink&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,bookingId,createdBy,expiresAt);
}

@override
String toString() {
    return 'ShareLink(bookingId: $bookingId, createdBy: $createdBy, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$ShareLinkCopyWith<$Res> implements $ShareLinkCopyWith<$Res> {
  factory _$ShareLinkCopyWith(_ShareLink value, $Res Function(_ShareLink) _then) = __$ShareLinkCopyWithImpl;
@override @useResult
$Res call({
 String bookingId, String createdBy,@TimestampConverter() DateTime expiresAt
});




}
/// @nodoc
class __$ShareLinkCopyWithImpl<$Res>
    implements _$ShareLinkCopyWith<$Res> {
  __$ShareLinkCopyWithImpl(this._self, this._then);

  final _ShareLink _self;
  final $Res Function(_ShareLink) _then;

/// Create a copy of ShareLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingId = null,Object? createdBy = null,Object? expiresAt = null,}) {
  return _then(_ShareLink(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
