import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/core/error/exceptions.dart';
import 'package:ricesafe_app/core/error/failures.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';

void main() {
  group('userFacingMessage', () {
    test('DioException connectionTimeout', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(
        userFacingMessage(e),
        'หมดเวลารอ ลองใหม่ภายหลัง',
      );
    });

    test('DioException connectionError', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionError,
      );
      expect(
        userFacingMessage(e),
        'เชื่อมต่อไม่สำเร็จ ตรวจสอบอินเทอร์เน็ตแล้วลองใหม่',
      );
    });

    test('DioException badResponse 401 without body uses session message', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 401,
        ),
      );
      expect(
        userFacingMessage(e),
        'เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่',
      );
    });

    test('DioException badResponse 401 with JSON error translates body', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
          data: <String, dynamic>{'error': 'Invalid email or password'},
        ),
      );
      expect(
        userFacingMessage(e),
        'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
      );
    });

    test('DioException badResponse 404 with contextFallback', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 404,
        ),
      );
      expect(
        userFacingMessage(e, contextFallback: 'ไม่พบโรค'),
        'ไม่พบโรค',
      );
    });

    test('DioException badResponse 503', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 503,
        ),
      );
      expect(
        userFacingMessage(e),
        'เซิร์ฟเวอร์ไม่พร้อมใช้งาน ลองใหม่ภายหลัง',
      );
    });

    test('Exception with Thai message', () {
      expect(
        userFacingMessage(Exception('โหลดข้อมูลไม่สำเร็จ')),
        'โหลดข้อมูลไม่สำเร็จ',
      );
    });

    test('ServerException translates known English backend phrase', () {
      expect(
        userFacingMessage(ServerException('Outbreak not found')),
        'ไม่พบข้อมูลการระบาด',
      );
    });

    test('NetworkException falls back to generic Thai when phrase unknown', () {
      expect(
        userFacingMessage(NetworkException('Service unavailable')),
        'เชื่อมต่อไม่สำเร็จ ตรวจสอบอินเทอร์เน็ตแล้วลองใหม่',
      );
    });

    test('Request failed string maps to generic', () {
      expect(
        userFacingMessage('Request failed'),
        'ดำเนินการไม่สำเร็จ ลองใหม่ภายหลัง',
      );
    });

    test('NetworkException with Thai kept', () {
      expect(
        userFacingMessage(NetworkException('เครือข่ายขัดข้อง')),
        'เครือข่ายขัดข้อง',
      );
    });

    test('ServerFailure recurses to message', () {
      expect(
        userFacingMessage(const ServerFailure('Request failed')),
        'ดำเนินการไม่สำเร็จ ลองใหม่ภายหลัง',
      );
    });

    test('DioException raw string hidden', () {
      expect(
        userFacingMessage(
          Exception('DioException [bad response]: This is an error message'),
        ),
        'ดำเนินการไม่สำเร็จ ลองใหม่ภายหลัง',
      );
    });
  });
}
