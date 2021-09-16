import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

const String ssd = "SSD MobileNet";
const String yolo = "Tiny YOLOv2";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage([Key? key]) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  List? _recognitions;
  bool selection = false;
  double? _imageHeight;
  double? _imageWidth;
  ImagePicker? imagePicker;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  _imgFromCamera() async {
    XFile? pickedFile =
        await imagePicker!.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;
    File image = File(pickedFile.path);
    predictImage(image);
  }

  _imgFromGallery() async {
    XFile? pickedFile =
        await imagePicker!.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    File image = File(pickedFile.path);
    predictImage(image);
  }

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

    new FileImage(image).resolve(new ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          setState(
            () {
              _imageHeight = info.image.height.toDouble();
              _imageWidth = info.image.width.toDouble();
            },
          );
        },
      ),
    );

    setState(
      () {
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
                    )))
            : Image.file(_image!),
      ),
    );
    stackChildren.addAll(renderBoxes(size));
    stackChildren.add(
      Container(
        height: size.height,
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                onPressed: _imgFromCamera,
                child: Icon(
                  Icons.camera,
                  color: Colors.black,
                ),
                color: Colors.white,
              ),
              RaisedButton(
                onPressed: _imgFromGallery,
                child: Icon(
                  Icons.image,
                  color: Colors.black,
                ),
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        margin: EdgeInsets.only(top: 50),
        color: Colors.black,
        child: Stack(
          children: stackChildren,
        ),
      ),
    );
  }
}
