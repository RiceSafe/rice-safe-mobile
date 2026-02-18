import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/auth/presentation/screens/register_screen.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    mockRouter = MockGoRouter();
  });

  testWidgets('RegisterScreen displays correctly', (WidgetTester tester) async {
    await pumpRouterApp(tester, home: const RegisterScreen(), router: mockRouter);

    // Verify Title
    // findsWidgets is used because 'สร้างบัญชี' appears in AppBar and Button.
    expect(find.text('สร้างบัญชี'), findsWidgets);

    // Verify Fields
    expect(find.text('ชื่อผู้ใช้'), findsOneWidget);
    expect(find.text('อีเมล'), findsOneWidget);
    expect(find.text('รหัสผ่าน'), findsOneWidget);
    
    // 3 TextFields
    expect(find.byType(TextField), findsNWidgets(3));
  });

  testWidgets('RegisterScreen navigates to home on submit', (WidgetTester tester) async {
    // Set a larger screen size for the form
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    await pumpRouterApp(tester, home: const RegisterScreen(), router: mockRouter);
    
    // Reset size after test
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Find the elevated button with text "สร้างบัญชี"
    // Use pumpAndSettle to ensure navigation completes
    await tester.tap(find.widgetWithText(ElevatedButton, 'สร้างบัญชี'));
    await tester.pumpAndSettle();

    // Verify navigation
    verify(() => mockRouter.go('/home')).called(1);
  });
}
