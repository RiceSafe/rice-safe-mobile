class UserModel {
  final String id;
  final String username;
  final String? email;
  final String role;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    required this.role,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      role: json['role'] ?? 'FARMER',
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'avatar_url': avatarUrl,
    };
  }
}
