// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

 String get name;/// 🔒 From Auth (E.164). Rules require it to equal the signed-in phone number.
 String get phone; Language get language;/// Max 3, E.164 phones.
 List<Contact> get emergencyContacts; String? get fcmToken; Consent? get consent;/// 🔒 Set by `requestAccountDeletion`.
@TimestampConverter() DateTime? get deletionRequestedAt;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt; int get schemaVersion;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppUser;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.language, _this.language) || other.language == _this.language)&&const DeepCollectionEquality().equals(other.emergencyContacts, _this.emergencyContacts)&&(identical(other.fcmToken, _this.fcmToken) || other.fcmToken == _this.fcmToken)&&(identical(other.consent, _this.consent) || other.consent == _this.consent)&&(identical(other.deletionRequestedAt, _this.deletionRequestedAt) || other.deletionRequestedAt == _this.deletionRequestedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppUser;
  return Object.hash(runtimeType,_this.name,_this.phone,_this.language,const DeepCollectionEquality().hash(_this.emergencyContacts),_this.fcmToken,_this.consent,_this.deletionRequestedAt,_this.createdAt,_this.updatedAt,_this.schemaVersion);
}

@override
String toString() {
  final _this = this as AppUser;
  return 'AppUser(name: ${_this.name}, phone: ${_this.phone}, language: ${_this.language}, emergencyContacts: ${_this.emergencyContacts}, fcmToken: ${_this.fcmToken}, consent: ${_this.consent}, deletionRequestedAt: ${_this.deletionRequestedAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, schemaVersion: ${_this.schemaVersion})';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String name, String phone, Language language, List<Contact> emergencyContacts, String? fcmToken, Consent? consent,@TimestampConverter() DateTime? deletionRequestedAt,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});


$ConsentCopyWith<$Res>? get consent;

}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? phone = null,Object? language = null,Object? emergencyContacts = null,Object? fcmToken = freezed,Object? consent = freezed,Object? deletionRequestedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(AppUser(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as Language,emergencyContacts: null == emergencyContacts ? _self.emergencyContacts : emergencyContacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,consent: freezed == consent ? _self.consent : consent // ignore: cast_nullable_to_non_nullable
as Consent?,deletionRequestedAt: freezed == deletionRequestedAt ? _self.deletionRequestedAt : deletionRequestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConsentCopyWith<$Res>? get consent {
    if (_self.consent == null) {
    return null;
  }

  return $ConsentCopyWith<$Res>(_self.consent!, (value) {
    return _then(_self.copyWith(consent: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String phone,  Language language,  List<Contact> emergencyContacts,  String? fcmToken,  Consent? consent, @TimestampConverter()  DateTime? deletionRequestedAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.name,_that.phone,_that.language,_that.emergencyContacts,_that.fcmToken,_that.consent,_that.deletionRequestedAt,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String phone,  Language language,  List<Contact> emergencyContacts,  String? fcmToken,  Consent? consent, @TimestampConverter()  DateTime? deletionRequestedAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.name,_that.phone,_that.language,_that.emergencyContacts,_that.fcmToken,_that.consent,_that.deletionRequestedAt,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String phone,  Language language,  List<Contact> emergencyContacts,  String? fcmToken,  Consent? consent, @TimestampConverter()  DateTime? deletionRequestedAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.name,_that.phone,_that.language,_that.emergencyContacts,_that.fcmToken,_that.consent,_that.deletionRequestedAt,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser implements AppUser {
  const _AppUser({required this.name, required this.phone, required this.language,  List<Contact> emergencyContacts = const <Contact>[], this.fcmToken, this.consent, @TimestampConverter() this.deletionRequestedAt, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, this.schemaVersion = kSchemaVersion}): _emergencyContacts = emergencyContacts;
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String name;
/// 🔒 From Auth (E.164). Rules require it to equal the signed-in phone number.
@override final  String phone;
@override final  Language language;
/// Max 3, E.164 phones.
 final  List<Contact> _emergencyContacts;
/// Max 3, E.164 phones.
@override@JsonKey() List<Contact> get emergencyContacts {
  if (_emergencyContacts is EqualUnmodifiableListView) return _emergencyContacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_emergencyContacts);
}

@override final  String? fcmToken;
@override final  Consent? consent;
/// 🔒 Set by `requestAccountDeletion`.
@override@TimestampConverter() final  DateTime? deletionRequestedAt;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@JsonKey() final  int schemaVersion;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.language, language) || other.language == language)&&const DeepCollectionEquality().equals(other.emergencyContacts, _emergencyContacts)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.consent, consent) || other.consent == consent)&&(identical(other.deletionRequestedAt, deletionRequestedAt) || other.deletionRequestedAt == deletionRequestedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,phone,language,const DeepCollectionEquality().hash(_emergencyContacts),fcmToken,consent,deletionRequestedAt,createdAt,updatedAt,schemaVersion);
}

@override
String toString() {
    return 'AppUser(name: $name, phone: $phone, language: $language, emergencyContacts: $emergencyContacts, fcmToken: $fcmToken, consent: $consent, deletionRequestedAt: $deletionRequestedAt, createdAt: $createdAt, updatedAt: $updatedAt, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String name, String phone, Language language, List<Contact> emergencyContacts, String? fcmToken, Consent? consent,@TimestampConverter() DateTime? deletionRequestedAt,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});


@override $ConsentCopyWith<$Res>? get consent;

}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? phone = null,Object? language = null,Object? emergencyContacts = null,Object? fcmToken = freezed,Object? consent = freezed,Object? deletionRequestedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(_AppUser(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as Language,emergencyContacts: null == emergencyContacts ? _self._emergencyContacts : emergencyContacts // ignore: cast_nullable_to_non_nullable
as List<Contact>,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,consent: freezed == consent ? _self.consent : consent // ignore: cast_nullable_to_non_nullable
as Consent?,deletionRequestedAt: freezed == deletionRequestedAt ? _self.deletionRequestedAt : deletionRequestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConsentCopyWith<$Res>? get consent {
    if (_self.consent == null) {
    return null;
  }

  return $ConsentCopyWith<$Res>(_self.consent!, (value) {
    return _then(_self.copyWith(consent: value));
  });
}
}


/// @nodoc
mixin _$Consent {

 String get version;@TimestampConverter() DateTime get acceptedAt;
/// Create a copy of Consent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsentCopyWith<Consent> get copyWith => _$ConsentCopyWithImpl<Consent>(this as Consent, _$identity);

  /// Serializes this Consent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Consent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Consent&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.acceptedAt, _this.acceptedAt) || other.acceptedAt == _this.acceptedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Consent;
  return Object.hash(runtimeType,_this.version,_this.acceptedAt);
}

@override
String toString() {
  final _this = this as Consent;
  return 'Consent(version: ${_this.version}, acceptedAt: ${_this.acceptedAt})';
}


}

/// @nodoc
abstract mixin class $ConsentCopyWith<$Res>  {
  factory $ConsentCopyWith(Consent value, $Res Function(Consent) _then) = _$ConsentCopyWithImpl;
@useResult
$Res call({
 String version,@TimestampConverter() DateTime acceptedAt
});




}
/// @nodoc
class _$ConsentCopyWithImpl<$Res>
    implements $ConsentCopyWith<$Res> {
  _$ConsentCopyWithImpl(this._self, this._then);

  final Consent _self;
  final $Res Function(Consent) _then;

/// Create a copy of Consent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? acceptedAt = null,}) {
  return _then(Consent(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,acceptedAt: null == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Consent].
extension ConsentPatterns on Consent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Consent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Consent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Consent value)  $default,){
final _that = this;
switch (_that) {
case _Consent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Consent value)?  $default,){
final _that = this;
switch (_that) {
case _Consent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version, @TimestampConverter()  DateTime acceptedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Consent() when $default != null:
return $default(_that.version,_that.acceptedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version, @TimestampConverter()  DateTime acceptedAt)  $default,) {final _that = this;
switch (_that) {
case _Consent():
return $default(_that.version,_that.acceptedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version, @TimestampConverter()  DateTime acceptedAt)?  $default,) {final _that = this;
switch (_that) {
case _Consent() when $default != null:
return $default(_that.version,_that.acceptedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Consent implements Consent {
  const _Consent({required this.version, @TimestampConverter() required this.acceptedAt});
  factory _Consent.fromJson(Map<String, dynamic> json) => _$ConsentFromJson(json);

@override final  String version;
@override@TimestampConverter() final  DateTime acceptedAt;

/// Create a copy of Consent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsentCopyWith<_Consent> get copyWith => __$ConsentCopyWithImpl<_Consent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConsentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Consent&&(identical(other.version, version) || other.version == version)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,version,acceptedAt);
}

@override
String toString() {
    return 'Consent(version: $version, acceptedAt: $acceptedAt)';
}


}

/// @nodoc
abstract mixin class _$ConsentCopyWith<$Res> implements $ConsentCopyWith<$Res> {
  factory _$ConsentCopyWith(_Consent value, $Res Function(_Consent) _then) = __$ConsentCopyWithImpl;
@override @useResult
$Res call({
 String version,@TimestampConverter() DateTime acceptedAt
});




}
/// @nodoc
class __$ConsentCopyWithImpl<$Res>
    implements _$ConsentCopyWith<$Res> {
  __$ConsentCopyWithImpl(this._self, this._then);

  final _Consent _self;
  final $Res Function(_Consent) _then;

/// Create a copy of Consent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? acceptedAt = null,}) {
  return _then(_Consent(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,acceptedAt: null == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Vehicle {

 VehicleType get type; String get brand; String get model;/// Normalised with `normalizeRegNo` (upper case, no spaces), Indian or BH series.
 String get regNo; Fuel get fuel; bool get isDefault;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt; int get schemaVersion;
/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleCopyWith<Vehicle> get copyWith => _$VehicleCopyWithImpl<Vehicle>(this as Vehicle, _$identity);

  /// Serializes this Vehicle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Vehicle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Vehicle&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.regNo, _this.regNo) || other.regNo == _this.regNo)&&(identical(other.fuel, _this.fuel) || other.fuel == _this.fuel)&&(identical(other.isDefault, _this.isDefault) || other.isDefault == _this.isDefault)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Vehicle;
  return Object.hash(runtimeType,_this.type,_this.brand,_this.model,_this.regNo,_this.fuel,_this.isDefault,_this.createdAt,_this.updatedAt,_this.schemaVersion);
}

@override
String toString() {
  final _this = this as Vehicle;
  return 'Vehicle(type: ${_this.type}, brand: ${_this.brand}, model: ${_this.model}, regNo: ${_this.regNo}, fuel: ${_this.fuel}, isDefault: ${_this.isDefault}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, schemaVersion: ${_this.schemaVersion})';
}


}

/// @nodoc
abstract mixin class $VehicleCopyWith<$Res>  {
  factory $VehicleCopyWith(Vehicle value, $Res Function(Vehicle) _then) = _$VehicleCopyWithImpl;
@useResult
$Res call({
 VehicleType type, String brand, String model, String regNo, Fuel fuel, bool isDefault,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});




}
/// @nodoc
class _$VehicleCopyWithImpl<$Res>
    implements $VehicleCopyWith<$Res> {
  _$VehicleCopyWithImpl(this._self, this._then);

  final Vehicle _self;
  final $Res Function(Vehicle) _then;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? brand = null,Object? model = null,Object? regNo = null,Object? fuel = null,Object? isDefault = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(Vehicle(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as VehicleType,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,regNo: null == regNo ? _self.regNo : regNo // ignore: cast_nullable_to_non_nullable
as String,fuel: null == fuel ? _self.fuel : fuel // ignore: cast_nullable_to_non_nullable
as Fuel,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Vehicle].
extension VehiclePatterns on Vehicle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Vehicle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Vehicle value)  $default,){
final _that = this;
switch (_that) {
case _Vehicle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Vehicle value)?  $default,){
final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VehicleType type,  String brand,  String model,  String regNo,  Fuel fuel,  bool isDefault, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
return $default(_that.type,_that.brand,_that.model,_that.regNo,_that.fuel,_that.isDefault,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VehicleType type,  String brand,  String model,  String regNo,  Fuel fuel,  bool isDefault, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _Vehicle():
return $default(_that.type,_that.brand,_that.model,_that.regNo,_that.fuel,_that.isDefault,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VehicleType type,  String brand,  String model,  String regNo,  Fuel fuel,  bool isDefault, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt,  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
return $default(_that.type,_that.brand,_that.model,_that.regNo,_that.fuel,_that.isDefault,_that.createdAt,_that.updatedAt,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Vehicle implements Vehicle {
  const _Vehicle({required this.type, required this.brand, required this.model, required this.regNo, required this.fuel, this.isDefault = false, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, this.schemaVersion = kSchemaVersion});
  factory _Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);

@override final  VehicleType type;
@override final  String brand;
@override final  String model;
/// Normalised with `normalizeRegNo` (upper case, no spaces), Indian or BH series.
@override final  String regNo;
@override final  Fuel fuel;
@override@JsonKey() final  bool isDefault;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@JsonKey() final  int schemaVersion;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleCopyWith<_Vehicle> get copyWith => __$VehicleCopyWithImpl<_Vehicle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Vehicle&&(identical(other.type, type) || other.type == type)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.regNo, regNo) || other.regNo == regNo)&&(identical(other.fuel, fuel) || other.fuel == fuel)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,brand,model,regNo,fuel,isDefault,createdAt,updatedAt,schemaVersion);
}

@override
String toString() {
    return 'Vehicle(type: $type, brand: $brand, model: $model, regNo: $regNo, fuel: $fuel, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$VehicleCopyWith<$Res> implements $VehicleCopyWith<$Res> {
  factory _$VehicleCopyWith(_Vehicle value, $Res Function(_Vehicle) _then) = __$VehicleCopyWithImpl;
@override @useResult
$Res call({
 VehicleType type, String brand, String model, String regNo, Fuel fuel, bool isDefault,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt, int schemaVersion
});




}
/// @nodoc
class __$VehicleCopyWithImpl<$Res>
    implements _$VehicleCopyWith<$Res> {
  __$VehicleCopyWithImpl(this._self, this._then);

  final _Vehicle _self;
  final $Res Function(_Vehicle) _then;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? brand = null,Object? model = null,Object? regNo = null,Object? fuel = null,Object? isDefault = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? schemaVersion = null,}) {
  return _then(_Vehicle(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as VehicleType,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,regNo: null == regNo ? _self.regNo : regNo // ignore: cast_nullable_to_non_nullable
as String,fuel: null == fuel ? _self.fuel : fuel // ignore: cast_nullable_to_non_nullable
as Fuel,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
