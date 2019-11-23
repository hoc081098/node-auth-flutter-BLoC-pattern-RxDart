import 'dart:io';

import 'package:meta/meta.dart';
import 'package:node_auth/data/models/auth_state.dart';
import 'package:node_auth/data/models/result.dart';
import 'package:rxdart/rxdart.dart';

abstract class UserRepository {
  ValueObservable<AuthenticationState> get authenticationState$;

  Observable<Result<void>> login({
    @required String email,
    @required String password,
  });

  Observable<Result<void>> registerUser({
    @required String name,
    @required String email,
    @required String password,
  });

  Observable<Result<void>> logout();

  Observable<Result<void>> uploadImage(File image);

  Observable<Result<void>> changePassword({
    @required String password,
    @required String newPassword,
  });

  Observable<Result<void>> resetPassword({
    @required String email,
    @required String token,
    @required String newPassword,
  });

  Observable<Result<void>> sendResetPasswordEmail(String email);
}
