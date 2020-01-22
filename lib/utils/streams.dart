import 'dart:async';

extension DebugMapStreamsExtension on Map<String, Stream<dynamic>> {
  List<StreamSubscription> debug() => entries
      .map((entry) =>
          entry.value.listen((data) => print('[DEBUG] [${entry.key}] = $data')))
      .toList();
}
