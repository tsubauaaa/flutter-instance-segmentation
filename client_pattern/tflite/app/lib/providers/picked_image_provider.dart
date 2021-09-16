import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final pickedImageProvider =
    StateNotifierProvider.autoDispose<PickedImageController, File?>(
  (ref) => PickedImageController(),
);

class PickedImageController extends StateNotifier<File?> {
  PickedImageController() : super(null);

  update(XFile image) {
    state = File(image.path);
  }

  Future<ImageSize> getImageSize() async {
    final decodedImage = await decodeImageFromList(state!.readAsBytesSync());
    final imageHeight = decodedImage.height.toDouble();
    final imageWidth = decodedImage.width.toDouble();
    return ImageSize(imageHeight, imageWidth);
  }
}

class ImageSize {
  ImageSize(this.height, this.width);
  double height;
  double width;
}
