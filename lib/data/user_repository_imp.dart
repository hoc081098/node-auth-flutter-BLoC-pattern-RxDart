import 'package:meta/meta.dart';
import 'package:node_auth/data/local/local_data_source.dart';
import 'package:node_auth/data/models/my_http_exception.dart';
import 'package:node_auth/data/models/result.dart';
import 'package:node_auth/data/models/shared_pref_exception.dart';
import 'package:node_auth/data/models/user.dart';
import 'package:node_auth/data/models/user_and_token.dart';
import 'package:node_auth/data/remote/api_service.dart';
import 'package:node_auth/data/user_repository.dart';
import 'package:rxdart/rxdart.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;
  final LocalDataSource _localDataSource;
  final BehaviorSubject<UserAndToken> _userAndTokenController;

  const UserRepositoryImpl._(
    this._apiService,
    this._localDataSource,
    this._userAndTokenController,
  )   : assert(_apiService != null),
        assert(_localDataSource != null),
        assert(_userAndTokenController != null);

  factory UserRepositoryImpl({
    @required ApiService apiService,
    @required LocalDataSource localDataSource,
  }) {
    final behaviorSubject = BehaviorSubject<UserAndToken>();
    init(apiService, localDataSource, behaviorSubject);
    return UserRepositoryImpl._(
      apiService,
      localDataSource,
      behaviorSubject,
    );
  }

  @override
  Observable<Result> login({
    String email,
    String password,
  }) {
    return Observable.fromFuture(_apiService.loginUser(email, password))
        .map((response) => response.token)
        .flatMap((token) {
          return Observable.zip2(
            Stream.fromFuture(
              _apiService.getUserProfile(
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
        .map<Result>((_) => Success())
        .onErrorReturnWith(_errorToResult);
  }

  Failure _errorToResult(e) {
    if (e is MyHttpException) {
      return Failure(e.message, e);
    }
    if (e is SharedPrefException) {
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
            _apiService.registerUser(name, email, password))
        .map<Result>((_) => Success())
        .onErrorReturnWith(_errorToResult);
  }

  @override
  Observable<Result> logout() {
    return Observable.zip2(Stream.fromFuture(_localDataSource.deleteToken()),
            Stream.fromFuture(_localDataSource.deleteUser()), (_, __) => null)
        .map<Result>((_) => Success())
        .doOnData((_) => _userAndTokenController.add(UserAndToken(null, null)))
        .onErrorReturnWith(_errorToResult);
  }

  static void init(
    ApiService apiService,
    LocalDataSource localDataSource,
    BehaviorSubject behaviorSubject,
  ) async {
    try {
      final userAndToken = await Future.wait(
              [localDataSource.getToken(), localDataSource.getUser()])
          .then((list) => UserAndToken(list[1] as User, list[0] as String));

      behaviorSubject.add(userAndToken);
      print('[DEBUG] init userAndToken=$userAndToken');

      final token = userAndToken.token;
      if (token != null) {
        final userProfile = await apiService.getUserProfile(
          userAndToken.user.email,
          token,
        );
        behaviorSubject.add(UserAndToken(userProfile, token));
        await localDataSource.saveUser(userProfile);
      }
    } on MyHttpException catch (e) {
      if (e.statusCode == 0) {
        behaviorSubject.add(UserAndToken(null, null));
      }
    } catch (e) {
      print('[DEBUG] init error=$e');
    }
  }
}
