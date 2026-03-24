import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/community/data/community_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late CommunityRepository repo;

  setUp(() {
    dio = MockDio();
    repo = CommunityRepository(dio);
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(Options());
  });

  Map<String, dynamic> minimalPostJson(String id) => <String, dynamic>{
        'id': id,
        'user_id': 'user-$id',
        'author_name': 'Author',
        'content': 'Body',
        'like_count': 1,
        'comment_count': 2,
        'is_liked': false,
      };

  Map<String, dynamic> minimalCommentJson({
    required String id,
    required String postId,
  }) =>
      <String, dynamic>{
        'id': id,
        'post_id': postId,
        'user_id': 'commenter',
        'author_name': 'Commenter',
        'content': 'Nice',
      };

  group('CommunityRepository.getPosts', () {
    test('returns posts on 200', () async {
      final raw = <dynamic>[
        minimalPostJson('p1'),
        minimalPostJson('p2'),
      ];
      when(
        () => dio.get<dynamic>(
          '/community/posts',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/community/posts'),
          statusCode: 200,
          data: raw,
        ),
      );

      final posts = await repo.getPosts();

      expect(posts, hasLength(2));
      expect(posts.first.id, 'p1');
      expect(posts.last.content, 'Body');
      verify(
        () => dio.get<dynamic>(
          '/community/posts',
          queryParameters: <String, dynamic>{'limit': 20, 'offset': 0},
        ),
      ).called(1);
    });

    test('passes limit and offset', () async {
      when(
        () => dio.get<dynamic>(
          '/community/posts',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/community/posts'),
          statusCode: 200,
          data: <dynamic>[],
        ),
      );

      await repo.getPosts(limit: 5, offset: 10);

      verify(
        () => dio.get<dynamic>(
          '/community/posts',
          queryParameters: <String, dynamic>{'limit': 5, 'offset': 10},
        ),
      ).called(1);
    });

    test('returns empty list when data is null or not a list', () async {
      when(
        () => dio.get<dynamic>(
          '/community/posts',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/community/posts'),
          statusCode: 200,
          data: null,
        ),
      );
      expect(await repo.getPosts(), isEmpty);

      when(
        () => dio.get<dynamic>(
          '/community/posts',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/community/posts'),
          statusCode: 200,
          data: <String, dynamic>{'not': 'list'},
        ),
      );
      expect(await repo.getPosts(), isEmpty);
    });

    test('throws on non-200', () async {
      when(
        () => dio.get<dynamic>(
          '/community/posts',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/community/posts'),
          statusCode: 500,
          data: null,
        ),
      );

      expect(
        repo.getPosts(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('โหลดโพสต์ไม่สำเร็จ'),
          ),
        ),
      );
    });

    test('throws Exception from DioException', () async {
      when(
        () => dio.get<dynamic>(
          '/community/posts',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/community/posts'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/community/posts'),
            statusCode: 503,
            data: <String, dynamic>{'error': 'Down'},
          ),
        ),
      );

      expect(
        repo.getPosts(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Down'),
          ),
        ),
      );
    });
  });

  group('CommunityRepository.getPostWithComments', () {
    test('returns post and comments on 200', () async {
      final body = <String, dynamic>{
        'post': minimalPostJson('pid'),
        'comments': <dynamic>[
          minimalCommentJson(id: 'c1', postId: 'pid'),
        ],
      };
      when(() => dio.get<dynamic>('/community/posts/pid')).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/community/posts/pid'),
          statusCode: 200,
          data: body,
        ),
      );

      final result = await repo.getPostWithComments('pid');

      expect(result.post.id, 'pid');
      expect(result.comments, hasLength(1));
      expect(result.comments.single.id, 'c1');
    });

    test('throws when data is not a Map', () async {
      when(() => dio.get<dynamic>('/community/posts/x')).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/community/posts/x'),
          statusCode: 200,
          data: <dynamic>[],
        ),
      );

      expect(
        repo.getPostWithComments('x'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('โหลดโพสต์ไม่สำเร็จ'),
          ),
        ),
      );
    });

    test('throws when post field is missing or not Map', () async {
      when(() => dio.get<dynamic>('/community/posts/y')).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/community/posts/y'),
          statusCode: 200,
          data: <String, dynamic>{'comments': <dynamic>[]},
        ),
      );

      expect(
        repo.getPostWithComments('y'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('โหลดโพสต์ไม่สำเร็จ'),
          ),
        ),
      );
    });

    test('throws Exception from DioException', () async {
      when(() => dio.get<dynamic>('/community/posts/z')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/community/posts/z'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/community/posts/z'),
            statusCode: 404,
            data: <String, dynamic>{'error': 'Not found'},
          ),
        ),
      );

      expect(
        repo.getPostWithComments('z'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Not found'),
          ),
        ),
      );
    });
  });

  group('CommunityRepository.createPost', () {
    test('completes on 201 without image', () async {
      when(
        () => dio.post<dynamic>(
          '/community/posts',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/community/posts'),
          statusCode: 201,
          data: null,
        ),
      );

      await expectLater(
        repo.createPost(content: 'Hello'),
        completes,
      );

      verify(
        () => dio.post<dynamic>(
          '/community/posts',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('completes on 200', () async {
      when(
        () => dio.post<dynamic>(
          '/community/posts',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/community/posts'),
          statusCode: 200,
          data: null,
        ),
      );

      await repo.createPost(content: 'Only text');
    });

    test('includes image when file exists', () async {
      final dir = await Directory.systemTemp.createTemp('ricesafe_community_');
      final file = File('${dir.path}${Platform.pathSeparator}pic.jpg');
      await file.writeAsString('x');
      addTearDown(() async {
        if (await file.exists()) await file.delete();
        await dir.delete(recursive: true);
      });

      when(
        () => dio.post<dynamic>(
          '/community/posts',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/community/posts'),
          statusCode: 201,
          data: null,
        ),
      );

      await repo.createPost(content: 'With pic', image: file);

      verify(
        () => dio.post<dynamic>(
          '/community/posts',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('throws on non-success status', () async {
      when(
        () => dio.post<dynamic>(
          '/community/posts',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/community/posts'),
          statusCode: 400,
          data: null,
        ),
      );

      expect(
        () => repo.createPost(content: 'x'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('สร้างโพสต์ไม่สำเร็จ'),
          ),
        ),
      );
    });

    test('throws Exception from DioException', () async {
      when(
        () => dio.post<dynamic>(
          '/community/posts',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/community/posts'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/community/posts'),
            statusCode: 413,
            data: <String, dynamic>{'error': 'Too large'},
          ),
        ),
      );

      expect(
        () => repo.createPost(content: 'big'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Too large'),
          ),
        ),
      );
    });
  });

  group('CommunityRepository.addComment', () {
    test('returns comment on 201', () async {
      final body = minimalCommentJson(id: 'nc', postId: 'p9');
      when(
        () => dio.post<Map<String, dynamic>>(
          '/community/posts/p9/comments',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/community/posts/p9/comments'),
          statusCode: 201,
          data: body,
        ),
      );

      final c = await repo.addComment('p9', 'text');

      expect(c.id, 'nc');
      expect(c.content, 'Nice');
      verify(
        () => dio.post<Map<String, dynamic>>(
          '/community/posts/p9/comments',
          data: <String, dynamic>{'content': 'text'},
        ),
      ).called(1);
    });

    test('throws when status is not 201', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/community/posts/p/comments',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/community/posts/p/comments'),
          statusCode: 200,
          data: <String, dynamic>{},
        ),
      );

      expect(
        () => repo.addComment('p', 'x'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('ส่งความคิดเห็นไม่สำเร็จ'),
          ),
        ),
      );
    });

    test('throws Exception from DioException', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/community/posts/p/comments',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/community/posts/p/comments'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/community/posts/p/comments'),
            statusCode: 403,
            data: <String, dynamic>{'error': 'Banned'},
          ),
        ),
      );

      expect(
        () => repo.addComment('p', 'x'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Banned'),
          ),
        ),
      );
    });
  });

  group('CommunityRepository.toggleLike', () {
    test('returns liked bool on 200', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/community/posts/pl/like',
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/community/posts/pl/like'),
          statusCode: 200,
          data: <String, dynamic>{'liked': true},
        ),
      );

      expect(await repo.toggleLike('pl'), isTrue);
    });

    test('throws when liked is not bool', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/community/posts/pl/like',
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/community/posts/pl/like'),
          statusCode: 200,
          data: <String, dynamic>{'liked': 'yes'},
        ),
      );

      expect(
        repo.toggleLike('pl'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('อัปเดตถูกใจไม่สำเร็จ'),
          ),
        ),
      );
    });

    test('throws Exception from DioException', () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          '/community/posts/pl/like',
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/community/posts/pl/like'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/community/posts/pl/like'),
            statusCode: 500,
            data: <String, dynamic>{'error': 'Like failed'},
          ),
        ),
      );

      expect(
        repo.toggleLike('pl'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('Like failed'),
          ),
        ),
      );
    });
  });
}
