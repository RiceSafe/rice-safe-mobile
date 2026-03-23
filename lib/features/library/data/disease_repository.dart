import 'package:dio/dio.dart';
import 'package:ricesafe_app/core/network/dio_error_detail.dart';
import 'package:ricesafe_app/features/library/data/models/library_disease.dart';

class DiseaseRepository {
  DiseaseRepository(this._dio);

  final Dio _dio;

  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get<List<dynamic>>('/diseases/categories');
      if (response.statusCode == 200 && response.data != null) {
        return response.data!.map((e) => e.toString()).toList();
      }
      throw Exception('โหลดหมวดหมู่ไม่สำเร็จ');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  /// [category] null or empty = all diseases.
  Future<List<LibraryDisease>> listDiseases({String? category}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/diseases',
        queryParameters: {
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .whereType<Map>()
            .map((e) => LibraryDisease.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      throw Exception('โหลดรายการโรคไม่สำเร็จ');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  Future<LibraryDisease> getById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/diseases/$id');
      if (response.statusCode == 200 && response.data != null) {
        return LibraryDisease.fromJson(response.data!);
      }
      throw Exception('ไม่พบข้อมูลโรค');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('ไม่พบข้อมูลโรค');
      }
      throw Exception(dioErrorDetail(e));
    }
  }
}
