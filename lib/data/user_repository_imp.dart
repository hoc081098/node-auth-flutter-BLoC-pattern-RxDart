import 'dart:io';

import 'package:meta/meta.dart';
import 'package:node_auth/data/local/local_data_source.dart';
import 'package:node_auth/data/models/local_data_source_exception.dart';
import 'package:node_auth/data/models/remote_data_source_exception.dart';
import 'package:node_auth/data/models/result.dart';
import 'package:node_auth/data/models/user.dart';
import 'package:node_auth/data/models/user_and_token.dart';
import 'package:node_auth/data/remote/remote_data_source.dart';
import 'package:node_auth/data/user_repository.dart';
import 'package:rxdart/rxdart.dart';

class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;
  final BehaviorSubject<UserAndToken> _userAndTokenController;

  const UserRepositoryImpl._(
    this._remoteDataSource,
    this._localDataSource,
    this._userAndTokenController,
  )   : assert(_remoteDataSource != null),
        assert(_localDataSource != null),
        assert(_userAndTokenController != null);

  factory UserRepositoryImpl({
    @required RemoteDataSource remoteDataSource,
    @required LocalDataSource localDataSource,
  }) {
    final behaviorSubject = BehaviorSubject<UserAndToken>();
    behaviorSubject.stream.listen((userAndToken) {
      print('[DEBUG] UserRepositoryImpl userAndToken=$userAndToken');
    });
    _init(remoteDataSource, localDataSource, behaviorSubject);
    return UserRepositoryImpl._(
      remoteDataSource,
      localDataSource,
      behaviorSubject,
    );
  }

  @override
  Observable<Result> login({
    String email,
    String password,
  }) {
    return Observable.fromFuture(_remoteDataSource.loginUser(email, password))
        .map((response) => response.token)
        .flatMap((token) {
          return Observable.zip2(
            Stream.fromFuture(
              _remoteDataSource.getUserProfile(
                email,
                token,
              ),
            ),
            Stream.fromFuture(
              _localDataSource.saveToken(token),
            ),
            (User user, _) => user,
          ).map((user) => UserAndToken(user, token));
        })
        .flatMap((userAndToken) {
          return Stream.fromFuture(_localDataSource.saveUser(userAndToken.user))
              .map((_) => userAndToken);
        })
        .doOnData((userAndToken) {
          _userAndTokenController.add(
            UserAndToken(
              userAndToken.user,
              userAndToken.token,
            ),
          );
        })
        .map<Result>((_) => const Success())
        .onErrorReturnWith(_errorToResult);
  }

  Failure _errorToResult(e) {
    if (e is RemoteDataSourceException) {
      return Failure(e.message, e);
    }
    if (e is LocalDataSourceException) {
      return Failure(e.message, e);
    }
    return Failure(e.toString(), e);
  }

  @override
  ValueObservable<UserAndToken> get userAndToken$ =>
      _userAndTokenController.stream;

  @override
  Observable<Result> registerUser({
    String name,
    String email,
    String password,
  }) {
    return Observable.fromFuture(
            _remoteDataSource.registerUser(name, email, password))
        .map<Result>((_) => const Success())
        .onErrorReturnWith(_errorToResult);
  }

  @override
  Observable<Result> logout() {
    return Observable.zip2(Stream.fromFuture(_localDataSource.deleteToken()),
            Stream.fromFuture(_localDataSource.deleteUser()), (_, __) => null)
        .map<Result>((_) => const Success())
        .doOnData((_) => _userAndTokenController.add(UserAndToken(null, null)))
        .onErrorReturnWith(_errorToResult);
  }

  static void _init(
    RemoteDataSource remoteDataSource,
    LocalDataSource localDataSource,
    BehaviorSubject behaviorSubject,
  ) async {
    try {
      final userAndToken = await Future.wait([
        localDataSource.getToken(),
        localDataSource.getUser(),
      ]).then((list) => UserAndToken(list[1] as User, list[0] as String));

      behaviorSubject.add(userAndToken);
      print('[DEBUG] init userAndToken local=$userAndToken');

      if (userAndToken.token != null && userAndToken.user != null) {
        final userProfile = await remoteDataSource.getUserProfile(
          userAndToken.user.email,
          userAndToken.token,
        );
        behaviorSubject.add(UserAndToken(userProfile, userAndToken.token));
        await localDataSource.saveUser(userProfile);
        print('[DEBUG] init userProfile server=$userProfile');
      }
    } on RemoteDataSourceException catch (e) {
      print('[DEBUG] init error=$e');
      if (e.statusCode == 401 && e.message == 'Invalid token!') {
        print('[DEBUG] init error=$e invalid token ==> login again');
        behaviorSubject.add(UserAndToken(null, null));
      }
    } catch (e) {
      print('[DEBUG] init error=$e');
    }
  }

  @override
  Observable<Result> uploadImage(File image) {
    var email = _userAndTokenController.value?.user?.email;
    var token = _userAndTokenController.value?.token;
    if (email == null || token == null) {
      return Observable.just(
        const Failure(
          'Require login!',
          'Email or token is null',
        ),
      );
    }
    return Observable.fromFuture(_remoteDataSource.uploadImage(image, email))
        .flatMap((user) {
          return Stream.fromFuture(_localDataSource.saveUser(user))
              .map((_) => user);
        })
        .doOnData((user) {
          _userAndTokenController.add(UserAndToken(user, token));
        })
        .map<Result>((_) => const Success())
        .onErrorReturnWith(_errorToResult);
  }

  @override
  Observable<Result> changePassword({
    String password,
    String newPassword,
  }) {
    var email = _userAndTokenController.value?.user?.email;
    var token = _userAndTokenController.value?.token;
    if (email == null || token == null) {
      return Observable.just(
        const Failure(
          'Require login!',
          'Email or token is null',
        ),
      );
    }
    return Observable.fromFuture(_remoteDataSource.changePassword(
            email, password, newPassword, token))
        .map<Result>((_) => const Success())
        .onErrorReturnWith(_errorToResult);
  }
}
