import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';
import 'package:ricesafe_app/core/widgets/app_bar_profile_button.dart';
import 'package:ricesafe_app/features/diagnosis/data/models/diagnosis_history_dto.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_backend_parser.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/diagnosis_provider.dart';
import 'diagnosis_camera_capture_screen.dart';
import '../../../../main.dart';

class DiagnosisInputScreen extends ConsumerStatefulWidget {
  const DiagnosisInputScreen({super.key});

  @override
  ConsumerState<DiagnosisInputScreen> createState() =>
      _DiagnosisInputScreenState();
}

class _DiagnosisInputScreenState extends ConsumerState<DiagnosisInputScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;

  // Speech to Text
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  void _speechLog(String label, Object? msg) {
    if (kDebugMode) debugPrint('[speech] $label: $msg');
  }

  void _initSpeech() async {
    await _speech.initialize(
      onError: (e) => _speechLog('error', e),
      onStatus: (s) => _speechLog('status', s),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _resetInputFields() {
    setState(() {
      _selectedImage = null;
      _descriptionController.clear();
    });
    ref.read(diagnosisProvider.notifier).reset();
  }

  Future<void> _openCameraCapture() async {
    final path = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (context) => const DiagnosisCameraCaptureScreen(),
        fullscreenDialog: true,
      ),
    );
    if (path != null && path.isNotEmpty && mounted) {
      setState(() => _selectedImage = File(path));
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (s) => _speechLog('status', s),
        onError: (e) => _speechLog('error', e),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult:
              (val) => setState(() {
                _descriptionController.text = val.recognizedWords;
              }),
          localeId: 'th_TH',
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _diagnoseDisease() {
    final String description = _descriptionController.text.trim();
    if (_selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกรูปภาพ')));
      return;
    }
    if (description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาใส่คำอธิบายอาการ')));
      return;
    }

    ref
        .read(diagnosisProvider.notifier)
        .diagnoseDisease(image: _selectedImage!, description: description);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    ref.listen<DiagnosisState>(diagnosisProvider, (previous, next) {
      if (next is DiagnosisSuccess) {
        context.push('/diagnosis/result', extra: next.result).then((_) {
          _resetInputFields();
        });
      } else if (next is DiagnosisError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    final state = ref.watch(diagnosisProvider);
    final bool isLoading = state is DiagnosisLoading;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Image.asset(
            'assets/rice_icon.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.image,
                color: riceSafeDarkGreen,
                size: 28,
              );
            },
          ),
        ),
        title: const Text('RiceSafe'),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'ประวัติการวินิจฉัย',
            onPressed: () => context.push('/diagnosis/history'),
          ),
          const AppBarProfileButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSectionContainer(
              title: 'อัปโหลดรูปภาพ',
              titleStyle: textTheme.titleMedium!,
              child: DottedBorder(
                color: Colors.grey[400]!,
                strokeWidth: 1.5,
                dashPattern: const [6, 5],
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                padding: EdgeInsets.zero,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 180),
                  padding: const EdgeInsets.symmetric(
                    vertical: 25.0,
                    horizontal: 20.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11.5),
                  ),
                  child:
                      _selectedImage == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Icon(
                                Icons.camera_alt_outlined,
                                size: 44,
                                color: Colors.black54,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'แตะด้านล่างเพื่อเปิดกล้อง — เลือกจากแกลเลอรี่ได้ที่มุมล่างในหน้ากล้อง',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed:
                                      isLoading ? null : _openCameraCapture,
                                  icon: const Icon(Icons.photo_camera_outlined),
                                  label: const Text('เลือกรูปภาพ'),
                                ),
                              ),
                            ],
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(
                                  _selectedImage!,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () {
                                          setState(() {
                                            _selectedImage = null;
                                          });
                                        },
                                child: Text(
                                  'ลบรูปภาพ',
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionContainer(
              title: 'อธิบายลักษณะหรืออาการโรค',
              titleStyle: textTheme.titleMedium!,
              trailing: IconButton(
                onPressed: _listen,
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.red : riceSafeGreen,
                ),
                tooltip: 'พูดเพื่อพิมพ์',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDescriptionGuidanceBullets(textTheme),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    minLines: 3,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      hintText:
                          'อธิบายลักษณะหรืออาการโรคที่พบเห็น (กดไมค์เพื่อพูด)',
                    ),
                    style: textTheme.bodyLarge?.copyWith(
                      color: riceSafeTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed:
                  (isLoading || _selectedImage == null)
                      ? null
                      : _diagnoseDisease,
              child:
                  isLoading
                      ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                      : const Text('วินิจฉัยโรค'),
            ),
            const SizedBox(height: 20),
            _buildHistorySection(textTheme),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionGuidanceBullets(TextTheme textTheme) {
    final TextStyle? lineStyle = textTheme.bodySmall?.copyWith(
      color: Colors.black54,
      height: 1.35,
      fontSize: 13,
    );
    const List<String> lines = <String>[
      'ระยะข้าว (ถ้ารู้) เช่น กล้า / แตกกอ',
      'ตำแหน่งบนใบ เช่น ปลายใบ / ขอบใบ / กลางใบ',
      'ลักษณะแผล เช่น เป็นจุด / เป็นเส้นยาว',
      'สี เช่น เหลือง / น้ำตาล',
      'การกระจายแผล เช่น เป็นจุดๆ / ทั่วแผ่นใบ',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lines.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i < lines.length - 1 ? 4 : 0),
            child: Text('• ${lines[i]}', style: lineStyle),
          ),
      ],
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required Widget child,
    required TextStyle titleStyle,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: titleStyle),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  String _historyRowTitle(DiagnosisHistoryDto h) {
    return DiagnosisBackendParser.displayTitleForHistory(
      prediction: h.prediction,
      diseaseName: h.diseaseName,
    );
  }

  String _historyRowDateLabel(DiagnosisHistoryDto h) {
    final dt = h.createdAt;
    if (dt == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
  }

  Widget _buildHistorySection(TextTheme textTheme) {
    final async = ref.watch(diagnosisHistoryProvider);

    return async.when(
      loading: () => _buildSectionContainer(
        title: 'การวิเคราะห์โรคล่าสุด',
        titleStyle: textTheme.titleMedium!,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error:
          (e, _) => _buildSectionContainer(
            title: 'การวิเคราะห์โรคล่าสุด',
            titleStyle: textTheme.titleMedium!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  userFacingMessage(
                    e,
                    contextFallback: 'โหลดประวัติไม่สำเร็จ',
                  ),
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(diagnosisHistoryProvider),
                  style: FilledButton.styleFrom(backgroundColor: riceSafeGreen),
                  child: const Text('ลองอีกครั้ง'),
                ),
              ],
            ),
          ),
      data: (items) {
        final latest = items.take(3).toList();
        if (latest.isEmpty) {
          return _buildSectionContainer(
            title: 'การวิเคราะห์โรคล่าสุด',
            titleStyle: textTheme.titleMedium!,
            child: Text(
              'ยังไม่มีประวัติการวินิจฉัย',
              style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          );
        }
        return _buildSectionContainer(
          title: 'การวิเคราะห์โรคล่าสุด',
          titleStyle: textTheme.titleMedium!,
          child: Column(
            children:
                latest.map((h) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            h.imageUrl.isNotEmpty
                                ? Image.network(
                                  h.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                                : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.biotech_outlined,
                                    color: Colors.grey,
                                  ),
                                ),
                      ),
                      title: Text(
                        _historyRowTitle(h),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ความแม่นยำ: ${h.confidence.toStringAsFixed(1)}%',
                            ),
                            Text(
                              'วันที่: ${_historyRowDateLabel(h)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push(
                          '/diagnosis/result',
                          extra: DiagnosisResult.fromHistory(h),
                        );
                      },
                    ),
                  );
                }).toList(),
          ),
        );
      },
    );
  }
}
