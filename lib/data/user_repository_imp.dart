import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:node_auth/data/exception/local_data_source_exception.dart';
import 'package:node_auth/data/exception/remote_data_source_exception.dart';
import 'package:node_auth/data/local/entities/user_and_token_entity.dart';
import 'package:node_auth/data/local/entities/user_entity.dart';
import 'package:node_auth/data/local/local_data_source.dart';
import 'package:node_auth/data/remote/remote_data_source.dart';
import 'package:node_auth/data/remote/response/user_response.dart';
import 'package:node_auth/domain/models/app_error.dart';
import 'package:node_auth/domain/models/auth_state.dart';
import 'package:node_auth/domain/models/user.dart';
import 'package:node_auth/domain/models/user_and_token.dart';
import 'package:node_auth/domain/repositories/user_repository.dart';
import 'package:node_auth/utils/streams.dart';
import 'package:tuple/tuple.dart';

part 'mappers.dart';

class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;

  @override
  final Stream<AuthenticationState> authenticationState$;

  @override
  Single<Result<AuthenticationState>> get authenticationState =>
      _execute(() => _localDataSource.userAndToken
          .then(_Mappers.userAndTokenEntityToDomainAuthState));

  UserRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  ) : authenticationState$ = _localDataSource.userAndToken$
            .map(_Mappers.userAndTokenEntityToDomainAuthState)
            .onErrorReturn(UnauthenticatedState())
            .publishValue()
          ..listen((state) => debugPrint('[USER_REPOSITORY] state=$state'))
          ..connect() {
    _init();
  }

  @override
  UnitResultSingle login({
    required String email,
    required String password,
  }) {
    return _execute(() => _remoteDataSource.loginUser(email, password))
        .flatMapEitherSingle((result) {
          final token = result.token!;
          return _execute(() => _remoteDataSource
              .getUserProfile(email, token)
              .then((user) => Tuple2(user, token)));
        })
        .flatMapEitherSingle(
          (tuple) => _execute(
            () => _localDataSource.saveUserAndToken(
              _Mappers.userResponseToUserAndTokenEntity(
                tuple.item1,
                tuple.item2,
              ),
            ),
          ),
        )
        .asUnit();
  }

  @override
  UnitResultSingle registerUser({
    required String name,
    required String email,
    required String password,
  }) =>
      _execute(() => _remoteDataSource.registerUser(name, email, password))
          .asUnit();

  @override
  UnitResultSingle logout() =>
      _execute<void>(() => _localDataSource.removeUserAndToken()).asUnit();

  @override
  UnitResultSingle uploadImage(File image) {
    return _userAndToken
        .flatMapEitherSingle((userAndToken) {
          if (userAndToken == null) {
            return Single.value(
              AppError(
                message: 'Require login!',
                error: 'Email or token is null',
                stackTrace: StackTrace.current,
              ).left(),
            );
          }

          return _execute(
            () => _remoteDataSource
                .uploadImage(
                  image,
                  userAndToken.user.email,
                  userAndToken.token,
                )
                .then((user) => Tuple2(user, userAndToken.token)),
          );
        })
        .flatMapEitherSingle(
          (tuple) => _execute(
            () => _localDataSource.saveUserAndToken(
              _Mappers.userResponseToUserAndTokenEntity(
                tuple.item1,
                tuple.item2,
              ),
            ),
          ),
        )
        .asUnit();
  }

  @override
  UnitResultSingle changePassword({
    required String password,
    required String newPassword,
  }) {
    return _userAndToken.flatMapEitherSingle((userAndToken) {
      if (userAndToken == null) {
        return Single.value(
          AppError(
            message: 'Require login!',
            error: 'Email or token is null',
            stackTrace: StackTrace.current,
          ).left(),
        );
      }

      return _execute(
        () => _remoteDataSource.changePassword(
          userAndToken.user.email,
          password,
          newPassword,
          userAndToken.token,
        ),
      ).asUnit();
    });
  }

  @override
  UnitResultSingle resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) =>
      _execute(
        () => _remoteDataSource.resetPassword(
          email,
          token: token,
          newPassword: newPassword,
        ),
      ).asUnit();

  @override
  UnitResultSingle sendResetPasswordEmail(String email) =>
      _execute(() => _remoteDataSource.resetPassword(email)).asUnit();

  ///
  /// Helpers functions
  ///

  Single<Result<UserAndTokenEntity?>> get _userAndToken =>
      _execute(() => _localDataSource.userAndToken);

  ///
  /// Execute [factory] when listen to observable,
  /// if future is successful, emit [Success]
  /// if future complete with error, emit [Failure]
  ///
  Single<Result<T>> _execute<T>(Future<T> Function() factory) =>
      Single.fromCallable(factory)
          .doOnError(_handleUnauthenticatedError)
          .map<Result<T>>((value) => Right<T>(value))
          .onErrorReturnWith(_errorToResult);

  ///
  /// Like error http interceptor
  ///
  void _handleUnauthenticatedError(Object e, StackTrace? s) {
    if (e is RemoteDataSourceException &&
        e.statusCode == HttpStatus.unauthorized) {
      debugPrint(
          '[USER_REPOSITORY] {interceptor} 401 - unauthenticated error ===> login again');
      _localDataSource.removeUserAndToken();
    }
  }

  ///
  /// Convert error to [Failure]
  ///
  static Result<Never> _errorToResult(Object e, StackTrace s) {
    if (e is RemoteDataSourceException) {
      return AppError(
        message: e.message,
        error: e,
        stackTrace: s,
      ).left();
    }

    if (e is LocalDataSourceException) {
      return AppError(
        message: e.message,
        error: e,
        stackTrace: s,
      ).left();
    }

    return AppError(
      message: e.toString(),
      error: e,
      stackTrace: s,
    ).left();
  }

  ///
  /// Check auth when starting app
  ///
  void _init() async {
    const tag = '[USER_REPOSITORY] { init }';

    try {
      final userAndToken = await _localDataSource.userAndToken;
      debugPrint('$tag userAndToken local=$userAndToken');

      if (userAndToken == null) {
        return;
      }

      final userProfile = await _remoteDataSource.getUserProfile(
        userAndToken.user.email,
        userAndToken.token,
      );
      debugPrint('$tag userProfile server=$userProfile');
      await _localDataSource.saveUserAndToken(
        _Mappers.userResponseToUserAndTokenEntity(
          userProfile,
          userAndToken.token,
        ),
      );
    } on RemoteDataSourceException catch (e) {
      debugPrint('$tag remote error=$e');

      if (e.statusCode == HttpStatus.unauthorized) {
        debugPrint('$tag 401 - unauthenticated error ===> login again');
        await _localDataSource.removeUserAndToken();
      }
    } on LocalDataSourceException catch (e) {
      debugPrint('$tag local error=$e');
      await _localDataSource.removeUserAndToken();
    }
  }
}
