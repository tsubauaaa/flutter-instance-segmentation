import 'package:app/providers/api_service_provider.dart';
import 'package:app/repositories/prediction_result_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final predictionResultRepositoryProvider = Provider.autoDispose(
  (ref) => PredictionResultRepository(
    ref.read(apiServiceProvider),
  ),
);
