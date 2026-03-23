import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';
import 'package:ricesafe_app/features/auth/domain/models/user_model.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/main.dart';
import 'package:ricesafe_app/features/community/data/models/community_api_models.dart';
import 'package:ricesafe_app/features/community/presentation/providers/community_provider.dart';
import 'package:ricesafe_app/features/community/presentation/utils/effective_community_avatar.dart';
import 'package:ricesafe_app/features/community/presentation/widgets/post_content_with_location.dart';
import 'package:ricesafe_app/features/community/presentation/widgets/post_image_lightbox.dart';

class PostDetailCommentsScreen extends ConsumerStatefulWidget {
  const PostDetailCommentsScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<PostDetailCommentsScreen> createState() =>
      _PostDetailCommentsScreenState();
}

class _PostDetailCommentsScreenState
    extends ConsumerState<PostDetailCommentsScreen> {
  final _commentController = TextEditingController();
  bool _sendingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike(CommunityPostDto post) async {
    try {
      await ref.read(communityPostDetailProvider(widget.postId).notifier).toggleLike();
      // One API call only: copy updated post from detail state into the feed (no second toggle)
      final updated =
          ref.read(communityPostDetailProvider(widget.postId)).valueOrNull?.post;
      if (updated != null) {
        ref
            .read(communityFeedProvider(kDefaultCommunityFeedQuery).notifier)
            .applyPostUpdate(updated);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userFacingMessage(
                e,
                contextFallback: 'อัปเดตถูกใจไม่สำเร็จ',
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _addComment() async {
    final trimmed = _commentController.text.trim();
    if (trimmed.isEmpty || _sendingComment) return;

    setState(() => _sendingComment = true);
    try {
      await ref.read(communityRepositoryProvider).addComment(
            widget.postId,
            trimmed,
          );
      if (mounted) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
        ref.read(communityPostDetailProvider(widget.postId).notifier).refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userFacingMessage(
                e,
                contextFallback: 'ส่งความคิดเห็นไม่สำเร็จ',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewer = ref.watch(authStateProvider.select((s) => s.user));
    final async = ref.watch(communityPostDetailProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('โพสต์ของชุมชน'),
      ),
      body: async.when(
        data: (record) {
          final post = record.post;
          final comments = record.comments;
          final postAvatar = effectiveCommunityAvatarUrl(
            authorUserId: post.userId,
            dtoAvatarUrl: post.authorAvatarUrl,
            viewer: viewer,
          );
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _DetailAvatar(
                                  imageUrl: postAvatar,
                                  initial: post.avatarInitial,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.authorName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        post.timeAgoLabel,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            PostContentWithLocation(
                              content: post.content,
                              bodyStyle: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (post.imageUrl != null &&
                                post.imageUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => showPostImageLightbox(
                                      context,
                                      post.imageUrl!,
                                    ),
                                    child: Image.network(
                                      post.imageUrl!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, err, _) =>
                                          Container(
                                        height: 200,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => _toggleLike(post),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 8,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          post.isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: post.isLiked
                                              ? Colors.red
                                              : Colors.grey,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${post.likeCount}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 28),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble_outline,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${comments.length}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(thickness: 4, color: Color(0xFFEEEEEE)),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ความคิดเห็น',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (comments.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'ยังไม่มีความคิดเห็น',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            else
                              ...comments.map(
                                (c) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: _buildCommentTile(c, viewer),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: riceSafeGreen,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          enabled: !_sendingComment,
                          decoration: InputDecoration(
                            hintText: 'เขียนความคิดเห็น...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed:
                            _sendingComment ? null : () => _addComment(),
                        icon: _sendingComment
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send, color: riceSafeGreen),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userFacingMessage(
                    e,
                    contextFallback: 'โหลดโพสต์ไม่สำเร็จ',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[800]),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(communityPostDetailProvider(widget.postId)),
                  child: const Text('ลองอีกครั้ง'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentTile(CommunityCommentDto c, UserModel? viewer) {
    final avatarUrl = effectiveCommunityAvatarUrl(
      authorUserId: c.userId,
      dtoAvatarUrl: c.authorAvatarUrl,
      viewer: viewer,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailAvatar(
          imageUrl: avatarUrl,
          initial: c.avatarInitial,
          radius: 16,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  c.content,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  c.timeAgoLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailAvatar extends StatelessWidget {
  const _DetailAvatar({
    required this.imageUrl,
    required this.initial,
    this.radius = 20,
  });

  final String? imageUrl;
  final String initial;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final d = radius * 2;
    final url = imageUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: Image.network(
            url,
            width: d,
            height: d,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Text(
              initial,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: riceSafeGreen,
                fontSize: radius * 0.9,
              ),
            ),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.9,
          color: Colors.black54,
        ),
      ),
    );
  }
}
