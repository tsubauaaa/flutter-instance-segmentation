import 'dart:io' as io;
import 'dart:typed_data';

import 'package:app/providers/prediction_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:pytorch_mobile/enums/dtype.dart';
import 'package:pytorch_mobile/model.dart';
import 'package:pytorch_mobile/pytorch_mobile.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class Classifier {
  Classifier();

  Future<PredictionModel> classifyImage(XFile image) async {
    // Pickされた画像をinputにしてその画像内の0-9を返す

    // 画像をUint8Listにする
    var _file = io.File(image.path);
    img.Image? imageTemp = img.decodeImage(_file.readAsBytesSync());
    img.Image? resizedImg = img.copyResize(imageTemp!, height: 28, width: 28);
    var imgBytes = resizedImg.getBytes();
    var imgAsList = imgBytes.buffer.asUint8List();

    return getPrediction(imgAsList);
  }

  Future<PredictionModel> getPrediction(Uint8List imgAsList) async {
    // Uint8Listにした画像をmodelのinputにしてpredictionを得る

    // カメラ画像はRGBAなので、これをグレースケールにする。alphaを無視して、R.G.Bの平均の1チャンネルにする
    // 28 * 28 で初期値は0.0
    final resultBytes = List<double>.filled(28 * 28, 0.0, growable: false);

    // modelの入出力データをreshape
    var input = resultBytes.reshape([1, 28, 28, 1]);

    // 推論時間をTrackする
    int startTime = DateTime.now().millisecondsSinceEpoch;

    const pathCustomModel = "assets/models/model.pt";
    Model? _customModel;
    List? prediction;
    try {
      _customModel = await PyTorchMobile.loadModel(pathCustomModel);
      prediction = await _customModel!
          .getPrediction(input as List<double>, [224, 224], DType.float32);
    } catch (e) {
      debugPrint("Error loading model: $e");
    }

    int endTime = DateTime.now().millisecondsSinceEpoch;
    debugPrint("Inference took ${endTime - startTime} ms");

    debugPrint(prediction![0].toString());

    return PredictionModel(prediction![0]);
  }
}
