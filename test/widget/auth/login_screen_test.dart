import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/auth/presentation/screens/login_screen.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    mockRouter = MockGoRouter();
    when(() => mockRouter.go(any())).thenReturn(null);
    when(() => mockRouter.push(any())).thenAnswer((_) async => null);
  });

  testWidgets('LoginScreen displays correctly', (WidgetTester tester) async {
    await pumpRouterApp(tester, home: const LoginScreen(), router: mockRouter);

    // Verify Logo and Title
    expect(find.text('RiceSafe'), findsOneWidget);
    expect(find.text('เข้าสู่ระบบเพื่อใช้งานแอพพลิเคชั่น'), findsOneWidget);

    // Verify Fields
    expect(find.text('อีเมล'), findsOneWidget);
    expect(find.text('รหัสผ่าน'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));

    // Verify Login Button
    // findsWidgets is used because the text 'เข้าสู่ระบบ' might appear in both the button and the title.
    expect(find.text('เข้าสู่ระบบ'), findsWidgets);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('LoginScreen navigates to home on login', (WidgetTester tester) async {
    // Set a larger screen size
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    await pumpRouterApp(tester, home: const LoginScreen(), router: mockRouter);

    // Reset size after test
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Tap Login Button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify navigation
    verify(() => mockRouter.go('/home')).called(1);
  });

  testWidgets('LoginScreen navigates to register on link tap', (WidgetTester tester) async {
    // Set a larger screen size
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    await pumpRouterApp(tester, home: const LoginScreen(), router: mockRouter);

    // Reset size after test
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Tap Register Link
    await tester.tap(find.text('สร้างบัญชี'));
    await tester.pump();

    // Verify navigation
    verify(() => mockRouter.push('/register')).called(1);
  });
}
