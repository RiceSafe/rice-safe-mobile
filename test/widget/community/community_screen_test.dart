import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/community/presentation/screens/community_screen.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    mockRouter = MockGoRouter();
  });

  testWidgets('CommunityScreen displays posts', (WidgetTester tester) async {
    await pumpRouterApp(tester, home: const CommunityScreen(), router: mockRouter);

    // Verify Title
    expect(find.text('ชุมชน'), findsOneWidget);

    // Verify Post button
    expect(find.text('โพสต์'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Verify Posts List
    expect(find.byType(ListView), findsOneWidget);
    
    // Check for standard post elements (Like/Comment buttons)
    // Use findsWidgets because multiple posts are displayed in the list.
    expect(find.byIcon(Icons.favorite_border), findsWidgets);
    expect(find.byIcon(Icons.chat_bubble_outline), findsWidgets);
  });

  testWidgets('CommunityScreen like button toggles', (WidgetTester tester) async {
    await pumpRouterApp(tester, home: const CommunityScreen(), router: mockRouter);

    // Find first like button
    final likeButton = find.byIcon(Icons.favorite_border).first;
    
    // Tap it
    await tester.tap(likeButton);
    await tester.pump();

    // It should now be filled (red)
    expect(find.byIcon(Icons.favorite), findsWidgets);
  });
}
