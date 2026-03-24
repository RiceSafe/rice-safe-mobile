import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/auth/data/repositories/auth_repository.dart';
import 'package:ricesafe_app/features/auth/domain/models/user_model.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import '../helpers/test_helpers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestHive.init();
    mockRepo = MockAuthRepository();
    when(
      () => mockRepo.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => AuthResponse(
        user: UserModel(
          id: 'id',
          username: 'u',
          email: 'u@u.com',
          role: 'FARMER',
        ),
        token: 'tok',
      ),
    );
    when(
      () => mockRepo.register(
        username: any(named: 'username'),
        email: any(named: 'email'),
        password: any(named: 'password'),
        role: any(named: 'role'),
      ),
    ).thenAnswer(
      (_) async => AuthResponse(
        user: UserModel(
          id: 'id2',
          username: 'r',
          email: 'r@r.com',
          role: 'FARMER',
        ),
        token: 'tok2',
      ),
    );
  });

  tearDown(() async {
    await TestHive.reset();
  });

  test('AuthNotifier.loginWithEmailPassword uses overridden AuthRepository', () async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWith((ref) => mockRepo),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(authStateProvider.notifier)
        .loginWithEmailPassword('a@b.com', 'secret');

    verify(() => mockRepo.login(email: 'a@b.com', password: 'secret')).called(1);
    expect(container.read(authStateProvider).token, 'tok');
  });
}
