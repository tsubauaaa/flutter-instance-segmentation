import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

final pickedImageProvider =
    StateNotifierProvider.autoDispose<PickedImageController, File?>(
  (ref) => PickedImageController(),
);

class PickedImageController extends StateNotifier<File?> {
  PickedImageController() : super(null);

  update(XFile image) {
    state = File(image.path);
  }

  Size? getImageSize() {
    if (state == null) return null;
    final Size imageSize = ImageSizeGetter.getSize(FileInput(state!));
    return imageSize;
  }
}

class ImageSize {
  ImageSize(this.height, this.width);
  double height;
  double width;
}
