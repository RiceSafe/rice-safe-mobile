import 'dart:io';
import 'package:flutter/material.dart';
import 'main.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> diseaseData;

  const ResultScreen({super.key, required this.diseaseData});

  // Helper to split a string by newline and filter out empty lines
  List<String> _splitStringToList(String? text) {
    if (text == null || text.trim().isEmpty) {
      return [];
    }
    return text.split('\n').where((step) => step.trim().isNotEmpty).map((step) {
      // Remove leading numbers like "1. ", "2. " etc.
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

  // This widget is now simplified as we directly use the string for "วิธีการรักษา" and "การควบคุมดูแล".
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
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, top: 3.0),
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
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final String diseaseName = diseaseData['name'] ?? 'ไม่พบชื่อโรค';

    final File? userUploadedImage = diseaseData['userUploadedImage'] as File?;
    final String? diseaseSpecificImageUrl =
        diseaseData['diseaseSpecificImageUrl'] as String?;

    final String remedy = diseaseData['remedy'] ?? 'ไม่มีข้อมูล';

    final String treatment = diseaseData['treatment'] ?? 'ไม่มีข้อมูล';

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Image.asset(
            'assets/rice_icon.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.eco_rounded,
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
                    diseaseName,
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

            // Display Image: Prioritize API's specific disease image, fallback to user's uploaded image
            if (diseaseSpecificImageUrl != null &&
                diseaseSpecificImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  diseaseSpecificImageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (c, e, s) => _buildUserUploadedImageOrPlaceholder(
                        userUploadedImage,
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
            else if (userUploadedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.file(
                  userUploadedImage,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => _buildPlaceholderImage(),
                ),
              )
            else
              _buildPlaceholderImage(),

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: Icon(
                  Icons.share_outlined,
                  color: riceSafeGreen.withOpacity(0.8),
                ),
                label: Text(
                  'Share',
                  style: textTheme.bodyMedium?.copyWith(
                    color: riceSafeGreen.withOpacity(0.8),
                  ),
                ),
                onPressed: () {},
              ),
            ),
            const Divider(height: 20),

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
              content: _buildMultiLineTextContent(context, remedy),
            ),

            _buildSectionCard(
              context,
              icon: Icons.eco_outlined,
              title: 'การควบคุมดูแล',
              content: _buildMultiLineTextContent(context, treatment),
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('วินิจฉัยรายการใหม่'),
                onPressed: () {
                  Navigator.of(context).pop('diagnose_new');
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

  // Helper for fallback image display logic
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
