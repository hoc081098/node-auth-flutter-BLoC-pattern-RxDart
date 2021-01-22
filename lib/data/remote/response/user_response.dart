import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:node_auth/data/serializers.dart';

part 'user_response.g.dart';

abstract class UserResponse
    implements Built<UserResponse, UserResponseBuilder> {
  @BuiltValueField(wireName: 'name')
  String get name;

  @BuiltValueField(wireName: 'email')
  String get email;

  @BuiltValueField(wireName: 'created_at')
  DateTime get createdAt;

  @nullable
  @BuiltValueField(wireName: 'image_url')
  String get imageUrl;

  static Serializer<UserResponse> get serializer => _$userResponseSerializer;

  UserResponse._();

  factory UserResponse([void Function(UserResponseBuilder) updates]) =
      _$UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      serializers.deserializeWith<UserResponse>(serializer, json);

  Map<String, dynamic> toJson() => serializers.serializeWith(serializer, this);
}
