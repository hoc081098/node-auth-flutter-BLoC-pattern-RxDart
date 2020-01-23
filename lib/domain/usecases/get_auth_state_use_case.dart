import 'package:node_auth/domain/models/auth_state.dart';
import 'package:node_auth/domain/repositories/user_repository.dart';
import 'package:rxdart/rxdart.dart';

class GetAuthStateUseCase {
  final UserRepository _userRepository;

  const GetAuthStateUseCase(this._userRepository);

  ValueStream<AuthenticationState> call() =>
      _userRepository.authenticationState$;
}
