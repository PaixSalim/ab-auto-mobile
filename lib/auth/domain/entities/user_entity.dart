class UserEntity {
  final String id;
  final String token;
  final String fullName;
  final String email;
  final String phone;
  final String role;

  const UserEntity({
    this.id = '',
    required this.token,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
  });
}
