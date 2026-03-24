import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ricesafe_app/features/auth/onboarding/register_onboarding_state.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/main.dart';

/// Leading-style profile shortcut on main tabs: opens `/settings` and shows
/// server `avatar_url`, then local onboarding file, then placeholder.
class AppBarProfileButton extends ConsumerWidget {
  const AppBarProfileButton({
    super.key,
    this.radius = 18,
    this.rightPadding = 16,
  });

  final double radius;
  final double rightPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authStateProvider).user;
    final avatarUrl = authUser?.avatarUrl;
    final avatarPath = RegisterOnboardingState.avatarFilePath;
    File? avatarFile;
    if (avatarPath != null &&
        avatarPath.isNotEmpty &&
        File(avatarPath).existsSync()) {
      avatarFile = File(avatarPath);
    }

    final size = radius * 2;

    Widget fallbackAvatar() {
      final file = avatarFile;
      if (file != null) {
        return ClipOval(
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      }
      return Icon(
        Icons.person,
        color: Colors.white,
        size: radius * 1.15,
      );
    }

    Widget avatarChild() {
      final url = avatarUrl;
      if (url != null && url.isNotEmpty) {
        return ClipOval(
          child: Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallbackAvatar(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: size,
                height: size,
                child: const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
      return fallbackAvatar();
    }

    return Padding(
      padding: EdgeInsets.only(right: rightPadding),
      child: InkWell(
        onTap: () => context.push('/settings'),
        borderRadius: BorderRadius.circular(20),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: riceSafeGreen,
          child: avatarChild(),
        ),
      ),
    );
  }
}
