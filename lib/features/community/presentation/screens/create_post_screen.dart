import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ricesafe_app/features/auth/domain/models/user_model.dart';
import 'package:ricesafe_app/features/auth/onboarding/register_onboarding_state.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';
import 'package:ricesafe_app/features/community/presentation/providers/community_provider.dart';
import 'package:ricesafe_app/main.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  bool _submitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    if (image == null || !mounted) return;
    setState(() => _imagePath = image.path);
  }

  /// รูปโปรไฟล์ผู้ใช้เท่านั้น (ไม่ใช้รูปแนบโพสต์ — แบบเดียวกับ Facebook composer)
  Widget _buildUserAvatar() {
    final user = ref.watch(authStateProvider).user;
    final url = user?.avatarUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade300,
        child: ClipOval(
          child: Image.network(
            url,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _userAvatarFallback(user),
          ),
        ),
      );
    }

    final localPath = RegisterOnboardingState.avatarFilePath;
    if (localPath != null &&
        localPath.isNotEmpty &&
        File(localPath).existsSync()) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: FileImage(File(localPath)),
      );
    }

    return _userAvatarFallback(user);
  }

  Widget _userAvatarFallback(UserModel? user) {
    final name = user?.username.trim() ?? '';
    final letter = name.isNotEmpty ? name.substring(0, 1) : '?';
    return CircleAvatar(
      radius: 22,
      backgroundColor: riceSafeGreen,
      child: Text(
        letter,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _submitPost() async {
    final text = _contentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาใส่ข้อความ (จำเป็นต่อการโพสต์)'),
        ),
      );
      return;
    }

    final file = (_imagePath != null && File(_imagePath!).existsSync())
        ? File(_imagePath!)
        : null;

    setState(() => _submitting = true);
    try {
      await ref.read(communityRepositoryProvider).createPost(
            content: text,
            image: file,
          );
      if (mounted) {
        ref.read(communityFeedProvider(kDefaultCommunityFeedQuery).notifier).refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('โพสต์สำเร็จ')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userFacingMessage(
                e,
                contextFallback: 'โพสต์ไม่สำเร็จ',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _imagePath != null && File(_imagePath!).existsSync();
    final user = ref.watch(authStateProvider).user;
    final displayName = user?.username.trim().isNotEmpty == true
        ? user!.username.trim()
        : 'เกษตรกร';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'สร้างโพสต์',
          style: TextStyle(
            color: Colors.grey.shade900,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submitPost,
            child: _submitting
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: riceSafeGreen,
                    ),
                  )
                : Text(
                    'โพสต์',
                    style: TextStyle(
                      color: riceSafeGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserAvatar(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.public,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'ชุมชน · ทุกคนเห็น',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    minLines: 6,
                    enabled: !_submitting,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.35,
                    ),
                    decoration: InputDecoration(
                      hintText: 'คุณกำลังคิดอะไรอยู่เกี่ยวกับการทำนา?',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 18,
                        height: 1.35,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (hasImage) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 320),
                            child: Image.file(
                              File(_imagePath!),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Material(
                            color: Colors.black45,
                            shape: const CircleBorder(),
                            child: IconButton(
                              onPressed: _submitting
                                  ? null
                                  : () => setState(() => _imagePath = null),
                              icon: const Icon(Icons.close, size: 22),
                              color: Colors.white,
                              tooltip: 'ลบรูป',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ColoredBox(
            color: Colors.grey.shade100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 6),
                  child: Text(
                    'เพิ่มในโพสต์ของคุณ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: _FbStyleAttachTile(
                      icon: Icons.photo_library_outlined,
                      label: 'รูปภาพ',
                      iconColor: riceSafeGreen,
                      onTap: _submitting ? null : _pickImage,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ปุ่มแนบแบบกล่องสี่เหลี่ยมใต้แถบ "เพิ่มในโพสต์"
class _FbStyleAttachTile extends StatelessWidget {
  const _FbStyleAttachTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
