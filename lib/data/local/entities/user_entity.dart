import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:node_auth/data/serializers.dart';

part 'user_entity.g.dart';

abstract class UserEntity implements Built<UserEntity, UserEntityBuilder> {
  @BuiltValueField(wireName: 'name')
  String get name;

  @BuiltValueField(wireName: 'email')
  String get email;

  @BuiltValueField(wireName: 'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: 'image_url')
  String? get imageUrl;

  static Serializer<UserEntity> get serializer => _$userEntitySerializer;

  UserEntity._();

  factory UserEntity([void Function(UserEntityBuilder) updates]) = _$UserEntity;

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      serializers.deserializeWith<UserEntity>(serializer, json)!;

  Map<String, dynamic> toJson() =>
      serializers.serializeWith(serializer, this) as Map<String, dynamic>;
}
