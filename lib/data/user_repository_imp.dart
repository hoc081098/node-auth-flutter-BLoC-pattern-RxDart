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
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:tuple/tuple.dart';

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
  ) : authenticationState$ = _localDataSource.userAndToken$
            .map(_Mappers.userAndTokenEntityToDomainAuthState)
            .onErrorReturn(UnauthenticatedState())
            .publishValue()
              ..listen((state) => print('[USER_REPOSITORY] state=$state'))
              ..connect() {
    _init();
  }

  @override
  Single_Result_Unit login({
    required String email,
    required String password,
  }) {
    return _execute(() => _remoteDataSource.loginUser(email, password))
        .flatMapResult((result) {
          final token = result.token!;
          return _execute(() => _remoteDataSource
              .getUserProfile(email, token)
              .then((user) => Tuple2(user, token)));
        })
        .flatMapResult(
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
  Single_Result_Unit registerUser({
    required String name,
    required String email,
    required String password,
  }) =>
      _execute(() => _remoteDataSource.registerUser(name, email, password))
          .asUnit();

  @override
  Single_Result_Unit logout() =>
      _execute<void>(() => _localDataSource.removeUserAndToken()).asUnit();

  @override
  Single_Result_Unit uploadImage(File image) {
    return _userAndToken
        .flatMapResult((userAndToken) {
          if (userAndToken == null) {
            return Single.value(
              Failure(
                message: 'Require login!',
                error: 'Email or token is null',
              ),
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
        .flatMapResult(
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
  Single_Result_Unit changePassword({
    required String password,
    required String newPassword,
  }) {
    return _userAndToken.flatMapResult((userAndToken) {
      if (userAndToken == null) {
        return Single.value(
          Failure(
            message: 'Require login!',
            error: 'Email or token is null',
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
      ).asUnit();
    });
  }

  @override
  Single_Result_Unit resetPassword({
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
  Single_Result_Unit sendResetPasswordEmail(String email) =>
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
          .doOnError(
              _handleUnauthenticatedError) // TODO(single): remove singleOrError
          .singleOrError()
          .map<Result<T>>((value) => Success<T>(value))
          .onErrorReturnWith(_errorToResult);

  ///
  /// Like error http interceptor
  ///
  void _handleUnauthenticatedError(Object e, StackTrace? s) {
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
  static Failure _errorToResult(Object e, StackTrace s) {
    if (e is RemoteDataSourceException) {
      return Failure(message: e.message, error: e);
    }
    if (e is LocalDataSourceException) {
      return Failure(message: e.message, error: e);
    }
    return Failure(message: e.toString(), error: e);
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
