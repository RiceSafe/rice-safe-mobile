import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ricesafe_app/features/outbreak/presentation/screens/outbreak_screen.dart';
import '../../helpers/test_helpers.dart';

// Tests for OutbreakScreen
//
// Limitations:
// - FlutterMap is difficult to mock fully in widget tests without network calls.
// - We focus on testing the Tab switching logic (Map vs List) and UI presence.
// - The "Map Tab" is verified by checking for Zoom controls.
// - The "List Tab" is verified by checking for the ListView and specific text elements.

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    mockRouter = MockGoRouter();
  });

  testWidgets('OutbreakScreen displays tabs and map initially', (WidgetTester tester) async {
    await pumpRouterApp(tester, home: const OutbreakScreen(), router: mockRouter);

    // Verify AppBar
    expect(find.text('แจ้งเตือนการระบาด'), findsOneWidget);

    // Verify Tabs
    expect(find.text('แผนที่'), findsOneWidget);
    expect(find.text('รายการ'), findsOneWidget);

    // Verify Zoom Controls (indicating map tab is active)
    expect(find.byIcon(Icons.add), findsOneWidget); // Zoom in
    expect(find.byIcon(Icons.remove), findsOneWidget); // Zoom out
  });

  testWidgets('OutbreakScreen switches to List tab', (WidgetTester tester) async {
    await pumpRouterApp(tester, home: const OutbreakScreen(), router: mockRouter);

    // Tap List Tab
    await tester.tap(find.text('รายการ'));
    await tester.pumpAndSettle();

    // Verify List Content
    // Check for the "Verified Only" switch which is present in the List tab.
    expect(find.text('เฉพาะที่ตรวจสอบแล้ว'), findsOneWidget);
    
    // We should see some list items or at least the structure
    expect(find.byType(ListView), findsOneWidget);
  });
}
