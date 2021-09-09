import 'package:app/models/prediction_result_model.dart';
import 'package:app/providers/picked_image_string_provider.dart';
import 'package:app/providers/prediction_result_repository_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final predictionResultProvider =
    FutureProvider.autoDispose<PredictionResultModel?>(
  (ref) async {
    final repository = ref.read(predictionResultRepositoryProvider);
    final imageString = ref.watch(pickedImageStringProvider);
    if (imageString == null) return null;

    return repository.fetchPredictionResult(imageString);
  },
);
