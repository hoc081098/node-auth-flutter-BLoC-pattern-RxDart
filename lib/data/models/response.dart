class Response {
  final String token;
  final String message;

  Response({this.token, this.message});

  Response.fromJson(Map<String, dynamic> json)
      : message = json['message'],
        token = json['token'];

  @override
  String toString() => 'Response{token=$token, message=$message}';
}
