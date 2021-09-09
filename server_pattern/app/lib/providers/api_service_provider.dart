import 'package:app/const.dart';
import 'package:app/services/api_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final apiServiceProvider = Provider.autoDispose(
  (_) => APIService(kHost),
);
