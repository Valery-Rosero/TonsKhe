class UserEntity {
  final String id;
  final String username;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
  });
}
