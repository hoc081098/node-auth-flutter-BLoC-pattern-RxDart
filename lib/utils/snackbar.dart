import 'package:flutter/material.dart';

extension ShowSnackbarGlobalKeyScaffoldStateExtension
    on GlobalKey<ScaffoldState> {
  @deprecated
  void showSnackBar(
    String message, [
    Duration duration = const Duration(seconds: 1),
  ]) =>
      currentContext?.showSnackBar(message, duration);
}

extension ShowSnackBarBuildContextExtension on BuildContext {
  void showSnackBar(
    String message, [
    Duration duration = const Duration(seconds: 1),
  ]) {
    final messengerState = ScaffoldMessenger.of(this);
    messengerState.hideCurrentSnackBar();
    messengerState.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }

  void hideCurrentSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }
}
