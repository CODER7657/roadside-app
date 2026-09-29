// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'platform.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Price {

 VehicleType get vehicleType; ProblemType get problemType; int get min; int get max;/// Short text shown under the PriceRange.
 String get includes; Map<CityId, PriceRange>? get cityOverrides;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt; int get schemaVersion;
/// Create a copy of Price
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceCopyWith<Price> get copyWith => _$PriceCopyWithImpl<Price>(this as Price, _$identity);

  /// Serializes this Price to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Price;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Price&&(identical(other.vehicleType, _this.vehicleType) || other.vehicleType == _this.vehicleType)&&(identical(other.problemType, _this.problemType) || other.problemType == _this.problemType)&&(identical(other.min, _this.min) || other.min == _this.min)&&(identical(other.max, _this.max) || other.max == _this.max)&&(identical(other.includes, _this.includes) || other.includes == _this.includes)&&const DeepCollectionEquality().equals(other.cityOverrides, _this.cityOverrides)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Price;
  return Object.hash(runtimeType,_this.vehicleType,_this.problemType,_this.min,_this.max,_this.includes,const DeepCollectionEquality().hash(_this.cityOverrides),_this.createdAt,_this.updatedAt,_this.schemaVersion);
}

@override
String toString() {
  final _this = this as Price;
  return 'Price(vehicleType: ${_this.vehicleType}, problemType: ${_this.problemType}, min: ${_this.min}, max: ${_this.max}, includes: ${_this.includes}, cityOverrides: ${_this.cityOverrides}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, schemaVersion: ${_this.schemaVersion})';
}


}

/// @nodoc
abstract mixin class $PriceCopyWith<$Res>  {
  factory $PriceCopyWith(Price value, $Res Function(Price) _then) = _$PriceCopyWithImpl;
@useResult
$Res call({
 VehicleType vehicleType, ProblemType problemType, int min, int max, String includes, Map<CityId, PriceRange>? cityOverrides,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});




}
/// @nodoc
class _$PriceCopyWithImpl<$Res>
    implements $PriceCopyWith<$Res> {
  _$PriceCopyWithImpl(this._self, this._then);

  final Price _self;
  final $Res Function(Price) _then;

/// Create a copy of Price
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vehicleType = null,Object? problemType = null,Object? min = null,Object? max = null,Object? includes = null,Object? cityOverrides = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(Price(
vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,problemType: null == problemType ? _self.problemType : problemType // ignore: cast_nullable_to_non_nullable
as ProblemType,min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,includes: null == includes ? _self.includes : includes // ignore: cast_nullable_to_non_nullable
as String,cityOverrides: freezed == cityOverrides ? _self.cityOverrides : cityOverrides // ignore: cast_nullable_to_non_nullable
as Map<CityId, PriceRange>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Price].
extension PricePatterns on Price {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Price value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Price() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Price value)  $default,){
final _that = this;
switch (_that) {
case _Price():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Price value)?  $default,){
final _that = this;
switch (_that) {
case _Price() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VehicleType vehicleType,  ProblemType problemType,  int min,  int max,  String includes,  Map<CityId, PriceRange>? cityOverrides, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Price() when $default != null:
return $default(_that.vehicleType,_that.problemType,_that.min,_that.max,_that.includes,_that.cityOverrides,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VehicleType vehicleType,  ProblemType problemType,  int min,  int max,  String includes,  Map<CityId, PriceRange>? cityOverrides, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _Price():
return $default(_that.vehicleType,_that.problemType,_that.min,_that.max,_that.includes,_that.cityOverrides,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VehicleType vehicleType,  ProblemType problemType,  int min,  int max,  String includes,  Map<CityId, PriceRange>? cityOverrides, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _Price() when $default != null:
return $default(_that.vehicleType,_that.problemType,_that.min,_that.max,_that.includes,_that.cityOverrides,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _Price extends Price {
  const _Price({required this.vehicleType, required this.problemType, required this.min, required this.max, required this.includes,  Map<CityId, PriceRange>? cityOverrides, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, this.schemaVersion = kSchemaVersion}): _cityOverrides = cityOverrides,super._();
  factory _Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);

@override final  VehicleType vehicleType;
@override final  ProblemType problemType;
@override final  int min;
@override final  int max;
/// Short text shown under the PriceRange.
@override final  String includes;
 final  Map<CityId, PriceRange>? _cityOverrides;
@override Map<CityId, PriceRange>? get cityOverrides {
  final value = _cityOverrides;
  if (value == null) return null;
  if (_cityOverrides is EqualUnmodifiableMapView) return _cityOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@JsonKey() final  int schemaVersion;

/// Create a copy of Price
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceCopyWith<_Price> get copyWith => __$PriceCopyWithImpl<_Price>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Price&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.problemType, problemType) || other.problemType == problemType)&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max)&&(identical(other.includes, includes) || other.includes == includes)&&const DeepCollectionEquality().equals(other.cityOverrides, _cityOverrides)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,vehicleType,problemType,min,max,includes,const DeepCollectionEquality().hash(_cityOverrides),createdAt,updatedAt,schemaVersion);
}

@override
String toString() {
    return 'Price(vehicleType: $vehicleType, problemType: $problemType, min: $min, max: $max, includes: $includes, cityOverrides: $cityOverrides, createdAt: $createdAt, updatedAt: $updatedAt, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$PriceCopyWith<$Res> implements $PriceCopyWith<$Res> {
  factory _$PriceCopyWith(_Price value, $Res Function(_Price) _then) = __$PriceCopyWithImpl;
@override @useResult
$Res call({
 VehicleType vehicleType, ProblemType problemType, int min, int max, String includes, Map<CityId, PriceRange>? cityOverrides,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});




}
/// @nodoc
class __$PriceCopyWithImpl<$Res>
    implements _$PriceCopyWith<$Res> {
  __$PriceCopyWithImpl(this._self, this._then);

  final _Price _self;
  final $Res Function(_Price) _then;

/// Create a copy of Price
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vehicleType = null,Object? problemType = null,Object? min = null,Object? max = null,Object? includes = null,Object? cityOverrides = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(_Price(
vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,problemType: null == problemType ? _self.problemType : problemType // ignore: cast_nullable_to_non_nullable
as ProblemType,min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,includes: null == includes ? _self.includes : includes // ignore: cast_nullable_to_non_nullable
as String,cityOverrides: freezed == cityOverrides ? _self._cityOverrides : cityOverrides // ignore: cast_nullable_to_non_nullable
as Map<CityId, PriceRange>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ServiceArea {

 LocalizedText get name;@GeoPointConverter() GeoPoint get center; double get radiusKm; bool get active; String get supportPhone;@TimestampConverter() DateTime? get launchedAt;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt; int get schemaVersion;
/// Create a copy of ServiceArea
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceAreaCopyWith<ServiceArea> get copyWith => _$ServiceAreaCopyWithImpl<ServiceArea>(this as ServiceArea, _$identity);

  /// Serializes this ServiceArea to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ServiceArea;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceArea&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.center, _this.center) || other.center == _this.center)&&(identical(other.radiusKm, _this.radiusKm) || other.radiusKm == _this.radiusKm)&&(identical(other.active, _this.active) || other.active == _this.active)&&(identical(other.supportPhone, _this.supportPhone) || other.supportPhone == _this.supportPhone)&&(identical(other.launchedAt, _this.launchedAt) || other.launchedAt == _this.launchedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ServiceArea;
  return Object.hash(runtimeType,_this.name,_this.center,_this.radiusKm,_this.active,_this.supportPhone,_this.launchedAt,_this.createdAt,_this.updatedAt,_this.schemaVersion);
}

@override
String toString() {
  final _this = this as ServiceArea;
  return 'ServiceArea(name: ${_this.name}, center: ${_this.center}, radiusKm: ${_this.radiusKm}, active: ${_this.active}, supportPhone: ${_this.supportPhone}, launchedAt: ${_this.launchedAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, schemaVersion: ${_this.schemaVersion})';
}


}

/// @nodoc
abstract mixin class $ServiceAreaCopyWith<$Res>  {
  factory $ServiceAreaCopyWith(ServiceArea value, $Res Function(ServiceArea) _then) = _$ServiceAreaCopyWithImpl;
@useResult
$Res call({
 LocalizedText name,@GeoPointConverter() GeoPoint center, double radiusKm, bool active, String supportPhone,@TimestampConverter() DateTime? launchedAt,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});


$LocalizedTextCopyWith<$Res> get name;

}
/// @nodoc
class _$ServiceAreaCopyWithImpl<$Res>
    implements $ServiceAreaCopyWith<$Res> {
  _$ServiceAreaCopyWithImpl(this._self, this._then);

  final ServiceArea _self;
  final $Res Function(ServiceArea) _then;

/// Create a copy of ServiceArea
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? center = null,Object? radiusKm = null,Object? active = null,Object? supportPhone = null,Object? launchedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(ServiceArea(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as LocalizedText,center: null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as GeoPoint,radiusKm: null == radiusKm ? _self.radiusKm : radiusKm // ignore: cast_nullable_to_non_nullable
as double,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,supportPhone: null == supportPhone ? _self.supportPhone : supportPhone // ignore: cast_nullable_to_non_nullable
as String,launchedAt: freezed == launchedAt ? _self.launchedAt : launchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ServiceArea
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextCopyWith<$Res> get name {
  
  return $LocalizedTextCopyWith<$Res>(_self.name, (value) {
    return _then(_self.copyWith(name: value));
  });
}
}


/// Adds pattern-matching-related methods to [ServiceArea].
extension ServiceAreaPatterns on ServiceArea {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceArea value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceArea() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceArea value)  $default,){
final _that = this;
switch (_that) {
case _ServiceArea():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceArea value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceArea() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalizedText name, @GeoPointConverter()  GeoPoint center,  double radiusKm,  bool active,  String supportPhone, @TimestampConverter()  DateTime? launchedAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceArea() when $default != null:
return $default(_that.name,_that.center,_that.radiusKm,_that.active,_that.supportPhone,_that.launchedAt,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalizedText name, @GeoPointConverter()  GeoPoint center,  double radiusKm,  bool active,  String supportPhone, @TimestampConverter()  DateTime? launchedAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _ServiceArea():
return $default(_that.name,_that.center,_that.radiusKm,_that.active,_that.supportPhone,_that.launchedAt,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalizedText name, @GeoPointConverter()  GeoPoint center,  double radiusKm,  bool active,  String supportPhone, @TimestampConverter()  DateTime? launchedAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _ServiceArea() when $default != null:
return $default(_that.name,_that.center,_that.radiusKm,_that.active,_that.supportPhone,_that.launchedAt,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceArea implements ServiceArea {
  const _ServiceArea({required this.name, @GeoPointConverter() required this.center, required this.radiusKm, required this.active, required this.supportPhone, @TimestampConverter() this.launchedAt, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, this.schemaVersion = kSchemaVersion});
  factory _ServiceArea.fromJson(Map<String, dynamic> json) => _$ServiceAreaFromJson(json);

@override final  LocalizedText name;
@override@GeoPointConverter() final  GeoPoint center;
@override final  double radiusKm;
@override final  bool active;
@override final  String supportPhone;
@override@TimestampConverter() final  DateTime? launchedAt;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@JsonKey() final  int schemaVersion;

/// Create a copy of ServiceArea
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceAreaCopyWith<_ServiceArea> get copyWith => __$ServiceAreaCopyWithImpl<_ServiceArea>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceAreaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceArea&&(identical(other.name, name) || other.name == name)&&(identical(other.center, center) || other.center == center)&&(identical(other.radiusKm, radiusKm) || other.radiusKm == radiusKm)&&(identical(other.active, active) || other.active == active)&&(identical(other.supportPhone, supportPhone) || other.supportPhone == supportPhone)&&(identical(other.launchedAt, launchedAt) || other.launchedAt == launchedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,center,radiusKm,active,supportPhone,launchedAt,createdAt,updatedAt,schemaVersion);
}

@override
String toString() {
    return 'ServiceArea(name: $name, center: $center, radiusKm: $radiusKm, active: $active, supportPhone: $supportPhone, launchedAt: $launchedAt, createdAt: $createdAt, updatedAt: $updatedAt, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$ServiceAreaCopyWith<$Res> implements $ServiceAreaCopyWith<$Res> {
  factory _$ServiceAreaCopyWith(_ServiceArea value, $Res Function(_ServiceArea) _then) = __$ServiceAreaCopyWithImpl;
@override @useResult
$Res call({
 LocalizedText name,@GeoPointConverter() GeoPoint center, double radiusKm, bool active, String supportPhone,@TimestampConverter() DateTime? launchedAt,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});


@override $LocalizedTextCopyWith<$Res> get name;

}
/// @nodoc
class __$ServiceAreaCopyWithImpl<$Res>
    implements _$ServiceAreaCopyWith<$Res> {
  __$ServiceAreaCopyWithImpl(this._self, this._then);

  final _ServiceArea _self;
  final $Res Function(_ServiceArea) _then;

/// Create a copy of ServiceArea
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? center = null,Object? radiusKm = null,Object? active = null,Object? supportPhone = null,Object? launchedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(_ServiceArea(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as LocalizedText,center: null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as GeoPoint,radiusKm: null == radiusKm ? _self.radiusKm : radiusKm // ignore: cast_nullable_to_non_nullable
as double,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,supportPhone: null == supportPhone ? _self.supportPhone : supportPhone // ignore: cast_nullable_to_non_nullable
as String,launchedAt: freezed == launchedAt ? _self.launchedAt : launchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ServiceArea
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextCopyWith<$Res> get name {
  
  return $LocalizedTextCopyWith<$Res>(_self.name, (value) {
    return _then(_self.copyWith(name: value));
  });
}
}


/// @nodoc
mixin _$Review {

 String get customerId; String get mechanicId;/// 1–5.
 int get stars; List<String> get tags;/// ≤ 500 characters.
 String get comment;@TimestampConverter() DateTime? get createdAt;
/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewCopyWith<Review> get copyWith => _$ReviewCopyWithImpl<Review>(this as Review, _$identity);

  /// Serializes this Review to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Review;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Review&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.mechanicId, _this.mechanicId) || other.mechanicId == _this.mechanicId)&&(identical(other.stars, _this.stars) || other.stars == _this.stars)&&const DeepCollectionEquality().equals(other.tags, _this.tags)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Review;
  return Object.hash(runtimeType,_this.customerId,_this.mechanicId,_this.stars,const DeepCollectionEquality().hash(_this.tags),_this.comment,_this.createdAt);
}

@override
String toString() {
  final _this = this as Review;
  return 'Review(customerId: ${_this.customerId}, mechanicId: ${_this.mechanicId}, stars: ${_this.stars}, tags: ${_this.tags}, comment: ${_this.comment}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ReviewCopyWith<$Res>  {
  factory $ReviewCopyWith(Review value, $Res Function(Review) _then) = _$ReviewCopyWithImpl;
@useResult
$Res call({
 String customerId, String mechanicId, int stars, List<String> tags, String comment,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class _$ReviewCopyWithImpl<$Res>
    implements $ReviewCopyWith<$Res> {
  _$ReviewCopyWithImpl(this._self, this._then);

  final Review _self;
  final $Res Function(Review) _then;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = null,Object? mechanicId = null,Object? stars = null,Object? tags = null,Object? comment = null,Object? createdAt = freezed,}) {
  return _then(Review(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,mechanicId: null == mechanicId ? _self.mechanicId : mechanicId // ignore: cast_nullable_to_non_nullable
as String,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Review].
extension ReviewPatterns on Review {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Review value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Review() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Review value)  $default,){
final _that = this;
switch (_that) {
case _Review():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Review value)?  $default,){
final _that = this;
switch (_that) {
case _Review() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String customerId,  String mechanicId,  int stars,  List<String> tags,  String comment, @TimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Review() when $default != null:
return $default(_that.customerId,_that.mechanicId,_that.stars,_that.tags,_that.comment,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String customerId,  String mechanicId,  int stars,  List<String> tags,  String comment, @TimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Review():
return $default(_that.customerId,_that.mechanicId,_that.stars,_that.tags,_that.comment,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String customerId,  String mechanicId,  int stars,  List<String> tags,  String comment, @TimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Review() when $default != null:
return $default(_that.customerId,_that.mechanicId,_that.stars,_that.tags,_that.comment,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Review implements Review {
  const _Review({required this.customerId, required this.mechanicId, required this.stars,  List<String> tags = const <String>[], this.comment = '', @TimestampConverter() this.createdAt}): _tags = tags;
  factory _Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

@override final  String customerId;
@override final  String mechanicId;
/// 1–5.
@override final  int stars;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// ≤ 500 characters.
@override@JsonKey() final  String comment;
@override@TimestampConverter() final  DateTime? createdAt;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewCopyWith<_Review> get copyWith => __$ReviewCopyWithImpl<_Review>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Review&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.mechanicId, mechanicId) || other.mechanicId == mechanicId)&&(identical(other.stars, stars) || other.stars == stars)&&const DeepCollectionEquality().equals(other.tags, _tags)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,customerId,mechanicId,stars,const DeepCollectionEquality().hash(_tags),comment,createdAt);
}

@override
String toString() {
    return 'Review(customerId: $customerId, mechanicId: $mechanicId, stars: $stars, tags: $tags, comment: $comment, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReviewCopyWith<$Res> implements $ReviewCopyWith<$Res> {
  factory _$ReviewCopyWith(_Review value, $Res Function(_Review) _then) = __$ReviewCopyWithImpl;
@override @useResult
$Res call({
 String customerId, String mechanicId, int stars, List<String> tags, String comment,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class __$ReviewCopyWithImpl<$Res>
    implements _$ReviewCopyWith<$Res> {
  __$ReviewCopyWithImpl(this._self, this._then);

  final _Review _self;
  final $Res Function(_Review) _then;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = null,Object? mechanicId = null,Object? stars = null,Object? tags = null,Object? comment = null,Object? createdAt = freezed,}) {
  return _then(_Review(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,mechanicId: null == mechanicId ? _self.mechanicId : mechanicId // ignore: cast_nullable_to_non_nullable
as String,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Complaint {

 String get bookingId; String get raisedBy; String get category; String get text; ComplaintStatus get status; String? get resolution;@TimestampConverter() DateTime? get createdAt;
/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplaintCopyWith<Complaint> get copyWith => _$ComplaintCopyWithImpl<Complaint>(this as Complaint, _$identity);

  /// Serializes this Complaint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Complaint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Complaint&&(identical(other.bookingId, _this.bookingId) || other.bookingId == _this.bookingId)&&(identical(other.raisedBy, _this.raisedBy) || other.raisedBy == _this.raisedBy)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.resolution, _this.resolution) || other.resolution == _this.resolution)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Complaint;
  return Object.hash(runtimeType,_this.bookingId,_this.raisedBy,_this.category,_this.text,_this.status,_this.resolution,_this.createdAt);
}

@override
String toString() {
  final _this = this as Complaint;
  return 'Complaint(bookingId: ${_this.bookingId}, raisedBy: ${_this.raisedBy}, category: ${_this.category}, text: ${_this.text}, status: ${_this.status}, resolution: ${_this.resolution}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ComplaintCopyWith<$Res>  {
  factory $ComplaintCopyWith(Complaint value, $Res Function(Complaint) _then) = _$ComplaintCopyWithImpl;
@useResult
$Res call({
 String bookingId, String raisedBy, String category, String text, ComplaintStatus status, String? resolution,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class _$ComplaintCopyWithImpl<$Res>
    implements $ComplaintCopyWith<$Res> {
  _$ComplaintCopyWithImpl(this._self, this._then);

  final Complaint _self;
  final $Res Function(Complaint) _then;

/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingId = null,Object? raisedBy = null,Object? category = null,Object? text = null,Object? status = null,Object? resolution = freezed,Object? createdAt = freezed,}) {
  return _then(Complaint(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,raisedBy: null == raisedBy ? _self.raisedBy : raisedBy // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ComplaintStatus,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Complaint].
extension ComplaintPatterns on Complaint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Complaint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Complaint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Complaint value)  $default,){
final _that = this;
switch (_that) {
case _Complaint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Complaint value)?  $default,){
final _that = this;
switch (_that) {
case _Complaint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bookingId,  String raisedBy,  String category,  String text,  ComplaintStatus status,  String? resolution, @TimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Complaint() when $default != null:
return $default(_that.bookingId,_that.raisedBy,_that.category,_that.text,_that.status,_that.resolution,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bookingId,  String raisedBy,  String category,  String text,  ComplaintStatus status,  String? resolution, @TimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Complaint():
return $default(_that.bookingId,_that.raisedBy,_that.category,_that.text,_that.status,_that.resolution,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bookingId,  String raisedBy,  String category,  String text,  ComplaintStatus status,  String? resolution, @TimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Complaint() when $default != null:
return $default(_that.bookingId,_that.raisedBy,_that.category,_that.text,_that.status,_that.resolution,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Complaint implements Complaint {
  const _Complaint({required this.bookingId, required this.raisedBy, required this.category, required this.text, this.status = ComplaintStatus.open, this.resolution, @TimestampConverter() this.createdAt});
  factory _Complaint.fromJson(Map<String, dynamic> json) => _$ComplaintFromJson(json);

@override final  String bookingId;
@override final  String raisedBy;
@override final  String category;
@override final  String text;
@override@JsonKey() final  ComplaintStatus status;
@override final  String? resolution;
@override@TimestampConverter() final  DateTime? createdAt;

/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintCopyWith<_Complaint> get copyWith => __$ComplaintCopyWithImpl<_Complaint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComplaintToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Complaint&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.raisedBy, raisedBy) || other.raisedBy == raisedBy)&&(identical(other.category, category) || other.category == category)&&(identical(other.text, text) || other.text == text)&&(identical(other.status, status) || other.status == status)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,bookingId,raisedBy,category,text,status,resolution,createdAt);
}

@override
String toString() {
    return 'Complaint(bookingId: $bookingId, raisedBy: $raisedBy, category: $category, text: $text, status: $status, resolution: $resolution, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ComplaintCopyWith<$Res> implements $ComplaintCopyWith<$Res> {
  factory _$ComplaintCopyWith(_Complaint value, $Res Function(_Complaint) _then) = __$ComplaintCopyWithImpl;
@override @useResult
$Res call({
 String bookingId, String raisedBy, String category, String text, ComplaintStatus status, String? resolution,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class __$ComplaintCopyWithImpl<$Res>
    implements _$ComplaintCopyWith<$Res> {
  __$ComplaintCopyWithImpl(this._self, this._then);

  final _Complaint _self;
  final $Res Function(_Complaint) _then;

/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingId = null,Object? raisedBy = null,Object? category = null,Object? text = null,Object? status = null,Object? resolution = freezed,Object? createdAt = freezed,}) {
  return _then(_Complaint(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,raisedBy: null == raisedBy ? _self.raisedBy : raisedBy // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ComplaintStatus,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$InboxItem {

 String get type;/// ARB keys, resolved in the app with [args].
 String get titleKey; String get bodyKey; Map<String, String> get args; String? get bookingId; bool get read;
/// Create a copy of InboxItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InboxItemCopyWith<InboxItem> get copyWith => _$InboxItemCopyWithImpl<InboxItem>(this as InboxItem, _$identity);

  /// Serializes this InboxItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InboxItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InboxItem&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.titleKey, _this.titleKey) || other.titleKey == _this.titleKey)&&(identical(other.bodyKey, _this.bodyKey) || other.bodyKey == _this.bodyKey)&&const DeepCollectionEquality().equals(other.args, _this.args)&&(identical(other.bookingId, _this.bookingId) || other.bookingId == _this.bookingId)&&(identical(other.read, _this.read) || other.read == _this.read));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InboxItem;
  return Object.hash(runtimeType,_this.type,_this.titleKey,_this.bodyKey,const DeepCollectionEquality().hash(_this.args),_this.bookingId,_this.read);
}

@override
String toString() {
  final _this = this as InboxItem;
  return 'InboxItem(type: ${_this.type}, titleKey: ${_this.titleKey}, bodyKey: ${_this.bodyKey}, args: ${_this.args}, bookingId: ${_this.bookingId}, read: ${_this.read})';
}


}

/// @nodoc
abstract mixin class $InboxItemCopyWith<$Res>  {
  factory $InboxItemCopyWith(InboxItem value, $Res Function(InboxItem) _then) = _$InboxItemCopyWithImpl;
@useResult
$Res call({
 String type, String titleKey, String bodyKey, Map<String, String> args, String? bookingId, bool read
});




}
/// @nodoc
class _$InboxItemCopyWithImpl<$Res>
    implements $InboxItemCopyWith<$Res> {
  _$InboxItemCopyWithImpl(this._self, this._then);

  final InboxItem _self;
  final $Res Function(InboxItem) _then;

/// Create a copy of InboxItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? titleKey = null,Object? bodyKey = null,Object? args = null,Object? bookingId = freezed,Object? read = null,}) {
  return _then(InboxItem(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,bodyKey: null == bodyKey ? _self.bodyKey : bodyKey // ignore: cast_nullable_to_non_nullable
as String,args: null == args ? _self.args : args // ignore: cast_nullable_to_non_nullable
as Map<String, String>,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [InboxItem].
extension InboxItemPatterns on InboxItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InboxItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InboxItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InboxItem value)  $default,){
final _that = this;
switch (_that) {
case _InboxItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InboxItem value)?  $default,){
final _that = this;
switch (_that) {
case _InboxItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String titleKey,  String bodyKey,  Map<String, String> args,  String? bookingId,  bool read)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InboxItem() when $default != null:
return $default(_that.type,_that.titleKey,_that.bodyKey,_that.args,_that.bookingId,_that.read);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String titleKey,  String bodyKey,  Map<String, String> args,  String? bookingId,  bool read)  $default,) {final _that = this;
switch (_that) {
case _InboxItem():
return $default(_that.type,_that.titleKey,_that.bodyKey,_that.args,_that.bookingId,_that.read);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String titleKey,  String bodyKey,  Map<String, String> args,  String? bookingId,  bool read)?  $default,) {final _that = this;
switch (_that) {
case _InboxItem() when $default != null:
return $default(_that.type,_that.titleKey,_that.bodyKey,_that.args,_that.bookingId,_that.read);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InboxItem implements InboxItem {
  const _InboxItem({required this.type, required this.titleKey, required this.bodyKey,  Map<String, String> args = const <String, String>{}, this.bookingId, this.read = false}): _args = args;
  factory _InboxItem.fromJson(Map<String, dynamic> json) => _$InboxItemFromJson(json);

@override final  String type;
/// ARB keys, resolved in the app with [args].
@override final  String titleKey;
@override final  String bodyKey;
 final  Map<String, String> _args;
@override@JsonKey() Map<String, String> get args {
  if (_args is EqualUnmodifiableMapView) return _args;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_args);
}

@override final  String? bookingId;
@override@JsonKey() final  bool read;

/// Create a copy of InboxItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InboxItemCopyWith<_InboxItem> get copyWith => __$InboxItemCopyWithImpl<_InboxItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InboxItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InboxItem&&(identical(other.type, type) || other.type == type)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.bodyKey, bodyKey) || other.bodyKey == bodyKey)&&const DeepCollectionEquality().equals(other.args, _args)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.read, read) || other.read == read));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,titleKey,bodyKey,const DeepCollectionEquality().hash(_args),bookingId,read);
}

@override
String toString() {
    return 'InboxItem(type: $type, titleKey: $titleKey, bodyKey: $bodyKey, args: $args, bookingId: $bookingId, read: $read)';
}


}

/// @nodoc
abstract mixin class _$InboxItemCopyWith<$Res> implements $InboxItemCopyWith<$Res> {
  factory _$InboxItemCopyWith(_InboxItem value, $Res Function(_InboxItem) _then) = __$InboxItemCopyWithImpl;
@override @useResult
$Res call({
 String type, String titleKey, String bodyKey, Map<String, String> args, String? bookingId, bool read
});




}
/// @nodoc
class __$InboxItemCopyWithImpl<$Res>
    implements _$InboxItemCopyWith<$Res> {
  __$InboxItemCopyWithImpl(this._self, this._then);

  final _InboxItem _self;
  final $Res Function(_InboxItem) _then;

/// Create a copy of InboxItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? titleKey = null,Object? bodyKey = null,Object? args = null,Object? bookingId = freezed,Object? read = null,}) {
  return _then(_InboxItem(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,bodyKey: null == bodyKey ? _self.bodyKey : bodyKey // ignore: cast_nullable_to_non_nullable
as String,args: null == args ? _self._args : args // ignore: cast_nullable_to_non_nullable
as Map<String, String>,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AppConfig {

/// Builds below this see the force-update screen.
 int get minSupportedBuild; String? get maintenanceMessage; String get supportPhone;/// Kill switch for new bookings.
 bool get dispatchEnabled;
/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppConfigCopyWith<AppConfig> get copyWith => _$AppConfigCopyWithImpl<AppConfig>(this as AppConfig, _$identity);

  /// Serializes this AppConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppConfig&&(identical(other.minSupportedBuild, _this.minSupportedBuild) || other.minSupportedBuild == _this.minSupportedBuild)&&(identical(other.maintenanceMessage, _this.maintenanceMessage) || other.maintenanceMessage == _this.maintenanceMessage)&&(identical(other.supportPhone, _this.supportPhone) || other.supportPhone == _this.supportPhone)&&(identical(other.dispatchEnabled, _this.dispatchEnabled) || other.dispatchEnabled == _this.dispatchEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppConfig;
  return Object.hash(runtimeType,_this.minSupportedBuild,_this.maintenanceMessage,_this.supportPhone,_this.dispatchEnabled);
}

@override
String toString() {
  final _this = this as AppConfig;
  return 'AppConfig(minSupportedBuild: ${_this.minSupportedBuild}, maintenanceMessage: ${_this.maintenanceMessage}, supportPhone: ${_this.supportPhone}, dispatchEnabled: ${_this.dispatchEnabled})';
}


}

/// @nodoc
abstract mixin class $AppConfigCopyWith<$Res>  {
  factory $AppConfigCopyWith(AppConfig value, $Res Function(AppConfig) _then) = _$AppConfigCopyWithImpl;
@useResult
$Res call({
 int minSupportedBuild, String? maintenanceMessage, String supportPhone, bool dispatchEnabled
});




}
/// @nodoc
class _$AppConfigCopyWithImpl<$Res>
    implements $AppConfigCopyWith<$Res> {
  _$AppConfigCopyWithImpl(this._self, this._then);

  final AppConfig _self;
  final $Res Function(AppConfig) _then;

/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minSupportedBuild = null,Object? maintenanceMessage = freezed,Object? supportPhone = null,Object? dispatchEnabled = null,}) {
  return _then(AppConfig(
minSupportedBuild: null == minSupportedBuild ? _self.minSupportedBuild : minSupportedBuild // ignore: cast_nullable_to_non_nullable
as int,maintenanceMessage: freezed == maintenanceMessage ? _self.maintenanceMessage : maintenanceMessage // ignore: cast_nullable_to_non_nullable
as String?,supportPhone: null == supportPhone ? _self.supportPhone : supportPhone // ignore: cast_nullable_to_non_nullable
as String,dispatchEnabled: null == dispatchEnabled ? _self.dispatchEnabled : dispatchEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppConfig].
extension AppConfigPatterns on AppConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppConfig value)  $default,){
final _that = this;
switch (_that) {
case _AppConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppConfig value)?  $default,){
final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int minSupportedBuild,  String? maintenanceMessage,  String supportPhone,  bool dispatchEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
return $default(_that.minSupportedBuild,_that.maintenanceMessage,_that.supportPhone,_that.dispatchEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int minSupportedBuild,  String? maintenanceMessage,  String supportPhone,  bool dispatchEnabled)  $default,) {final _that = this;
switch (_that) {
case _AppConfig():
return $default(_that.minSupportedBuild,_that.maintenanceMessage,_that.supportPhone,_that.dispatchEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int minSupportedBuild,  String? maintenanceMessage,  String supportPhone,  bool dispatchEnabled)?  $default,) {final _that = this;
switch (_that) {
case _AppConfig() when $default != null:
return $default(_that.minSupportedBuild,_that.maintenanceMessage,_that.supportPhone,_that.dispatchEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppConfig implements AppConfig {
  const _AppConfig({required this.minSupportedBuild, this.maintenanceMessage, required this.supportPhone, required this.dispatchEnabled});
  factory _AppConfig.fromJson(Map<String, dynamic> json) => _$AppConfigFromJson(json);

/// Builds below this see the force-update screen.
@override final  int minSupportedBuild;
@override final  String? maintenanceMessage;
@override final  String supportPhone;
/// Kill switch for new bookings.
@override final  bool dispatchEnabled;

/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppConfigCopyWith<_AppConfig> get copyWith => __$AppConfigCopyWithImpl<_AppConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppConfig&&(identical(other.minSupportedBuild, minSupportedBuild) || other.minSupportedBuild == minSupportedBuild)&&(identical(other.maintenanceMessage, maintenanceMessage) || other.maintenanceMessage == maintenanceMessage)&&(identical(other.supportPhone, supportPhone) || other.supportPhone == supportPhone)&&(identical(other.dispatchEnabled, dispatchEnabled) || other.dispatchEnabled == dispatchEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,minSupportedBuild,maintenanceMessage,supportPhone,dispatchEnabled);
}

@override
String toString() {
    return 'AppConfig(minSupportedBuild: $minSupportedBuild, maintenanceMessage: $maintenanceMessage, supportPhone: $supportPhone, dispatchEnabled: $dispatchEnabled)';
}


}

/// @nodoc
abstract mixin class _$AppConfigCopyWith<$Res> implements $AppConfigCopyWith<$Res> {
  factory _$AppConfigCopyWith(_AppConfig value, $Res Function(_AppConfig) _then) = __$AppConfigCopyWithImpl;
@override @useResult
$Res call({
 int minSupportedBuild, String? maintenanceMessage, String supportPhone, bool dispatchEnabled
});




}
/// @nodoc
class __$AppConfigCopyWithImpl<$Res>
    implements _$AppConfigCopyWith<$Res> {
  __$AppConfigCopyWithImpl(this._self, this._then);

  final _AppConfig _self;
  final $Res Function(_AppConfig) _then;

/// Create a copy of AppConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minSupportedBuild = null,Object? maintenanceMessage = freezed,Object? supportPhone = null,Object? dispatchEnabled = null,}) {
  return _then(_AppConfig(
minSupportedBuild: null == minSupportedBuild ? _self.minSupportedBuild : minSupportedBuild // ignore: cast_nullable_to_non_nullable
as int,maintenanceMessage: freezed == maintenanceMessage ? _self.maintenanceMessage : maintenanceMessage // ignore: cast_nullable_to_non_nullable
as String?,supportPhone: null == supportPhone ? _self.supportPhone : supportPhone // ignore: cast_nullable_to_non_nullable
as String,dispatchEnabled: null == dispatchEnabled ? _self.dispatchEnabled : dispatchEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AuditLog {

 String get actorUid;/// e.g. `mechanic.approve`, `price.update`.
 String get action;/// Document path, e.g. `mechanics/abc`.
 String get target; Object? get before; Object? get after;@TimestampConverter() DateTime? get at;
/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditLogCopyWith<AuditLog> get copyWith => _$AuditLogCopyWithImpl<AuditLog>(this as AuditLog, _$identity);

  /// Serializes this AuditLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuditLog;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditLog&&(identical(other.actorUid, _this.actorUid) || other.actorUid == _this.actorUid)&&(identical(other.action, _this.action) || other.action == _this.action)&&(identical(other.target, _this.target) || other.target == _this.target)&&const DeepCollectionEquality().equals(other.before, _this.before)&&const DeepCollectionEquality().equals(other.after, _this.after)&&(identical(other.at, _this.at) || other.at == _this.at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuditLog;
  return Object.hash(runtimeType,_this.actorUid,_this.action,_this.target,const DeepCollectionEquality().hash(_this.before),const DeepCollectionEquality().hash(_this.after),_this.at);
}

@override
String toString() {
  final _this = this as AuditLog;
  return 'AuditLog(actorUid: ${_this.actorUid}, action: ${_this.action}, target: ${_this.target}, before: ${_this.before}, after: ${_this.after}, at: ${_this.at})';
}


}

/// @nodoc
abstract mixin class $AuditLogCopyWith<$Res>  {
  factory $AuditLogCopyWith(AuditLog value, $Res Function(AuditLog) _then) = _$AuditLogCopyWithImpl;
@useResult
$Res call({
 String actorUid, String action, String target, Object? before, Object? after,@TimestampConverter() DateTime? at
});




}
/// @nodoc
class _$AuditLogCopyWithImpl<$Res>
    implements $AuditLogCopyWith<$Res> {
  _$AuditLogCopyWithImpl(this._self, this._then);

  final AuditLog _self;
  final $Res Function(AuditLog) _then;

/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? actorUid = null,Object? action = null,Object? target = null,Object? before = freezed,Object? after = freezed,Object? at = freezed,}) {
  return _then(AuditLog(
actorUid: null == actorUid ? _self.actorUid : actorUid // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,before: freezed == before ? _self.before : before ,after: freezed == after ? _self.after : after ,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditLog].
extension AuditLogPatterns on AuditLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditLog value)  $default,){
final _that = this;
switch (_that) {
case _AuditLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditLog value)?  $default,){
final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String actorUid,  String action,  String target,  Object? before,  Object? after, @TimestampConverter()  DateTime? at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
return $default(_that.actorUid,_that.action,_that.target,_that.before,_that.after,_that.at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String actorUid,  String action,  String target,  Object? before,  Object? after, @TimestampConverter()  DateTime? at)  $default,) {final _that = this;
switch (_that) {
case _AuditLog():
return $default(_that.actorUid,_that.action,_that.target,_that.before,_that.after,_that.at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String actorUid,  String action,  String target,  Object? before,  Object? after, @TimestampConverter()  DateTime? at)?  $default,) {final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
return $default(_that.actorUid,_that.action,_that.target,_that.before,_that.after,_that.at);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditLog implements AuditLog {
  const _AuditLog({required this.actorUid, required this.action, required this.target, this.before, this.after, @TimestampConverter() this.at});
  factory _AuditLog.fromJson(Map<String, dynamic> json) => _$AuditLogFromJson(json);

@override final  String actorUid;
/// e.g. `mechanic.approve`, `price.update`.
@override final  String action;
/// Document path, e.g. `mechanics/abc`.
@override final  String target;
@override final  Object? before;
@override final  Object? after;
@override@TimestampConverter() final  DateTime? at;

/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditLogCopyWith<_AuditLog> get copyWith => __$AuditLogCopyWithImpl<_AuditLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditLogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditLog&&(identical(other.actorUid, actorUid) || other.actorUid == actorUid)&&(identical(other.action, action) || other.action == action)&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other.before, before)&&const DeepCollectionEquality().equals(other.after, after)&&(identical(other.at, at) || other.at == at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,actorUid,action,target,const DeepCollectionEquality().hash(before),const DeepCollectionEquality().hash(after),at);
}

@override
String toString() {
    return 'AuditLog(actorUid: $actorUid, action: $action, target: $target, before: $before, after: $after, at: $at)';
}


}

/// @nodoc
abstract mixin class _$AuditLogCopyWith<$Res> implements $AuditLogCopyWith<$Res> {
  factory _$AuditLogCopyWith(_AuditLog value, $Res Function(_AuditLog) _then) = __$AuditLogCopyWithImpl;
@override @useResult
$Res call({
 String actorUid, String action, String target, Object? before, Object? after,@TimestampConverter() DateTime? at
});




}
/// @nodoc
class __$AuditLogCopyWithImpl<$Res>
    implements _$AuditLogCopyWith<$Res> {
  __$AuditLogCopyWithImpl(this._self, this._then);

  final _AuditLog _self;
  final $Res Function(_AuditLog) _then;

/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? actorUid = null,Object? action = null,Object? target = null,Object? before = freezed,Object? after = freezed,Object? at = freezed,}) {
  return _then(_AuditLog(
actorUid: null == actorUid ? _self.actorUid : actorUid // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,before: freezed == before ? _self.before : before ,after: freezed == after ? _self.after : after ,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$RoleClaims {

 Role? get role; MechanicStatus? get mechanicStatus;
/// Create a copy of RoleClaims
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleClaimsCopyWith<RoleClaims> get copyWith => _$RoleClaimsCopyWithImpl<RoleClaims>(this as RoleClaims, _$identity);

  /// Serializes this RoleClaims to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RoleClaims;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleClaims&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.mechanicStatus, _this.mechanicStatus) || other.mechanicStatus == _this.mechanicStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RoleClaims;
  return Object.hash(runtimeType,_this.role,_this.mechanicStatus);
}

@override
String toString() {
  final _this = this as RoleClaims;
  return 'RoleClaims(role: ${_this.role}, mechanicStatus: ${_this.mechanicStatus})';
}


}

/// @nodoc
abstract mixin class $RoleClaimsCopyWith<$Res>  {
  factory $RoleClaimsCopyWith(RoleClaims value, $Res Function(RoleClaims) _then) = _$RoleClaimsCopyWithImpl;
@useResult
$Res call({
 Role? role, MechanicStatus? mechanicStatus
});




}
/// @nodoc
class _$RoleClaimsCopyWithImpl<$Res>
    implements $RoleClaimsCopyWith<$Res> {
  _$RoleClaimsCopyWithImpl(this._self, this._then);

  final RoleClaims _self;
  final $Res Function(RoleClaims) _then;

/// Create a copy of RoleClaims
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = freezed,Object? mechanicStatus = freezed,}) {
  return _then(RoleClaims(
role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role?,mechanicStatus: freezed == mechanicStatus ? _self.mechanicStatus : mechanicStatus // ignore: cast_nullable_to_non_nullable
as MechanicStatus?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoleClaims].
extension RoleClaimsPatterns on RoleClaims {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoleClaims value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoleClaims() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoleClaims value)  $default,){
final _that = this;
switch (_that) {
case _RoleClaims():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoleClaims value)?  $default,){
final _that = this;
switch (_that) {
case _RoleClaims() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Role? role,  MechanicStatus? mechanicStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoleClaims() when $default != null:
return $default(_that.role,_that.mechanicStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Role? role,  MechanicStatus? mechanicStatus)  $default,) {final _that = this;
switch (_that) {
case _RoleClaims():
return $default(_that.role,_that.mechanicStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Role? role,  MechanicStatus? mechanicStatus)?  $default,) {final _that = this;
switch (_that) {
case _RoleClaims() when $default != null:
return $default(_that.role,_that.mechanicStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoleClaims extends RoleClaims {
  const _RoleClaims({this.role, this.mechanicStatus}): super._();
  factory _RoleClaims.fromJson(Map<String, dynamic> json) => _$RoleClaimsFromJson(json);

@override final  Role? role;
@override final  MechanicStatus? mechanicStatus;

/// Create a copy of RoleClaims
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoleClaimsCopyWith<_RoleClaims> get copyWith => __$RoleClaimsCopyWithImpl<_RoleClaims>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoleClaimsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoleClaims&&(identical(other.role, role) || other.role == role)&&(identical(other.mechanicStatus, mechanicStatus) || other.mechanicStatus == mechanicStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,role,mechanicStatus);
}

@override
String toString() {
    return 'RoleClaims(role: $role, mechanicStatus: $mechanicStatus)';
}


}

/// @nodoc
abstract mixin class _$RoleClaimsCopyWith<$Res> implements $RoleClaimsCopyWith<$Res> {
  factory _$RoleClaimsCopyWith(_RoleClaims value, $Res Function(_RoleClaims) _then) = __$RoleClaimsCopyWithImpl;
@override @useResult
$Res call({
 Role? role, MechanicStatus? mechanicStatus
});




}
/// @nodoc
class __$RoleClaimsCopyWithImpl<$Res>
    implements _$RoleClaimsCopyWith<$Res> {
  __$RoleClaimsCopyWithImpl(this._self, this._then);

  final _RoleClaims _self;
  final $Res Function(_RoleClaims) _then;

/// Create a copy of RoleClaims
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = freezed,Object? mechanicStatus = freezed,}) {
  return _then(_RoleClaims(
role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role?,mechanicStatus: freezed == mechanicStatus ? _self.mechanicStatus : mechanicStatus // ignore: cast_nullable_to_non_nullable
as MechanicStatus?,
  ));
}


}

// dart format on
