import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'prediction_result_model.freezed.dart';
part 'prediction_result_model.g.dart';

@freezed
class PredictionResultModel with _$PredictionResultModel {
  factory PredictionResultModel({
    int? numberOfBooks,
    String? image,
    String? mime,
  }) = _PredictionResultModel;

  factory PredictionResultModel.fromJson(Map<String, dynamic> json) =>
      _$PredictionResultModelFromJson(json);
}
