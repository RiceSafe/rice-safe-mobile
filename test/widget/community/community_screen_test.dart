import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/community/data/community_repository.dart';
import 'package:ricesafe_app/features/community/data/models/community_api_models.dart';
import 'package:ricesafe_app/features/community/presentation/providers/community_provider.dart';
import 'package:ricesafe_app/features/community/presentation/screens/community_screen.dart';
import '../../helpers/test_helpers.dart';

class _FakeCommunityRepository extends CommunityRepository {
  _FakeCommunityRepository() : super(Dio(BaseOptions()));

  bool _liked = false;

  @override
  Future<List<CommunityPostDto>> getPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    return [
      CommunityPostDto(
        id: '11111111-1111-1111-1111-111111111111',
        userId: 'u',
        authorName: 'ทดสอบ',
        authorRole: 'FARMER',
        content: 'ข้อความทดสอบ',
        likeCount: _liked ? 1 : 0,
        commentCount: 0,
        isLiked: _liked,
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<({CommunityPostDto post, List<CommunityCommentDto> comments})>
      getPostWithComments(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<void> createPost({
    required String content,
    File? image,
  }) async {}

  @override
  Future<CommunityCommentDto> addComment(String postId, String content) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> toggleLike(String postId) async {
    _liked = !_liked;
    return _liked;
  }
}

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    mockRouter = MockGoRouter();
  });

  testWidgets('CommunityScreen displays posts from repository',
      (WidgetTester tester) async {
    await pumpRouterApp(
      tester,
      home: const CommunityScreen(),
      router: mockRouter,
      overrides: [
        communityRepositoryProvider.overrideWith(
          (ref) => _FakeCommunityRepository(),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('ชุมชน'), findsOneWidget);
    expect(find.text('โพสต์'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('ข้อความทดสอบ'), findsOneWidget);
    expect(find.text('ชาวนา'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsWidgets);
    expect(find.byIcon(Icons.chat_bubble_outline), findsWidgets);
  });

  testWidgets('CommunityScreen like toggles after tap', (WidgetTester tester) async {
    await pumpRouterApp(
      tester,
      home: const CommunityScreen(),
      router: mockRouter,
      overrides: [
        communityRepositoryProvider.overrideWith(
          (ref) => _FakeCommunityRepository(),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_border), findsWidgets);

    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsWidgets);
  });
}
