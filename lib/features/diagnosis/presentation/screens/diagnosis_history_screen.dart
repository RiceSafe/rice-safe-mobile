import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ricesafe_app/features/diagnosis/data/models/diagnosis_history_dto.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_backend_parser.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_result.dart';
import 'package:ricesafe_app/features/diagnosis/presentation/providers/diagnosis_provider.dart';
import 'package:ricesafe_app/main.dart';

/// Diagnosis history list (`GET /diagnosis/history`).
class DiagnosisHistoryScreen extends ConsumerWidget {
  const DiagnosisHistoryScreen({super.key});

  String _title(DiagnosisHistoryDto h) {
    return DiagnosisBackendParser.displayTitleForHistory(
      prediction: h.prediction,
      diseaseName: h.diseaseName,
    );
  }

  String _subtitle(DiagnosisHistoryDto h) {
    final dt = h.createdAt;
    if (dt == null) return '${h.confidence.toStringAsFixed(1)}%';
    return '${DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal())} · ${h.confidence.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(diagnosisHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการวินิจฉัย'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userFacingMessage(
                    e,
                    contextFallback: 'โหลดประวัติไม่สำเร็จ',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(diagnosisHistoryProvider),
                  style: FilledButton.styleFrom(backgroundColor: riceSafeGreen),
                  child: const Text('ลองอีกครั้ง'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return RefreshIndicator(
              color: riceSafeGreen,
              onRefresh: () async {
                ref.invalidate(diagnosisHistoryProvider);
                await ref.read(diagnosisHistoryProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('ยังไม่มีประวัติการวินิจฉัย')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: riceSafeGreen,
            onRefresh: () async {
              ref.invalidate(diagnosisHistoryProvider);
              await ref.read(diagnosisHistoryProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final h = items[i];
                return ListTile(
                  onTap: () => context.push(
                    '/diagnosis/result',
                    extra: DiagnosisResult.fromHistory(h),
                  ),
                  leading: h.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            h.imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              size: 40,
                            ),
                          ),
                        )
                      : const Icon(Icons.biotech_outlined, size: 40),
                  title: Text(_title(h)),
                  subtitle: Text(_subtitle(h)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
