import 'package:node_auth/domain/repositories/user_repository.dart';
import 'package:node_auth/utils/result.dart';

class SendResetPasswordEmailUseCase {
  final UserRepository _userRepository;

  const SendResetPasswordEmailUseCase(this._userRepository);

  Single_Result_Unit call(String email) =>
      _userRepository.sendResetPasswordEmail(email);
}
