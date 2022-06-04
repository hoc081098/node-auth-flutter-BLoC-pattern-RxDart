import 'package:node_auth/domain/models/app_error.dart';
import 'package:node_auth/domain/repositories/user_repository.dart';

class LogoutUseCase {
  final UserRepository _userRepository;

  const LogoutUseCase(this._userRepository);

  UnitResultSingle call() => _userRepository.logout();
}
