// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$User extends User {
  @override
  final String name;
  @override
  final String email;
  @override
  final DateTime createdAt;
  @override
  final String? imageUrl;

  factory _$User([void Function(UserBuilder)? updates]) =>
      (new UserBuilder()..update(updates)).build();

  _$User._(
      {required this.name,
      required this.email,
      required this.createdAt,
      this.imageUrl})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(name, 'User', 'name');
    BuiltValueNullFieldError.checkNotNull(email, 'User', 'email');
    BuiltValueNullFieldError.checkNotNull(createdAt, 'User', 'createdAt');
  }

  @override
  User rebuild(void Function(UserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserBuilder toBuilder() => new UserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is User &&
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
    return (newBuiltValueToStringHelper('User')
          ..add('name', name)
          ..add('email', email)
          ..add('createdAt', createdAt)
          ..add('imageUrl', imageUrl))
        .toString();
  }
}

class UserBuilder implements Builder<User, UserBuilder> {
  _$User? _$v;

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

  UserBuilder();

  UserBuilder get _$this {
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
  void replace(User other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$User;
  }

  @override
  void update(void Function(UserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$User build() {
    final _$result = _$v ??
        new _$User._(
            name: BuiltValueNullFieldError.checkNotNull(name, 'User', 'name'),
            email:
                BuiltValueNullFieldError.checkNotNull(email, 'User', 'email'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, 'User', 'createdAt'),
            imageUrl: imageUrl);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
