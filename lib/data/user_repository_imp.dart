import 'dart:io';

import 'package:node_auth/data/local/local_data_source.dart';
import 'package:node_auth/data/models/auth_state.dart';
import 'package:node_auth/data/models/local_data_source_exception.dart';
import 'package:node_auth/data/models/remote_data_source_exception.dart';
import 'package:node_auth/data/models/result.dart';
import 'package:node_auth/data/models/token_response.dart';
import 'package:node_auth/data/models/user.dart';
import 'package:node_auth/data/models/user_and_token.dart';
import 'package:node_auth/data/remote/remote_data_source.dart';
import 'package:node_auth/data/user_repository.dart';
import 'package:rxdart/rxdart.dart';

class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;
  final ValueConnectableObservable<AuthenticationState> _authenticationState$;

  UserRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  )   : assert(_remoteDataSource != null),
        assert(_localDataSource != null),
        _authenticationState$ = _localDataSource.userAndToken$
            .map((userAndToken) => userAndToken == null
                ? const UnauthenticatedState()
                : AuthenticatedState(userAndToken))
            .onErrorReturn(const UnauthenticatedState())
            .publishValue() {
    _init();

    _authenticationState$
        .listen((state) => print('[USER_REPOSITORY] state=$state'));
    _authenticationState$.connect();
  }

  @override
  ValueObservable<AuthenticationState> get authenticationState$ =>
      _authenticationState$;

  @override
  Observable<Result<void>> login({
    String email,
    String password,
  }) =>
      _execute(() => _remoteDataSource.loginUser(email, password))
          .flatMap((result) => _getUserProfileAndSaveToLocal(email, result));

  @override
  Observable<Result<void>> registerUser({
    String name,
    String email,
    String password,
  }) =>
      _execute(() => _remoteDataSource.registerUser(name, email, password));

  @override
  Observable<Result<void>> logout() =>
      _execute(() => _localDataSource.removeUserAndToken());

  @override
  Observable<Result<void>> uploadImage(File image) {
    final userAndToken = _userAndToken;

    if (userAndToken == null) {
      return Observable.just(
        const Failure(
          'Require login!',
          'Email or token is null',
        ),
      );
    }

    return _execute(
      () => _remoteDataSource.uploadImage(
        image,
        userAndToken.user.email,
      ),
    ).asyncMap((result) async {
      if (result is Success<User>) {
        await _localDataSource.saveUserAndToken(
          UserAndToken(
            result.result,
            userAndToken.token,
          ),
        );
      }
      return result;
    });
  }

  @override
  Observable<Result<void>> changePassword({
    String password,
    String newPassword,
  }) {
    final userAndToken = _userAndToken;

    if (userAndToken == null) {
      return Observable.just(
        const Failure(
          'Require login!',
          'Email or token is null',
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
  Observable<Result<void>> resetPassword({
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
  Observable<Result<void>> sendResetPasswordEmail(String email) =>
      _execute(() => _remoteDataSource.resetPassword(email));

  Stream<Result<void>> _getUserProfileAndSaveToLocal(
    String email,
    Result<TokenResponse> tokenResult,
  ) {
    if (tokenResult is Failure) {
      return Observable.just(tokenResult);
    }

    if (tokenResult is Success<TokenResponse>) {
      final token = tokenResult.result.token;
      return _execute(
        () => _remoteDataSource.getUserProfile(
          email,
          token,
        ),
      ).asyncMap((userResult) async {
        if (userResult is Success<User>) {
          await _localDataSource.saveUserAndToken(
            UserAndToken(
              userResult.result,
              token,
            ),
          );
        }
        return userResult;
      });
    }

    return Observable.error('Unknow $tokenResult');
  }

  ///
  /// Helpers functions
  ///

  UserAndToken get _userAndToken => _authenticationState$.value?.userAndToken;

  ///
  /// Execute [factory] when listen to observable,
  /// if future is successful, emit [Success]
  /// if future complete with error, emit [Failure]
  ///
  Observable<Result<T>> _execute<T>(Future<T> Function() factory) {
    return Observable.defer(() {
      return Observable.fromFuture(factory())
          .doOnError(_handleUnauthenticatedError)
          .map<Result<T>>((result) => Success<T>(result))
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
      return Failure(e.message, e);
    }
    if (e is LocalDataSourceException) {
      return Failure(e.message, e);
    }
    return Failure(e.toString(), e);
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
        UserAndToken(
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
