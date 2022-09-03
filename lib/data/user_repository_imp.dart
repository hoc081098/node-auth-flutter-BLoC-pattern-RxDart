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
  final Stream<Result<AuthenticationState>> authenticationState$;

  @override
  Single<Result<AuthenticationState>> get authenticationState =>
      _executeFuture(() => _localDataSource.userAndToken
          .then(_Mappers.userAndTokenEntityToDomainAuthState));

  UserRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  ) : authenticationState$ = _localDataSource.userAndToken$
            .map(_Mappers.userAndTokenEntityToDomainAuthState)
            .toEitherStream(_errorToAppError)
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
    return _remoteDataSource
        .loginUser(email, password)
        .toEitherSingle(_errorToAppError)
        .flatMapEitherSingle((result) {
          final token = result.token!;
          return _remoteDataSource
              .getUserProfile(email, token)
              .map((user) => Tuple2(user, token))
              .toEitherSingle(_errorToAppError);
        })
        .flatMapEitherSingle(
          (tuple) => _executeFuture(
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
      _remoteDataSource
          .registerUser(name, email, password)
          .toEitherSingle(_errorToAppError)
          .asUnit();

  @override
  UnitResultSingle logout() =>
      _executeFuture<void>(() => _localDataSource.removeUserAndToken())
          .asUnit();

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

          return _remoteDataSource
              .uploadImage(
                image,
                userAndToken.user.email,
                userAndToken.token,
              )
              .map((user) => Tuple2(user, userAndToken.token))
              .toEitherSingle(_errorToAppError);
        })
        .flatMapEitherSingle(
          (tuple) => _executeFuture(
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

      return _remoteDataSource
          .changePassword(
            userAndToken.user.email,
            password,
            newPassword,
            userAndToken.token,
          )
          .toEitherSingle(_errorToAppError)
          .asUnit();
    });
  }

  @override
  UnitResultSingle resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) =>
      _remoteDataSource
          .resetPassword(
            email,
            token: token,
            newPassword: newPassword,
          )
          .toEitherSingle(_errorToAppError)
          .asUnit();

  @override
  UnitResultSingle sendResetPasswordEmail(String email) => _remoteDataSource
      .resetPassword(email)
      .toEitherSingle(_errorToAppError)
      .asUnit();

  ///
  /// Helpers functions
  ///

  Single<Result<UserAndTokenEntity?>> get _userAndToken =>
      _executeFuture(() => _localDataSource.userAndToken);

  ///
  /// Execute [factory] when listen to observable,
  /// if future is successful, emit [Success]
  /// if future complete with error, emit [Failure]
  ///
  static Single<Result<T>> _executeFuture<T>(Future<T> Function() factory) =>
      Single.fromCallable(factory).toEitherSingle(_errorToAppError);

  ///
  /// Convert error to [Failure]
  ///
  static AppError _errorToAppError(Object e, StackTrace s) {
    if (e is RemoteDataSourceException) {
      return AppError(
        message: e.message,
        error: e,
        stackTrace: s,
      );
    }

    if (e is LocalDataSourceException) {
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

      final userProfile = await _remoteDataSource
          .getUserProfile(
            userAndToken.user.email,
            userAndToken.token,
          )
          .single;

      debugPrint('$tag userProfile server=$userProfile');
      await _localDataSource.saveUserAndToken(
        _Mappers.userResponseToUserAndTokenEntity(
          userProfile,
          userAndToken.token,
        ),
      );
    } on RemoteDataSourceException catch (e) {
      debugPrint('$tag remote error=$e');
    } on LocalDataSourceException catch (e) {
      debugPrint('$tag local error=$e');
      await _localDataSource.removeUserAndToken();
    }
  }
}
