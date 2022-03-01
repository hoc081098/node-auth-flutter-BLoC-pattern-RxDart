import 'package:node_auth/data/local/entities/user_and_token_entity.dart';

abstract class LocalDataSource {
  /// Returns a single-subscription stream that emits [UserAndTokenEntity] or null
  Stream<UserAndTokenEntity?> get userAndToken$;

  /// Returns a future that completes with a [UserAndTokenEntity] value or null
  Future<UserAndTokenEntity?> get userAndToken;

  /// Save [userAndToken] into local storage.
  /// Throws [LocalDataSourceException] if saving is failed
  Future<void> saveUserAndToken(UserAndTokenEntity userAndToken);

  /// Remove user and token from local storage.
  /// Throws [LocalDataSourceException] if removing is failed
  Future<void> removeUserAndToken();
}

abstract class Crypto {
  Future<String> encrypt(String plaintext);

  Future<String> decrypt(String ciphertext);
}
