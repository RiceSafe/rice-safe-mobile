import 'package:dio/dio.dart';
import 'package:ricesafe_app/core/network/dio_error_detail.dart';
import 'package:ricesafe_app/features/outbreak/data/models/outbreak_api_model.dart';

class OutbreakRepository {
  OutbreakRepository(this._dio);

  final Dio _dio;

  /// [limit] 0 = no limit query param (return all from server after filters).
  Future<List<OutbreakSummary>> listOutbreaks({
    required bool verifiedOnly,
    double? userLat,
    double? userLong,
    int limit = 0,
  }) async {
    try {
      final query = <String, dynamic>{
        'verified': verifiedOnly,
      };
      if (userLat != null && userLong != null) {
        query['lat'] = userLat;
        query['long'] = userLong;
      }
      if (limit > 0) {
        query['limit'] = limit;
      }

      // Backend may return JSON `null` (HTTP 200) when the list is empty; treat as [].
      final response = await _dio.get<dynamic>(
        '/outbreaks',
        queryParameters: query,
      );
      if (response.statusCode != 200) {
        throw Exception('โหลดข้อมูลการระบาดไม่สำเร็จ');
      }
      final raw = response.data;
      if (raw == null) {
        return [];
      }
      if (raw is! List) {
        throw Exception('โหลดข้อมูลการระบาดไม่สำเร็จ');
      }
      return raw
          .whereType<Map>()
          .map((e) => OutbreakSummary.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  Future<OutbreakSummary> getById(
    String id, {
    double? userLat,
    double? userLong,
  }) async {
    try {
      final Map<String, dynamic>? query;
      if (userLat != null && userLong != null) {
        query = {'lat': userLat, 'long': userLong};
      } else {
        query = null;
      }

      final response = await _dio.get<Map<String, dynamic>>(
        '/outbreaks/$id',
        queryParameters: query,
      );
      if (response.statusCode == 200 && response.data != null) {
        return OutbreakSummary.fromJson(response.data!);
      }
      throw Exception('ไม่พบข้อมูลการระบาด');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('ไม่พบข้อมูลการระบาด');
      }
      throw Exception(dioErrorDetail(e));
    }
  }
}
