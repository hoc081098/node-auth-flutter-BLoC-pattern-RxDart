// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_and_token.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserAndToken extends UserAndToken {
  @override
  final String token;
  @override
  final User user;

  factory _$UserAndToken([void Function(UserAndTokenBuilder)? updates]) =>
      (new UserAndTokenBuilder()..update(updates))._build();

  _$UserAndToken._({required this.token, required this.user}) : super._() {
    BuiltValueNullFieldError.checkNotNull(token, r'UserAndToken', 'token');
    BuiltValueNullFieldError.checkNotNull(user, r'UserAndToken', 'user');
  }

  @override
  UserAndToken rebuild(void Function(UserAndTokenBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserAndTokenBuilder toBuilder() => new UserAndTokenBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserAndToken && token == other.token && user == other.user;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, token.hashCode), user.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserAndToken')
          ..add('token', token)
          ..add('user', user))
        .toString();
  }
}

class UserAndTokenBuilder
    implements Builder<UserAndToken, UserAndTokenBuilder> {
  _$UserAndToken? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  UserBuilder? _user;
  UserBuilder get user => _$this._user ??= new UserBuilder();
  set user(UserBuilder? user) => _$this._user = user;

  UserAndTokenBuilder();

  UserAndTokenBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _user = $v.user.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserAndToken other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$UserAndToken;
  }

  @override
  void update(void Function(UserAndTokenBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserAndToken build() => _build();

  _$UserAndToken _build() {
    _$UserAndToken _$result;
    try {
      _$result = _$v ??
          new _$UserAndToken._(
              token: BuiltValueNullFieldError.checkNotNull(
                  token, r'UserAndToken', 'token'),
              user: user.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'UserAndToken', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,no_leading_underscores_for_local_identifiers,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new,unnecessary_lambdas
