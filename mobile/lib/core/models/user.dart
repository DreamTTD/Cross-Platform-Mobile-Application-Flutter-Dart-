class User {
  final String email;
  final String role;
  final String memberSince;

  User({required this.email, required this.role, required this.memberSince});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String,
      role: json['role'] as String? ?? 'User',
      memberSince: json['memberSince'] as String? ?? 'N/A',
    );
  }
}
