import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/diagnosis_result.dart';
import '../providers/diagnosis_provider.dart';
import '../../../../main.dart';

class DiagnosisResultScreen extends ConsumerWidget {
  final DiagnosisResult result;

  const DiagnosisResultScreen({super.key, required this.result});

  List<String> _splitStringToList(String? text) {
    if (text == null || text.trim().isEmpty) {
      return [];
    }
    return text.split('\n').where((step) => step.trim().isNotEmpty).map((step) {
      return step.trim().replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
    }).toList();
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 26, color: riceSafeDarkGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      color: riceSafeDarkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildMultiLineTextContent(BuildContext context, String text) {
    List<String> lines = _splitStringToList(text);
    if (lines.isEmpty) {
      return Text("ไม่มีข้อมูล", style: Theme.of(context).textTheme.bodyMedium);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          lines
              .map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0, top: 3.0),
                        child: Icon(
                          Icons.check_circle,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          line,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: riceSafeTextPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                const Icon(
                  Icons.biotech_outlined,
                  color: riceSafeDarkGreen,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.name,
                    style: textTheme.headlineSmall?.copyWith(
                      color: riceSafeTextPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Display Image Logic
            if (result.diseaseSpecificImageUrl != null &&
                result.diseaseSpecificImageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  result.diseaseSpecificImageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (c, e, s) => _buildUserUploadedImageOrPlaceholder(
                        result.userUploadedImage,
                      ),
                  loadingBuilder: (c, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            riceSafeGreen,
                          ),
                          value:
                              progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                        ),
                      ),
                    );
                  },
                ),
              )
            else if (result.userUploadedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.file(
                  result.userUploadedImage!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => _buildPlaceholderImage(),
                ),
              )
            else
              _buildPlaceholderImage(),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'คำแนะนำการรักษา',
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            _buildSectionCard(
              context,
              icon: Icons.science_outlined,
              title: 'วิธีการรักษา',
              content: _buildMultiLineTextContent(context, result.remedy),
            ),

            _buildSectionCard(
              context,
              icon: Icons.eco_outlined,
              title: 'การควบคุมดูแล',
              content: _buildMultiLineTextContent(context, result.treatment),
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('วินิจฉัยรายการใหม่'),
                onPressed: () {
                  ref.read(diagnosisProvider.notifier).reset();
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: riceSafeDarkGreen,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUserUploadedImageOrPlaceholder(File? userUploadedImage) {
    if (userUploadedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.file(
          userUploadedImage,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _buildPlaceholderImage(),
        ),
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 60,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
