import 'dart:io';

import 'package:node_auth/data/models/token_response.dart';
import 'package:node_auth/data/models/user.dart';

abstract class RemoteDataSource {
  Future<TokenResponse> loginUser(String email, String password);

  Future<TokenResponse> registerUser(
      String name, String email, String password);

  Future<TokenResponse> changePassword(
    String email,
    String password,
    String newPassword,
    String token,
  );

  Future<TokenResponse> resetPassword(
    String email, {
    String token,
    String newPassword,
  });

  Future<User> getUserProfile(String email, String token);

  Future<User> uploadImage(File file, String email);
}
