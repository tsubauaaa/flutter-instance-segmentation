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
    List<List<RecognitionModel>> duplicateGroups = [];
    for (int i = 0; i < recognitions.length; i++) {
      List<RecognitionModel> group = [];
      final target = recognitions[i];
      for (int j = 0; j < recognitions.length; j++) {
        final comparison = recognitions[j];
        final diff = ((target.rect.y - comparison.rect.y) * factorY).abs();
        if (target.rect != comparison.rect && diff <= 2.0) {
          group.add(comparison);
        }
      }
      duplicateGroups.add(group);
    }
    // print(duplicateGroups.length);
    // print(duplicateGroups.toSet().toList().length);
    if (duplicateGroups.isEmpty) return recognitions;

    List<RecognitionModel> displayRecognitions = [];
    for (var group in duplicateGroups.toSet().toList()) {
      displayRecognitions.add(group[0]);
    }

    // List<RecognitionModel> displayRecognitions =
    //     List<RecognitionModel>.from(recognitions);
    // for (int i = 0; i < displayRecognitions.length; i++) {
    //   final targetRect = displayRecognitions[i].rect;
    //   final targetY = targetRect.y;
    //   for (int j = 0; j < displayRecognitions.length; j++) {
    //     final comparisonRect = displayRecognitions[j].rect;
    //     final comparisonY = comparisonRect.y;
    //     final diff = ((targetY - comparisonY) * factorY).abs();
    //     if (targetRect != comparisonRect && diff <= 2.0) {
    //       displayRecognitions.remove(recognitions[j]);
    //     }
    //     print(displayRecognitions.length);
    //   }
    // }
    return displayRecognitions;
  },
);
