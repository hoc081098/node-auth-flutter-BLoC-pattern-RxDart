import 'package:node_auth/data/models/user.dart';

class UserAndToken {
  final User user;
  final String token;

  const UserAndToken(this.user, this.token);

  @override
  String toString() => 'UserAndToken{user=$user, token=$token}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserAndToken &&
              runtimeType == other.runtimeType &&
              user == other.user &&
              token == other.token;

  @override
  int get hashCode =>
      user.hashCode ^
      token.hashCode;
}
