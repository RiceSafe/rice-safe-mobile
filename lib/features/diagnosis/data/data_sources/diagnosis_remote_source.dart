import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ricesafe_app/core/network/dio_error_detail.dart';
import 'package:http_parser/http_parser.dart';
import 'package:ricesafe_app/core/error/exceptions.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';
import 'package:ricesafe_app/features/diagnosis/data/models/diagnosis_history_dto.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_backend_parser.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_result.dart';

class DiagnosisRemoteDataSource {
  DiagnosisRemoteDataSource(this._dio);

  final Dio _dio;

  MediaType? _imageMediaType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    if (lower.endsWith('.gif')) return MediaType('image', 'gif');
    return MediaType('image', 'jpeg');
  }

  /// `POST /diagnosis` — multipart: `image`, `description`, optional `latitude` + `longitude` (both strings, send as pair).
  Future<DiagnosisResult> diagnose({
    required File imageFile,
    required String description,
    double? latitude,
    double? longitude,
  }) async {
    final path = imageFile.path;
    final fileName = path.split(Platform.pathSeparator).last;

    final map = <String, dynamic>{
      'description': description,
      'image': await MultipartFile.fromFile(
        path,
        filename: fileName,
        contentType: _imageMediaType(path),
      ),
    };
    if (latitude != null && longitude != null) {
      map['latitude'] = latitude.toString();
      map['longitude'] = longitude.toString();
    }

    final formData = FormData.fromMap(map);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/diagnosis',
        data: formData,
        options: Options(
          contentType: null,
          sendTimeout: const Duration(seconds: 90),
          receiveTimeout: const Duration(seconds: 90),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return DiagnosisBackendParser.fromBackendJson(
          response.data!,
          userUploadedImage: imageFile,
        );
      }
      throw ServerException('วินิจฉัยไม่สำเร็จ');
    } on DioException catch (e) {
      if (e.response == null) {
        throw NetworkException(dioErrorDetail(e));
      }
      throw ServerException(dioErrorDetail(e));
    } catch (e) {
      if (e is ServerException) rethrow;
      if (e is NetworkException) rethrow;
      throw ServerException(
        userFacingMessage(
          e,
          contextFallback: 'วินิจฉัยไม่สำเร็จ',
        ),
      );
    }
  }

  /// `GET /diagnosis/history`
  Future<List<DiagnosisHistoryDto>> getHistory() async {
    try {
      final response = await _dio.get<dynamic>('/diagnosis/history');
      if (response.statusCode != 200) {
        throw ServerException('โหลดประวัติไม่สำเร็จ');
      }
      final raw = response.data;
      if (raw == null) return [];
      if (raw is! List) return [];
      return raw
          .whereType<Map>()
          .map((e) => DiagnosisHistoryDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      if (e.response == null) {
        throw NetworkException(dioErrorDetail(e));
      }
      throw ServerException(dioErrorDetail(e));
    }
  }
}
