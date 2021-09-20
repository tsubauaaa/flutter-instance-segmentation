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
      List<RecognitionModel> group = [];
      var target = recognitions[i];
      for (int j = 0; j < recognitions.length; j++) {
        var comparison = recognitions[j];
        var diff = ((target.rect.y - comparison.rect.y) * factorY).abs();
        if (target.rect != comparison.rect && diff <= 2.0) {
          group.add(target);
          group.add(comparison);
        }
      }
      if (group.isEmpty) {
        displayRecognitions.add(target);
        continue;
      }
      group = group.toSet().toList();
      group.sort((a, b) => a.rect.y.compareTo(b.rect.y));
      duplicateGroups.add(group);
    }

    if (duplicateGroups.isEmpty) return displayRecognitions;

    // Eliminate duplicate groups in duplicationGroup
    Set<List<RecognitionModel>> seens = {};
    List<List<RecognitionModel>> newDuplicateGroups = [];
    for (var group in duplicateGroups) {
      bool isSeen = false;
      for (var seen in seens) {
        if (listEquals(group, seen)) {
          isSeen = true;
        }
      }
      if (!isSeen) {
        newDuplicateGroups.add(group);
        seens.add(group);
      }
    }

    for (var group in newDuplicateGroups) {
      displayRecognitions.add(group[0]);
    }
    return displayRecognitions;
  },
);
