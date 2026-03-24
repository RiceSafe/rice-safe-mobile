import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifies [GoRouter] to re-run redirect when auth session changes.
class AuthRouterNotifier extends ChangeNotifier {
  void notifyAuthChanged() => notifyListeners();
}

final authRouterNotifierProvider =
    ChangeNotifierProvider<AuthRouterNotifier>((ref) => AuthRouterNotifier());
