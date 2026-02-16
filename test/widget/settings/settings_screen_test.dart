import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/settings/presentation/screens/settings_screen.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    mockRouter = MockGoRouter();
  });

  testWidgets('SettingsScreen displays profile and options', (WidgetTester tester) async {
    await pumpRouterApp(tester, home: const SettingsScreen(), router: mockRouter);

    // Verify Title
    expect(find.text('โปรไฟล์และการตั้งค่า'), findsOneWidget);

    // Verify Profile Name
    expect(find.text('ใบข้าว บ้านนา'), findsOneWidget);

    // Verify Settings Options
    expect(find.text('ข้อมูลส่วนตัว'), findsOneWidget);
    expect(find.text('การแจ้งเตือน'), findsOneWidget);
    expect(find.text('คู่มือการใช้งาน'), findsOneWidget);

    // Verify Logout Button
    expect(find.text('ออกจากระบบ'), findsOneWidget);
  });

  testWidgets('SettingsScreen logout navigates to login', (WidgetTester tester) async {
    await pumpRouterApp(tester, home: const SettingsScreen(), router: mockRouter);

    // Find Logout button (OutlinedButton)
    final logoutButton = find.widgetWithText(OutlinedButton, 'ออกจากระบบ');
    
    // Scroll to the button to ensure it is visible before tapping.
    await tester.scrollUntilVisible(logoutButton, 500);

    // Tap it
    await tester.tap(logoutButton);
    await tester.pump();

    // Verify navigation
    verify(() => mockRouter.go('/login')).called(1);
  });
}
