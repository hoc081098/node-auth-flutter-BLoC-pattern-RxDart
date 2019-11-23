import 'package:node_auth/data/models/user.dart';

class UserAndToken {
  // not null
  final User user;

  // not null
  final String token;

  const UserAndToken(this.user, this.token)
      : assert(user != null),
        assert(token != null);

  factory UserAndToken.fromJson(Map<String, dynamic> json) {
    return UserAndToken(
      User.fromJson(json['user']),
      json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }

  @override
  String toString() => 'UserAndToken{user: $user, token: $token}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAndToken &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          token == other.token;

  @override
  int get hashCode => user.hashCode ^ token.hashCode;
}
