import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ricesafe_app/features/home/presentation/screens/home_screen.dart';

// Mock map to avoid network calls and complex rendering
class MockMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

void main() {
  testWidgets('HomeScreen displays greeting and sections', (WidgetTester tester) async {
    // Build the HomeScreen directly wrapped in MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeScreen(),
      ),
    );

    // Verify Greeting
    expect(find.text('สวัสดี, ใบข้าว'), findsOneWidget);
    expect(find.text('ตรวจสอบสุขภาพข้าวของคุณวันนี้'), findsOneWidget);

    // Verify Weather Section
    expect(find.text('สภาพอากาศวันนี้'), findsOneWidget);
    expect(find.text('สุพรรณบุรี'), findsOneWidget);
    expect(find.text('32°C'), findsOneWidget);

    // Verify Outbreak Map Section
    expect(find.text('สถานการณ์การระบาด'), findsOneWidget);
    
    // Verify Map Widget Presence
    expect(find.byType(FlutterMap), findsOneWidget);

    // Verify Daily Disease Knowledge
    expect(find.text('โรคข้าวน่ารู้ประจำวัน'), findsOneWidget);
    expect(find.text('โรคไหม้\n(Rice Blast Disease)'), findsOneWidget);
  });
}
