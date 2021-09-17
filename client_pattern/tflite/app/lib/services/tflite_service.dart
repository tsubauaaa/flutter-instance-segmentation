import 'dart:io';

import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'package:tflite_object_detection/models/recognition_model.dart';

class TfliteService {
  TfliteService();

  List<RecognitionModel> recognitions = [];

  Future loadModel() async {
    Tflite.close();
    try {
      String? res = await Tflite.loadModel(
        model: "assets/tiny-yolo-book.tflite",
        labels: "assets/tiny-yolo-book.txt",
      );
      print(res);
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Future<List<RecognitionModel>> classifyImage(File image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitionList = await Tflite.detectObjectOnImage(
      path: image.path,
      model: "YOLO",
      imageMean: 0.0,
      imageStd: 255.0,
      numResultsPerClass: 100,
    );
    if (recognitionList != null && recognitionList.isEmpty) {
      recognitions = recognitionList
          .map(
            (e) => RecognitionModel(
                e['rect'], e['confidenceInClass'], e['detectedClass']),
          )
          .toList();
    }
    int endTime = DateTime.now().millisecondsSinceEpoch;
    debugPrint("Inference took ${endTime - startTime}ms");
    return recognitions;
  }
}
