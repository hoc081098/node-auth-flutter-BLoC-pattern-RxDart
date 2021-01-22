import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:node_auth/data/constants.dart';
import 'package:node_auth/data/remote/network_utils.dart';
import 'package:node_auth/data/remote/remote_data_source.dart';
import 'package:node_auth/data/remote/response/token_response.dart';
import 'package:node_auth/data/remote/response/user_response.dart';

class ApiService implements RemoteDataSource {
  static const String xAccessToken = 'x-access-token';

  const ApiService();

  ///
  /// Login user with [email] and [password]
  /// return [TokenResponse] including message and token
  ///
  @override
  Future<TokenResponse> loginUser(
    String email,
    String password,
  ) async {
    final url = Uri.https(baseUrl, '/users/authenticate');
    final credentials = '$email:$password';
    final basic = 'Basic ${base64Encode(utf8.encode(credentials))}';
    final json = await NetworkUtils.post(url, headers: {
      HttpHeaders.authorizationHeader: basic,
    });
    return TokenResponse.fromJson(json);
  }

  ///
  /// Login user with [email] and [password]
  /// return message
  ///
  @override
  Future<TokenResponse> registerUser(
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
    return TokenResponse.fromJson(decoded);
  }

  ///
  /// Get user profile by [email] and [token]
  /// return [User]
  ///
  @override
  Future<UserResponse> getUserProfile(
    String email,
    String token,
  ) async {
    final url = Uri.https(baseUrl, '/users/$email');
    final json = await NetworkUtils.get(url, headers: {xAccessToken: token});
    return UserResponse.fromJson(json);
  }

  ///
  /// Change password of user
  /// return message
  ///
  @override
  Future<TokenResponse> changePassword(
    String email,
    String password,
    String newPassword,
    String token,
  ) async {
    final url = Uri.https(baseUrl, '/users/$email/password');
    final body = {'password': password, 'new_password': newPassword};
    final json = await NetworkUtils.put(
      url,
      headers: {xAccessToken: token},
      body: body,
    );
    return TokenResponse.fromJson(json);
  }

  ///
  /// Reset password
  /// Special token and newPassword to reset password,
  /// otherwise, send an email to email
  /// return message
  ///
  @override
  Future<TokenResponse> resetPassword(
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
    return TokenResponse.fromJson(json);
  }

  ///
  /// Upload avatar image
  /// return [User] profile after image file is uploaded
  ///
  @override
  Future<UserResponse> uploadImage(
    File file,
    String email,
    String token,
  ) async {
    final url = Uri.https(baseUrl, '/users/upload');
    final decoded = await NetworkUtils.multipartPost(
      url,
      file,
      'my_image',
      fields: {'user': email},
      headers: {xAccessToken: token},
    );
    return UserResponse.fromJson(decoded);
  }
}
