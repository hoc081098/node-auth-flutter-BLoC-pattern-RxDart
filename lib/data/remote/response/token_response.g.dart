// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<TokenResponse> _$tokenResponseSerializer =
    new _$TokenResponseSerializer();

class _$TokenResponseSerializer implements StructuredSerializer<TokenResponse> {
  @override
  final Iterable<Type> types = const [TokenResponse, _$TokenResponse];
  @override
  final String wireName = 'TokenResponse';

  @override
  Iterable<Object> serialize(Serializers serializers, TokenResponse object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'message',
      serializers.serialize(object.message,
          specifiedType: const FullType(String)),
    ];
    if (object.token != null) {
      result
        ..add('token')
        ..add(serializers.serialize(object.token,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  TokenResponse deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TokenResponseBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'token':
          result.token = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'message':
          result.message = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$TokenResponse extends TokenResponse {
  @override
  final String token;
  @override
  final String message;

  factory _$TokenResponse([void Function(TokenResponseBuilder) updates]) =>
      (new TokenResponseBuilder()..update(updates)).build();

  _$TokenResponse._({this.token, this.message}) : super._() {
    if (message == null) {
      throw new BuiltValueNullFieldError('TokenResponse', 'message');
    }
  }

  @override
  TokenResponse rebuild(void Function(TokenResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TokenResponseBuilder toBuilder() => new TokenResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TokenResponse &&
        token == other.token &&
        message == other.message;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, token.hashCode), message.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('TokenResponse')
          ..add('token', token)
          ..add('message', message))
        .toString();
  }
}

class TokenResponseBuilder
    implements Builder<TokenResponse, TokenResponseBuilder> {
  _$TokenResponse _$v;

  String _token;
  String get token => _$this._token;
  set token(String token) => _$this._token = token;

  String _message;
  String get message => _$this._message;
  set message(String message) => _$this._message = message;

  TokenResponseBuilder();

  TokenResponseBuilder get _$this {
    if (_$v != null) {
      _token = _$v.token;
      _message = _$v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TokenResponse other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$TokenResponse;
  }

  @override
  void update(void Function(TokenResponseBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$TokenResponse build() {
    final _$result =
        _$v ?? new _$TokenResponse._(token: token, message: message);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
