import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ricesafe_app/features/auth/onboarding/register_onboarding_state.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/main.dart';

class OnboardingProfilePhotoScreen extends ConsumerStatefulWidget {
  const OnboardingProfilePhotoScreen({super.key});

  @override
  ConsumerState<OnboardingProfilePhotoScreen> createState() =>
      _OnboardingProfilePhotoScreenState();
}

class _OnboardingProfilePhotoScreenState
    extends ConsumerState<OnboardingProfilePhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _localPath;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _localPath = RegisterOnboardingState.profileImagePath;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    setState(() {
      _localPath = image.path;
      RegisterOnboardingState.profileImagePath = image.path;
    });
  }

  Future<void> _goToFarmLocation({required bool skipPhoto}) async {
    if (skipPhoto) {
      RegisterOnboardingState.profileImagePath = null;
      setState(() => _localPath = null);
      if (mounted) context.go('/register/farm-location');
      return;
    }

    if (_localPath != null) {
      RegisterOnboardingState.profileImagePath = _localPath;
    }

    final path = _localPath;
    if (path != null && File(path).existsSync()) {
      setState(() => _uploading = true);
      final ok = await ref.read(authStateProvider.notifier).updateProfile(
            avatarFilePath: path,
          );
      if (!mounted) return;
      setState(() => _uploading = false);
      if (!ok) {
        final err = ref.read(authStateProvider).profileError ?? 'อัปโหลดรูปไม่สำเร็จ';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.replaceFirst('Exception: ', ''))),
        );
        return;
      }
    }

    if (mounted) context.go('/register/farm-location');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'รูปโปรไฟล์',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _uploading ? null : () => context.go('/register'),
        ),
        actions: [
          TextButton(
            onPressed: _uploading ? null : () => _goToFarmLocation(skipPhoto: true),
            child: const Text(
              'ข้าม',
              style: TextStyle(
                color: riceSafeGreen,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              'เพิ่มรูปโปรไฟล์ของคุณ\n(ไม่บังคับ)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Builder(
                    builder: (context) {
                      final path = _localPath;
                      if (path != null && File(path).existsSync()) {
                        return CircleAvatar(
                          radius: 72,
                          backgroundColor: riceSafeGreen.withValues(alpha: 0.15),
                          backgroundImage: FileImage(File(path)),
                          child: null,
                        );
                      }
                      return CircleAvatar(
                        radius: 72,
                        backgroundColor: riceSafeGreen.withValues(alpha: 0.15),
                        child: const Icon(Icons.person, size: 72, color: riceSafeGreen),
                      );
                    },
                  ),
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      onTap: _uploading ? null : _pickImage,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(Icons.camera_alt, color: riceSafeGreen, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _uploading ? null : _pickImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('เลือกรูป'),
              style: OutlinedButton.styleFrom(
                foregroundColor: riceSafeGreen,
                side: const BorderSide(color: riceSafeGreen),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const Spacer(),
            if (_uploading)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(color: riceSafeGreen),
              ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _uploading ? null : () => _goToFarmLocation(skipPhoto: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: riceSafeGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _uploading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'ถัดไป',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _uploading ? null : () => _goToFarmLocation(skipPhoto: true),
              child: Text(
                'ข้ามขั้นตอนนี้',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
