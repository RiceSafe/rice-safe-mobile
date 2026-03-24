import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/auth/domain/models/user_model.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/features/auth/presentation/screens/register_screen.dart';
import '../../helpers/test_helpers.dart';

// Mock Notifier
class MockAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  MockAuthNotifier() : super(AuthState());

  bool registerCalled = false;
  String? calledUsername;
  String? calledEmail;
  String? calledPassword;

  @override
  Future<void> registerAndSignIn({
    required String username,
    required String email,
    required String password,
    String role = 'FARMER',
  }) async {
    registerCalled = true;
    calledUsername = username;
    calledEmail = email;
    calledPassword = password;
    
    // จำลองสถานะ Loading แป๊บเดียว
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 10));
    
    // จำลองสถานะ Success
    state = AuthState(
      user: UserModel(
        id: 'new-id',
        username: username,
        email: email,
        role: role,
      ),
      token: 'new-token',
      isLoading: false,
    );
  }

  // Implement methods อื่นๆ
  @override
  Future<void> loginWithEmailPassword(String email, String password) async {}
  @override
  Future<void> loginWithOAuth(String provider, String idToken) async {}
  @override
  Future<void> restoreSession() async {}
  @override
  Future<void> logout() async {}
  @override
  Future<bool> updateProfile({String? username, String? avatarFilePath}) async => true;
  @override
  Future<bool> changePassword({required String oldPassword, required String newPassword}) async => true;
}

void main() {
  late MockGoRouter mockRouter;
  late MockAuthNotifier mockAuthNotifier;

  setUp(() async {
    await TestHive.init();
    mockRouter = MockGoRouter();
    mockAuthNotifier = MockAuthNotifier();
    when(() => mockRouter.go(any())).thenReturn(null);
  });

  tearDown(() async {
    await TestHive.reset();
  });

  testWidgets('RegisterScreen displays correctly', (WidgetTester tester) async {
    final container = await pumpRouterWithProviderContainer(
      tester,
      home: const RegisterScreen(),
      router: mockRouter,
      overrides: [
        authStateProvider.overrideWith((ref) => mockAuthNotifier),
      ],
    );
    addTearDown(container.dispose);

    expect(find.text('สร้างบัญชี'), findsWidgets);
    expect(find.text('ชื่อผู้ใช้'), findsOneWidget);
    expect(find.text('อีเมล'), findsOneWidget);
    expect(find.text('รหัสผ่าน'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
  });

  testWidgets('RegisterScreen navigates to profile photo on submit', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = await pumpRouterWithProviderContainer(
      tester,
      home: const RegisterScreen(),
      router: mockRouter,
      overrides: [
        authStateProvider.overrideWith((ref) => mockAuthNotifier),
      ],
    );
    addTearDown(container.dispose);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'farmer1');
    await tester.pump();
    await tester.enterText(fields.at(1), 'farmer1@test.com');
    await tester.pump();
    await tester.enterText(fields.at(2), 'password123');
    await tester.pump();

    final submit = find.descendant(
      of: find.byType(RegisterScreen),
      matching: find.byType(ElevatedButton),
    );
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    
    // pumpAndSettle จะทำงานผ่านได้ เพราะ Mock เปลี่ยน isLoading เป็น false ทันที
    await tester.pumpAndSettle();

    // ตรวจสอบว่า Mock ถูกเรียกด้วยค่าที่ถูกต้อง
    expect(mockAuthNotifier.registerCalled, isTrue);
    expect(mockAuthNotifier.calledUsername, 'farmer1');
    expect(mockAuthNotifier.calledEmail, 'farmer1@test.com');
    expect(mockAuthNotifier.calledPassword, 'password123');

    verify(() => mockRouter.go('/register/profile-photo')).called(1);
  });
}
