import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ricesafe_app/core/network/dio_error_detail.dart';
import '../../domain/models/user_model.dart';

String _basename(String filePath) {
  final normalized = filePath.replaceAll('\\', '/');
  final i = normalized.lastIndexOf('/');
  return i < 0 ? normalized : normalized.substring(i + 1);
}

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 && response.data != null) {
        return AuthResponse.fromJson(response.data!);
      }
      throw Exception(response.data?['error']?.toString() ?? 'Login failed');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    String role = 'FARMER',
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      if (response.statusCode == 201 && response.data != null) {
        return AuthResponse.fromJson(response.data!);
      }
      throw Exception(response.data?['error']?.toString() ?? 'Register failed');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  Future<AuthResponse> loginWithOAuth({
    required String provider,
    required String idToken,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/oauth',
        data: {
          'provider': provider,
          'id_token': idToken,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return AuthResponse.fromJson(response.data!);
      }
      throw Exception(response.data?['error']?.toString() ?? 'Login failed');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  /// `GET /auth/me` — response is the user object (not wrapped).
  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data!);
      }
      throw Exception('Failed to load profile');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  /// `PUT /auth/me` — multipart: optional `username`, optional `avatar` file.
  Future<UserModel> updateProfile({
    String? username,
    String? avatarFilePath,
  }) async {
    if (username == null && (avatarFilePath == null || avatarFilePath.isEmpty)) {
      throw Exception('ไม่มีข้อมูลที่จะอัปเดต');
    }
    final map = <String, dynamic>{};
    if (username != null) {
      map['username'] = username;
    }
    if (avatarFilePath != null && avatarFilePath.isNotEmpty) {
      final file = File(avatarFilePath);
      if (!await file.exists()) {
        throw Exception('ไม่พบไฟล์รูปภาพ');
      }
      map['avatar'] = await MultipartFile.fromFile(
        avatarFilePath,
        filename: _basename(avatarFilePath),
      );
    }
    final formData = FormData.fromMap(map);
    try {
      // BaseOptions sets application/json; must not override multipart boundary.
      final response = await _dio.put<Map<String, dynamic>>(
        '/auth/me',
        data: formData,
        options: Options(contentType: null),
      );
      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data!);
      }
      throw Exception(response.data?['error']?.toString() ?? 'อัปเดตโปรไฟล์ไม่สำเร็จ');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/change-password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
      if (response.statusCode == 200) return;
      throw Exception(response.data?['error']?.toString() ?? 'เปลี่ยนรหัสผ่านไม่สำเร็จ');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  /// `POST /auth/forgot-password` — sends reset code to email if account exists.
  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/forgot-password',
        data: {'email': email.trim()},
      );
      if (response.statusCode == 200) return;
      throw Exception(
        response.data?['error']?.toString() ?? 'ส่งคำขอรีเซ็ตรหัสผ่านไม่สำเร็จ',
      );
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  /// `POST /auth/reset-password` — set new password using token from email.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/reset-password',
        data: {
          'token': token.trim(),
          'new_password': newPassword,
        },
      );
      if (response.statusCode == 200) return;
      throw Exception(
        response.data?['error']?.toString() ?? 'รีเซ็ตรหัสผ่านไม่สำเร็จ',
      );
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }
}

class AuthResponse {
  final UserModel user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}
