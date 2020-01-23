import 'dart:io';

import 'package:node_auth/data/exception/local_data_source_exception.dart';
import 'package:node_auth/data/exception/remote_data_source_exception.dart';
import 'package:node_auth/data/local/entities/user_and_token_entity.dart';
import 'package:node_auth/data/local/entities/user_entity.dart';
import 'package:node_auth/data/local/local_data_source.dart';
import 'package:node_auth/data/remote/remote_data_source.dart';
import 'package:node_auth/data/remote/response/token_response.dart';
import 'package:node_auth/data/remote/response/user_response.dart';
import 'package:node_auth/domain/models/auth_state.dart';
import 'package:node_auth/domain/models/user.dart';
import 'package:node_auth/domain/models/user_and_token.dart';
import 'package:node_auth/domain/repositories/user_repository.dart';
import 'package:node_auth/utils/result.dart';
import 'package:rxdart/rxdart.dart';

part 'mappers.dart';

class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;
  @override
  final ValueConnectableStream<AuthenticationState> authenticationState$;

  UserRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  )   : assert(_remoteDataSource != null),
        assert(_localDataSource != null),
        authenticationState$ = _localDataSource.userAndToken$
            .map(_Mappers.userAndTokenEntityToDomainAuthState)
            .onErrorReturn(UnauthenticatedState())
            .publishValue() {
    _init();

    authenticationState$
        .listen((state) => print('[USER_REPOSITORY] state=$state'));
    authenticationState$.connect();
  }

  @override
  Stream<Result<void>> login({
    String email,
    String password,
  }) =>
      _execute(() => _remoteDataSource.loginUser(email, password))
          .flatMap((result) => _getUserProfileAndSaveToLocal(email, result));

  @override
  Stream<Result<void>> registerUser({
    String name,
    String email,
    String password,
  }) =>
      _execute(() => _remoteDataSource.registerUser(name, email, password));

  @override
  Stream<Result<void>> logout() =>
      _execute(() => _localDataSource.removeUserAndToken());

  @override
  Stream<Result<void>> uploadImage(File image) {
    final userAndToken = _userAndToken;

    if (userAndToken == null) {
      return Stream.value(
        Failure(
          (b) => b
            ..message = 'Require login!'
            ..error = 'Email or token is null',
        ),
      );
    }

    return _execute(
      () => _remoteDataSource.uploadImage(
        image,
        userAndToken.user.email,
      ),
    ).asyncMap((result) async {
      if (result is Success<UserResponse>) {
        await _localDataSource.saveUserAndToken(
          _Mappers.userResponseToUserAndTokenEntity(
            result.result,
            userAndToken.token,
          ),
        );
      }
      return result;
    });
  }

  @override
  Stream<Result<void>> changePassword({
    String password,
    String newPassword,
  }) {
    final userAndToken = _userAndToken;

    if (userAndToken == null) {
      return Stream.value(
        Failure(
          (b) => b
            ..message = 'Require login!'
            ..error = 'Email or token is null',
        ),
      );
    }

    return _execute(
      () => _remoteDataSource.changePassword(
        userAndToken.user.email,
        password,
        newPassword,
        userAndToken.token,
      ),
    );
  }

  @override
  Stream<Result<void>> resetPassword({
    String email,
    String token,
    String newPassword,
  }) =>
      _execute(
        () => _remoteDataSource.resetPassword(
          email,
          token: token,
          newPassword: newPassword,
        ),
      );

  @override
  Stream<Result<void>> sendResetPasswordEmail(String email) =>
      _execute(() => _remoteDataSource.resetPassword(email));

  Stream<Result<void>> _getUserProfileAndSaveToLocal(
    String email,
    Result<TokenResponse> tokenResult,
  ) {
    if (tokenResult is Failure) {
      return Stream.value(tokenResult);
    }

    if (tokenResult is Success<TokenResponse>) {
      final token = tokenResult.result.token;

      return _execute(
        () => _remoteDataSource.getUserProfile(
          email,
          token,
        ),
      ).asyncMap((userResult) async {
        if (userResult is Success<UserResponse>) {
          await _localDataSource.saveUserAndToken(
            _Mappers.userResponseToUserAndTokenEntity(
              userResult.result,
              token,
            ),
          );
        }
        return userResult;
      });
    }

    return Stream.error('Unknow $tokenResult');
  }

  ///
  /// Helpers functions
  ///

  UserAndToken get _userAndToken => authenticationState$.value?.userAndToken;

  ///
  /// Execute [factory] when listen to observable,
  /// if future is successful, emit [Success]
  /// if future complete with error, emit [Failure]
  ///
  Stream<Result<T>> _execute<T>(Future<T> Function() factory) {
    return Rx.defer(() {
      return Stream.fromFuture(factory())
          .doOnError(_handleUnauthenticatedError)
          .map<Result<T>>((result) => Success<T>((b) => b.result = result))
          .onErrorReturnWith(_errorToResult);
    });
  }

  ///
  /// Like error http interceptor
  ///
  void _handleUnauthenticatedError(e, s) {
    if (e is RemoteDataSourceException &&
        e.statusCode == HttpStatus.unauthorized) {
      print(
          '[USER_REPOSITORY] {interceptor} 401 - unauthenticated error ===> login again');
      _localDataSource.removeUserAndToken();
    }
  }

  ///
  /// Convert error to [Failure]
  ///
  static Failure<T> _errorToResult<T>(e) {
    if (e is RemoteDataSourceException) {
      return Failure((b) => b
        ..message = e.message
        ..error = e);
    }
    if (e is LocalDataSourceException) {
      return Failure((b) => b
        ..message = e.message
        ..error = e);
    }
    return Failure((b) => b
      ..message = e.toString()
      ..error = e);
  }

  ///
  /// Check auth when starting app
  ///
  void _init() async {
    const tag = '[USER_REPOSITORY] { init }';

    try {
      final userAndToken = await _localDataSource.userAndToken$.first;
      print('$tag userAndToken local=$userAndToken');

      if (userAndToken == null) {
        return;
      }

      final userProfile = await _remoteDataSource.getUserProfile(
        userAndToken.user.email,
        userAndToken.token,
      );
      print('$tag userProfile server=$userProfile');
      await _localDataSource.saveUserAndToken(
        _Mappers.userResponseToUserAndTokenEntity(
          userProfile,
          userAndToken.token,
        ),
      );
    } on RemoteDataSourceException catch (e) {
      print('$tag remote error=$e');

      if (e.statusCode == HttpStatus.unauthorized) {
        print('$tag 401 - unauthenticated error ===> login again');
        await _localDataSource.removeUserAndToken();
      }
    } on LocalDataSourceException catch (e) {
      print('$tag local error=$e');
      await _localDataSource.removeUserAndToken();
    }
  }
}
