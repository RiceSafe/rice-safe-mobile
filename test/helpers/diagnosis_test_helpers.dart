import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/diagnosis/presentation/providers/diagnosis_provider.dart';

class MockDiagnosisNotifier extends StateNotifier<DiagnosisState> with Mock implements DiagnosisNotifier {
  MockDiagnosisNotifier() : super(DiagnosisInitial());
}
