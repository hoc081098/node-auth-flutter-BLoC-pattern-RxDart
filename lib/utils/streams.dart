import 'dart:async';

import 'package:flutter/foundation.dart';

extension DebugMapStreamsExtension on Map<String, Stream<dynamic>> {
  List<StreamSubscription> debug() => entries
      .map((entry) => entry.value
          .listen((data) => debugPrint('[DEBUG] [${entry.key}] = $data')))
      .toList();
}
