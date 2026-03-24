import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/auth/domain/models/user_model.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/features/community/data/community_repository.dart';
import 'package:ricesafe_app/features/community/data/models/community_api_models.dart';
import 'package:ricesafe_app/features/community/presentation/providers/community_provider.dart';
import 'package:ricesafe_app/features/community/presentation/screens/create_post_screen.dart';

import '../../helpers/test_helpers.dart';

class _FakeCreatePostRepository extends CommunityRepository {
  _FakeCreatePostRepository() : super(Dio(BaseOptions()));

  String? lastContent;
  int createCallCount = 0;

  @override
  Future<void> createPost({
    required String content,
    File? image,
  }) async {
    createCallCount++;
    lastContent = content;
  }

  @override
  Future<List<CommunityPostDto>> getPosts({
    int limit = 20,
    int offset = 0,
  }) async =>
      [];

  @override
  Future<({CommunityPostDto post, List<CommunityCommentDto> comments})>
      getPostWithComments(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<CommunityCommentDto> addComment(String postId, String content) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> toggleLike(String postId) async => false;
}

class _CreatePostMockAuth extends StateNotifier<AuthState> implements AuthNotifier {
  _CreatePostMockAuth()
      : super(
          AuthState(
            user: UserModel(
              id: 'u1',
              username: 'Poster',
              email: 'p@p.com',
              role: 'FARMER',
            ),
            token: 'tok',
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
  late MockGoRouter mockRouter;
  late _FakeCreatePostRepository fakeRepo;

  setUp(() {
    mockRouter = MockGoRouter();
    fakeRepo = _FakeCreatePostRepository();
    when(() => mockRouter.pop()).thenAnswer((_) {});
  });

  testWidgets('shows composer and image attach action', (tester) async {
    await pumpRouterApp(
      tester,
      home: const CreatePostScreen(),
      router: mockRouter,
      overrides: [
        authStateProvider.overrideWith((ref) => _CreatePostMockAuth()),
        communityRepositoryProvider.overrideWith((ref) => fakeRepo),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('สร้างโพสต์'), findsOneWidget);
    expect(
      find.text('คุณกำลังคิดอะไรอยู่เกี่ยวกับการทำนา?'),
      findsOneWidget,
    );
    expect(find.text('เพิ่มในโพสต์ของคุณ'), findsOneWidget);
    expect(find.text('รูปภาพ'), findsOneWidget);
    expect(find.text('Poster'), findsOneWidget);
  });

  testWidgets('submitting text post calls repository and pops', (tester) async {
    await pumpRouterApp(
      tester,
      home: const CreatePostScreen(),
      router: mockRouter,
      overrides: [
        authStateProvider.overrideWith((ref) => _CreatePostMockAuth()),
        communityRepositoryProvider.overrideWith((ref) => fakeRepo),
      ],
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'Hello from test',
    );
    await tester.tap(find.text('โพสต์'));
    await tester.pumpAndSettle();

    expect(fakeRepo.createCallCount, 1);
    expect(fakeRepo.lastContent, 'Hello from test');
    expect(find.text('โพสต์สำเร็จ'), findsOneWidget);
    verify(() => mockRouter.pop()).called(1);
  });
}
