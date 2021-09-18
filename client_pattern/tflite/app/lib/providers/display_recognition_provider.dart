import 'dart:ui';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tflite_object_detection/models/recognition_model.dart';
import 'package:tflite_object_detection/providers/picked_image_provider.dart';
import 'package:tflite_object_detection/providers/tflite_service_provider.dart';

final displayRecognitionProvider =
    FutureProvider.autoDispose.family<List<RecognitionModel>?, Size>(
  (ref, size) async {
    final tfliteService = ref.read(tfliteServiceProvider);
    final image = ref.watch(pickedImageProvider);
    final imageSize = ref.read(pickedImageProvider.notifier).getImageSize();
    if (image == null || imageSize == null) return null;
    final recognitions = await tfliteService.classifyImage(image);
    if (recognitions == null) return null;
    double factorY = imageSize.height / imageSize.width * size.width;

    // Remove recognition with overlapping bounding boxes
    // _recognition is in descending order of confidence
    List<RecognitionModel> displayRecognitions =
        List<RecognitionModel>.from(recognitions);
    for (int i = 0; i < displayRecognitions.length; i++) {
      final targetY = displayRecognitions[i].rect.y;
      for (int j = 0; j < displayRecognitions.length; j++) {
        final comparisonY = displayRecognitions[j].rect.y;
        final diff = ((targetY - comparisonY) * factorY).abs();
        // TODO: 全く同じポイントがありそう
        if (diff != 0.0 && diff < 2.0) {
          displayRecognitions.remove(recognitions[j]);
        }
      }
    }
    return displayRecognitions;
  },
);
