import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/library/presentation/screens/library_screen.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    mockRouter = MockGoRouter();
  });

  testWidgets('LibraryScreen displays search and grid', (WidgetTester tester) async {
    await pumpRouterApp(tester, home: const LibraryScreen(), router: mockRouter);

    // Verify Title
    expect(find.text('คลังความรู้'), findsOneWidget);

    // Verify Search Bar
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('ค้นหาโรคข้าว, อาการ...'), findsOneWidget);

    // Verify Filter Chips
    expect(find.text('ทั้งหมด'), findsOneWidget);
    // 'เชื้อรา' appears in both filter chips and grid items, so we check for multiple widgets.
    expect(find.text('เชื้อรา'), findsWidgets);

    // Verify Grid Items
    // Ensure that mocked items are displayed correctly in the grid.
    expect(find.text('โรคไหม้\n(Rice Blast Disease)'), findsOneWidget);
    expect(find.text('เชื้อรา'), findsWidgets); 
  });
}
