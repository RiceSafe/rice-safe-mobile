import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ricesafe_app/features/auth/onboarding/register_onboarding_state.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authStateProvider).user;
    final displayName =
        authUser?.username ?? RegisterOnboardingState.displayUsername;
    final avatarPath = RegisterOnboardingState.avatarFilePath;
    File? avatarFile;
    if (avatarPath != null &&
        avatarPath.isNotEmpty &&
        File(avatarPath).existsSync()) {
      avatarFile = File(avatarPath);
    }

    final avatarUrl = authUser?.avatarUrl;

    Widget profileAvatar() {
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        return CircleAvatar(
          radius: 60,
          backgroundColor: riceSafeGreen,
          child: ClipOval(
            child: Image.network(
              avatarUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                final local = avatarFile;
                if (local != null) {
                  return Image.file(
                    local,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  );
                }
                return const Icon(Icons.person, size: 60, color: Colors.white);
              },
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
      final localFile = avatarFile;
      if (localFile != null) {
        return CircleAvatar(
          radius: 60,
          backgroundColor: riceSafeGreen,
          backgroundImage: FileImage(localFile),
        );
      }
      return const CircleAvatar(
        radius: 60,
        backgroundColor: riceSafeGreen,
        child: Icon(Icons.person, size: 60, color: Colors.white),
      );
    }

    String roleLabel() {
      switch (authUser?.role) {
        case 'EXPERT':
          return 'ผู้เชี่ยวชาญ';
        case 'ADMIN':
          return 'ผู้ดูแลระบบ';
        default:
          return 'ชาวนา (Rice Farmer)';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์และการตั้งค่า'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Profile Header (เปลี่ยนรูปที่ ข้อมูลส่วนตัว)
            Center(child: profileAvatar()),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              roleLabel(),
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Settings List
            _buildSectionHeader('บัญชีของฉัน'),
            _buildSettingItem(
              icon: Icons.person_outline,
              title: 'ข้อมูลส่วนตัว',
              onTap: () {
                GoRouter.of(context).push('/settings/edit-profile');
              },
            ),
            _buildSettingItem(
              icon: Icons.location_on_outlined,
              title: 'ตั้งค่าตำแหน่งและการแจ้งเตือนการระบาด',
              onTap: () {
                GoRouter.of(context).push('/settings/farm-location');
              },
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('ช่วยเหลือ'),
            _buildSettingItem(
              icon: Icons.headset_mic_outlined,
              title: 'ติดต่อเรา',
              onTap: () {
                GoRouter.of(context).push('/settings/contact');
              },
            ),
            _buildSettingItem(
              icon: Icons.info_outline,
              title: 'เกี่ยวกับ RiceSafe',
              onTap: () {
                GoRouter.of(context).push('/settings/about');
              },
            ),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    GoRouter.of(context).go('/login');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ออกจากระบบสำเร็จ')),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('ออกจากระบบ'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
