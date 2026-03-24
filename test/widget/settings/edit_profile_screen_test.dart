import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/auth/domain/models/user_model.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/features/settings/presentation/screens/edit_profile_screen.dart';

void main() {
  testWidgets('shows profile form seeded with username', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => _EditProfileMockAuth(),
          ),
        ],
        child: const MaterialApp(
          home: EditProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('แก้ไขโปรไฟล์'), findsOneWidget);
    expect(find.text('ชื่อผู้ใช้งาน'), findsOneWidget);
    expect(find.text('TesterUser'), findsOneWidget);
    expect(find.text('เปลี่ยนรหัสผ่าน'), findsOneWidget);
    expect(find.text('บันทึกการเปลี่ยนแปลง'), findsOneWidget);
  });
}

class _EditProfileMockAuth extends StateNotifier<AuthState> implements AuthNotifier {
  _EditProfileMockAuth()
      : super(
          AuthState(
            user: UserModel(
              id: 'id1',
              username: 'TesterUser',
              email: 't@t.com',
              role: 'FARMER',
            ),
            token: 'tok',
          ),
        );

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
  Future<bool> updateProfile({
    String? username,
    String? avatarFilePath,
  }) async =>
      true;

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async =>
      true;
}
