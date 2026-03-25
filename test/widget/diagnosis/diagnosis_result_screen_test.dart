import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/diagnosis/data/models/diagnosis_history_dto.dart';
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

    expect(find.textContaining('ความมั่นใจ'), findsOneWidget);
  });

  testWidgets('DiagnosisResultScreen shows symptoms card when present',
      (WidgetTester tester) async {
    final result = DiagnosisResult(
      name: 'โรคทดสอบ',
      confidence: '88.0%',
      remedy: 'รักษา',
      treatment: 'ป้องกัน',
      symptoms: 'อาการ A\nรายละเอียด A',
    );

    await pumpRouterApp(
      tester,
      home: DiagnosisResultScreen(result: result),
      router: mockRouter,
    );

    expect(find.text('อาการที่พบ'), findsOneWidget);
    expect(find.textContaining('อาการ A'), findsOneWidget);
  });

  testWidgets(
      'DiagnosisResultScreen hides care section but keeps new-diagnosis button for non-disease history',
      (WidgetTester tester) async {
    final result = DiagnosisResult.fromHistory(
      const DiagnosisHistoryDto(
        id: 'x',
        imageUrl: '',
        prediction: 'not_clear',
        diseaseName: '',
        confidence: 0.601,
        createdAt: null,
      ),
    );

    await pumpRouterApp(
      tester,
      home: DiagnosisResultScreen(result: result),
      router: mockRouter,
    );

    expect(find.text('ไม่ชัดเจน'), findsOneWidget);
    expect(find.text('คำแนะนำการรักษา'), findsNothing);
    expect(find.text('วิธีการรักษา'), findsNothing);
    expect(find.text('การควบคุมดูแล'), findsNothing);
    expect(find.text('วินิจฉัยรายการใหม่'), findsOneWidget);
    expect(find.text('คำแนะจากระบบ'), findsNothing);
  });

  testWidgets(
      'DiagnosisResultScreen shows compact api info card after live diagnosis',
      (WidgetTester tester) async {
    final result = DiagnosisResult(
      name: 'ไม่ชัดเจน',
      confidence: '60.1%',
      remedy: 'รูปภาพไม่ชัดเจน กรุณาถ่ายรูปใหม่อีกครั้ง',
      treatment: 'รูปภาพไม่ชัดเจน กรุณาถ่ายรูปใหม่อีกครั้ง',
      diseaseSpecificImageUrl: 'http://example.com/x.jpg',
      careLookupAlias: 'not_clear',
      apiInfoMessage: 'รูปภาพไม่ชัดเจน กรุณาถ่ายรูปใหม่อีกครั้ง',
    );

    await pumpRouterApp(
      tester,
      home: DiagnosisResultScreen(result: result),
      router: mockRouter,
    );

    expect(find.text('คำแนะจากระบบ'), findsOneWidget);
    expect(
      find.textContaining('รูปภาพไม่ชัดเจน'),
      findsWidgets,
    );
    expect(find.text('วินิจฉัยรายการใหม่'), findsOneWidget);
    expect(find.text('คำแนะนำการรักษา'), findsNothing);
  });

  testWidgets(
      'DiagnosisResultScreen compact without apiInfoMessage skips info card',
      (WidgetTester tester) async {
    final result = DiagnosisResult(
      name: 'ไม่ชัดเจน',
      confidence: '60%',
      remedy: 'x',
      treatment: 'y',
      careLookupAlias: 'not_clear',
    );

    await pumpRouterApp(
      tester,
      home: DiagnosisResultScreen(result: result),
      router: mockRouter,
    );

    expect(find.text('คำแนะจากระบบ'), findsNothing);
    expect(find.text('วินิจฉัยรายการใหม่'), findsOneWidget);
  });
}
