import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/settings/presentation/screens/settings_screen.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockGoRouter mockRouter;

  setUp(() async {
    await TestHive.init();
    mockRouter = MockGoRouter();
    when(() => mockRouter.go(any())).thenReturn(null);
  });

  tearDown(() async {
    await TestHive.reset();
  });

  testWidgets('SettingsScreen displays profile and options', (WidgetTester tester) async {
    await pumpRouterApp(tester, home: const SettingsScreen(), router: mockRouter);

    expect(find.text('โปรไฟล์และการตั้งค่า'), findsOneWidget);
    expect(find.text('ใบข้าว บ้านนา'), findsOneWidget);
    expect(find.text('ข้อมูลส่วนตัว'), findsOneWidget);
    expect(find.text('ติดต่อเรา'), findsOneWidget);
    expect(find.text('เกี่ยวกับ RiceSafe'), findsOneWidget);
    expect(find.text('ออกจากระบบ'), findsOneWidget);
  });

  testWidgets('SettingsScreen logout navigates to login', (WidgetTester tester) async {
    await pumpRouterApp(tester, home: const SettingsScreen(), router: mockRouter);

    final logoutButton = find.widgetWithText(OutlinedButton, 'ออกจากระบบ');
    await tester.scrollUntilVisible(logoutButton, 500);

    await tester.tap(logoutButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    verify(() => mockRouter.go('/login')).called(1);
  });
}
