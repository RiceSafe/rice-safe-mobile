import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/auth/domain/models/user_model.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/features/community/data/community_repository.dart';
import 'package:ricesafe_app/features/community/data/models/community_api_models.dart';
import 'package:ricesafe_app/features/community/presentation/providers/community_provider.dart';
import 'package:ricesafe_app/features/community/presentation/screens/post_detail_comments_screen.dart';

import '../../helpers/test_helpers.dart';

class _FakePostDetailRepository extends CommunityRepository {
  _FakePostDetailRepository(this._postId) : super(Dio(BaseOptions()));

  final String _postId;
  String? lastCommentContent;

  @override
  Future<({CommunityPostDto post, List<CommunityCommentDto> comments})>
      getPostWithComments(String id) async {
    expect(id, _postId);
    return (
      post: CommunityPostDto(
        id: id,
        userId: 'viewer-1',
        authorName: 'Author Name',
        authorRole: 'EXPERT',
        content: 'Post body text',
        likeCount: 2,
        commentCount: 1,
        isLiked: false,
        createdAt: DateTime(2025, 1, 1, 12, 0),
      ),
      comments: [
        CommunityCommentDto(
          id: 'c1',
          postId: id,
          userId: 'other',
          authorName: 'Commenter',
          content: 'First comment',
          createdAt: DateTime(2025, 1, 1, 13, 0),
        ),
      ],
    );
  }

  @override
  Future<List<CommunityPostDto>> getPosts({
    int limit = 20,
    int offset = 0,
  }) async =>
      [];

  @override
  Future<void> createPost({
    required String content,
    File? image,
  }) async {}

  @override
  Future<CommunityCommentDto> addComment(String postId, String content) async {
    lastCommentContent = content;
    return CommunityCommentDto(
      id: 'new',
      postId: postId,
      userId: 'viewer-1',
      authorName: 'Me',
      content: content,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<bool> toggleLike(String postId) async => true;
}

class _PostDetailMockAuth extends StateNotifier<AuthState> implements AuthNotifier {
  _PostDetailMockAuth()
      : super(
          AuthState(
            user: UserModel(
              id: 'viewer-1',
              username: 'viewer',
              email: 'v@v.com',
              role: 'FARMER',
            ),
            token: 't',
          ),
        );

  @override
  Future<void> loginWithEmailPassword(String email, String password) async {}

  @override
  Future<void> loginWithOAuth(String provider, String idToken) async {}

  @override
  Future<void> registerAndSignIn({
    required String username,
    required String email,
    required String password,
    String role = 'FARMER',
  }) async {}

  @override
  Future<void> restoreSession() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<bool> updateProfile({
    String? username,
    String? avatarFilePath,
  }) async =>
      true;

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async =>
      true;
}

void main() {
  const postId = 'post-uuid-1';

  testWidgets('shows post and comments from repository', (tester) async {
    await pumpRouterApp(
      tester,
      home: const PostDetailCommentsScreen(postId: postId),
      overrides: [
        authStateProvider.overrideWith((ref) => _PostDetailMockAuth()),
        communityRepositoryProvider.overrideWith(
          (ref) => _FakePostDetailRepository(postId),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('โพสต์ของชุมชน'), findsOneWidget);
    expect(
      find.textContaining('Author Name', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('ผู้เชี่ยวชาญ'), findsOneWidget);
    expect(find.text('Post body text'), findsOneWidget);
    expect(find.text('ความคิดเห็น'), findsOneWidget);
    expect(find.text('First comment'), findsOneWidget);
    expect(find.text('เขียนความคิดเห็น...'), findsOneWidget);
  });

  testWidgets('send comment calls repository with trimmed text', (tester) async {
    final fake = _FakePostDetailRepository(postId);
    await pumpRouterApp(
      tester,
      home: const PostDetailCommentsScreen(postId: postId),
      overrides: [
        authStateProvider.overrideWith((ref) => _PostDetailMockAuth()),
        communityRepositoryProvider.overrideWith((ref) => fake),
      ],
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '  hello  ');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(fake.lastCommentContent, 'hello');
  });
}
