import 'dart:convert';
import 'dart:io' as io;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final pickedImageStringProvider =
    StateNotifierProvider.autoDispose<PickedImageStringController, String?>(
  (ref) => PickedImageStringController(),
);

class PickedImageStringController extends StateNotifier<String?> {
  PickedImageStringController() : super(null);

  update(XFile image) {
    final List<int> imageBytes = io.File(image.path).readAsBytesSync();
    final String base64Image = base64Encode(imageBytes);
    state = base64Image;
  }
}
