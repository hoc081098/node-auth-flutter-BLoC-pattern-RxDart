import 'dart:io';

import 'package:node_auth/domain/models/auth_state.dart';
import 'package:node_auth/utils/result.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

typedef Single_Result_Unit = Single<Result<Unit>>;

abstract class UserRepository {
  Stream<AuthenticationState> get authenticationState$;

  Future<AuthenticationState> get authenticationState;

  Single_Result_Unit login({
    required String email,
    required String password,
  });

  Single_Result_Unit registerUser({
    required String name,
    required String email,
    required String password,
  });

  Single_Result_Unit logout();

  Single_Result_Unit uploadImage(File image);

  Single_Result_Unit changePassword({
    required String password,
    required String newPassword,
  });

  Single_Result_Unit resetPassword({
    required String email,
    required String token,
    required String newPassword,
  });

  Single_Result_Unit sendResetPasswordEmail(String email);
}
