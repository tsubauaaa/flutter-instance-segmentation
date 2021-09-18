import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_object_detection/components/rectangles_containers.dart';
import 'package:tflite_object_detection/providers/display_recognition_provider.dart';
import 'package:tflite_object_detection/providers/picked_image_provider.dart';

class CountPage extends HookConsumerWidget {
  const CountPage([Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;
    final pickedImageState = ref.watch(pickedImageProvider);
    final imageSize = ref.read(pickedImageProvider.notifier).getImageSize();
    final displayRecognitionsState =
        ref.watch(displayRecognitionProvider(size));
    final ImagePicker _picker = ImagePicker();

    return Scaffold(
      backgroundColor: Colors.black,
      body: displayRecognitionsState.when(
        data: (dispRec) {
          if (pickedImageState == null ||
              imageSize == null ||
              dispRec == null) {
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
          stackChildren.addAll(dispRec.map(
            (re) {
              return RectanglesContainers(
                factorX: factorX,
                factorY: factorY,
                recognition: re,
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
                Text(
                  dispRec.length.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 88,
                  ),
                ),
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
