// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'prediction_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PredictionResultModel _$PredictionResultModelFromJson(
    Map<String, dynamic> json) {
  return _PredictionResultModel.fromJson(json);
}

/// @nodoc
class _$PredictionResultModelTearOff {
  const _$PredictionResultModelTearOff();

  _PredictionResultModel call(
      {int? numberOfBooks, String? image, String? mime}) {
    return _PredictionResultModel(
      numberOfBooks: numberOfBooks,
      image: image,
      mime: mime,
    );
  }

  PredictionResultModel fromJson(Map<String, Object> json) {
    return PredictionResultModel.fromJson(json);
  }
}

/// @nodoc
const $PredictionResultModel = _$PredictionResultModelTearOff();

/// @nodoc
mixin _$PredictionResultModel {
  int? get numberOfBooks => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  String? get mime => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PredictionResultModelCopyWith<PredictionResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredictionResultModelCopyWith<$Res> {
  factory $PredictionResultModelCopyWith(PredictionResultModel value,
          $Res Function(PredictionResultModel) then) =
      _$PredictionResultModelCopyWithImpl<$Res>;
  $Res call({int? numberOfBooks, String? image, String? mime});
}

/// @nodoc
class _$PredictionResultModelCopyWithImpl<$Res>
    implements $PredictionResultModelCopyWith<$Res> {
  _$PredictionResultModelCopyWithImpl(this._value, this._then);

  final PredictionResultModel _value;
  // ignore: unused_field
  final $Res Function(PredictionResultModel) _then;

  @override
  $Res call({
    Object? numberOfBooks = freezed,
    Object? image = freezed,
    Object? mime = freezed,
  }) {
    return _then(_value.copyWith(
      numberOfBooks: numberOfBooks == freezed
          ? _value.numberOfBooks
          : numberOfBooks // ignore: cast_nullable_to_non_nullable
              as int?,
      image: image == freezed
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      mime: mime == freezed
          ? _value.mime
          : mime // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$PredictionResultModelCopyWith<$Res>
    implements $PredictionResultModelCopyWith<$Res> {
  factory _$PredictionResultModelCopyWith(_PredictionResultModel value,
          $Res Function(_PredictionResultModel) then) =
      __$PredictionResultModelCopyWithImpl<$Res>;
  @override
  $Res call({int? numberOfBooks, String? image, String? mime});
}

/// @nodoc
class __$PredictionResultModelCopyWithImpl<$Res>
    extends _$PredictionResultModelCopyWithImpl<$Res>
    implements _$PredictionResultModelCopyWith<$Res> {
  __$PredictionResultModelCopyWithImpl(_PredictionResultModel _value,
      $Res Function(_PredictionResultModel) _then)
      : super(_value, (v) => _then(v as _PredictionResultModel));

  @override
  _PredictionResultModel get _value => super._value as _PredictionResultModel;

  @override
  $Res call({
    Object? numberOfBooks = freezed,
    Object? image = freezed,
    Object? mime = freezed,
  }) {
    return _then(_PredictionResultModel(
      numberOfBooks: numberOfBooks == freezed
          ? _value.numberOfBooks
          : numberOfBooks // ignore: cast_nullable_to_non_nullable
              as int?,
      image: image == freezed
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      mime: mime == freezed
          ? _value.mime
          : mime // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PredictionResultModel
    with DiagnosticableTreeMixin
    implements _PredictionResultModel {
  _$_PredictionResultModel({this.numberOfBooks, this.image, this.mime});

  factory _$_PredictionResultModel.fromJson(Map<String, dynamic> json) =>
      _$$_PredictionResultModelFromJson(json);

  @override
  final int? numberOfBooks;
  @override
  final String? image;
  @override
  final String? mime;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PredictionResultModel(numberOfBooks: $numberOfBooks, image: $image, mime: $mime)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PredictionResultModel'))
      ..add(DiagnosticsProperty('numberOfBooks', numberOfBooks))
      ..add(DiagnosticsProperty('image', image))
      ..add(DiagnosticsProperty('mime', mime));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _PredictionResultModel &&
            (identical(other.numberOfBooks, numberOfBooks) ||
                const DeepCollectionEquality()
                    .equals(other.numberOfBooks, numberOfBooks)) &&
            (identical(other.image, image) ||
                const DeepCollectionEquality().equals(other.image, image)) &&
            (identical(other.mime, mime) ||
                const DeepCollectionEquality().equals(other.mime, mime)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(numberOfBooks) ^
      const DeepCollectionEquality().hash(image) ^
      const DeepCollectionEquality().hash(mime);

  @JsonKey(ignore: true)
  @override
  _$PredictionResultModelCopyWith<_PredictionResultModel> get copyWith =>
      __$PredictionResultModelCopyWithImpl<_PredictionResultModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PredictionResultModelToJson(this);
  }
}

abstract class _PredictionResultModel implements PredictionResultModel {
  factory _PredictionResultModel(
      {int? numberOfBooks,
      String? image,
      String? mime}) = _$_PredictionResultModel;

  factory _PredictionResultModel.fromJson(Map<String, dynamic> json) =
      _$_PredictionResultModel.fromJson;

  @override
  int? get numberOfBooks => throw _privateConstructorUsedError;
  @override
  String? get image => throw _privateConstructorUsedError;
  @override
  String? get mime => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$PredictionResultModelCopyWith<_PredictionResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}
