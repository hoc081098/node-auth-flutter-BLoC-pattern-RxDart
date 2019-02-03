import 'dart:convert';

import 'package:node_auth/data/local/local_data_source.dart';
import 'package:node_auth/data/models/local_data_source_exception.dart';
import 'package:node_auth/data/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefUtil implements LocalDataSource {
  static const _kTokenKey = 'com.hoc.node_auth_flutter.token';
  static const _kUserKey = 'com.hoc.node_auth_flutter.user';

  const SharedPrefUtil();

  @override
  Future<String> getToken() async {
    try {
      final sharedPreference = await SharedPreferences.getInstance();
      return sharedPreference.getString(_kTokenKey);
    } catch (e) {
      throw LocalDataSourceException('Cannot get token', e);
    }
  }

  @override
  Future<void> saveToken(String token) async {
    bool result;
    try {
      final sharedPreference = await SharedPreferences.getInstance();
      result = await sharedPreference.setString(_kTokenKey, token);
    } catch (e) {
      throw LocalDataSourceException('Cannot save token', e);
    }
    if (!result) {
      throw LocalDataSourceException('Cannot save token');
    }
  }

  @override
  Future<void> deleteToken() async {
    bool result;
    try {
      final sharedPreference = await SharedPreferences.getInstance();
      result = await sharedPreference.remove(_kTokenKey);
    } catch (e) {
      throw LocalDataSourceException('Cannot delete token', e);
    }

    if (!result) {
      throw LocalDataSourceException('Cannot delete token');
    }
  }

  @override
  Future<void> saveUser(User user) async {
    print('saveUser $user');
    bool result;
    try {
      final sharedPreference = await SharedPreferences.getInstance();
      result = await sharedPreference.setString(_kUserKey, json.encode(user));
    } catch (e) {
      throw LocalDataSourceException('Cannot save user', e);
    }

    if (!result) {
      throw LocalDataSourceException('Cannot save user');
    }
  }

  @override
  Future<void> deleteUser() async {
    bool result;
    try {
      final sharedPreference = await SharedPreferences.getInstance();
      result = await sharedPreference.remove(_kUserKey);
    } catch (e) {
      throw LocalDataSourceException('Cannot delete user', e);
    }

    if (!result) {
      throw LocalDataSourceException('Cannot delete user');
    }
  }

  @override
  Future<User> getUser() async {
    try {
      final sharedPreference = await SharedPreferences.getInstance();
      var string = sharedPreference.getString(_kUserKey);
      if (string == null) {
        return null;
      }
      return User.fromJson(json.decode(string));
    } catch (e) {
      throw LocalDataSourceException('Cannot get user', e);
    }
  }
}
