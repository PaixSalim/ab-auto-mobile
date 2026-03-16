class UserEntity {
  final String token;
  final String fullName;
  final String email;
  final String role;

  const UserEntity({
    required this.token,
    required this.fullName,
    required this.email,
    required this.role,
  });
}
