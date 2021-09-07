import 'package:app/providers/recognition_provider.dart';
import 'package:app/services/classifier.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class DetectPage extends HookConsumerWidget {
  const DetectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ImagePicker _picker = ImagePicker();
    final classifier = Classifier();
    final recognition = ref.watch(recognitionProvider);
    return Scaffold(
      body: Center(
        child: Text(recognition.digit.toString()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final XFile? image =
              await _picker.pickImage(source: ImageSource.camera);
          if (image == null) return;
          final prediction = await classifier.classifyImage(image);
          ref.read(recognitionProvider.notifier).update(prediction);
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
