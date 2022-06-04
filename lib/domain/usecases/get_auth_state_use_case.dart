import 'package:node_auth/domain/models/app_error.dart';
import 'package:node_auth/domain/models/auth_state.dart';
import 'package:node_auth/domain/repositories/user_repository.dart';

class GetAuthStateUseCase {
  final UserRepository _userRepository;

  const GetAuthStateUseCase(this._userRepository);

  Single<Result<AuthenticationState>> call() =>
      _userRepository.authenticationState;
}
