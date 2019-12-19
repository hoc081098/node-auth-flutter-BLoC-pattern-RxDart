class User {
  final String name;
  final String email;
  final DateTime createdAt;
  final String imageUrl;

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        createdAt = DateTime.tryParse(json['created_at']) ?? DateTime.now(),
        imageUrl = json['image_url'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'image_url': imageUrl,
    };
  }

  @override
  String toString() =>
      'User{name=$name, email=$email, imageUrl=$imageUrl, createdAt=$createdAt}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          email == other.email &&
          createdAt == other.createdAt &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      name.hashCode ^ email.hashCode ^ createdAt.hashCode ^ imageUrl.hashCode;
}
