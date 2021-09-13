import 'dart:convert';

import 'package:app/providers/picked_image_string_provider.dart';
import 'package:app/providers/prediction_result_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class CountPage extends HookConsumerWidget {
  const CountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ImagePicker _picker = ImagePicker();
    final pickedImageStringState = ref.watch(pickedImageStringProvider);
    final predictionResultState = ref.watch(predictionResultProvider);
    return Scaffold(
      body: predictionResultState.when(
        data: (predictionResult) {
          return predictionResult == null
              ? const Center(
                  child: Text(
                    "Please count the books.",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image.memory(
                      //   base64Decode(pickedImageStringState!),
                      // ),
                      Image.memory(
                        base64Decode(predictionResult.image!),
                      ),
                      Text(
                        predictionResult.numberOfBooks.toString(),
                        style: const TextStyle(fontSize: 112),
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
          final XFile? image =
              await _picker.pickImage(source: ImageSource.gallery);
          if (image == null) return;
          ref.read(pickedImageStringProvider.notifier).update(image);
        },
        child: FloatingActionButton(
          onPressed: () async {
            final XFile? image =
                await _picker.pickImage(source: ImageSource.camera);
            if (image == null) return;
            ref.read(pickedImageStringProvider.notifier).update(image);
          },
          child: const Icon(Icons.camera),
        ),
      ),
    );
  }
}
