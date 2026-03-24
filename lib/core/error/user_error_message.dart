import 'package:dio/dio.dart';
import 'package:ricesafe_app/core/error/exceptions.dart';
import 'package:ricesafe_app/core/error/failures.dart';
import 'package:ricesafe_app/core/network/dio_error_detail.dart';

/// short user-facing message; avoids raw error strings.
String userFacingMessage(
  Object error, {
  String? contextFallback,
}) {
  if (error is DioException) {
    return _fromDio(error, contextFallback: contextFallback);
  }
  if (error is NetworkException) {
    final m = error.message.trim();
    if (m.isEmpty) {
      return 'เชื่อมต่อไม่สำเร็จ ตรวจสอบอินเทอร์เน็ตแล้วลองใหม่';
    }
    if (_containsThai(m)) return m;
    final translated = _translateBackendError(m);
    if (translated != null) return translated;
    return 'เชื่อมต่อไม่สำเร็จ ตรวจสอบอินเทอร์เน็ตแล้วลองใหม่';
  }
  if (error is ServerException) {
    final m = error.message.trim();
    if (m.isEmpty) {
      return contextFallback ?? 'ดำเนินการไม่สำเร็จ ลองใหม่ภายหลัง';
    }
    if (_containsThai(m)) return m;
    final translated = _translateBackendError(m);
    if (translated != null) return translated;
    return contextFallback ?? 'ดำเนินการไม่สำเร็จ ลองใหม่ภายหลัง';
  }
  if (error is Failure) {
    return userFacingMessage(
      error.message,
      contextFallback: contextFallback,
    );
  }
  if (error is FormatException) {
    return contextFallback ?? 'ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง';
  }
  if (error is String) {
    return _fromPlainString(error, contextFallback: contextFallback);
  }

  final raw = error.toString();
  final stripped = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
  if (stripped.isEmpty) {
    return contextFallback ?? 'ดำเนินการไม่สำเร็จ ลองใหม่ภายหลัง';
  }
  if (_containsThai(stripped)) return stripped;
  final translated = _translateBackendError(stripped);
  if (translated != null) return translated;
  
  return contextFallback ?? 'ดำเนินการไม่สำเร็จ ลองใหม่ภายหลัง';
}

String? _translateBackendError(String msg) {
  final lower = msg.toLowerCase().trim();
  
  // Auth
  if (lower.contains('invalid email or password')) return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
  if (lower.contains('email already exists')) return 'อีเมลนี้ถูกใช้งานแล้ว';
  if (lower.contains('username already exists')) return 'ชื่อผู้ใช้นี้ถูกใช้งานแล้ว';
  if (lower.contains('user not found')) return 'ไม่พบข้อมูลผู้ใช้ในระบบ';
  if (lower.contains('invalid password')) return 'รหัสผ่านไม่ถูกต้อง';
  if (lower.contains('invalid user session')) return 'เซสชันไม่ถูกต้อง กรุณาเข้าสู่ระบบใหม่';
  if (lower.contains('invalid user id')) return 'รหัสผู้ใช้ไม่ถูกต้อง';
  
  // Community
  if (lower.contains('content is required')) return 'กรุณากรอกเนื้อหา';
  if (lower.contains('post not found')) return 'ไม่พบโพสต์นี้';
  if (lower.contains('invalid post id')) return 'รหัสโพสต์ไม่ถูกต้อง';
  
  // Diagnosis / Image
  if (lower.contains('image file is required') || lower.contains('image is required')) return 'กรุณาแนบรูปภาพ';
  if (lower.contains('failed to upload image')) return 'อัปโหลดรูปภาพไม่สำเร็จ';
  
  // Outbreak & Weather
  if (lower.contains('outbreak not found')) return 'ไม่พบข้อมูลการระบาด';
  if (lower.contains('invalid outbreak id')) return 'รหัสการระบาดไม่ถูกต้อง';
  if (lower.contains('latitude and longitude are required')) return 'กรุณาระบุพิกัดตำแหน่ง';
  if (lower.contains('weather data is currently unavailable')) return 'ข้อมูลสภาพอากาศไม่พร้อมใช้งานในขณะนี้';
  
  // General / Validation
  if (lower.contains('invalid request body') || lower.contains('invalid body') || lower.contains('invalid input')) return 'ข้อมูลไม่ถูกต้อง';
  if (lower.contains('validation failed')) return 'ข้อมูลไม่ถูกต้อง';
  if (lower.contains('invalid id format') || lower.contains('invalid id')) return 'รหัสไม่ถูกต้อง';
  if (lower.contains('disease not found')) return 'ไม่พบข้อมูลโรค';
  if (lower.contains('invalid notification id')) return 'รหัสการแจ้งเตือนไม่ถูกต้อง';

  return null;
}

String _fromPlainString(String s, {String? contextFallback}) {
  final t = s.trim();
  if (t.isEmpty) {
    return contextFallback ?? 'ดำเนินการไม่สำเร็จ ลองใหม่ภายหลัง';
  }
  if (_containsThai(t)) return t;
  final translated = _translateBackendError(t);
  if (translated != null) return translated;
  
  return contextFallback ?? 'ดำเนินการไม่สำเร็จ ลองใหม่ภายหลัง';
}

bool _containsThai(String s) {
  return RegExp(r'[\u0E00-\u0E7F]').hasMatch(s);
}

String _fromDio(DioException e, {String? contextFallback}) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'หมดเวลารอ ลองใหม่ภายหลัง';
    case DioExceptionType.connectionError:
      return 'เชื่อมต่อไม่สำเร็จ ตรวจสอบอินเทอร์เน็ตแล้วลองใหม่';
    case DioExceptionType.cancel:
      return 'ยกเลิกแล้ว';
    case DioExceptionType.badCertificate:
      return 'เชื่อมต่อไม่ปลอดภัย ลองใหม่ภายหลัง';
    case DioExceptionType.badResponse:
      final detail = dioErrorDetail(e).trim();
      if (detail.isNotEmpty) {
        if (_containsThai(detail)) return detail;
        final translated = _translateBackendError(detail);
        if (translated != null) return translated;
      }
      return _fromStatus(
        e.response?.statusCode,
        contextFallback: contextFallback,
      );
    case DioExceptionType.unknown:
      if (e.response == null) {
        return 'เชื่อมต่อไม่สำเร็จ ตรวจสอบอินเทอร์เน็ตแล้วลองใหม่';
      }
      return contextFallback ?? 'ดำเนินการไม่สำเร็จ ลองใหม่ภายหลัง';
  }
}

String _fromStatus(int? code, {String? contextFallback}) {
  switch (code) {
    case 401:
      return 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่';
    case 403:
      return 'ไม่มีสิทธิ์ใช้งาน';
    case 404:
      return contextFallback ?? 'ไม่พบข้อมูล';
    case 422:
      return 'ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง';
    case 429:
      return 'ใช้งานถี่เกินไป ลองใหม่ภายหลัง';
    default:
      if (code != null && code >= 500) {
        return 'เซิร์ฟเวอร์ไม่พร้อมใช้งาน ลองใหม่ภายหลัง';
      }
      if (code == 400) {
        return contextFallback ?? 'ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง';
      }
      return contextFallback ?? 'ดำเนินการไม่สำเร็จ ลองใหม่ภายหลัง';
  }
}
