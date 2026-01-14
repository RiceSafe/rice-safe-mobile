class CommunityPost {
  final String id;
  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String content;
  final String? postImage;
  int likeCount;
  int commentCount;
  bool isLiked;

  CommunityPost({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.content,
    this.postImage,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });
}

final List<CommunityPost> mockPosts = [
  CommunityPost(
    id: '1',
    userName: 'สมชาย รักนา',
    userAvatar: 'S',
    timeAgo: '2 ชม. ที่แล้ว',
    content: 'ข้าวใบเหลืองแบบนี้คือโรคอะไรครับ? ช่วยดูหน่อย',
    postImage: 'assets/mock/rice_blast_2.jpg',
    likeCount: 12,
    commentCount: 5,
  ),
  CommunityPost(
    id: '2',
    userName: 'ลุงแดง ชาวไร่',
    userAvatar: 'L',
    timeAgo: '5 ชม. ที่แล้ว',
    content: 'ช่วงนี้มีใครเจอปัญหาข้าวโตช้าบ้างไหมครับ',
    likeCount: 45,
    commentCount: 8,
    isLiked: true,
  ),
  CommunityPost(
    id: '3',
    userName: 'พิมพ์ใจ รักทุ่ง',
    userAvatar: 'P',
    timeAgo: '1 วัน ที่แล้ว',
    content: 'ขอบใบแห้งเริ่มระบาดในหมู่บ้านเรา ระวังกันด้วย',
    postImage: 'assets/mock/leaf_blight_2.jpg',
    likeCount: 20,
    commentCount: 2,
  ),
];
