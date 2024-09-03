// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthenticatedState extends AuthenticatedState {
  @override
  final UserAndToken userAndToken;

  factory _$AuthenticatedState(
          [void Function(AuthenticatedStateBuilder)? updates]) =>
      (new AuthenticatedStateBuilder()..update(updates))._build();

  _$AuthenticatedState._({required this.userAndToken}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        userAndToken, r'AuthenticatedState', 'userAndToken');
  }

  @override
  AuthenticatedState rebuild(
          void Function(AuthenticatedStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthenticatedStateBuilder toBuilder() =>
      new AuthenticatedStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthenticatedState && userAndToken == other.userAndToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userAndToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthenticatedState')
          ..add('userAndToken', userAndToken))
        .toString();
  }
}

class AuthenticatedStateBuilder
    implements Builder<AuthenticatedState, AuthenticatedStateBuilder> {
  _$AuthenticatedState? _$v;

  UserAndTokenBuilder? _userAndToken;
  UserAndTokenBuilder get userAndToken =>
      _$this._userAndToken ??= new UserAndTokenBuilder();
  set userAndToken(UserAndTokenBuilder? userAndToken) =>
      _$this._userAndToken = userAndToken;

  AuthenticatedStateBuilder();

  AuthenticatedStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userAndToken = $v.userAndToken.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthenticatedState other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$AuthenticatedState;
  }

  @override
  void update(void Function(AuthenticatedStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthenticatedState build() => _build();

  _$AuthenticatedState _build() {
    _$AuthenticatedState _$result;
    try {
      _$result =
          _$v ?? new _$AuthenticatedState._(userAndToken: userAndToken.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'userAndToken';
        userAndToken.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'AuthenticatedState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$UnauthenticatedState extends UnauthenticatedState {
  factory _$UnauthenticatedState(
          [void Function(UnauthenticatedStateBuilder)? updates]) =>
      (new UnauthenticatedStateBuilder()..update(updates))._build();

  _$UnauthenticatedState._() : super._();

  @override
  UnauthenticatedState rebuild(
          void Function(UnauthenticatedStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UnauthenticatedStateBuilder toBuilder() =>
      new UnauthenticatedStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UnauthenticatedState;
  }

  @override
  int get hashCode {
    return 228826372;
  }

  @override
  String toString() {
    return newBuiltValueToStringHelper(r'UnauthenticatedState').toString();
  }
}

class UnauthenticatedStateBuilder
    implements Builder<UnauthenticatedState, UnauthenticatedStateBuilder> {
  _$UnauthenticatedState? _$v;

  UnauthenticatedStateBuilder();

  @override
  void replace(UnauthenticatedState other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$UnauthenticatedState;
  }

  @override
  void update(void Function(UnauthenticatedStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UnauthenticatedState build() => _build();

  _$UnauthenticatedState _build() {
    final _$result = _$v ?? new _$UnauthenticatedState._();
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
