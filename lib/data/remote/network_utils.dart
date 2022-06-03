import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:node_auth/data/exception/remote_data_source_exception.dart';
import 'package:path/path.dart' as path;

final _indent = ' ' * 11;

void _logRequest(
  Uri url,
  String method, {
  Map<String, String>? headers,
  Map<String, String>? body,
  Map<String, String>? multipartFields,
  List<http.MultipartFile>? multipartFiles,
}) {
  debugPrint('[http] --> $method $url');
  debugPrint('${_indent}headers: $headers');

  if (method == 'POST' || method == 'PUT') {
    debugPrint('${_indent}body: $body');

    if (method == 'POST') {
      if (multipartFields != null) {
        debugPrint('${_indent}multipartFields: $multipartFields');
      }
      if (multipartFields != null) {
        debugPrint('${_indent}multipartFiles: $multipartFiles');
      }
    }
  }
}

void _logResponse(http.Response response) {
  debugPrint('[http] <-- ${response.statusCode} ${response.request}');
  debugPrint('${_indent}bodyBytes: ${response.bodyBytes.length}');
  try {
    debugPrint('${_indent}body: ${response.body}');
  } catch (_) {}
}

class NetworkUtils {
  static Future get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    _logRequest(url, 'GET', headers: headers);

    final response = await http.get(url, headers: headers);
    _logResponse(response);
    return _parse(response);
  }

  static dynamic _parse(http.Response response) {
    final body = response.body;
    final statusCode = response.statusCode;

    final decoded = json.decode(body);
    if (statusCode < 200 || statusCode >= 300) {
      throw RemoteDataSourceException(statusCode, decoded['message']);
    }
    return decoded;
  }

  static Future post(
    Uri url, {
    Map<String, String>? headers,
    Map<String, String>? body,
  }) =>
      _helper(
        'POST',
        url,
        headers: headers,
        body: body,
      );

  static Future _helper(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Map<String, String>? body,
  }) async {
    _logRequest(url, method, headers: headers, body: body);

    final request = http.Request(method, url);
    if (body != null) {
      request.bodyFields = body;
    }
    if (headers != null) {
      request.headers.addAll(headers);
    }
    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);
    _logResponse(response);
    return _parse(response);
  }

  static Future put(
    Uri url, {
    Map<String, String>? headers,
    Map<String, String>? body,
  }) =>
      _helper(
        'PUT',
        url,
        headers: headers,
        body: body,
      );

  static Future multipartPost(
    Uri url,
    File file,
    String field, {
    Map<String, String>? headers,
    Map<String, String>? fields,
  }) async {
    final stream = http.ByteStream(file.openRead());
    final length = await file.length();

    final request = http.MultipartRequest('POST', url)
      ..fields.addAll(fields ?? {})
      ..files.add(
        http.MultipartFile(
          field,
          stream,
          length,
          filename: path.basename(file.path),
        ),
      )
      ..headers.addAll(headers ?? {});
    _logRequest(
      url,
      'POST',
      headers: headers,
      multipartFields: request.fields,
      multipartFiles: request.files,
    );
    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);
    _logResponse(response);
    return _parse(response);
  }
}
