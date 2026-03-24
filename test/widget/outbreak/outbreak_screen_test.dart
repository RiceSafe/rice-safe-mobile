import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/outbreak/data/models/outbreak_api_model.dart';
import 'package:ricesafe_app/features/outbreak/data/outbreak_repository.dart';
import 'package:ricesafe_app/features/outbreak/presentation/providers/outbreak_provider.dart';
import 'package:ricesafe_app/features/outbreak/presentation/screens/outbreak_screen.dart';
import '../../helpers/test_helpers.dart';

class _FakeOutbreakRepository extends OutbreakRepository {
  _FakeOutbreakRepository() : super(Dio(BaseOptions()));

  @override
  Future<List<OutbreakSummary>> listOutbreaks({
    required bool verifiedOnly,
    double? userLat,
    double? userLong,
    int limit = 0,
  }) async {
    return [
      OutbreakSummary(
        id: '11111111-1111-1111-1111-111111111111',
        diseaseId: '22222222-2222-2222-2222-222222222222',
        diseaseName: 'โรคทดสอบ',
        latitude: 15.0,
        longitude: 100.0,
        distance: 42,
        isActive: true,
        isVerified: verifiedOnly,
        createdAt: DateTime(2025, 1, 1),
      ),
    ];
  }

  @override
  Future<OutbreakSummary> getById(
    String id, {
    double? userLat,
    double? userLong,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    mockRouter = MockGoRouter();
  });

  testWidgets('OutbreakScreen shows tabs and list from repository',
      (WidgetTester tester) async {
    await pumpRouterApp(
      tester,
      home: const OutbreakScreen(),
      router: mockRouter,
      overrides: [
        outbreakRepositoryProvider.overrideWith(
          (ref) => _FakeOutbreakRepository(),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('แจ้งเตือนการระบาด'), findsOneWidget);
    expect(find.text('แผนที่'), findsOneWidget);
    expect(find.text('รายการ'), findsOneWidget);

    await tester.tap(find.text('รายการ'));
    await tester.pumpAndSettle();

    expect(find.text('โรคทดสอบ'), findsOneWidget);
  });
}
