import 'dart:io';

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

  Observable<Result> uploadImage(File image);

  Observable<Result> changePassword({
    @required String password,
    @required String newPassword,
  });

  Observable<Result> resetPassword({
    @required String email,
    @required String token,
    @required String newPassword,
  });

  Observable<Result> sendResetPasswordEmail(String email);
}
