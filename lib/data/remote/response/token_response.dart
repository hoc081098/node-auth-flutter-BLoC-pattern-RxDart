import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:node_auth/data/serializers.dart';

part 'token_response.g.dart';

abstract class TokenResponse
    implements Built<TokenResponse, TokenResponseBuilder> {
  @nullable
  String get token;

  String get message;

  static Serializer<TokenResponse> get serializer => _$tokenResponseSerializer;

  TokenResponse._();

  factory TokenResponse([void Function(TokenResponseBuilder) updates]) =
      _$TokenResponse;

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      serializers.deserializeWith(serializer, json);

  Map<String, dynamic> toJson() => serializers.serializeWith(serializer, this);
}
