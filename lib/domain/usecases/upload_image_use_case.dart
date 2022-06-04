import 'dart:io';

import 'package:node_auth/domain/models/app_error.dart';
import 'package:node_auth/domain/repositories/user_repository.dart';

class UploadImageUseCase {
  final UserRepository _userRepository;

  const UploadImageUseCase(this._userRepository);

  UnitResultSingle call(File image) => _userRepository.uploadImage(image);
}
