import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:ricesafe_app/features/auth/presentation/screens/login_screen.dart';
import 'package:ricesafe_app/features/auth/presentation/screens/reset_password_screen.dart';

class MockAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  MockAuthNotifier() : super(AuthState());

  @override
  Future<void> loginWithEmailPassword(String email, String password) async {}

  @override
  Future<void> loginWithOAuth(String provider, String idToken) async {}

  @override
  Future<void> registerAndSignIn({
    required String username,
    required String email,
    required String password,
    String role = 'FARMER',
  }) async {}

  @override
  Future<void> restoreSession() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<bool> updateProfile({String? username, String? avatarFilePath}) async =>
      true;

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async =>
      true;
}

void main() {
  testWidgets('LoginScreen forgot button navigates to ForgotPasswordScreen',
      (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/reset-password',
          builder: (context, state) => const ResetPasswordScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => MockAuthNotifier()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('ลืมรหัสผ่าน?'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('ลืมรหัสผ่าน'), findsOneWidget);
    expect(find.textContaining('กรอกอีเมล'), findsWidgets);
  });
}
