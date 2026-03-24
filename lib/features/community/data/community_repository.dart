import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ricesafe_app/core/network/dio_error_detail.dart';
import 'package:http_parser/http_parser.dart';
import 'package:ricesafe_app/features/community/data/models/community_api_models.dart';

class CommunityRepository {
  CommunityRepository(this._dio);

  final Dio _dio;

  static List<CommunityPostDto> _parsePostsList(dynamic raw) {
    if (raw == null) return [];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => CommunityPostDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<CommunityPostDto>> getPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/community/posts',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.statusCode == 200) {
        return _parsePostsList(response.data);
      }
      throw Exception('โหลดโพสต์ไม่สำเร็จ');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  Future<({CommunityPostDto post, List<CommunityCommentDto> comments})>
      getPostWithComments(String id) async {
    try {
      final response = await _dio.get<dynamic>('/community/posts/$id');
      if (response.statusCode != 200 || response.data == null) {
        throw Exception('โหลดโพสต์ไม่สำเร็จ');
      }
      final map = response.data;
      if (map is! Map) {
        throw Exception('โหลดโพสต์ไม่สำเร็จ');
      }
      final m = Map<String, dynamic>.from(map);
      final postRaw = m['post'];
      if (postRaw is! Map) {
        throw Exception('โหลดโพสต์ไม่สำเร็จ');
      }
      final post = CommunityPostDto.fromJson(
        Map<String, dynamic>.from(postRaw),
      );
      final commentsRaw = m['comments'];
      final comments = <CommunityCommentDto>[];
      if (commentsRaw is List) {
        for (final item in commentsRaw) {
          if (item is Map) {
            comments.add(
              CommunityCommentDto.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          }
        }
      }
      return (post: post, comments: comments);
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  MediaType? _imageMediaType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (lower.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    if (lower.endsWith('.gif')) {
      return MediaType('image', 'gif');
    }
    return MediaType('image', 'jpeg');
  }

  /// Backend requires non-empty [content]. [image] is optional.
  Future<void> createPost({
    required String content,
    File? image,
  }) async {
    try {
      final map = <String, dynamic>{'content': content};
      if (image != null && await image.exists()) {
        final path = image.path;
        final name = path.split(Platform.pathSeparator).last;
        map['image'] = await MultipartFile.fromFile(
          path,
          filename: name,
          contentType: _imageMediaType(path),
        );
      }
      final formData = FormData.fromMap(map);
      final response = await _dio.post<dynamic>(
        '/community/posts',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return;
      }
      throw Exception('สร้างโพสต์ไม่สำเร็จ');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  Future<CommunityCommentDto> addComment(String postId, String content) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/community/posts/$postId/comments',
        data: {'content': content},
      );
      if (response.statusCode == 201 && response.data != null) {
        return CommunityCommentDto.fromJson(response.data!);
      }
      throw Exception('ส่งความคิดเห็นไม่สำเร็จ');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  Future<bool> toggleLike(String postId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/community/posts/$postId/like',
      );
      if (response.statusCode == 200 && response.data != null) {
        final liked = response.data!['liked'];
        if (liked is bool) return liked;
      }
      throw Exception('อัปเดตถูกใจไม่สำเร็จ');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }
}
