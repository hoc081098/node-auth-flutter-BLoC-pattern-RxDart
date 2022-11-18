part of 'user_repository_imp.dart';

abstract class _Mappers {
  ///
  /// Convert error to [Failure]
  ///
  static AppError errorToAppError(Object e, StackTrace s) {
    if (e is CancellationException) {
      return const AppCancellationError();
    }

    if (e is RemoteDataSourceException) {
      if (e.error is CancellationException) {
        return const AppCancellationError();
      }
      return AppError(
        message: e.message,
        error: e,
        stackTrace: s,
      );
    }

    if (e is LocalDataSourceException) {
      if (e.error is CancellationException) {
        return const AppCancellationError();
      }
      return AppError(
        message: e.message,
        error: e,
        stackTrace: s,
      );
    }

    return AppError(
      message: e.toString(),
      error: e,
      stackTrace: s,
    );
  }

  /// Entity -> Domain
  static AuthenticationState userAndTokenEntityToDomainAuthState(
      UserAndTokenEntity? entity) {
    if (entity == null) {
      return UnauthenticatedState();
    }

    final userAndTokenBuilder = UserAndTokenBuilder()
      ..user = _Mappers.userEntityToUserDomain(entity.user)
      ..token = entity.token;

    return AuthenticatedState((b) => b.userAndToken = userAndTokenBuilder);
  }

  /// Entity -> Domain
  static UserBuilder userEntityToUserDomain(UserEntity userEntity) {
    return UserBuilder()
      ..name = userEntity.name
      ..email = userEntity.email
      ..createdAt = userEntity.createdAt
      ..imageUrl = userEntity.imageUrl;
  }

  /// Response -> Entity
  static UserEntityBuilder userResponseToUserEntity(UserResponse userResponse) {
    return UserEntityBuilder()
      ..name = userResponse.name
      ..email = userResponse.email
      ..createdAt = userResponse.createdAt
      ..imageUrl = userResponse.imageUrl;
  }

  /// Response -> Entity
  static UserAndTokenEntity userResponseToUserAndTokenEntity(
    UserResponse user,
    String token,
  ) {
    return UserAndTokenEntity(
      (b) => b
        ..token = token
        ..user = userResponseToUserEntity(user),
    );
  }
}
