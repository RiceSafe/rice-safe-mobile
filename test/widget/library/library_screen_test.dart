import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/library/data/disease_repository.dart';
import 'package:ricesafe_app/features/library/data/models/library_disease.dart';
import 'package:ricesafe_app/features/library/presentation/providers/disease_library_provider.dart';
import 'package:ricesafe_app/features/library/presentation/screens/library_screen.dart';
import '../../helpers/test_helpers.dart';

class _FakeDiseaseRepository extends DiseaseRepository {
  _FakeDiseaseRepository() : super(Dio(BaseOptions()));

  @override
  Future<List<String>> getCategories() async => ['เชื้อรา'];

  @override
  Future<List<LibraryDisease>> listDiseases({String? category}) async => [
        LibraryDisease(
          id: '1',
          alias: 'blast',
          name: 'โรคไหม้ (Rice Blast Disease)',
          category: 'เชื้อรา',
          description: 'คำอธิบายทดสอบ',
        ),
      ];

  @override
  Future<LibraryDisease> getById(String id) async {
    throw UnimplementedError();
  }
}

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    mockRouter = MockGoRouter();
  });

  testWidgets('LibraryScreen displays search, chips and grid from repository',
      (WidgetTester tester) async {
    await pumpRouterApp(
      tester,
      home: const LibraryScreen(),
      router: mockRouter,
      overrides: [
        diseaseRepositoryProvider.overrideWith(
          (ref) => _FakeDiseaseRepository(),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('คลังความรู้'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('ค้นหาโรคข้าว, อาการ...'), findsOneWidget);

    expect(find.text('ทั้งหมด'), findsOneWidget);
    expect(find.text('เชื้อรา'), findsWidgets);

    expect(find.text('โรคไหม้ (Rice Blast Disease)'), findsOneWidget);
  });
}
