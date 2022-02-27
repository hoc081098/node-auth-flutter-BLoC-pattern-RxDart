import 'package:flutter/services.dart';
import 'package:node_auth/data/exception/local_data_source_exception.dart';
import 'package:node_auth/data/local/local_data_source.dart';

class MethodChannelCryptoImpl implements Crypto {
  static const cryptoChannel = 'com.hoc.node_auth/crypto';
  static const cryptoErrorCode = 'com.hoc.node_auth/crypto_error';
  static const encryptMethod = 'encrypt';
  static const decryptMethod = 'decrypt';
  static const MethodChannel channel = MethodChannel(cryptoChannel);

  @override
  Future<String> encrypt(String plaintext) => channel
      .invokeMethod<String>(encryptMethod, plaintext)
      .then((v) => v!)
      .onError<MissingPluginException>((e, s) => plaintext)
      .onError<Object>((e, s) =>
          throw LocalDataSourceException('Cannot encrypt the plaintext', e, s));

  @override
  Future<String> decrypt(String ciphertext) => channel
      .invokeMethod<String>(decryptMethod, ciphertext)
      .then((v) => v!)
      .onError<MissingPluginException>((e, s) => ciphertext)
      .onError<Object>((e, s) => throw LocalDataSourceException(
          'Cannot decrypt the ciphertext', e, s));
}
