import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:node_auth/data/local/entities/user_entity.dart';
import 'package:node_auth/data/serializers.dart';

part 'user_and_token_entity.g.dart';

abstract class UserAndTokenEntity
    implements Built<UserAndTokenEntity, UserAndTokenEntityBuilder> {
  @BuiltValueField(wireName: 'token')
  String get token;

  @BuiltValueField(wireName: 'user')
  UserEntity get user;

  static Serializer<UserAndTokenEntity> get serializer =>
      _$userAndTokenEntitySerializer;

  UserAndTokenEntity._();

  factory UserAndTokenEntity(
          [void Function(UserAndTokenEntityBuilder) updates]) =
      _$UserAndTokenEntity;

  factory UserAndTokenEntity.fromJson(Map<String, dynamic> json) =>
      serializers.deserializeWith<UserAndTokenEntity>(serializer, json)!;

  Map<String, dynamic> toJson() =>
      serializers.serializeWith(serializer, this) as Map<String, dynamic>;
}
