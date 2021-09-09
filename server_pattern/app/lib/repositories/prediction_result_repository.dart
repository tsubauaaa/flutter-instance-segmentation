import 'dart:convert';

import 'package:app/models/prediction_result_model.dart';
import 'package:app/services/api_service.dart';

class PredictionResultRepository {
  PredictionResultRepository(this.apiService);
  final APIService apiService;

  Future<PredictionResultModel?> fetchPredictionResult(
      String imageString) async {
    final responseBody = await apiService.postInferenceServer(imageString);
    try {
      final decodedJson = json.decode(responseBody);
      return PredictionResultModel.fromJson(decodedJson);
    } on Exception catch (error) {
      throw Exception('Json decode error: $error');
    }
  }
}
