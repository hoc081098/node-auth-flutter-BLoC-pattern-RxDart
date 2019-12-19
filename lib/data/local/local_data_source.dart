import 'package:node_auth/data/data.dart';
import 'package:rxdart/rxdart.dart';

abstract class LocalDataSource {
  ValueStream<UserAndToken> get userAndToken$;

  Future<void> saveUserAndToken(UserAndToken userAndToken);

  Future<void> removeUserAndToken();
}
