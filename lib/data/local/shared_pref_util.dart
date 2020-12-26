import 'dart:convert';

import 'package:node_auth/data/exception/local_data_source_exception.dart';
import 'package:node_auth/data/local/entities/user_and_token_entity.dart';
import 'package:node_auth/data/local/local_data_source.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

class SharedPrefUtil implements LocalDataSource {
  static const _kUserTokenKey = 'com.hoc.node_auth_flutter.user_and_token';
  final RxSharedPreferences _rxPrefs;

  const SharedPrefUtil(this._rxPrefs);

  @override
  Future<void> removeUserAndToken() async {
    bool result;
    try {
      result = await _rxPrefs.remove(_kUserTokenKey);
    } catch (e) {
      throw LocalDataSourceException('Cannot delete user and token', e);
    }

    if (!result) {
      throw LocalDataSourceException('Cannot delete user and token');
    }
  }

  @override
  Future<void> saveUserAndToken(UserAndTokenEntity userAndToken) async {
    bool result;
    try {
      result = await _rxPrefs.write(_kUserTokenKey, userAndToken, _toString);
    } catch (e) {
      throw LocalDataSourceException('Cannot save user and token', e);
    }
    if (!result) {
      throw LocalDataSourceException('Cannot save user and token');
    }
  }

  @override
  Future<UserAndTokenEntity> get userAndToken =>
      _rxPrefs.read(_kUserTokenKey, _toEntity).catchError((_) => null);

  static UserAndTokenEntity _toEntity(dynamic jsonString) => jsonString == null
      ? null
      : UserAndTokenEntity.fromJson(json.decode(jsonString));

  static String _toString(UserAndTokenEntity entity) =>
      entity == null ? null : jsonEncode(entity);

  @override
  Stream<UserAndTokenEntity> get userAndToken$ =>
      _rxPrefs.observe(_kUserTokenKey, _toEntity).onErrorReturn(null);
}
