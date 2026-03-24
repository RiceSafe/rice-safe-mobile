import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/main.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _pickedImagePath;
  bool _seededUsername = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seededUsername) return;
    final u = ref.read(authStateProvider).user;
    if (u != null) {
      _seededUsername = true;
      _usernameController.text = u.username;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    setState(() => _pickedImagePath = image.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้')),
      );
      return;
    }

    final newName = _usernameController.text.trim();
    final nameChanged = newName != user.username;
    final hasNewImage =
        _pickedImagePath != null && File(_pickedImagePath!).existsSync();

    final oldP = _oldPasswordController.text;
    final newP = _newPasswordController.text;
    final conf = _confirmPasswordController.text;
    final anyPwd = oldP.isNotEmpty || newP.isNotEmpty || conf.isNotEmpty;

    if (!nameChanged && !hasNewImage && !anyPwd) {
      if (mounted) Navigator.pop(context);
      return;
    }

    if (nameChanged || hasNewImage) {
      final ok = await ref.read(authStateProvider.notifier).updateProfile(
            username: nameChanged ? newName : null,
            avatarFilePath: hasNewImage ? _pickedImagePath : null,
          );
      if (!mounted) return;
      if (!ok) {
        final err =
            ref.read(authStateProvider).profileError ?? 'บันทึกโปรไฟล์ไม่สำเร็จ';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.replaceFirst('Exception: ', ''))),
        );
        return;
      }
      setState(() => _pickedImagePath = null);
    }

    if (anyPwd) {
      if (oldP.isEmpty || newP.isEmpty || conf.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณากรอกรหัสผ่านให้ครบทุกช่อง')),
        );
        return;
      }
      if (newP != conf) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('รหัสผ่านใหม่ไม่ตรงกัน')),
        );
        return;
      }
      if (newP.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('รหัสผ่านใหม่ต้องมีอย่างน้อย 6 ตัวอักษร')),
        );
        return;
      }

      final pwdOk = await ref.read(authStateProvider.notifier).changePassword(
            oldPassword: oldP,
            newPassword: newP,
          );
      if (!mounted) return;
      if (!pwdOk) {
        final err = ref.read(authStateProvider).passwordError ??
            'เปลี่ยนรหัสผ่านไม่สำเร็จ';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.replaceFirst('Exception: ', ''))),
        );
        return;
      }
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')),
    );
    Navigator.pop(context);
  }

  Widget _buildAvatarPreview() {
    final picked = _pickedImagePath;
    if (picked != null && File(picked).existsSync()) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: riceSafeGreen,
        backgroundImage: FileImage(File(picked)),
      );
    }

    final url = ref.watch(authStateProvider).user?.avatarUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: riceSafeGreen,
        child: ClipOval(
          child: Image.network(
            url,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Padding(
                padding: EdgeInsets.all(28.0),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              );
            },
          ),
        ),
      );
    }

    return const CircleAvatar(
      radius: 60,
      backgroundColor: riceSafeGreen,
      child: Icon(Icons.person, size: 60, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final busy = authState.profileLoading || authState.passwordLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขโปรไฟล์'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Tooltip(
                  message: 'แตะรูปหรือไอคอนกล้องเพื่อเปลี่ยนรูปโปรไฟล์',
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    clipBehavior: Clip.none,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: busy ? null : _pickImage,
                          customBorder: const CircleBorder(),
                          child: _buildAvatarPreview(),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: busy ? null : _pickImage,
                          customBorder: const CircleBorder(),
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.camera_alt,
                              color: riceSafeGreen,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'ชื่อผู้ใช้งาน',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _usernameController,
                enabled: !busy,
                decoration: InputDecoration(
                  hintText: 'กรอกชื่อผู้ใช้งาน',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'กรุณากรอกชื่อผู้ใช้';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'เปลี่ยนรหัสผ่าน',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                enabled: !busy,
                decoration: InputDecoration(
                  hintText: 'รหัสผ่านเดิม (เว้นว่างถ้าไม่เปลี่ยน)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                enabled: !busy,
                decoration: InputDecoration(
                  hintText: 'รหัสผ่านใหม่',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                enabled: !busy,
                decoration: InputDecoration(
                  hintText: 'ยืนยันรหัสผ่านใหม่',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: busy ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: riceSafeGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'บันทึกการเปลี่ยนแปลง',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
