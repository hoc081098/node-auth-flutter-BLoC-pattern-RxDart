// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http_client_hoc081098/http_client_hoc081098.dart';

class AuthInterceptor {
  final Future<void> Function() onUnauthorized;

  AuthInterceptor({
    required this.onUnauthorized,
  });

  late final RequestInterceptor requestInterceptor = (request) => request;

  late final ResponseInterceptor responseInterceptor =
      (request, response) async {
    if (response.statusCode == HttpStatus.unauthorized) {
      debugPrint(
          '[AUTH_INTERCEPTOR] {interceptor} 401 - unauthenticated error ===> login again');
      await onUnauthorized();
    }
  };
}
