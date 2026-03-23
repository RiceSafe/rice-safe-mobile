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
    // Backend sends UUID as string; ignore extra fields (created_at, updated_at, etc.)
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email'] as String?,
      role: json['role']?.toString() ?? 'FARMER',
      avatarUrl: json['avatar_url'] as String?,
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
