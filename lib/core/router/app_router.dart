import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:ricesafe_app/core/router/auth_router_notifier.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_token_provider.dart';

import '../../features/diagnosis/presentation/screens/diagnosis_input_screen.dart';
import '../../features/diagnosis/presentation/screens/diagnosis_history_screen.dart';
import '../../features/diagnosis/presentation/screens/diagnosis_result_screen.dart';
import '../../features/diagnosis/models/diagnosis_result.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/community/presentation/screens/community_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/edit_profile_screen.dart';
import '../../features/settings/presentation/screens/farm_location_settings_screen.dart';
import '../../features/community/presentation/screens/create_post_screen.dart';
import '../../features/community/presentation/screens/post_detail_comments_screen.dart';
import '../../features/outbreak/presentation/screens/outbreak_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/main/presentation/screens/main_wrapper.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/onboarding_farm_location_screen.dart';
import '../../features/auth/presentation/screens/onboarding_profile_photo_screen.dart';
import '../../features/settings/presentation/screens/map_picker_screen.dart';
import '../../features/settings/presentation/screens/contact_support_screen.dart';
import '../../features/settings/presentation/screens/about_ricesafe_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';

/// Root navigator for push overlays / SnackBars outside shell branches.
final rootNavigatorKey = GlobalKey<NavigatorState>();

bool _isPublicAuthRoute(String location) {
  return location == '/login' ||
      location == '/forgot-password' ||
      location == '/reset-password' ||
      location.startsWith('/register');
}

bool _hasToken(BuildContext context) {
  final container = ProviderScope.containerOf(context);
  final token = container.read(authTokenProvider);
  return token != null && token.isNotEmpty;
}

/// Router with auth redirect; [refreshListenable] re-evaluates redirect on login/logout.
final goRouterProvider = Provider<GoRouter>((ref) {
  final authRefresh = ref.read(authRouterNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final loggedIn = _hasToken(context);
      final loc = state.matchedLocation;

      if (!loggedIn) {
        if (_isPublicAuthRoute(loc)) return null;
        return '/login';
      }

      if (loc == '/login' ||
          loc == '/forgot-password' ||
          loc == '/reset-password') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
        routes: [
          GoRoute(
            path: 'profile-photo',
            builder: (context, state) => const OnboardingProfilePhotoScreen(),
          ),
          GoRoute(
            path: 'farm-location',
            builder: (context, state) => const OnboardingFarmLocationScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/map-picker',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final initialLocation = state.extra as LatLng?;
          return MapPickerScreen(initialLocation: initialLocation);
        },
      ),

      GoRoute(
        path: '/onboarding/farm-location',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingFarmLocationScreen(
          commitRegisterProfile: false,
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/diagnosis',
                builder: (context, state) => const DiagnosisInputScreen(),
                routes: [
                  GoRoute(
                    path: 'history',
                    builder: (context, state) => const DiagnosisHistoryScreen(),
                  ),
                  GoRoute(
                    path: 'result',
                    builder: (context, state) {
                      final result = state.extra as DiagnosisResult;
                      return DiagnosisResultScreen(result: result);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/community',
                builder: (context, state) => const CommunityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/outbreak',
                builder: (context, state) => const OutbreakScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'edit-profile',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'farm-location',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const FarmLocationSettingsScreen(),
          ),
          GoRoute(
            path: 'contact',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const ContactSupportScreen(),
          ),
          GoRoute(
            path: 'about',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const AboutRiceSafeScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/community/create-post',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/community/post/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PostDetailCommentsScreen(postId: id);
        },
      ),
    ],
  );
});
