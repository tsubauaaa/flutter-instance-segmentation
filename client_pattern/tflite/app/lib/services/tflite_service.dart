import 'dart:io';

import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'package:tflite_object_detection/models/recognition_model.dart';

class TfliteService {
  TfliteService();

  List<RecognitionModel>? recognitions;

  Future loadModel() async {
    Tflite.close();
    try {
      String? res = await Tflite.loadModel(
        model: "assets/models/tiny-yolo-book.tflite",
        labels: "assets/models/tiny-yolo-book.txt",
      );
      print(res);
    } catch (e) {
      debugPrint('Failed to load model. $e');
    }
  }

  Future<List<RecognitionModel>?> classifyImage(File image) async {
    loadModel();
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitionList = await Tflite.detectObjectOnImage(
      path: image.path,
      model: "YOLO",
      imageMean: 0.0,
      imageStd: 255.0,
      numResultsPerClass: 100,
    );
    if (recognitionList != null && recognitionList.isNotEmpty) {
      recognitions = recognitionList
          .map(
            (e) => RecognitionModel(
                Rectangle(
                  e['rect']['w'],
                  e['rect']['x'],
                  e['rect']['h'],
                  e['rect']['y'],
                ),
                e['confidenceInClass'],
                e['detectedClass']),
          )
          .toList();
    }

    int endTime = DateTime.now().millisecondsSinceEpoch;
    debugPrint("Inference took ${endTime - startTime}ms");
    if (recognitions == null) return null;
    return recognitions!;
  }
}
