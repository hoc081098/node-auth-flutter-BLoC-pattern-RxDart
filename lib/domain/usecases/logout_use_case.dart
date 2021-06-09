import 'package:node_auth/domain/repositories/user_repository.dart';
import 'package:node_auth/utils/result.dart';

class LogoutUseCase {
  final UserRepository _userRepository;

  const LogoutUseCase(this._userRepository);

  Single_Result_Unit call() => _userRepository.logout();
}
