import 'package:ricesafe_app/features/auth/domain/models/user_model.dart';

/// โพสต์/คอมเมนต์ของผู้ใช้ที่ล็อกอินอยู่ ให้ใช้รูปล่าสุดจาก [UserModel.avatarUrl]
/// แทน snapshot ใน DTO หลังอัปเดตโปรไฟล์ (จนกว่าจะรีเฟรชจาก API)
String? effectiveCommunityAvatarUrl({
  required String authorUserId,
  required String? dtoAvatarUrl,
  required UserModel? viewer,
}) {
  if (viewer != null && authorUserId == viewer.id) {
    final live = viewer.avatarUrl;
    if (live != null && live.isNotEmpty) return live;
  }
  return dtoAvatarUrl;
}
