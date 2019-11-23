import 'dart:convert';

import 'package:node_auth/data/local/local_data_source.dart';
import 'package:node_auth/data/models/local_data_source_exception.dart';
import 'package:node_auth/data/models/user_and_token.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

class SharedPrefUtil implements LocalDataSource {
  static const _kUserTokenKey = 'com.hoc.node_auth_flutter.user_and_token';

  final RxSharedPreferences _rxPrefs;
  final ValueObservable<UserAndToken> _userAndToken$;

  SharedPrefUtil(this._rxPrefs)
      : _userAndToken$ = _rxPrefs
            .getStringObservable(_kUserTokenKey)
            .map((jsonString) => jsonString == null
                ? null
                : UserAndToken.fromJson(json.decode(jsonString)))
            .onErrorReturn(null)
            .shareValue();

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
  Future<void> saveUserAndToken(UserAndToken userAndToken) async {
    bool result;
    try {
      result =
          await _rxPrefs.setString(_kUserTokenKey, json.encode(userAndToken));
      print('Saved $userAndToken');
    } catch (e) {
      throw LocalDataSourceException('Cannot save user and token', e);
    }
    if (!result) {
      throw LocalDataSourceException('Cannot save user and token');
    }
  }

  @override
  ValueObservable<UserAndToken> get userAndToken$ => _userAndToken$;
}
