import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';

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

// Helper to pump widgets with Riverpod and GoRouter
Future<void> pumpRouterApp(
  WidgetTester tester, {
  required Widget home,
  MockGoRouter? router,
}) async {
  final mockRouter = router ?? MockGoRouter();
  
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: MockGoRouterProvider(
          goRouter: mockRouter,
          child: home,
        ),
      ),
    ),
  );
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
