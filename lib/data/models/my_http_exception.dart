import 'dart:io';

class MyHttpException extends HttpException {
  final int statusCode;
  MyHttpException(this.statusCode, String message) : super(message);

  @override
  String toString() =>
      'MyHttpException{statusCode=$statusCode, message=$message}';
}
