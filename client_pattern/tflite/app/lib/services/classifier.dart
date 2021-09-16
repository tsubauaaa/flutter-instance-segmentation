import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'package:tflite_object_detection/providers/recognition_provider.dart';

class Classifier {
  Classifier();

  Future<RecognitionModel> classifyImage(XFile image) async {}

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

  Future predictImage(File image) async {
    loadModel();
    await yolov2Tiny(image);
  }

  Future<RecognitionModel> yolov2Tiny(File image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.detectObjectOnImage(
      path: image.path,
      model: "YOLO",
      imageMean: 0.0,
      imageStd: 255.0,
      numResultsPerClass: 100,
    );
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    debugPrint("Inference took ${endTime - startTime}ms");
    return RecognitionModel(-1);
  }
}
