import 'dart:io';

import 'package:node_auth/domain/models/auth_state.dart';
import 'package:node_auth/utils/result.dart';

abstract class UserRepository {
  Stream<AuthenticationState> get authenticationState$;

  Future<AuthenticationState> get authenticationState;

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
