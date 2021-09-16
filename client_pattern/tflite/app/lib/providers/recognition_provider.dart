import 'package:hooks_riverpod/hooks_riverpod.dart';

final recognitionProvider =
    StateNotifierProvider<RecognitionController, RecognitionModel?>(
  (ref) => RecognitionController(),
);

class RecognitionController extends StateNotifier<RecognitionModel?> {
  RecognitionController() : super(null);

  update(recognition) => state = recognition;
}

class RecognitionModel {
  RecognitionModel(this.rect, this.confidenceInClass, this.detectedClass);
  Rectangle rect;
  double confidenceInClass;
  String detectedClass;
}

class Rectangle {
  Rectangle(this.w, this.x, this.h, this.y);
  double w;
  double x;
  double h;
  double y;
}
