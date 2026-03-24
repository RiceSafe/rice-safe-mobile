import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:ricesafe_app/features/auth/domain/models/user_model.dart';

/// Hive-backed session storage (token + cached user JSON).
class AuthLocalStorage {
  static const String boxName = 'auth';
  static const String keyToken = 'token';
  static const String keyUserJson = 'user_json';

  Box<String> get _box => Hive.box<String>(boxName);

  Future<void> saveSession({required String token, required UserModel user}) async {
    await _box.put(keyToken, token);
    await _box.put(keyUserJson, jsonEncode(user.toJson()));
  }

  String? readToken() => _box.get(keyToken);

  UserModel? readUser() {
    final raw = _box.get(keyUserJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    await _box.delete(keyToken);
    await _box.delete(keyUserJson);
  }
}
