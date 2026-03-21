import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/auth_repository.dart';

final dioClientProvider = Provider((ref) => DioClient());

final authRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return AuthRepository(dio);
});
