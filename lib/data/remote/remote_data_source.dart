import 'dart:io';

import 'package:node_auth/data/remote/response/token_response.dart';
import 'package:node_auth/data/remote/response/user_response.dart';

abstract class RemoteDataSource {
  Future<TokenResponse> loginUser(String email, String password);

  Future<TokenResponse> registerUser(
    String name,
    String email,
    String password,
  );

  Future<TokenResponse> changePassword(
    String email,
    String password,
    String newPassword,
    String token,
  );

  Future<TokenResponse> resetPassword(
    String email, {
    String? token,
    String? newPassword,
  });

  Future<UserResponse> getUserProfile(String email, String token);

  Future<UserResponse> uploadImage(
    File file,
    String email,
    String token,
  );
}
