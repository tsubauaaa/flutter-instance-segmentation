import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class CountPage extends StatefulWidget {
  CountPage([Key? key]) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<CountPage> {
  File? _image;
  List? _recognitions;
  double? _imageHeight;
  double? _imageWidth;

  Future loadModel() async {
    Tflite.close();
    try {
      String? res = await Tflite.loadModel(
        model: "assets/models/tiny-yolo-book.tflite",
        labels: "assets/models/tiny-yolo-book.txt",
      );
      print(res);
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Future predictImage(File image) async {
    loadModel();
    await yolov2Tiny(image);
    final decodedImage = await decodeImageFromList(image.readAsBytesSync());
    setState(
      () {
        _imageHeight = decodedImage.height.toDouble();
        _imageWidth = decodedImage.width.toDouble();
        _image = image;
      },
    );
  }

  Future yolov2Tiny(File image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.detectObjectOnImage(
      path: image.path,
      model: "YOLO",
      imageMean: 0.0,
      imageStd: 255.0,
      numResultsPerClass: 100,
    );
    setState(
      () {
        _recognitions = recognitions;
      },
    );
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    debugPrint("Inference took ${endTime - startTime}ms");
  }

  List<Widget> renderBoxes(Size screen) {
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];
    double factorX = screen.width;
    double factorY = _imageHeight! / _imageWidth! * screen.width;

    // Remove recognition with overlapping bounding boxes
    // _recognition is in descending order of confidence
    List<dynamic> displayRecognitions = List<dynamic>.from(_recognitions!);
    for (int i = 0; i < displayRecognitions.length; i++) {
      final targetY = displayRecognitions[i]['rect']['y'];
      for (int j = 0; j < displayRecognitions.length; j++) {
        final comparisonY = displayRecognitions[j]['rect']['y'];
        final diff = ((targetY - comparisonY) * factorY).abs();
        if (diff != 0.0 && diff < 2.0) {
          displayRecognitions.remove(_recognitions![j]);
        }
      }
    }

    return displayRecognitions.map(
      (re) {
        return Positioned(
          left: re["rect"]["x"] * factorX,
          top: re["rect"]["y"] * factorY,
          width: re["rect"]["w"] * factorX,
          height: re["rect"]["h"] * factorY,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              border: Border.all(
                color: Colors.yellow,
                width: 2,
              ),
            ),
            child: Text(
              "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                background: Paint()..color = Colors.yellow,
                color: Colors.black,
                fontSize: 15.0,
              ),
            ),
          ),
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ImagePicker _picker = ImagePicker();
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    stackChildren.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        child: _image == null
            ? Center(
                child: Container(
                  margin: EdgeInsets.only(top: size.height / 2 - 140),
                  child: Icon(
                    Icons.image_rounded,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
              )
            : Image.file(_image!),
      ),
    );
    stackChildren.addAll(renderBoxes(size));
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        margin: EdgeInsets.only(top: 50),
        color: Colors.black,
        child: Stack(
          children: stackChildren,
        ),
      ),
      floatingActionButton: InkWell(
        onLongPress: () async {
          final XFile? pickedFile =
              await _picker.pickImage(source: ImageSource.gallery);
          if (pickedFile == null) return;
          File image = File(pickedFile.path);
          predictImage(image);
          // ref.read(pickedImageStringProvider.notifier).update(image);
        },
        child: FloatingActionButton(
          onPressed: () async {
            final XFile? pickedFile =
                await _picker.pickImage(source: ImageSource.camera);
            if (pickedFile == null) return;
            File image = File(pickedFile.path);
            predictImage(image);
            // ref.read(pickedImageStringProvider.notifier).update(image);
          },
          child: const Icon(Icons.camera),
        ),
      ),
    );
  }
}
