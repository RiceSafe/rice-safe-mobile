import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/library/data/disease_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late DiseaseRepository repo;

  setUp(() {
    dio = MockDio();
    repo = DiseaseRepository(dio);
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(<String, dynamic>{});
  });

  Map<String, dynamic> minimalDiseaseJson(String id) => <String, dynamic>{
        'id': id,
        'alias': 'a',
        'name': 'Test disease',
        'category': 'Fungal',
        'description': 'Desc',
      };

  group('DiseaseRepository.getCategories', () {
    test('returns string list on 200', () async {
      when(() => dio.get<List<dynamic>>('/diseases/categories')).thenAnswer(
        (_) async => Response<List<dynamic>>(
          requestOptions: RequestOptions(path: '/diseases/categories'),
          statusCode: 200,
          data: <dynamic>['A', 'B'],
        ),
      );

      final categories = await repo.getCategories();

      expect(categories, ['A', 'B']);
    });

    test('throws Exception on non-200', () async {
      when(() => dio.get<List<dynamic>>('/diseases/categories')).thenAnswer(
        (_) async => Response<List<dynamic>>(
          requestOptions: RequestOptions(path: '/diseases/categories'),
          statusCode: 500,
          data: null,
        ),
      );

      expect(
        repo.getCategories(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('โหลดหมวดหมู่ไม่สำเร็จ'),
          ),
        ),
      );
    });

    test('throws Exception from DioException body error', () async {
      when(() => dio.get<List<dynamic>>('/diseases/categories')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/diseases/categories'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/diseases/categories'),
            statusCode: 503,
            data: <String, dynamic>{'error': 'Service unavailable'},
          ),
        ),
      );

      expect(
        repo.getCategories(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Service unavailable'),
          ),
        ),
      );
    });
  });

  group('DiseaseRepository.listDiseases', () {
    test('returns LibraryDisease list on 200 without category', () async {
      final raw = <dynamic>[
        minimalDiseaseJson('1'),
        minimalDiseaseJson('2'),
      ];
      when(
        () => dio.get<List<dynamic>>(
          '/diseases',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<List<dynamic>>(
          requestOptions: RequestOptions(path: '/diseases'),
          statusCode: 200,
          data: raw,
        ),
      );

      final list = await repo.listDiseases();

      expect(list, hasLength(2));
      expect(list.first.id, '1');
      expect(list.last.name, 'Test disease');
      verify(
        () => dio.get<List<dynamic>>(
          '/diseases',
          queryParameters: <String, dynamic>{},
        ),
      ).called(1);
    });

    test('passes category query when non-empty', () async {
      when(
        () => dio.get<List<dynamic>>(
          '/diseases',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<List<dynamic>>(
          requestOptions: RequestOptions(path: '/diseases'),
          statusCode: 200,
          data: <dynamic>[minimalDiseaseJson('x')],
        ),
      );

      await repo.listDiseases(category: 'Fungal');

      verify(
        () => dio.get<List<dynamic>>(
          '/diseases',
          queryParameters: <String, dynamic>{'category': 'Fungal'},
        ),
      ).called(1);
    });

    test('omits category when null or empty string', () async {
      when(
        () => dio.get<List<dynamic>>(
          '/diseases',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<List<dynamic>>(
          requestOptions: RequestOptions(path: '/diseases'),
          statusCode: 200,
          data: <dynamic>[],
        ),
      );

      await repo.listDiseases(category: null);
      await repo.listDiseases(category: '');

      verify(
        () => dio.get<List<dynamic>>(
          '/diseases',
          queryParameters: <String, dynamic>{},
        ),
      ).called(2);
    });

    test('throws Exception from DioException', () async {
      when(
        () => dio.get<List<dynamic>>(
          '/diseases',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/diseases'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/diseases'),
            statusCode: 500,
            data: <String, dynamic>{'error': 'List failed'},
          ),
        ),
      );

      expect(
        repo.listDiseases(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('List failed'),
          ),
        ),
      );
    });
  });

  group('DiseaseRepository.getById', () {
    test('returns LibraryDisease on 200', () async {
      final body = minimalDiseaseJson('id-1');
      when(() => dio.get<Map<String, dynamic>>('/diseases/id-1')).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/diseases/id-1'),
          statusCode: 200,
          data: body,
        ),
      );

      final d = await repo.getById('id-1');

      expect(d.id, 'id-1');
      expect(d.category, 'Fungal');
    });

    test('throws not-found message on 404 DioException', () async {
      when(() => dio.get<Map<String, dynamic>>('/diseases/missing')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/diseases/missing'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/diseases/missing'),
            statusCode: 404,
            data: null,
          ),
        ),
      );

      expect(
        repo.getById('missing'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('ไม่พบข้อมูลโรค'),
          ),
        ),
      );
    });

    test('throws server error from DioException when not 404', () async {
      when(() => dio.get<Map<String, dynamic>>('/diseases/bad')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/diseases/bad'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/diseases/bad'),
            statusCode: 500,
            data: <String, dynamic>{'error': 'Internal'},
          ),
        ),
      );

      expect(
        repo.getById('bad'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Internal'),
          ),
        ),
      );
    });

    test('throws when status is not 200', () async {
      when(() => dio.get<Map<String, dynamic>>('/diseases/x')).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/diseases/x'),
          statusCode: 404,
          data: null,
        ),
      );

      expect(
        repo.getById('x'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('ไม่พบข้อมูลโรค'),
          ),
        ),
      );
    });
  });
}
