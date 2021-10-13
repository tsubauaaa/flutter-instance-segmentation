import 'dart:io';

import 'package:app/models/recognition_model.dart';
import 'package:app/plugins/d2go_model.dart';
import 'package:app/plugins/flutter_d2go.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class D2GoService {
  D2GoService();

  List<RecognitionModel>? recognitions;

  D2GoModel? _d2Model;

  Future<List<RecognitionModel>?> classifyImage(File image) async {
    String pathD2Model = 'assets/models/d2go.pt';
    try {
      _d2Model = await FlutterD2Go.loadModel(pathD2Model);
    } on PlatformException {
      debugPrint('only supported for android and ios so far');
    }

    int startTime = DateTime.now().millisecondsSinceEpoch;

    var recognitionList = await _d2Model!.getPredictionD2Go(image: image);

    if (recognitionList != null && recognitionList.isNotEmpty) {
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
