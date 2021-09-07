import 'dart:io' as io;
import 'dart:typed_data';

import 'package:app/providers/prediction_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
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
    final resultBytes = List.filled(28 * 28, 0.0, growable: false);
    int index = 0;
    for (int i = 0; i < imgAsList.lengthInBytes; i += 4) {
      final r = imgAsList[i];
      final g = imgAsList[i + 1];
      final b = imgAsList[i + 2];

      // R,G,Bチャンネルの平均を1チャンネルのグレースケールに変換する
      resultBytes[index] = ((r + g + b) / 3.0) / 255.0;
      index++;
    }

    // modelの入出力データをreshape
    var input = resultBytes.reshape([1, 28, 28, 1]);
    var output = List.filled(1 * 10, 0.0, growable: false).reshape([1, 10]);

    // GPUDelegate, NNAPI, parallel cores などのオプションも設定可能
    InterpreterOptions interpreterOptions = InterpreterOptions();

    // 推論時間をTrackする
    int startTime = DateTime.now().millisecondsSinceEpoch;

    try {
      Interpreter interpreter = await Interpreter.fromAsset(
          "models/model.tflite",
          options: interpreterOptions);
      interpreter.run(input, output);
    } catch (e) {
      debugPrint("Error loading model: $e");
    }

    int endTime = DateTime.now().millisecondsSinceEpoch;
    debugPrint("Inference took ${endTime - startTime} ms");

    double highestProb = 0;
    int digitPrediction = -1;

    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > highestProb) {
        highestProb = output[0][i];
        digitPrediction = i;
      }
    }
    return PredictionModel(digitPrediction);
  }
}
