import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:ricesafe_app/features/settings/presentation/screens/map_picker_screen.dart';

void main() {
  testWidgets('confirm returns initial pinned location', (tester) async {
    const initial = LatLng(14.02, 100.51);
    LatLng? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<LatLng>(
                  MaterialPageRoute(
                    builder: (_) => const MapPickerScreen(
                      initialLocation: initial,
                    ),
                  ),
                );
              },
              child: const Text('OpenPicker'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('OpenPicker'));
    await tester.pump();
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }

    await tester.tap(find.text('ยืนยัน'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    final r = result!;
    expect(r.latitude, initial.latitude);
    expect(r.longitude, initial.longitude);
  });
}
