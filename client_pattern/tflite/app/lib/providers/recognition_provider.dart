import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tflite_object_detection/models/recognition_model.dart';
import 'package:tflite_object_detection/providers/picked_image_provider.dart';
import 'package:tflite_object_detection/providers/tflite_service_provider.dart';

final recognitionProvider = FutureProvider.autoDispose<List<RecognitionModel>?>(
  (ref) async {
    final tfliteService = ref.read(tfliteServiceProvider);
    final image = ref.watch(pickedImageProvider);
    if (image == null) return null;
    return tfliteService.classifyImage(image);
  },
);
