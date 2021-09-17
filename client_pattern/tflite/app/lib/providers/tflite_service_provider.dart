import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tflite_object_detection/services/tflite_service.dart';

final tfliteServiceProvider = Provider<TfliteService>((ref) => TfliteService());
