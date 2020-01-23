import 'package:node_auth/data/local/entities/user_and_token_entity.dart';
import 'package:rxdart/rxdart.dart';

abstract class LocalDataSource {
  ValueStream<UserAndTokenEntity> get userAndToken$;

  Future<void> saveUserAndToken(UserAndTokenEntity userAndToken);

  Future<void> removeUserAndToken();
}
