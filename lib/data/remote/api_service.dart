import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:node_auth/data/data.dart';
import 'package:node_auth/data/models/response.dart';
import 'package:node_auth/data/remote/network_utils.dart';
import 'package:path/path.dart' as path;

class ApiService implements RemoteDataSource {
  static const String xAccessToken = 'x-access-token';

  const ApiService();

  ///
  /// Login user with [email] and [password]
  /// return [Response] including message and token
  ///
  @override
  Future<Response> loginUser(
    String email,
    String password,
  ) async {
    final url = Uri.https(baseUrl, '/users/authenticate');
    final credentials = '$email:$password';
    final basic = 'Basic ${base64Encode(utf8.encode(credentials))}';
    final json = await NetworkUtils.post(url, headers: {
      HttpHeaders.authorizationHeader: basic,
    });
    return Response.fromJson(json);
  }

  ///
  /// Login user with [email] and [password]
  /// return message
  ///
  @override
  Future<Response> registerUser(
    String name,
    String email,
    String password,
  ) async {
    final url = Uri.https(baseUrl, '/users');
    final body = <String, String>{
      'name': name,
      'email': email,
      'password': password,
    };
    final decoded = await NetworkUtils.post(url, body: body);
    return Response.fromJson(decoded);
  }

  ///
  /// Get user profile by [email] and [token]
  /// return [User]
  ///
  @override
  Future<User> getUserProfile(
    String email,
    String token,
  ) async {
    final url = Uri.https(baseUrl, '/users/$email');
    final json = await NetworkUtils.get(url, headers: {xAccessToken: token});
    return User.fromJson(json);
  }

  ///
  /// Change password of user
  /// return message
  ///
  @override
  Future<Response> changePassword(
    String email,
    String password,
    String newPassword,
    String token,
  ) async {
    final url = Uri.http(baseUrl, "/users/$email/password");
    final body = {'password': password, 'new_password': newPassword};
    final json = await NetworkUtils.put(
      url,
      headers: {xAccessToken: token},
      body: body,
    );
    return Response.fromJson(json);
  }

  ///
  /// Reset password
  /// Special token and newPassword to reset password,
  /// otherwise, send an email to email
  /// return message
  ///
  @override
  Future<Response> resetPassword(
    String email, {
    String token,
    String newPassword,
  }) async {
    final url = Uri.https(baseUrl, '/users/$email/password');
    final task = token != null && newPassword != null
        ? NetworkUtils.post(url, body: {
            'token': token,
            'new_password': newPassword,
          })
        : NetworkUtils.post(url);
    final json = await task;
    return Response.fromJson(json);
  }

  ///
  /// Upload avatar image
  /// return [User] profile after image file is uploaded
  ///
  @override
  Future<User> uploadImage(
    File file,
    String email,
  ) async {
    final url = Uri.https(baseUrl, '/users/upload');
    final stream = http.ByteStream(file.openRead());
    final length = await file.length();
    final request = http.MultipartRequest('POST', url)
      ..fields['user'] = email
      ..files.add(
        http.MultipartFile(
          'my_image',
          stream,
          length,
          filename: path.basename(file.path),
        ),
      );
    final streamedReponse = await request.send();
    final statusCode = streamedReponse.statusCode;
    final decoded = json.decode(await streamedReponse.stream.bytesToString());

    debugPrint('decoded: $decoded');

    if (statusCode < 200 || statusCode >= 300) {
      throw RemoteDataSourceException(statusCode, decoded['message']);
    }

    return User.fromJson(decoded);
  }
}
