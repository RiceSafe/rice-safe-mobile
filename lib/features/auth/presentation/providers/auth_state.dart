import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';
import 'package:ricesafe_app/core/router/auth_router_notifier.dart';
import 'package:ricesafe_app/features/settings/presentation/providers/farm_location_provider.dart';
import '../../data/auth_local_storage.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/user_model.dart';
import 'auth_provider.dart';
import 'auth_token_provider.dart';

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? error;

  final bool profileLoading;
  final bool passwordLoading;
  final String? profileError;
  final String? passwordError;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.profileLoading = false,
    this.passwordLoading = false,
    this.profileError,
    this.passwordError,
  });

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? profileLoading,
    bool? passwordLoading,
    String? profileError,
    String? passwordError,
    bool clearProfileError = false,
    bool clearPasswordError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      profileLoading: profileLoading ?? this.profileLoading,
      passwordLoading: passwordLoading ?? this.passwordLoading,
      profileError: clearProfileError ? null : (profileError ?? this.profileError),
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref)
      : _repository = _ref.read(authRepositoryProvider),
        _storage = _ref.read(authLocalStorageProvider),
        super(AuthState());

  final Ref _ref;
  final AuthRepository _repository;
  final AuthLocalStorage _storage;

  void _syncTokenAndRouter(String? token) {
    _ref.read(authTokenProvider.notifier).state = token;
    _ref.read(authRouterNotifierProvider).notifyAuthChanged();
  }

  Future<void> _applyAuthSuccess(AuthResponse response) async {
    await _storage.saveSession(
      token: response.token,
      user: response.user,
    );
    _syncTokenAndRouter(response.token);
    state = AuthState(
      user: response.user,
      token: response.token,
      isLoading: false,
    );
    _ref.invalidate(farmLocationProvider);
  }

  Future<void> loginWithEmailPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.login(
        email: email.trim(),
        password: password,
      );
      await _applyAuthSuccess(response);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: userFacingMessage(e),
      );
    }
  }

  Future<void> registerAndSignIn({
    required String username,
    required String email,
    required String password,
    String role = 'FARMER',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.register(
        username: username.trim(),
        email: email.trim(),
        password: password,
        role: role,
      );
      await _applyAuthSuccess(response);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: userFacingMessage(e),
      );
    }
  }

  Future<void> loginWithOAuth(String provider, String idToken) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.loginWithOAuth(
        provider: provider,
        idToken: idToken,
      );
      await _applyAuthSuccess(response);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: userFacingMessage(e),
      );
    }
  }

  Future<void> restoreSession() async {
    final token = _storage.readToken();
    if (token == null || token.isEmpty) {
      _syncTokenAndRouter(null);
      return;
    }

    _ref.read(authTokenProvider.notifier).state = token;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.getProfile();
      await _storage.saveSession(token: token, user: user);
      state = AuthState(user: user, token: token, isLoading: false);
    } catch (_) {
      final cached = _storage.readUser();
      if (cached != null) {
        state = AuthState(user: cached, token: token, isLoading: false);
      } else {
        await _storage.clear();
        _ref.read(authTokenProvider.notifier).state = null;
        state = AuthState(isLoading: false);
      }
    }
    _ref.read(authRouterNotifierProvider).notifyAuthChanged();
    _ref.invalidate(farmLocationProvider);
  }

  Future<void> logout() async {
    await _storage.clear();
    _syncTokenAndRouter(null);
    state = AuthState();
    _ref.invalidate(farmLocationProvider);
  }

  Future<bool> updateProfile({
    String? username,
    String? avatarFilePath,
  }) async {
    state = state.copyWith(profileLoading: true, clearProfileError: true);
    try {
      final updatedUser = await _repository.updateProfile(
        username: username,
        avatarFilePath: avatarFilePath,
      );
      if (state.token != null) {
        await _storage.saveSession(token: state.token!, user: updatedUser);
      }
      state = state.copyWith(
        user: updatedUser,
        profileLoading: false,
        clearProfileError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        profileLoading: false,
        profileError: userFacingMessage(e),
      );
      return false;
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(passwordLoading: true, clearPasswordError: true);
    try {
      await _repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(
        passwordLoading: false,
        clearPasswordError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        passwordLoading: false,
        passwordError: userFacingMessage(e),
      );
      return false;
    }
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
