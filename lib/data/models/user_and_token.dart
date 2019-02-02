import 'package:node_auth/data/models/user.dart';

class UserAndToken {
  final User user;
  final String token;

  const UserAndToken(this.user, this.token);

  @override
  String toString() => 'UserAndToken{user=$user, token=$token}';
}
