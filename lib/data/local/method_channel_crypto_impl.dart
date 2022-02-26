import 'dart:typed_data';

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
  Future<Uint8List> encrypt(Uint8List plaintext) => channel
      .invokeMethod<Uint8List>(encryptMethod, plaintext)
      .then((v) => v!)
      .onError<MissingPluginException>((e, s) => plaintext)
      .onError<Object>((e, s) =>
          throw LocalDataSourceException('Cannot encrypt the plaintext', e, s));

  @override
  Future<Uint8List> decrypt(Uint8List ciphertext) => channel
      .invokeMethod<Uint8List>(decryptMethod, ciphertext)
      .then((v) => v!)
      .onError<MissingPluginException>((e, s) => ciphertext)
      .onError<Object>((e, s) => throw LocalDataSourceException(
          'Cannot decrypt the ciphertext', e, s));
}
