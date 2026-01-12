import 'package:go_router/go_router.dart';
import 'package:ricesafe_app/features/diagnosis/presentation/screens/diagnosis_input_screen.dart';
import 'package:ricesafe_app/features/diagnosis/presentation/screens/diagnosis_result_screen.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_result.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DiagnosisInputScreen(),
      ),
      GoRoute(
        path: '/diagnosis/result',
        builder: (context, state) {
          final result = state.extra as DiagnosisResult;
          return DiagnosisResultScreen(result: result);
        },
      ),
    ],
  );
}
