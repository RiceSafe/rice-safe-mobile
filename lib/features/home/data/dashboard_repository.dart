import 'package:dio/dio.dart';
import 'package:ricesafe_app/core/network/dio_error_detail.dart';
import 'package:ricesafe_app/features/home/data/models/weather_response.dart';

class DashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  /// `GET /dashboard/weather?lat=&long=` (JWT required). Backend uses query name `long`.
  Future<WeatherResponse> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/dashboard/weather',
        queryParameters: {
          'lat': latitude,
          'long': longitude,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 600,
        ),
      );
      final code = response.statusCode;
      if (code == 200 && response.data != null) {
        return WeatherResponse.fromJson(response.data!);
      }
      if (code == 400) {
        throw Exception('กรุณาระบุตำแหน่งแปลงนา (ละติจูด/ลองจิจูด)');
      }
      if (code == 401) {
        throw Exception('กรุณาเข้าสู่ระบบใหม่');
      }
      if (code == 503) {
        throw Exception(
          'บริการสภาพอากาศไม่พร้อมใช้งานชั่วคราว (ตรวจสอบ API key บนเซิร์ฟเวอร์)',
        );
      }
      throw Exception('โหลดสภาพอากาศไม่สำเร็จ');
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 400) {
        throw Exception('กรุณาระบุตำแหน่งแปลงนา (ละติจูด/ลองจิจูด)');
      }
      if (code == 401) {
        throw Exception('กรุณาเข้าสู่ระบบใหม่');
      }
      if (code == 503) {
        throw Exception(
          'บริการสภาพอากาศไม่พร้อมใช้งานชั่วคราว (ตรวจสอบ API key บนเซิร์ฟเวอร์)',
        );
      }
      throw Exception(dioErrorDetail(e));
    }
  }
}
