import 'dart:io';

import 'package:app/models/recognition_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_d2go/flutter_d2go.dart';

class D2GoService {
  D2GoService();

  List<RecognitionModel>? recognitions;

  Future<List<RecognitionModel>?> classifyImage(File image) async {
    String modelPath = 'assets/models/d2go.pt';
    String labelPath = 'assets/models/classes.txt';

    try {
      await FlutterD2go.loadModel(modelPath: modelPath, labelPath: labelPath);
    } on PlatformException {
      debugPrint('only supported for android and ios so far');
    }

    int startTime = DateTime.now().millisecondsSinceEpoch;

    var recognitionList = await FlutterD2go.getImagePrediction(image: image);

    if (recognitionList.isNotEmpty) {
      recognitions = recognitionList
          .map(
            (e) => RecognitionModel(
                Rectangle(
                  e['rect']['left'],
                  e['rect']['top'],
                  e['rect']['right'],
                  e['rect']['bottom'],
                ),
                e['confidenceInClass'],
                e['detectedClass']),
          )
          .toList();
    }

    int endTime = DateTime.now().millisecondsSinceEpoch;
    debugPrint("Inference took ${endTime - startTime}ms");
    if (recognitions == null) return null;
    return recognitions;
  }
}
