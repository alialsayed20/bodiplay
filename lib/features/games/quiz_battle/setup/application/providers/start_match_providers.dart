import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/start_match_service.dart';

final Provider<StartMatchService> startMatchServiceProvider =
    Provider<StartMatchService>((Ref ref) {
  return const StartMatchService();
});