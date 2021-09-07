import 'package:hooks_riverpod/hooks_riverpod.dart';

final recognitionProvider =
    StateNotifierProvider<RecognitionController, RecognitionModel>(
  (ref) => RecognitionController(),
);

class RecognitionController extends StateNotifier<RecognitionModel> {
  RecognitionController() : super(RecognitionModel(-1));

  update(recognition) => state = recognition;
}

class RecognitionModel {
  RecognitionModel(this.digit);
  int digit;
}
