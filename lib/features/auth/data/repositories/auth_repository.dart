import 'package:dio/dio.dart';
import '../../domain/models/user_model.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<AuthResponse> loginWithOAuth({
    required String provider,
    required String idToken,
  }) async {
    try {
      final response = await _dio.post('/auth/oauth', data: {
        'provider': provider,
        'id_token': idToken,
      });

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['error'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? e.message);
    }
  }
}

class AuthResponse {
  final UserModel user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user']),
      token: json['token'],
    );
  }
}
