import 'package:built_value/built_value.dart';

part 'user.g.dart';

abstract class User implements Built<User, UserBuilder> {
  String get name;

  String get email;

  DateTime get createdAt;

  String get imageUrl;

  User._();

  factory User([void Function(UserBuilder) updates]) = _$User;
}
