import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/features/library/data/disease_repository.dart';
import 'package:ricesafe_app/features/library/data/models/library_disease.dart';
import 'package:ricesafe_app/features/library/presentation/providers/disease_library_provider.dart';
import 'package:ricesafe_app/features/library/presentation/screens/library_detail_screen.dart';

class _FakeDetailRepository extends DiseaseRepository {
  _FakeDetailRepository(this._disease) : super(Dio(BaseOptions()));

  final LibraryDisease _disease;

  @override
  Future<List<String>> getCategories() async => [];

  @override
  Future<List<LibraryDisease>> listDiseases({String? category}) async => [];

  @override
  Future<LibraryDisease> getById(String id) async {
    if (id == 'test-1') return _disease;
    throw Exception('not found');
  }
}

void main() {
  testWidgets('LibraryDetailScreen displays disease info and tabs',
      (WidgetTester tester) async {
    final disease = LibraryDisease(
      id: 'test-1',
      alias: 'test',
      name: 'Test Disease',
      category: 'เชื้อรา',
      description: 'Test Description',
      symptoms: const [
        LibraryInfoSection(title: 'Symptom 1', description: 'Desc 1'),
      ],
      prevention: const [
        LibraryInfoSection(title: 'Prevent 1', description: 'Desc 2'),
      ],
      treatment: const [
        LibraryInfoSection(title: 'Treat 1', description: 'Desc 3'),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          diseaseRepositoryProvider.overrideWith(
            (ref) => _FakeDetailRepository(disease),
          ),
        ],
        child: const MaterialApp(
          home: LibraryDetailScreen(diseaseId: 'test-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Disease'), findsOneWidget);
    expect(find.text('ข้อมูลทั่วไป'), findsOneWidget);
    expect(find.text('อาการ'), findsOneWidget);
    expect(find.text('การป้องกัน'), findsOneWidget);
    expect(find.text('การรักษา'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
  });
}
