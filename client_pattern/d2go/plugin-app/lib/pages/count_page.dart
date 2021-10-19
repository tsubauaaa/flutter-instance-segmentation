import 'dart:ui';

import 'package:app/components/rectangle_containers.dart';
import 'package:app/providers/display_recognition_provider.dart';
import 'package:app/providers/picked_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class CountPage extends HookConsumerWidget {
  const CountPage([Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;
    final pickedImageState = ref.watch(pickedImageProvider);
    final imageSize = ref.read(pickedImageProvider.notifier).getImageSize();
    final double screenWidth = size.width;

    final displayRecognitionsState =
        ref.watch(displayRecognitionProvider(size));
    final ImagePicker _picker = ImagePicker();

    return Scaffold(
      body: displayRecognitionsState.when(
        data: (displayRecognitions) {
          if (pickedImageState == null ||
              imageSize == null ||
              displayRecognitions == null) {
            return const Center(
              child: Text(
                'Let\'s count the books.',
                style: TextStyle(fontSize: 32),
              ),
            );
          }
          final double adjustedAspectRatio =
              imageSize.height / imageSize.width * screenWidth;
          final imageWidthScale = screenWidth / imageSize.width;
          final imageHeightScale = adjustedAspectRatio / imageSize.height;
          List<Widget> stackChildren = [];
          stackChildren.add(
            Positioned(
              top: 0.0,
              left: 0.0,
              width: size.width,
              child: Image.file(pickedImageState),
            ),
          );
          stackChildren.addAll(displayRecognitions.map(
            (displayRecognition) {
              return RectanglesContainers(
                imageWidthScale: imageWidthScale,
                imageHeightScale: imageHeightScale,
                recognition: displayRecognition,
              );
            },
          ).toList());
          return Container(
            margin: const EdgeInsets.only(top: 150),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Stack(
                    children: stackChildren,
                  ),
                ),
                const SizedBox(height: 48),
                Flexible(
                  child: Text(
                    displayRecognitions.length.toString(),
                    style: const TextStyle(
                      fontSize: 88,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: (prev) => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack, prev) => Center(
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
