import 'package:app/models/recognition_model.dart';
import 'package:flutter/material.dart';

class RectanglesContainers extends StatelessWidget {
  const RectanglesContainers({
    Key? key,
    required this.factorX,
    required this.factorY,
    required this.recognition,
  }) : super(key: key);

  final double factorX;
  final double factorY;
  final RecognitionModel recognition;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: recognition.rect.x * factorX,
      top: recognition.rect.y * factorY,
      width: recognition.rect.w * factorX,
      height: recognition.rect.h * factorY,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          border: Border.all(
            color: Colors.yellow,
            width: 2,
          ),
        ),
        child: Text(
          "${recognition.detectedClass} ${(recognition.confidenceInClass * 100).toStringAsFixed(0)}%",
          style: TextStyle(
            background: Paint()..color = Colors.yellow,
            color: Colors.black,
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }
}
