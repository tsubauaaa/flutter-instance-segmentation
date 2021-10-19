import 'package:app/services/d2go_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final d2goServiceProvider = Provider<D2GoService>((ref) => D2GoService());
