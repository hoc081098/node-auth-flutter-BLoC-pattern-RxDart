import 'dart:io';

import 'package:node_auth/domain/repositories/user_repository.dart';
import 'package:node_auth/utils/result.dart';

class UploadImageUseCase {
  final UserRepository _userRepository;

  const UploadImageUseCase(this._userRepository);

  Stream<Result<void>> call(File image) => _userRepository.uploadImage(image);
}
