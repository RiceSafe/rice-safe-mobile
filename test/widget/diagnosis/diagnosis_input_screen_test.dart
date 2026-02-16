import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/diagnosis/presentation/providers/diagnosis_provider.dart';
import 'package:ricesafe_app/features/diagnosis/presentation/screens/diagnosis_input_screen.dart';
import '../../helpers/diagnosis_test_helpers.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockGoRouter mockRouter;
  late MockDiagnosisNotifier mockNotifier;

  setUp(() {
    mockRouter = MockGoRouter();
    mockNotifier = MockDiagnosisNotifier();
  });

  testWidgets('DiagnosisInputScreen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          diagnosisProvider.overrideWith((ref) => mockNotifier),
        ],
        child: MaterialApp(
          home: MockGoRouterProvider(
            goRouter: mockRouter,
            child: const DiagnosisInputScreen(),
          ),
        ),
      ),
    );

    // Verify Title
    expect(find.text('RiceSafe'), findsOneWidget);
    
    // Verify Image Upload Section
    expect(find.text('อัปโหลดรูปภาพ'), findsOneWidget);
    expect(find.text('ถ่ายรูปหรือนำรูปภาพมาจากแกลลอรี่'), findsOneWidget);
    expect(find.text('เลือกรูปภาพ'), findsOneWidget);

    // Verify Description Section
    expect(find.text('อธิบายลักษณะหรืออาการโรค'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Verify Diagnose Button
    expect(find.text('วินิจฉัยโรค'), findsOneWidget);
  });
}
