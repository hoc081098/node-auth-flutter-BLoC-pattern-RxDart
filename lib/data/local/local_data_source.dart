import 'package:node_auth/data/models/user.dart';

abstract class LocalDataSource {
  Future<String> getToken();

  Future<void> saveToken(String token);

  Future<void> deleteToken();

  Future<void> saveUser(User user);

  Future<void> deleteUser();

  Future<User> getUser();
}
