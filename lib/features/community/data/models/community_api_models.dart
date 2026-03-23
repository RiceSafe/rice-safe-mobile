import 'package:intl/intl.dart';

/// Aligns with backend `PostResponse`.
class CommunityPostDto {
  final String id;
  final String userId;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final String? imageUrl;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CommunityPostDto({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.content,
    this.imageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    this.createdAt,
    this.updatedAt,
  });

  factory CommunityPostDto.fromJson(Map<String, dynamic> json) {
    return CommunityPostDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      authorName: json['author_name'] as String? ?? '',
      authorAvatarUrl: json['author_avatar'] as String?,
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: _parseJsonDate(json['created_at']),
      updatedAt: _parseJsonDate(json['updated_at']),
    );
  }

  String get avatarInitial => _firstGrapheme(authorName);

  String get timeAgoLabel => formatRelativeTime(createdAt);

  CommunityPostDto copyWith({
    String? id,
    String? userId,
    String? authorName,
    String? authorAvatarUrl,
    String? content,
    String? imageUrl,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityPostDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

DateTime? _parseJsonDate(dynamic v) {
  if (v is! String || v.isEmpty) return null;
  return DateTime.tryParse(v);
}

/// Aligns with backend `CommentResponse`.
class CommunityCommentDto {
  final String id;
  final String postId;
  final String userId;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final DateTime? createdAt;

  const CommunityCommentDto({
    required this.id,
    required this.postId,
    required this.userId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.content,
    this.createdAt,
  });

  factory CommunityCommentDto.fromJson(Map<String, dynamic> json) {
    return CommunityCommentDto(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      // CreateComment returns Comment; list/detail returns CommentResponse.
      authorName: json['author_name'] as String? ?? 'คุณ',
      authorAvatarUrl: json['author_avatar'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: _parseJsonDate(json['created_at']),
    );
  }

  String get avatarInitial => _firstGrapheme(authorName);

  String get timeAgoLabel => formatRelativeTime(createdAt);
}

String _firstGrapheme(String name) {
  final s = name.trim();
  if (s.isEmpty) return '?';
  final it = s.runes.iterator;
  if (!it.moveNext()) return '?';
  return String.fromCharCode(it.current);
}

String formatRelativeTime(DateTime? dt) {
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'เมื่อสักครู่';
  if (diff.inMinutes < 60) return '${diff.inMinutes} นาที ที่แล้ว';
  if (diff.inHours < 24) return '${diff.inHours} ชม. ที่แล้ว';
  if (diff.inDays < 7) return '${diff.inDays} วัน ที่แล้ว';
  return DateFormat('d MMM yyyy').format(dt);
}
