import 'dart:ui';

import 'package:flutter/foundation.dart';
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
    List<RecognitionModel> displayRecognitions = [];
    List<List<RecognitionModel>> duplicateGroups = [];
    for (int i = 0; i < recognitions.length; i++) {
      bool isDup = false;
      List<RecognitionModel> group = [];
      var target = recognitions[i];
      for (int j = 0; j < recognitions.length; j++) {
        var comparison = recognitions[j];
        var diff = ((target.rect.y - comparison.rect.y) * factorY).abs();
        if (target.rect != comparison.rect && diff <= 2.0) {
          isDup = true;
          group.add(target);
          group.add(comparison);
        }
      }
      if (!isDup) {
        displayRecognitions.add(target);
        continue;
      }
      duplicateGroups.add(group);
    }

    if (duplicateGroups.isEmpty) return displayRecognitions;

    for (int i = 0; i < duplicateGroups.length; i++) {
      var target = duplicateGroups[i];
      for (int j = 0; j < duplicateGroups.length; j++) {
        var comparison = duplicateGroups[j];
        if (listEquals(target, comparison)) {
          duplicateGroups.removeAt(j);
        }
      }
    }

    print(duplicateGroups);

    for (var group in duplicateGroups) {
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
