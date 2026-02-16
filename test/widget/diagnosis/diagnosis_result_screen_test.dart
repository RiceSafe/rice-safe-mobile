import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_result.dart';
import 'package:ricesafe_app/features/diagnosis/presentation/screens/diagnosis_result_screen.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    mockRouter = MockGoRouter();
  });

  testWidgets('DiagnosisResultScreen displays result data', (WidgetTester tester) async {
    final result = DiagnosisResult(
      name: 'Test Disease',
      confidence: '90%',
      remedy: 'Use water',
      treatment: 'Watch daily',
      diseaseSpecificImageUrl: 'http://example.com/image.jpg',
    );

    await pumpRouterApp(
      tester,
      home: DiagnosisResultScreen(result: result),
      router: mockRouter,
    );

    // Verify Disease Name
    expect(find.text('Test Disease'), findsOneWidget);

    // Verify Remedey Section
    expect(find.text('คำแนะนำการรักษา'), findsOneWidget);
    expect(find.text('วิธีการรักษา'), findsOneWidget);
    expect(find.text('Use water'), findsOneWidget);

    // Verify Treatment Section
    expect(find.text('การควบคุมดูแล'), findsOneWidget);
    expect(find.text('Watch daily'), findsOneWidget);

    // Verify New Diagnosis Button
    expect(find.text('วินิจฉัยรายการใหม่'), findsOneWidget);
  });
}
