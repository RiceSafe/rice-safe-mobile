import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../providers/diagnosis_provider.dart';
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
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการเลือกรูปภาพ: $e')),
        );
      }
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
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                GoRouter.of(context).push('/settings');
              },
              borderRadius: BorderRadius.circular(20),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: riceSafeGreen,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
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
                                'ถ่ายรูปหรือนำรูปภาพมาจากแกลลอรี่',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed:
                                    isLoading ? null : _pickImageFromGallery,
                                child: const Text('เลือกรูปภาพ'),
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
              child: TextField(
                controller: _descriptionController,
                maxLines: 4,
                minLines: 3,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  hintText: 'อธิบายลักษณะหรืออาการโรคที่พบเห็น',
                ),
                style: textTheme.bodyLarge?.copyWith(
                  color: riceSafeTextPrimary,
                ),
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

  Widget _buildSectionContainer({
    required String title,
    required Widget child,
    required TextStyle titleStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildHistorySection(TextTheme textTheme) {
    // Mock Data for History
    final historyItems = [
      {
        'name': 'โรคไหม้ (Rice Blast Disease)',
        'date': '12 ม.ค. 2024',
        'confidence': '95%',
        'image': 'assets/mock/rice_blast.jpg',
      },
      {
        'name': 'โรคใบจุดสีน้ำตาล (Brown Spot Disease)',
        'date': '10 ม.ค. 2024',
        'confidence': '88%',
        'image': 'assets/mock/brown_spot.jpg',
      },
      {
        'name': 'โรคขอบใบแห้ง (Bacterial Leaf Blight Disease)',
        'date': '05 ม.ค. 2024',
        'confidence': '92%',
        'image': 'assets/mock/leaf_blight.jpg',
      },
    ];

    return _buildSectionContainer(
      title: 'การวิเคราะห์โรคล่าสุด',
      titleStyle: textTheme.titleMedium!,
      child: Column(
        children:
            historyItems.map((item) {
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
                    child: Image.asset(
                      item['image']!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    item['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ความแม่นยำ: ${item["confidence"]}'),
                        Text(
                          'วันที่: ${item["date"]}',
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
                    // Navigate to detail
                  },
                ),
              );
            }).toList(),
      ),
    );
  }
}
