// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthenticatedState extends AuthenticatedState {
  @override
  final UserAndToken userAndToken;

  factory _$AuthenticatedState(
          [void Function(AuthenticatedStateBuilder) updates]) =>
      (new AuthenticatedStateBuilder()..update(updates)).build();

  _$AuthenticatedState._({this.userAndToken}) : super._() {
    if (userAndToken == null) {
      throw new BuiltValueNullFieldError('AuthenticatedState', 'userAndToken');
    }
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
    return $jf($jc(0, userAndToken.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('AuthenticatedState')
          ..add('userAndToken', userAndToken))
        .toString();
  }
}

class AuthenticatedStateBuilder
    implements Builder<AuthenticatedState, AuthenticatedStateBuilder> {
  _$AuthenticatedState _$v;

  UserAndTokenBuilder _userAndToken;
  UserAndTokenBuilder get userAndToken =>
      _$this._userAndToken ??= new UserAndTokenBuilder();
  set userAndToken(UserAndTokenBuilder userAndToken) =>
      _$this._userAndToken = userAndToken;

  AuthenticatedStateBuilder();

  AuthenticatedStateBuilder get _$this {
    if (_$v != null) {
      _userAndToken = _$v.userAndToken?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthenticatedState other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$AuthenticatedState;
  }

  @override
  void update(void Function(AuthenticatedStateBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$AuthenticatedState build() {
    _$AuthenticatedState _$result;
    try {
      _$result =
          _$v ?? new _$AuthenticatedState._(userAndToken: userAndToken.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'userAndToken';
        userAndToken.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'AuthenticatedState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$UnauthenticatedState extends UnauthenticatedState {
  factory _$UnauthenticatedState(
          [void Function(UnauthenticatedStateBuilder) updates]) =>
      (new UnauthenticatedStateBuilder()..update(updates)).build();

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
    return newBuiltValueToStringHelper('UnauthenticatedState').toString();
  }
}

class UnauthenticatedStateBuilder
    implements Builder<UnauthenticatedState, UnauthenticatedStateBuilder> {
  _$UnauthenticatedState _$v;

  UnauthenticatedStateBuilder();

  @override
  void replace(UnauthenticatedState other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$UnauthenticatedState;
  }

  @override
  void update(void Function(UnauthenticatedStateBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$UnauthenticatedState build() {
    final _$result = _$v ?? new _$UnauthenticatedState._();
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
