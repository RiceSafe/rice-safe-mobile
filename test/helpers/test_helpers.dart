import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
// ignore: depend_on_referenced_packages — transitive via hive_flutter; direct import for tests
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ricesafe_app/features/auth/data/auth_local_storage.dart';

// Mocks
class MockGoRouter extends Mock implements GoRouter {}
class MockGoRouterDelegate extends Mock implements GoRouterDelegate {}
class MockGoRouteInformationParser extends Mock implements GoRouteInformationParser {}
class MockGoRouteInformationProvider extends Mock implements GoRouteInformationProvider {}

// Mock Map
class MockMap extends StatelessWidget {
  const MockMap({
    Key? key,
    this.options,
    this.children,
    this.mapController,
  }) : super(key: key);

  final MapOptions? options;
  final List<Widget>? children;
  final MapController? mapController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Center(child: Text('Map Placeholder')),
    );
  }
}

/// Isolated Hive storage for widget tests that hit [AuthLocalStorage].
class TestHive {
  static Directory? _dir;

  static Future<void> init() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await reset();
    _dir = await Directory.systemTemp.createTemp('ricesafe_hive_');
    Hive.init(_dir!.path);
    await Hive.openBox<String>(AuthLocalStorage.boxName);
  }

  static Future<void> reset() async {
    if (Hive.isBoxOpen(AuthLocalStorage.boxName)) {
      await Hive.box<String>(AuthLocalStorage.boxName).close();
    }
    await Hive.close();
    if (_dir != null) {
      if (await _dir!.exists()) {
        await _dir!.delete(recursive: true);
      }
      _dir = null;
    }
  }
}

// Helper to pump widgets with Riverpod and GoRouter
Future<void> pumpRouterApp(
  WidgetTester tester, {
  required Widget home,
  MockGoRouter? router,
  List<Override> overrides = const [],
}) async {
  final mockRouter = router ?? MockGoRouter();

  // Initialize dotenv for tests to avoid NotInitializedError
  dotenv.testLoad(fileInput: 'BASE_URL=http://localhost:8080/api\n');

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: MockGoRouterProvider(
          goRouter: mockRouter,
          child: home,
        ),
      ),
    ),
  );
}

/// Exposes a [ProviderContainer] with [overrides] to the widget tree via
/// [UncontrolledProviderScope] (matches how [ProviderScope] tests should wire mocks).
Future<ProviderContainer> pumpRouterWithProviderContainer(
  WidgetTester tester, {
  required Widget home,
  MockGoRouter? router,
  List<Override> overrides = const [],
}) async {
  final mockRouter = router ?? MockGoRouter();
  dotenv.testLoad(fileInput: 'BASE_URL=http://localhost:8080/api\n');
  final container = ProviderContainer(overrides: overrides);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: MockGoRouterProvider(
          goRouter: mockRouter,
          child: home,
        ),
      ),
    ),
  );
  return container;
}

// Helper widget to inject GoRouter
class MockGoRouterProvider extends StatelessWidget {
  const MockGoRouterProvider({
    required this.goRouter,
    required this.child,
    Key? key,
  }) : super(key: key);

  final GoRouter goRouter;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InheritedGoRouter(
      goRouter: goRouter,
      child: child,
    );
  }
}
