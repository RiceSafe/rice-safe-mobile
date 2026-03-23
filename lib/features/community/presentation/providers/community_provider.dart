import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/network/dio_provider.dart';
import 'package:ricesafe_app/features/community/data/community_repository.dart';
import 'package:ricesafe_app/features/community/data/models/community_api_models.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository(ref.watch(dioProvider));
});

@immutable
class CommunityFeedQuery {
  const CommunityFeedQuery({this.limit = 20, this.offset = 0});

  final int limit;
  final int offset;

  @override
  bool operator ==(Object other) =>
      other is CommunityFeedQuery &&
      other.limit == limit &&
      other.offset == offset;

  @override
  int get hashCode => Object.hash(limit, offset);
}

/// Default first page of community feed.
const CommunityFeedQuery kDefaultCommunityFeedQuery = CommunityFeedQuery();

class CommunityFeedNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<CommunityPostDto>, CommunityFeedQuery> {
  @override
  Future<List<CommunityPostDto>> build(CommunityFeedQuery arg) async {
    return ref.read(communityRepositoryProvider).getPosts(
          limit: arg.limit,
          offset: arg.offset,
        );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }

  Future<void> toggleLike(CommunityPostDto post) async {
    final prev = state.valueOrNull;
    if (prev == null) return;

    try {
      final liked = await ref.read(communityRepositoryProvider).toggleLike(post.id);
      
      final delta = (liked ? 1 : 0) - (post.isLiked ? 1 : 0);
      var newLikeCount = post.likeCount + delta;
      if (newLikeCount < 0) newLikeCount = 0;

      final updatedPost = post.copyWith(
        isLiked: liked,
        likeCount: newLikeCount,
      );

      state = AsyncData(
        prev.map((p) => p.id == post.id ? updatedPost : p).toList(),
      );
    } catch (e) {
      // Let the UI handle the error (e.g. show snackbar)
      rethrow;
    }
  }

  /// Sync a post into the feed after it was updated elsewhere (e.g. detail screen)
  /// without calling the API again.
  void applyPostUpdate(CommunityPostDto updated) {
    final prev = state.valueOrNull;
    if (prev == null) return;
    final idx = prev.indexWhere((p) => p.id == updated.id);
    if (idx < 0) return;
    state = AsyncData(
      prev.map((p) => p.id == updated.id ? updated : p).toList(),
    );
  }
}

final communityFeedProvider = AsyncNotifierProvider.autoDispose.family<
    CommunityFeedNotifier, List<CommunityPostDto>, CommunityFeedQuery>(
  CommunityFeedNotifier.new,
);

typedef CommunityPostDetailRecord = ({
  CommunityPostDto post,
  List<CommunityCommentDto> comments,
});

class CommunityPostDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<CommunityPostDetailRecord, String> {
  @override
  Future<CommunityPostDetailRecord> build(String arg) async {
    return ref.read(communityRepositoryProvider).getPostWithComments(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }

  Future<void> toggleLike() async {
    final prev = state.valueOrNull;
    if (prev == null) return;

    try {
      final liked = await ref.read(communityRepositoryProvider).toggleLike(arg);
      
      final delta = (liked ? 1 : 0) - (prev.post.isLiked ? 1 : 0);
      var newLikeCount = prev.post.likeCount + delta;
      if (newLikeCount < 0) newLikeCount = 0;

      final updatedPost = prev.post.copyWith(
        isLiked: liked,
        likeCount: newLikeCount,
      );

      state = AsyncData((
        post: updatedPost,
        comments: prev.comments,
      ));
    } catch (e) {
      rethrow;
    }
  }
}

final communityPostDetailProvider = AsyncNotifierProvider.autoDispose
    .family<CommunityPostDetailNotifier, CommunityPostDetailRecord, String>(
  CommunityPostDetailNotifier.new,
);
