class TokenResponse {
  final String token;
  final String message;

  TokenResponse({this.token, this.message});

  TokenResponse.fromJson(Map<String, dynamic> json)
      : message = json['message'],
        token = json['token'];

  @override
  String toString() => 'TokenResponse{token=$token, message=$message}';
}
