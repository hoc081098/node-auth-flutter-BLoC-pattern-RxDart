import 'package:node_auth/data/local/entities/user_and_token_entity.dart';
import 'package:node_auth/domain/models/app_error.dart';

abstract class LocalDataSource {
  /// Returns a single-subscription stream that emits [UserAndTokenEntity] or null
  Stream<UserAndTokenEntity?> get userAndToken$;

  /// Returns a future that completes with a [UserAndTokenEntity] value or null
  Single<UserAndTokenEntity?> get userAndToken;

  /// Save [userAndToken] into local storage.
  /// Throws [LocalDataSourceException] if saving is failed
  Single<void> saveUserAndToken(UserAndTokenEntity userAndToken);

  /// Remove user and token from local storage.
  /// Throws [LocalDataSourceException] if removing is failed
  Single<void> removeUserAndToken();
}

abstract class Crypto {
  Future<String> encrypt(String plaintext);

  Future<String> decrypt(String ciphertext);
}
