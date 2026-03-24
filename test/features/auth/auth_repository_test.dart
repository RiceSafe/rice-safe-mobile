import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/auth/data/repositories/auth_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late AuthRepository repo;

  setUp(() {
    dio = MockDio();
    repo = AuthRepository(dio);
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(<String, dynamic>{});
  });

  group('AuthRepository.login', () {
    test('returns AuthResponse on 200 with valid body', () async {
      final body = <String, dynamic>{
        'token': 'tok',
        'user': <String, dynamic>{
          'id': '1',
          'username': 'u',
          'email': 'u@u.com',
          'role': 'FARMER',
        },
      };
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/login',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 200,
          data: body,
        ),
      );

      final result = await repo.login(email: 'u@u.com', password: 'p');

      expect(result.token, 'tok');
      expect(result.user.id, '1');
      expect(result.user.username, 'u');
      expect(result.user.email, 'u@u.com');
      expect(result.user.role, 'FARMER');
    });

    test('throws Exception with server error when DioException has error in body',
        () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/login',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/auth/login'),
            statusCode: 401,
            data: <String, dynamic>{'error': 'Invalid credentials'},
          ),
        ),
      );

      expect(
        () => repo.login(email: 'a@b.com', password: 'wrong'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Invalid credentials'),
          ),
        ),
      );
    });

    test('throws Exception with message field when error is absent', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/login',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/auth/login'),
            statusCode: 400,
            data: <String, dynamic>{'message': 'Bad request'},
          ),
        ),
      );

      expect(
        () => repo.login(email: 'a@b.com', password: 'p'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Bad request'),
          ),
        ),
      );
    });
  });

  group('AuthRepository.forgotPassword', () {
    test('completes on 200', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/forgot-password',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/auth/forgot-password'),
          statusCode: 200,
          data: <String, dynamic>{},
        ),
      );

      await expectLater(
        repo.forgotPassword(email: '  reset@example.com  '),
        completes,
      );

      verify(
        () => dio.post<Map<String, dynamic>>(
          '/auth/forgot-password',
          data: <String, dynamic>{'email': 'reset@example.com'},
        ),
      ).called(1);
    });
  });

  group('AuthRepository.register', () {
    test('returns AuthResponse on 201 with valid body', () async {
      final body = <String, dynamic>{
        'token': 'reg-tok',
        'user': <String, dynamic>{
          'id': '2',
          'username': 'newuser',
          'email': 'n@n.com',
          'role': 'FARMER',
        },
      };
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/register',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/auth/register'),
          statusCode: 201,
          data: body,
        ),
      );

      final result = await repo.register(
        username: 'newuser',
        email: 'n@n.com',
        password: 'secret',
      );

      expect(result.token, 'reg-tok');
      expect(result.user.username, 'newuser');
      verify(
        () => dio.post<Map<String, dynamic>>(
          '/auth/register',
          data: <String, dynamic>{
            'username': 'newuser',
            'email': 'n@n.com',
            'password': 'secret',
            'role': 'FARMER',
          },
        ),
      ).called(1);
    });

    test('throws Exception with body error when status is not 201', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/register',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/auth/register'),
          statusCode: 400,
          data: <String, dynamic>{'error': 'Email taken'},
        ),
      );

      expect(
        () => repo.register(
          username: 'u',
          email: 'taken@x.com',
          password: 'p',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Email taken'),
          ),
        ),
      );
    });

    test('throws Exception from DioException on register', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/register',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/register'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/auth/register'),
            statusCode: 500,
            data: <String, dynamic>{'error': 'Server down'},
          ),
        ),
      );

      expect(
        () => repo.register(username: 'u', email: 'e@e.com', password: 'p'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Server down'),
          ),
        ),
      );
    });
  });

  group('AuthRepository.getProfile', () {
    test('returns UserModel on 200', () async {
      final body = <String, dynamic>{
        'id': '9',
        'username': 'me',
        'email': 'me@me.com',
        'role': 'FARMER',
      };
      when(() => dio.get<Map<String, dynamic>>('/auth/me')).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/auth/me'),
          statusCode: 200,
          data: body,
        ),
      );

      final user = await repo.getProfile();

      expect(user.id, '9');
      expect(user.username, 'me');
      expect(user.email, 'me@me.com');
    });

    test('throws Exception when status is not 200', () async {
      when(() => dio.get<Map<String, dynamic>>('/auth/me')).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/auth/me'),
          statusCode: 404,
          data: null,
        ),
      );

      expect(
        repo.getProfile(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Failed to load profile'),
          ),
        ),
      );
    });

    test('throws Exception from DioException', () async {
      when(() => dio.get<Map<String, dynamic>>('/auth/me')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/me'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/auth/me'),
            statusCode: 401,
            data: <String, dynamic>{'message': 'Unauthorized'},
          ),
        ),
      );

      expect(
        repo.getProfile(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Unauthorized'),
          ),
        ),
      );
    });
  });

  group('AuthRepository.changePassword', () {
    test('completes on 200', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/change-password',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/auth/change-password'),
          statusCode: 200,
          data: <String, dynamic>{},
        ),
      );

      await expectLater(
        repo.changePassword(oldPassword: 'old', newPassword: 'new'),
        completes,
      );

      verify(
        () => dio.post<Map<String, dynamic>>(
          '/auth/change-password',
          data: <String, dynamic>{
            'old_password': 'old',
            'new_password': 'new',
          },
        ),
      ).called(1);
    });

    test('throws Exception when status is not 200', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/change-password',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/auth/change-password'),
          statusCode: 400,
          data: <String, dynamic>{'error': 'Weak password'},
        ),
      );

      expect(
        () => repo.changePassword(oldPassword: 'a', newPassword: 'b'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Weak password'),
          ),
        ),
      );
    });

    test('throws Exception from DioException', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/change-password',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/change-password'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/auth/change-password'),
            statusCode: 403,
            data: <String, dynamic>{'error': 'Forbidden'},
          ),
        ),
      );

      expect(
        () => repo.changePassword(oldPassword: 'x', newPassword: 'y'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Forbidden'),
          ),
        ),
      );
    });
  });

  group('AuthRepository.resetPassword', () {
    test('completes on 200 and trims token', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/reset-password',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/auth/reset-password'),
          statusCode: 200,
          data: <String, dynamic>{},
        ),
      );

      await repo.resetPassword(
        token: '  abc  ',
        newPassword: 'newpass',
      );

      verify(
        () => dio.post<Map<String, dynamic>>(
          '/auth/reset-password',
          data: <String, dynamic>{
            'token': 'abc',
            'new_password': 'newpass',
          },
        ),
      ).called(1);
    });

    test('throws Exception when status is not 200', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/reset-password',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/auth/reset-password'),
          statusCode: 400,
          data: <String, dynamic>{'error': 'Invalid token'},
        ),
      );

      expect(
        () => repo.resetPassword(token: 'bad', newPassword: 'n'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Invalid token'),
          ),
        ),
      );
    });

    test('throws Exception from DioException', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/auth/reset-password',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/reset-password'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/auth/reset-password'),
            statusCode: 500,
            data: <String, dynamic>{'error': 'Reset failed'},
          ),
        ),
      );

      expect(
        () => repo.resetPassword(token: 't', newPassword: 'n'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Reset failed'),
          ),
        ),
      );
    });
  });
}
