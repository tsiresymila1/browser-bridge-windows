// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'args.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JsArgs {
  String get method;
  Map<String, dynamic> get args;

  /// Create a copy of JsArgs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $JsArgsCopyWith<JsArgs> get copyWith =>
      _$JsArgsCopyWithImpl<JsArgs>(this as JsArgs, _$identity);

  /// Serializes this JsArgs to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is JsArgs &&
            (identical(other.method, method) || other.method == method) &&
            const DeepCollectionEquality().equals(other.args, args));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, method, const DeepCollectionEquality().hash(args));

  @override
  String toString() {
    return 'JsArgs(method: $method, args: $args)';
  }
}

/// @nodoc
abstract mixin class $JsArgsCopyWith<$Res> {
  factory $JsArgsCopyWith(JsArgs value, $Res Function(JsArgs) _then) =
      _$JsArgsCopyWithImpl;
  @useResult
  $Res call({String method, Map<String, dynamic> args});
}

/// @nodoc
class _$JsArgsCopyWithImpl<$Res> implements $JsArgsCopyWith<$Res> {
  _$JsArgsCopyWithImpl(this._self, this._then);

  final JsArgs _self;
  final $Res Function(JsArgs) _then;

  /// Create a copy of JsArgs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? method = null,
    Object? args = null,
  }) {
    return _then(_self.copyWith(
      method: null == method
          ? _self.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      args: null == args
          ? _self.args
          : args // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// Adds pattern-matching-related methods to [JsArgs].
extension JsArgsPatterns on JsArgs {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_JsArgs value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _JsArgs() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_JsArgs value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _JsArgs():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_JsArgs value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _JsArgs() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String method, Map<String, dynamic> args)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _JsArgs() when $default != null:
        return $default(_that.method, _that.args);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String method, Map<String, dynamic> args) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _JsArgs():
        return $default(_that.method, _that.args);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String method, Map<String, dynamic> args)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _JsArgs() when $default != null:
        return $default(_that.method, _that.args);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _JsArgs implements JsArgs {
  const _JsArgs(
      {required this.method, final Map<String, dynamic> args = const {}})
      : _args = args;
  factory _JsArgs.fromJson(Map<String, dynamic> json) => _$JsArgsFromJson(json);

  @override
  final String method;
  final Map<String, dynamic> _args;
  @override
  @JsonKey()
  Map<String, dynamic> get args {
    if (_args is EqualUnmodifiableMapView) return _args;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_args);
  }

  /// Create a copy of JsArgs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$JsArgsCopyWith<_JsArgs> get copyWith =>
      __$JsArgsCopyWithImpl<_JsArgs>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$JsArgsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _JsArgs &&
            (identical(other.method, method) || other.method == method) &&
            const DeepCollectionEquality().equals(other._args, _args));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, method, const DeepCollectionEquality().hash(_args));

  @override
  String toString() {
    return 'JsArgs(method: $method, args: $args)';
  }
}

/// @nodoc
abstract mixin class _$JsArgsCopyWith<$Res> implements $JsArgsCopyWith<$Res> {
  factory _$JsArgsCopyWith(_JsArgs value, $Res Function(_JsArgs) _then) =
      __$JsArgsCopyWithImpl;
  @override
  @useResult
  $Res call({String method, Map<String, dynamic> args});
}

/// @nodoc
class __$JsArgsCopyWithImpl<$Res> implements _$JsArgsCopyWith<$Res> {
  __$JsArgsCopyWithImpl(this._self, this._then);

  final _JsArgs _self;
  final $Res Function(_JsArgs) _then;

  /// Create a copy of JsArgs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? method = null,
    Object? args = null,
  }) {
    return _then(_JsArgs(
      method: null == method
          ? _self.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      args: null == args
          ? _self._args
          : args // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

// dart format on
