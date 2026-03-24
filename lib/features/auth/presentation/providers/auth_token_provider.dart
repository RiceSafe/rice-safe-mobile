import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current JWT; used by Dio interceptor. Keep in sync with [AuthNotifier] state.
final authTokenProvider = StateProvider<String?>((ref) => null);
