import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/recognition_model.dart';
import 'd2go_service_provider.dart';
import 'picked_image_provider.dart';

final displayRecognitionProvider =
    FutureProvider.autoDispose.family<List<RecognitionModel>?, Size>(
  (ref, size) async {
    final d2goService = ref.read(d2goServiceProvider);
    final image = ref.watch(pickedImageProvider);
    final imageSize = ref.read(pickedImageProvider.notifier).getImageSize();
    if (image == null || imageSize == null) return null;
    final recognitions = await d2goService.classifyImage(image);
    if (recognitions == null) return null;
    double factorY = imageSize.height / imageSize.width * size.width;

    // Remove recognition with overlapping bounding boxes
    // _recognition is in descending order of confidence
    List<RecognitionModel> displayRecognitions = [];
    List<List<RecognitionModel>> duplicateGroups = [];
    for (RecognitionModel target in recognitions) {
      List<RecognitionModel> group = [];
      for (RecognitionModel comparison in recognitions) {
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
      // Eliminate duplicates within group, then sort group by rectangle y
      group = group.toSet().toList();
      group.sort((a, b) => a.rect.y.compareTo(b.rect.y));

      duplicateGroups.add(group);
    }

    if (duplicateGroups.isEmpty) return displayRecognitions;

    // Eliminate duplicate groups in duplicationGroup
    // and add the first of a no duplicate group to displayRecognitions
    Set<List<RecognitionModel>> seen = {};
    for (List<RecognitionModel> group in duplicateGroups) {
      bool hasSeen = false;
      for (List<RecognitionModel> seenGroup in seen) {
        if (listEquals(group, seenGroup)) hasSeen = true;
      }
      if (hasSeen) continue;

      displayRecognitions.add(group.first);
      seen.add(group);
    }

    return displayRecognitions;
  },
);
