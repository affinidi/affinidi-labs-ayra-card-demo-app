// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vault_service_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VaultServiceState {

 Vault? get vault; Profile? get defaultProfile; List<DigitalCredential>? get claimedCredentials;
/// Create a copy of VaultServiceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VaultServiceStateCopyWith<VaultServiceState> get copyWith => _$VaultServiceStateCopyWithImpl<VaultServiceState>(this as VaultServiceState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VaultServiceState&&(identical(other.vault, vault) || other.vault == vault)&&(identical(other.defaultProfile, defaultProfile) || other.defaultProfile == defaultProfile)&&const DeepCollectionEquality().equals(other.claimedCredentials, claimedCredentials));
}


@override
int get hashCode => Object.hash(runtimeType,vault,defaultProfile,const DeepCollectionEquality().hash(claimedCredentials));

@override
String toString() {
  return 'VaultServiceState(vault: $vault, defaultProfile: $defaultProfile, claimedCredentials: $claimedCredentials)';
}


}

/// @nodoc
abstract mixin class $VaultServiceStateCopyWith<$Res>  {
  factory $VaultServiceStateCopyWith(VaultServiceState value, $Res Function(VaultServiceState) _then) = _$VaultServiceStateCopyWithImpl;
@useResult
$Res call({
 Vault? vault, Profile? defaultProfile, List<DigitalCredential>? claimedCredentials
});




}
/// @nodoc
class _$VaultServiceStateCopyWithImpl<$Res>
    implements $VaultServiceStateCopyWith<$Res> {
  _$VaultServiceStateCopyWithImpl(this._self, this._then);

  final VaultServiceState _self;
  final $Res Function(VaultServiceState) _then;

/// Create a copy of VaultServiceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vault = freezed,Object? defaultProfile = freezed,Object? claimedCredentials = freezed,}) {
  return _then(_self.copyWith(
vault: freezed == vault ? _self.vault : vault // ignore: cast_nullable_to_non_nullable
as Vault?,defaultProfile: freezed == defaultProfile ? _self.defaultProfile : defaultProfile // ignore: cast_nullable_to_non_nullable
as Profile?,claimedCredentials: freezed == claimedCredentials ? _self.claimedCredentials : claimedCredentials // ignore: cast_nullable_to_non_nullable
as List<DigitalCredential>?,
  ));
}

}


/// Adds pattern-matching-related methods to [VaultServiceState].
extension VaultServiceStatePatterns on VaultServiceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VaultServiceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VaultServiceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VaultServiceState value)  $default,){
final _that = this;
switch (_that) {
case _VaultServiceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VaultServiceState value)?  $default,){
final _that = this;
switch (_that) {
case _VaultServiceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Vault? vault,  Profile? defaultProfile,  List<DigitalCredential>? claimedCredentials)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VaultServiceState() when $default != null:
return $default(_that.vault,_that.defaultProfile,_that.claimedCredentials);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Vault? vault,  Profile? defaultProfile,  List<DigitalCredential>? claimedCredentials)  $default,) {final _that = this;
switch (_that) {
case _VaultServiceState():
return $default(_that.vault,_that.defaultProfile,_that.claimedCredentials);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Vault? vault,  Profile? defaultProfile,  List<DigitalCredential>? claimedCredentials)?  $default,) {final _that = this;
switch (_that) {
case _VaultServiceState() when $default != null:
return $default(_that.vault,_that.defaultProfile,_that.claimedCredentials);case _:
  return null;

}
}

}

/// @nodoc


class _VaultServiceState implements VaultServiceState {
   _VaultServiceState({this.vault, this.defaultProfile, final  List<DigitalCredential>? claimedCredentials}): _claimedCredentials = claimedCredentials;
  

@override final  Vault? vault;
@override final  Profile? defaultProfile;
 final  List<DigitalCredential>? _claimedCredentials;
@override List<DigitalCredential>? get claimedCredentials {
  final value = _claimedCredentials;
  if (value == null) return null;
  if (_claimedCredentials is EqualUnmodifiableListView) return _claimedCredentials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of VaultServiceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VaultServiceStateCopyWith<_VaultServiceState> get copyWith => __$VaultServiceStateCopyWithImpl<_VaultServiceState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VaultServiceState&&(identical(other.vault, vault) || other.vault == vault)&&(identical(other.defaultProfile, defaultProfile) || other.defaultProfile == defaultProfile)&&const DeepCollectionEquality().equals(other._claimedCredentials, _claimedCredentials));
}


@override
int get hashCode => Object.hash(runtimeType,vault,defaultProfile,const DeepCollectionEquality().hash(_claimedCredentials));

@override
String toString() {
  return 'VaultServiceState(vault: $vault, defaultProfile: $defaultProfile, claimedCredentials: $claimedCredentials)';
}


}

/// @nodoc
abstract mixin class _$VaultServiceStateCopyWith<$Res> implements $VaultServiceStateCopyWith<$Res> {
  factory _$VaultServiceStateCopyWith(_VaultServiceState value, $Res Function(_VaultServiceState) _then) = __$VaultServiceStateCopyWithImpl;
@override @useResult
$Res call({
 Vault? vault, Profile? defaultProfile, List<DigitalCredential>? claimedCredentials
});




}
/// @nodoc
class __$VaultServiceStateCopyWithImpl<$Res>
    implements _$VaultServiceStateCopyWith<$Res> {
  __$VaultServiceStateCopyWithImpl(this._self, this._then);

  final _VaultServiceState _self;
  final $Res Function(_VaultServiceState) _then;

/// Create a copy of VaultServiceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vault = freezed,Object? defaultProfile = freezed,Object? claimedCredentials = freezed,}) {
  return _then(_VaultServiceState(
vault: freezed == vault ? _self.vault : vault // ignore: cast_nullable_to_non_nullable
as Vault?,defaultProfile: freezed == defaultProfile ? _self.defaultProfile : defaultProfile // ignore: cast_nullable_to_non_nullable
as Profile?,claimedCredentials: freezed == claimedCredentials ? _self._claimedCredentials : claimedCredentials // ignore: cast_nullable_to_non_nullable
as List<DigitalCredential>?,
  ));
}


}

// dart format on
