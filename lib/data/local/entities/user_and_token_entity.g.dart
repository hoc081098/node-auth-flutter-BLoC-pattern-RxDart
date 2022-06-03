// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_and_token_entity.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<UserAndTokenEntity> _$userAndTokenEntitySerializer =
    new _$UserAndTokenEntitySerializer();

class _$UserAndTokenEntitySerializer
    implements StructuredSerializer<UserAndTokenEntity> {
  @override
  final Iterable<Type> types = const [UserAndTokenEntity, _$UserAndTokenEntity];
  @override
  final String wireName = 'UserAndTokenEntity';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, UserAndTokenEntity object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'token',
      serializers.serialize(object.token,
          specifiedType: const FullType(String)),
      'user',
      serializers.serialize(object.user,
          specifiedType: const FullType(UserEntity)),
    ];

    return result;
  }

  @override
  UserAndTokenEntity deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new UserAndTokenEntityBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'token':
          result.token = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'user':
          result.user.replace(serializers.deserialize(value,
              specifiedType: const FullType(UserEntity))! as UserEntity);
          break;
      }
    }

    return result.build();
  }
}

class _$UserAndTokenEntity extends UserAndTokenEntity {
  @override
  final String token;
  @override
  final UserEntity user;

  factory _$UserAndTokenEntity(
          [void Function(UserAndTokenEntityBuilder)? updates]) =>
      (new UserAndTokenEntityBuilder()..update(updates))._build();

  _$UserAndTokenEntity._({required this.token, required this.user})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        token, r'UserAndTokenEntity', 'token');
    BuiltValueNullFieldError.checkNotNull(user, r'UserAndTokenEntity', 'user');
  }

  @override
  UserAndTokenEntity rebuild(
          void Function(UserAndTokenEntityBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserAndTokenEntityBuilder toBuilder() =>
      new UserAndTokenEntityBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserAndTokenEntity &&
        token == other.token &&
        user == other.user;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, token.hashCode), user.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserAndTokenEntity')
          ..add('token', token)
          ..add('user', user))
        .toString();
  }
}

class UserAndTokenEntityBuilder
    implements Builder<UserAndTokenEntity, UserAndTokenEntityBuilder> {
  _$UserAndTokenEntity? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  UserEntityBuilder? _user;
  UserEntityBuilder get user => _$this._user ??= new UserEntityBuilder();
  set user(UserEntityBuilder? user) => _$this._user = user;

  UserAndTokenEntityBuilder();

  UserAndTokenEntityBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _user = $v.user.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserAndTokenEntity other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$UserAndTokenEntity;
  }

  @override
  void update(void Function(UserAndTokenEntityBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserAndTokenEntity build() => _build();

  _$UserAndTokenEntity _build() {
    _$UserAndTokenEntity _$result;
    try {
      _$result = _$v ??
          new _$UserAndTokenEntity._(
              token: BuiltValueNullFieldError.checkNotNull(
                  token, r'UserAndTokenEntity', 'token'),
              user: user.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'UserAndTokenEntity', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,no_leading_underscores_for_local_identifiers,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new,unnecessary_lambdas
