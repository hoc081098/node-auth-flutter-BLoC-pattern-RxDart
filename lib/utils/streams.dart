import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:node_auth/utils/unit.dart';
import 'package:dart_either/dart_either.dart';

extension FlatMapEitherSingleExtension<L, R1> on Single<Either<L, R1>> {
  Single<Either<L, R2>> flatMapEitherSingle<R2>(
    Single<Either<L, R2>> Function(R1 value) mapper,
  ) =>
      flatMapSingle(
        (result) => result.fold(
          ifRight: (v) => mapper(v),
          ifLeft: (v) => Single.value(v.left<R2>()),
        ),
      );
}

extension AsUnitSingleExtension<L, R> on Single<Either<L, R>> {
  Single<Either<L, Unit>> asUnit() => map((r) => r.map((_) => Unit.instance));
}

extension DebugMapStreamsExtension on Map<String, Stream<dynamic>> {
  List<StreamSubscription> debug() => entries
      .map((entry) => entry.value
          .listen((data) => debugPrint('[DEBUG] [${entry.key}] = $data')))
      .toList();
}

extension CastAsNullableStreamExtension<T> on Stream<T> {
  Stream<T?> castAsNullable() => cast<T?>();
}

extension CastAsNullableSingleExtension<T> on Single<T> {
  Single<T?> castAsNullable() => cast<T?>();
}
