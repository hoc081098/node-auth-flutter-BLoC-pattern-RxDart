import 'package:meta/meta.dart';
import 'package:node_auth/data/models/result.dart';
import 'package:node_auth/data/models/user_and_token.dart';
import 'package:rxdart/rxdart.dart';

abstract class UserRepository {
  ValueObservable<UserAndToken> get userAndToken$;

  Observable<Result> login({
    @required String email,
    @required String password,
  });

  Observable<Result> registerUser({
    @required String name,
    @required String email,
    @required String password,
  });

  Observable<Result> logout();
}
