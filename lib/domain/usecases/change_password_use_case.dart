import 'package:node_auth/domain/repositories/user_repository.dart';
import 'package:node_auth/utils/result.dart';

class ChangePasswordUseCase {
  final UserRepository _userRepository;

  const ChangePasswordUseCase(this._userRepository);

  Stream<Result_Unit> call({
    required String password,
    required String newPassword,
  }) =>
      _userRepository.changePassword(
        password: password,
        newPassword: newPassword,
      );
}
