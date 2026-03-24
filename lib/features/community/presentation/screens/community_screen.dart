import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';
import 'package:ricesafe_app/core/widgets/app_bar_profile_button.dart';
import 'package:ricesafe_app/features/auth/domain/models/user_model.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/features/community/presentation/utils/effective_community_avatar.dart';
import 'package:ricesafe_app/main.dart';
import 'package:ricesafe_app/features/community/data/models/community_api_models.dart';
import 'package:ricesafe_app/features/community/presentation/providers/community_provider.dart';
import 'package:ricesafe_app/features/community/presentation/widgets/community_role_badge.dart';
import 'package:ricesafe_app/features/community/presentation/widgets/post_content_with_location.dart';
import 'package:ricesafe_app/features/community/presentation/widgets/post_image_lightbox.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  static const _feedQuery = kDefaultCommunityFeedQuery;

  Future<void> _refresh() async {
    await ref.read(communityFeedProvider(_feedQuery).notifier).refresh();
  }

  Future<void> _onToggleLike(CommunityPostDto post) async {
    try {
      await ref.read(communityFeedProvider(_feedQuery).notifier).toggleLike(post);
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

  @override
  Widget build(BuildContext context) {
    final viewer = ref.watch(authStateProvider.select((s) => s.user));
    final feedAsync = ref.watch(communityFeedProvider(_feedQuery));

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/rice_icon.png'),
        ),
        title: const Text(
          'ชุมชน',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: const [AppBarProfileButton()],
      ),
      body: feedAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('ยังไม่มีโพสต์')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildPostCard(context, posts[index], viewer);
              },
            ),
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
                  onPressed: _refresh,
                  child: const Text('ลองอีกครั้ง'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          GoRouter.of(context).push('/community/create-post');
        },
        backgroundColor: riceSafeGreen,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('โพสต์', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildPostCard(
    BuildContext context,
    CommunityPostDto post,
    UserModel? viewer,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/community/post/${post.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _AuthorAvatar(
                    imageUrl: effectiveCommunityAvatarUrl(
                      authorUserId: post.userId,
                      dtoAvatarUrl: post.authorAvatarUrl,
                      viewer: viewer,
                    ),
                    initial: post.avatarInitial,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommunityAuthorNameWithRole(
                          authorName: post.authorName,
                          authorRole: post.authorRole,
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
              const SizedBox(height: 12),
              PostContentWithLocation(
                content: post.content,
                bodyStyle: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 12),
              if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            showPostImageLightbox(context, post.imageUrl!),
                        child: Image.network(
                          post.imageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, err, _) => Container(
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
                ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButtons(
                    icon: post.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: post.isLiked ? Colors.red : Colors.grey,
                    label: '${post.likeCount} ถูกใจ',
                    onTap: () => _onToggleLike(post),
                  ),
                  _buildActionButtons(
                    icon: Icons.chat_bubble_outline,
                    color: Colors.grey,
                    label: '${post.commentCount} ความคิดเห็น',
                    onTap: () => context.push('/community/post/${post.id}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({
    required this.imageUrl,
    required this.initial,
  });

  final String? imageUrl;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: Image.network(
            url,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Text(
              initial,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: riceSafeGreen,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }
    return CircleAvatar(
      backgroundColor: Colors.grey[200],
      child: Text(
        initial,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: riceSafeGreen,
        ),
      ),
    );
  }
}
