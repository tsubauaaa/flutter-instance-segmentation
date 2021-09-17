import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_object_detection/models/recognition_model.dart';
import 'package:tflite_object_detection/providers/picked_image_provider.dart';
import 'package:tflite_object_detection/providers/recognition_provider.dart';

class CountPage extends HookConsumerWidget {
  const CountPage([Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;
    final pickedImageState = ref.watch(pickedImageProvider);
    final imageSize = ref.read(pickedImageProvider.notifier).getImageSize();
    final recognitionsState = ref.watch(recognitionProvider);
    final ImagePicker _picker = ImagePicker();

    return Scaffold(
      backgroundColor: Colors.black,
      body: recognitionsState.when(
        data: (recognitions) {
          if (pickedImageState == null ||
              imageSize == null ||
              recognitions == null) {
            return Center(
              child: Container(
                margin: EdgeInsets.only(top: size.height / 2 - 140),
                child: const Icon(
                  Icons.image_rounded,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            );
          }
          List<Widget> stackChildren = [];
          stackChildren.add(
            Positioned(
              top: 0.0,
              left: 0.0,
              width: size.width,
              child: Image.file(pickedImageState),
            ),
          );
          double factorX = size.width;
          double factorY = imageSize.height / imageSize.width * size.width;

          // Remove recognition with overlapping bounding boxes
          // _recognition is in descending order of confidence
          List<RecognitionModel> displayRecognitions =
              List<RecognitionModel>.from(recognitions);
          for (int i = 0; i < displayRecognitions.length; i++) {
            final targetY = displayRecognitions[i].rect.y;
            for (int j = 0; j < displayRecognitions.length; j++) {
              final comparisonY = displayRecognitions[j].rect.y;
              final diff = ((targetY - comparisonY) * factorY).abs();
              if (diff != 0.0 && diff < 2.0) {
                displayRecognitions.remove(recognitions[j]);
              }
            }
          }
          stackChildren.addAll(displayRecognitions.map(
            (re) {
              return Positioned(
                left: re.rect.x * factorX,
                top: re.rect.y * factorY,
                width: re.rect.w * factorX,
                height: re.rect.h * factorY,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    border: Border.all(
                      color: Colors.yellow,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    "${re.detectedClass} ${(re.confidenceInClass * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      background: Paint()..color = Colors.yellow,
                      color: Colors.black,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              );
            },
          ).toList());
          return Container(
            margin: const EdgeInsets.only(top: 50),
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Stack(
                    children: stackChildren,
                  ),
                ),
                // if (_displayRecognitions != null)
                //   Text(
                //     _displayRecognitions!.length.toString(),
                //     style: const TextStyle(
                //       color: Colors.white,
                //       fontSize: 88,
                //     ),
                //   ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text(err.toString()),
        ),
      ),
      floatingActionButton: InkWell(
        onLongPress: () async {
          final XFile? pickedFile =
              await _picker.pickImage(source: ImageSource.gallery);
          if (pickedFile == null) return;
          ref.read(pickedImageProvider.notifier).update(pickedFile);
        },
        child: FloatingActionButton(
          onPressed: () async {
            final XFile? pickedFile =
                await _picker.pickImage(source: ImageSource.camera);
            if (pickedFile == null) return;
            ref.read(pickedImageProvider.notifier).update(pickedFile);
          },
          child: const Icon(Icons.camera),
        ),
      ),
    );
  }
}
