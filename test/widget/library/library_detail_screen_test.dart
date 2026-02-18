import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/library/data/mock_library_data.dart';
import 'package:ricesafe_app/features/library/presentation/screens/library_detail_screen.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    mockRouter = MockGoRouter();
  });

  testWidgets('LibraryDetailScreen displays disease info and tabs', (WidgetTester tester) async {
    final disease = DiseaseDetail(
      id: 'test-1',
      name: 'Test Disease',
      category: 'เชื้อรา',
      imagePath: 'assets/mock/rice_blast.jpg',
      description: 'Test Description',
      symptoms: [InfoSection(title: 'Symptom 1', description: 'Desc 1')],
      prevention: [InfoSection(title: 'Prevent 1', description: 'Desc 2')],
      treatment: [InfoSection(title: 'Treat 1', description: 'Desc 3')],
    );

    // Wrap in Scaffold/MaterialApp to handle Tabs
    await tester.pumpWidget(
      MaterialApp(
        home: LibraryDetailScreen(disease: disease),
      ),
    );

    // Verify Title
    expect(find.text('Test Disease'), findsOneWidget);

    // Verify Tabs
    expect(find.text('ข้อมูลทั่วไป'), findsOneWidget);
    expect(find.text('อาการ'), findsOneWidget);
    expect(find.text('การป้องกัน'), findsOneWidget);
    expect(find.text('การรักษา'), findsOneWidget);

    // Verify Descriptions
    expect(find.text('Test Description'), findsOneWidget);
  });
}
