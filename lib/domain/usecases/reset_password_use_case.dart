import 'package:node_auth/domain/models/app_error.dart';
import 'package:node_auth/domain/repositories/user_repository.dart';

class ResetPasswordUseCase {
  final UserRepository _userRepository;

  const ResetPasswordUseCase(this._userRepository);

  UnitResultSingle call({
    required String email,
    required String token,
    required String newPassword,
  }) =>
      _userRepository.resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );
}
