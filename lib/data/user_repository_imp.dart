import 'dart:io';

import 'package:node_auth/data/exception/local_data_source_exception.dart';
import 'package:node_auth/data/exception/remote_data_source_exception.dart';
import 'package:node_auth/data/local/entities/user_and_token_entity.dart';
import 'package:node_auth/data/local/entities/user_entity.dart';
import 'package:node_auth/data/local/local_data_source.dart';
import 'package:node_auth/data/remote/remote_data_source.dart';
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
  final Stream<AuthenticationState> authenticationState$;

  @override
  Future<AuthenticationState> get authenticationState =>
      _localDataSource.userAndToken
          .then(_Mappers.userAndTokenEntityToDomainAuthState)
          .catchError((_) => UnauthenticatedState());

  UserRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  )   : assert(_remoteDataSource != null),
        assert(_localDataSource != null),
        authenticationState$ = _localDataSource.userAndToken$
            .map(_Mappers.userAndTokenEntityToDomainAuthState)
            .onErrorReturn(UnauthenticatedState())
            .publishValue()
              ..listen((state) => print('[USER_REPOSITORY] state=$state'))
              ..connect() {
    _init();
  }

  @override
  Stream<Result<void>> login({
    String email,
    String password,
  }) {
    return _execute(
      () => _remoteDataSource.loginUser(
        email,
        password,
      ),
    ).flatMapResult((result) {
      final token = result.token;

      return _execute(
        () => _remoteDataSource.getUserProfile(
          email,
          token,
        ),
      ).flatMapResult(
        (user) => _execute(
          () => _localDataSource.saveUserAndToken(
            _Mappers.userResponseToUserAndTokenEntity(
              user,
              token,
            ),
          ),
        ),
      );
    });
  }

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
    return _userAndToken.flatMapResult((userAndToken) {
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
      ).flatMapResult(
        (user) => _execute(
          () => _localDataSource.saveUserAndToken(
            _Mappers.userResponseToUserAndTokenEntity(
              user,
              userAndToken.token,
            ),
          ),
        ),
      );
    });
  }

  @override
  Stream<Result<void>> changePassword({
    String password,
    String newPassword,
  }) {
    return _userAndToken.flatMapResult((userAndToken) {
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
    });
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

  ///
  /// Helpers functions
  ///

  Stream<Result<UserAndTokenEntity>> get _userAndToken =>
      _execute(() => _localDataSource.userAndToken);

  ///
  /// Execute [factory] when listen to observable,
  /// if future is successful, emit [Success]
  /// if future complete with error, emit [Failure]
  ///
  Stream<Result<T>> _execute<T>(Future<T> Function() factory) =>
      Rx.fromCallable(factory)
          .doOnError(_handleUnauthenticatedError)
          .map<Result<T>>((result) => Success<T>((b) => b.result = result))
          .onErrorReturnWith(_errorToResult);

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
      final userAndToken = await _localDataSource.userAndToken;
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
