import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/diagnosis/data/models/diagnosis_history_dto.dart';
import 'package:ricesafe_app/features/diagnosis/presentation/providers/diagnosis_provider.dart';
import 'package:ricesafe_app/features/diagnosis/presentation/screens/diagnosis_history_screen.dart';

import '../../helpers/test_helpers.dart';

class _FailHistoryOnce {
  bool fail = true;
}

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    mockRouter = MockGoRouter();
    when(() => mockRouter.canPop()).thenReturn(true);
    when(() => mockRouter.pop()).thenAnswer((_) {});
  });

  testWidgets('shows empty state when history is empty', (tester) async {
    await pumpRouterApp(
      tester,
      home: const DiagnosisHistoryScreen(),
      router: mockRouter,
      overrides: [
        diagnosisHistoryProvider.overrideWith((ref) async => <DiagnosisHistoryDto>[]),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('ประวัติการวินิจฉัย'), findsOneWidget);
    expect(find.text('ยังไม่มีประวัติการวินิจฉัย'), findsOneWidget);
  });

  testWidgets('shows disease title and subtitle for one row', (tester) async {
    final items = [
      const DiagnosisHistoryDto(
        id: 'h1',
        imageUrl: '',
        prediction: '',
        diseaseName: 'โรคไหม้',
        confidence: 88.5,
        createdAt: null,
      ),
    ];
    await pumpRouterApp(
      tester,
      home: const DiagnosisHistoryScreen(),
      router: mockRouter,
      overrides: [
        diagnosisHistoryProvider.overrideWith((ref) async => items),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('โรคไหม้'), findsOneWidget);
    expect(find.text('88.5%'), findsOneWidget);
  });

  testWidgets('retry clears error and shows empty state', (tester) async {
    final gate = _FailHistoryOnce();
    await pumpRouterApp(
      tester,
      home: const DiagnosisHistoryScreen(),
      router: mockRouter,
      overrides: [
        diagnosisHistoryProvider.overrideWith((ref) async {
          if (gate.fail) {
            gate.fail = false;
            throw Exception('Network error');
          }
          return <DiagnosisHistoryDto>[];
        }),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('โหลดประวัติไม่สำเร็จ'), findsOneWidget);
    expect(find.text('ลองอีกครั้ง'), findsOneWidget);

    await tester.tap(find.text('ลองอีกครั้ง'));
    await tester.pumpAndSettle();

    expect(find.text('ยังไม่มีประวัติการวินิจฉัย'), findsOneWidget);
  });

  testWidgets('back calls pop on router', (tester) async {
    await pumpRouterApp(
      tester,
      home: const DiagnosisHistoryScreen(),
      router: mockRouter,
      overrides: [
        diagnosisHistoryProvider.overrideWith((ref) async => <DiagnosisHistoryDto>[]),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    verify(() => mockRouter.pop()).called(1);
  });
}
