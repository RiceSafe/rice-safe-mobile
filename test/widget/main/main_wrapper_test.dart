import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ricesafe_app/features/main/presentation/screens/main_wrapper.dart';

void main() {
  testWidgets('MainWrapper shows five navigation destinations', (tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainWrapper(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) =>
                      const Scaffold(body: Center(child: Text('HomeBody'))),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/library',
                  builder: (context, state) =>
                      const Scaffold(body: Center(child: Text('LibBody'))),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/diagnosis',
                  builder: (context, state) =>
                      const Scaffold(body: Center(child: Text('DiagBody'))),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/community',
                  builder: (context, state) =>
                      const Scaffold(body: Center(child: Text('CommBody'))),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/outbreak',
                  builder: (context, state) =>
                      const Scaffold(body: Center(child: Text('OutBody'))),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('หน้าหลัก'), findsOneWidget);
    expect(find.text('คลังความรู้'), findsOneWidget);
    expect(find.text('ชุมชน'), findsOneWidget);
    expect(find.text('แผนที่ระบาด'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('HomeBody'), findsOneWidget);

    await tester.tap(find.text('คลังความรู้'));
    await tester.pumpAndSettle();
    expect(find.text('LibBody'), findsOneWidget);
  });
}
