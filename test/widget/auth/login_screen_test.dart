import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/auth/domain/models/user_model.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/features/auth/presentation/screens/login_screen.dart';
import '../../helpers/test_helpers.dart';

// Mock Notifier แทนที่จะ Mock Repository
class MockAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  MockAuthNotifier() : super(AuthState());

  bool loginCalled = false;
  String? calledEmail;
  String? calledPassword;

  @override
  Future<void> loginWithEmailPassword(String email, String password) async {
    loginCalled = true;
    calledEmail = email;
    calledPassword = password;
    
    // จำลองสถานะ Loading แป๊บเดียว
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 10));
    
    // จำลองสถานะ Success
    state = AuthState(
      user: UserModel(
        id: 'test-id',
        username: 'Tester',
        email: email,
        role: 'FARMER',
      ),
      token: 'test-token',
      isLoading: false,
    );
  }

  // Implement methods อื่นๆ ให้ครบตาม interface (แต่ไม่ต้องทำอะไรถ้าไม่ได้ใช้ในเทสนี้)
  @override
  Future<void> loginWithOAuth(String provider, String idToken) async {}
  @override
  Future<void> registerAndSignIn({required String username, required String email, required String password, String role = 'FARMER'}) async {}
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
    when(() => mockRouter.push(any())).thenAnswer((_) async => null);
  });

  tearDown(() async {
    await TestHive.reset();
  });

  testWidgets('LoginScreen displays correctly', (WidgetTester tester) async {
    final container = await pumpRouterWithProviderContainer(
      tester,
      home: const LoginScreen(),
      router: mockRouter,
      overrides: [
        authStateProvider.overrideWith((ref) => mockAuthNotifier),
      ],
    );
    addTearDown(container.dispose);

    expect(find.text('RiceSafe'), findsOneWidget);
    expect(find.text('เข้าสู่ระบบเพื่อใช้งานแอพพลิเคชั่น'), findsOneWidget);
    expect(find.text('อีเมล'), findsOneWidget);
    expect(find.text('รหัสผ่าน'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('เข้าสู่ระบบ'), findsWidgets);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('LoginScreen navigates to home on login', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = await pumpRouterWithProviderContainer(
      tester,
      home: const LoginScreen(),
      router: mockRouter,
      overrides: [
        authStateProvider.overrideWith((ref) => mockAuthNotifier),
      ],
    );
    addTearDown(container.dispose);

    await tester.enterText(find.byType(TextField).first, 't@test.com');
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, 'secret12');
    await tester.pump();

    final loginButton = find.descendant(
      of: find.byType(LoginScreen),
      matching: find.byType(ElevatedButton),
    );
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    
    // pumpAndSettle จะทำงานผ่านได้ เพราะ Mock เปลี่ยน isLoading เป็น false ทันที
    await tester.pumpAndSettle();

    // ตรวจสอบว่า Mock ถูกเรียกด้วยค่าที่ถูกต้อง
    expect(mockAuthNotifier.loginCalled, isTrue);
    expect(mockAuthNotifier.calledEmail, 't@test.com');
    expect(mockAuthNotifier.calledPassword, 'secret12');
    
    // ตรวจสอบว่ามีการนำทางไปหน้า home
    verify(() => mockRouter.go('/home')).called(1);
  });

  testWidgets('LoginScreen navigates to register on link tap', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = await pumpRouterWithProviderContainer(
      tester,
      home: const LoginScreen(),
      router: mockRouter,
      overrides: [
        authStateProvider.overrideWith((ref) => mockAuthNotifier),
      ],
    );
    addTearDown(container.dispose);

    await tester.tap(find.text('สร้างบัญชี'));
    await tester.pump();

    verify(() => mockRouter.push('/register')).called(1);
  });
}
