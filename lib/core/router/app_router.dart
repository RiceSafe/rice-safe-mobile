import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/diagnosis/presentation/screens/diagnosis_input_screen.dart';
import '../../features/diagnosis/presentation/screens/diagnosis_result_screen.dart';
import '../../features/diagnosis/models/diagnosis_result.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/community/presentation/screens/community_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/outbreak/presentation/screens/outbreak_screen.dart';
import '../../features/main/presentation/screens/main_wrapper.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      // Auth Routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ShellRoute pattern for Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 2: Library
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          // Tab 3: Diagnosis
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/diagnosis',
                builder: (context, state) => const DiagnosisInputScreen(),
                routes: [
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
          // Tab 4: Community
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/community',
                builder: (context, state) => const CommunityScreen(),
              ),
            ],
          ),
          // Tab 5: Outbreak Alert
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

      // Settings
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
