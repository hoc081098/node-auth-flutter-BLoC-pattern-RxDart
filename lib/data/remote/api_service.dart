import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http_client_hoc081098/http_client_hoc081098.dart';
import 'package:node_auth/data/constants.dart';
import 'package:node_auth/data/exception/remote_data_source_exception.dart';
import 'package:node_auth/data/remote/remote_data_source.dart';
import 'package:node_auth/data/remote/response/token_response.dart';
import 'package:node_auth/data/remote/response/user_response.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:rxdart_ext/rxdart_ext.dart';

class ApiService implements RemoteDataSource {
  static const String xAccessToken = 'x-access-token';

  final SimpleHttpClient _client;

  const ApiService(this._client);

  static Single<T> _wrap<T>(
          Future<T> Function(CancellationToken token) block) =>
      useCancellationToken<T>((cancelToken) async {
        try {
          return await block(cancelToken);
        } on SocketException catch (e, s) {
          throw RemoteDataSourceException('No internet connection', e, s);
        } on SimpleHttpClientException catch (e, s) {
          throw RemoteDataSourceException('Http error', e, s);
        } catch (e, s) {
          throw RemoteDataSourceException('Other error', e, s);
        }
      });

  ///
  /// Login user with [email] and [password]
  /// return [TokenResponse] including message and token
  ///
  @override
  Single<TokenResponse> loginUser(
    String email,
    String password,
  ) =>
      _wrap((cancelToken) async {
        final url = Uri.https(baseUrl, '/users/authenticate');
        final credentials = '$email:$password';
        final basic = 'Basic ${base64Encode(utf8.encode(credentials))}';
        final json = await _client.postJson(
          url,
          headers: {
            HttpHeaders.authorizationHeader: basic,
          },
          cancelToken: cancelToken,
        );
        return TokenResponse.fromJson(json);
      });

  ///
  /// Login user with [email] and [password]
  /// return message
  ///
  @override
  Single<TokenResponse> registerUser(
    String name,
    String email,
    String password,
  ) =>
      _wrap((cancelToken) async {
        final url = Uri.https(baseUrl, '/users');
        final body = <String, String>{
          'name': name,
          'email': email,
          'password': password,
        };
        final decoded = await _client.postJson(
          url,
          body: body,
          cancelToken: cancelToken,
        );
        return TokenResponse.fromJson(decoded);
      });

  ///
  /// Get user profile by [email] and [token]
  /// return [User]
  ///
  @override
  Single<UserResponse> getUserProfile(
    String email,
    String token,
  ) =>
      _wrap((cancelToken) async {
        final url = Uri.https(baseUrl, '/users/$email');
        final json = await _client.getJson(
          url,
          headers: {xAccessToken: token},
          cancelToken: cancelToken,
        );
        return UserResponse.fromJson(json);
      });

  ///
  /// Change password of user
  /// return message
  ///
  @override
  Single<TokenResponse> changePassword(
    String email,
    String password,
    String newPassword,
    String token,
  ) =>
      _wrap((cancelToken) async {
        final url = Uri.https(baseUrl, '/users/$email/password');
        final body = {'password': password, 'new_password': newPassword};
        final json = await _client.putJson(
          url,
          headers: {xAccessToken: token},
          body: body,
          cancelToken: cancelToken,
        );
        return TokenResponse.fromJson(json);
      });

  ///
  /// Reset password
  /// Special token and newPassword to reset password,
  /// otherwise, send an email to email
  /// return message
  ///
  @override
  Single<TokenResponse> resetPassword(
    String email, {
    String? token,
    String? newPassword,
  }) =>
      _wrap((cancelToken) async {
        final url = Uri.https(baseUrl, '/users/$email/password');
        final task = token != null && newPassword != null
            ? _client.postJson(
                url,
                body: {
                  'token': token,
                  'new_password': newPassword,
                },
                cancelToken: cancelToken,
              )
            : _client.postJson(
                url,
                cancelToken: cancelToken,
              );
        final json = await task;
        return TokenResponse.fromJson(json);
      });

  ///
  /// Upload avatar image
  /// return [User] profile after image file is uploaded
  ///
  @override
  Single<UserResponse> uploadImage(
    File file,
    String email,
    String token,
  ) =>
      _wrap((cancelToken) async {
        final url = Uri.https(baseUrl, '/users/upload');

        cancelToken.guard();

        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final filename = path.basename(file.path);

        cancelToken.guard();

        final decoded = await _client.postMultipart(
          url,
          [
            http.MultipartFile(
              'my_image',
              stream,
              length,
              filename: filename,
            ),
          ],
          fields: {'user': email},
          headers: {xAccessToken: token},
          cancelToken: cancelToken,
        );
        return UserResponse.fromJson(decoded);
      });
}
