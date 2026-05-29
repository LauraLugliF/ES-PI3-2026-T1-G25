//Max Thomazini Barbosa RA:25003934
class ProfileData {
  const ProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.cpf,
    required this.createdAt,
  });

  final String name;
  final String email;
  final String phone;
  final String cpf;
  final DateTime? createdAt;
}
