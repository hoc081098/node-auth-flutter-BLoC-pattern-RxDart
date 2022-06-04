import 'package:node_auth/domain/models/app_error.dart';
import 'package:node_auth/domain/models/auth_state.dart';
import 'package:node_auth/domain/repositories/user_repository.dart';

class GetAuthStateStreamUseCase {
  final UserRepository _userRepository;

  const GetAuthStateStreamUseCase(this._userRepository);

  Stream<Result<AuthenticationState>> call() =>
      _userRepository.authenticationState$;
}
