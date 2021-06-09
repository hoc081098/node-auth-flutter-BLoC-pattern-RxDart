// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<UserEntity> _$userEntitySerializer = new _$UserEntitySerializer();

class _$UserEntitySerializer implements StructuredSerializer<UserEntity> {
  @override
  final Iterable<Type> types = const [UserEntity, _$UserEntity];
  @override
  final String wireName = 'UserEntity';

  @override
  Iterable<Object?> serialize(Serializers serializers, UserEntity object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'email',
      serializers.serialize(object.email,
          specifiedType: const FullType(String)),
      'created_at',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(DateTime)),
    ];
    Object? value;
    value = object.imageUrl;
    if (value != null) {
      result
        ..add('image_url')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  UserEntity deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new UserEntityBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'email':
          result.email = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'created_at':
          result.createdAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime;
          break;
        case 'image_url':
          result.imageUrl = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$UserEntity extends UserEntity {
  @override
  final String name;
  @override
  final String email;
  @override
  final DateTime createdAt;
  @override
  final String? imageUrl;

  factory _$UserEntity([void Function(UserEntityBuilder)? updates]) =>
      (new UserEntityBuilder()..update(updates)).build();

  _$UserEntity._(
      {required this.name,
      required this.email,
      required this.createdAt,
      this.imageUrl})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(name, 'UserEntity', 'name');
    BuiltValueNullFieldError.checkNotNull(email, 'UserEntity', 'email');
    BuiltValueNullFieldError.checkNotNull(createdAt, 'UserEntity', 'createdAt');
  }

  @override
  UserEntity rebuild(void Function(UserEntityBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserEntityBuilder toBuilder() => new UserEntityBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserEntity &&
        name == other.name &&
        email == other.email &&
        createdAt == other.createdAt &&
        imageUrl == other.imageUrl;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, name.hashCode), email.hashCode), createdAt.hashCode),
        imageUrl.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('UserEntity')
          ..add('name', name)
          ..add('email', email)
          ..add('createdAt', createdAt)
          ..add('imageUrl', imageUrl))
        .toString();
  }
}

class UserEntityBuilder implements Builder<UserEntity, UserEntityBuilder> {
  _$UserEntity? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  UserEntityBuilder();

  UserEntityBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _email = $v.email;
      _createdAt = $v.createdAt;
      _imageUrl = $v.imageUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserEntity other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$UserEntity;
  }

  @override
  void update(void Function(UserEntityBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$UserEntity build() {
    final _$result = _$v ??
        new _$UserEntity._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, 'UserEntity', 'name'),
            email: BuiltValueNullFieldError.checkNotNull(
                email, 'UserEntity', 'email'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, 'UserEntity', 'createdAt'),
            imageUrl: imageUrl);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
