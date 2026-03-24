import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_token_provider.dart';
import 'package:ricesafe_app/main.dart';

import '../helpers/test_helpers.dart';

/// Full-app smoke: boots [RiceSafeApp] with no token (same intent as the old
/// `integration_test/` harness, but lives under [test/integration] and uses
/// [TestHive] so `flutter test` does not need `path_provider` plugins.
void main() {
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'BASE_URL=http://localhost:8080/api\n');
    await TestHive.init();
  });

  tearDownAll(() async {
    await TestHive.reset();
  });

  testWidgets('RiceSafeApp shows login when token is null', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authTokenProvider.overrideWith((ref) => null),
        ],
        child: const RiceSafeApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('RiceSafe'), findsWidgets);
  });
}
