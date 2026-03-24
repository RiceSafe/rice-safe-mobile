import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/auth/domain/models/user_model.dart';
import 'package:ricesafe_app/features/auth/onboarding/register_onboarding_state.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/features/auth/presentation/screens/onboarding_profile_photo_screen.dart';

import '../../helpers/test_helpers.dart';

class _PhotoOnboardingMockAuth extends StateNotifier<AuthState>
    implements AuthNotifier {
  _PhotoOnboardingMockAuth()
      : super(
          AuthState(
            user: UserModel(
              id: 'u1',
              username: 'NewUser',
              email: 'n@n.com',
              role: 'FARMER',
            ),
            token: 't',
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

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    RegisterOnboardingState.profileImagePath = null;
    RegisterOnboardingState.pendingUsername = null;
    RegisterOnboardingState.pendingEmail = null;
    mockRouter = MockGoRouter();
    when(() => mockRouter.go(any())).thenReturn(null);
  });

  testWidgets('shows title and skip navigates to farm location',
      (tester) async {
    await pumpRouterApp(
      tester,
      home: const OnboardingProfilePhotoScreen(),
      router: mockRouter,
      overrides: [
        authStateProvider.overrideWith((ref) => _PhotoOnboardingMockAuth()),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('รูปโปรไฟล์'), findsOneWidget);
    expect(find.text('ข้าม'), findsOneWidget);

    await tester.tap(find.text('ข้าม'));
    await tester.pumpAndSettle();

    verify(() => mockRouter.go('/register/farm-location')).called(1);
  });
}
