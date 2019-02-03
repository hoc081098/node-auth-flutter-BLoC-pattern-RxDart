import 'dart:io';

import 'package:node_auth/data/models/response.dart';
import 'package:node_auth/data/models/user.dart';

abstract class RemoteDataSource {
  Future<Response> loginUser(String email, String password);

  Future<Response> registerUser(String name, String email, String password);

  Future<Response> changePassword(
    String email,
    String password,
    String newPassword,
    String token,
  );

  Future<Response> resetPassword(
    String email, {
    String token,
    String newPassword,
  });

  Future<User> getUserProfile(String email, String token);

  Future<User> uploadImage(File file, String email);
}
