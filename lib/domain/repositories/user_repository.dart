import 'dart:io';

import 'package:node_auth/domain/models/app_error.dart';
import 'package:node_auth/domain/models/auth_state.dart';

abstract class UserRepository {
  Stream<Result<AuthenticationState>> get authenticationState$;

  Single<Result<AuthenticationState>> get authenticationState;

  UnitResultSingle login({
    required String email,
    required String password,
  });

  UnitResultSingle registerUser({
    required String name,
    required String email,
    required String password,
  });

  UnitResultSingle logout();

  UnitResultSingle uploadImage(File image);

  UnitResultSingle changePassword({
    required String password,
    required String newPassword,
  });

  UnitResultSingle resetPassword({
    required String email,
    required String token,
    required String newPassword,
  });

  UnitResultSingle sendResetPasswordEmail(String email);
}
