import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/diagnosis_backend_parser.dart';
import '../../models/diagnosis_result.dart';
import '../providers/diagnosis_provider.dart';
import '../../../library/data/models/library_disease.dart';
import '../../../library/presentation/providers/disease_library_provider.dart';
import '../../../../main.dart';

class DiagnosisResultScreen extends ConsumerWidget {
  /// Lines longer than this are always treated as body (indented, no icon).
  /// Short lines after a long line start a new heading (check icon).
  static const int _headingLineMaxChars = 72;

  /// check_circle (20) + gap — body lines align like library detail description.
  static const double _bodyIndentUnderHeading = 20.0 + 8.0;

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

  bool _isHeadingLine(int index, String line, List<String> lines) {
    final int len = line.length;
    if (len > _headingLineMaxChars) return false;
    if (index == 0) return true;
    return lines[index - 1].length > _headingLineMaxChars;
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

  Widget _buildMultiLineLineRow(
    TextTheme textTheme,
    int index,
    List<String> lines,
  ) {
    final bool heading = _isHeadingLine(index, lines[index], lines);
    if (!heading) {
      return Padding(
        padding: const EdgeInsets.only(left: _bodyIndentUnderHeading),
        child: Text(
          lines[index],
          style: textTheme.bodyLarge?.copyWith(
            color: riceSafeTextPrimary,
            height: 1.5,
          ),
        ),
      );
    }
    return Row(
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
            lines[index],
            style: textTheme.bodyLarge?.copyWith(
              color: riceSafeTextPrimary,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiLineTextContent(BuildContext context, String text) {
    final List<String> lines = _splitStringToList(text);
    if (lines.isEmpty) {
      return Text("ไม่มีข้อมูล", style: Theme.of(context).textTheme.bodyMedium);
    }
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lines.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: _buildMultiLineLineRow(textTheme, i, lines),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final initial = result;
    final fetchCare = DiagnosisBackendParser.shouldFetchCareFromLibrary(
      initial.careLookupAlias,
    );
    final AsyncValue<List<LibraryDisease>> diseasesAsync = fetchCare
        ? ref.watch(diseaseListProvider(''))
        : AsyncValue<List<LibraryDisease>>.data(<LibraryDisease>[]);
    final DiagnosisResult display = fetchCare
        ? diseasesAsync.when(
            data: (list) => DiagnosisBackendParser.applyLibraryCareIfMatched(
              initial,
              list,
            ),
            loading: () => initial,
            error: (_, _) => initial,
          )
        : initial;
    final careLoading =
        fetchCare && diseasesAsync.isLoading;
    final compact = DiagnosisBackendParser.isNonDiseasePredictionAlias(
      display.careLookupAlias,
    );
    final compactInfoTrimmed = display.apiInfoMessage?.trim() ?? '';
    final showCompactApiInfo = compact && compactInfoTrimmed.isNotEmpty;

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
                    display.name,
                    style: textTheme.headlineSmall?.copyWith(
                      color: riceSafeTextPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            if (display.confidence.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'ความมั่นใจ: ${display.confidence}',
                style: textTheme.bodyMedium?.copyWith(
                  color: riceSafeTextPrimary.withValues(alpha: 0.85),
                ),
              ),
            ],
            if (display.diagnosedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                DateFormat('dd/MM/yyyy HH:mm')
                    .format(display.diagnosedAt!.toLocal()),
                style: textTheme.bodySmall?.copyWith(
                  color: riceSafeTextPrimary.withValues(alpha: 0.6),
                ),
              ),
            ],
            if (careLoading) ...[
              const SizedBox(height: 10),
              const LinearProgressIndicator(minHeight: 3),
            ],
            const SizedBox(height: 16),

            // Display Image Logic: user's photo first (file or API image_url), not disease reference.
            if (display.userUploadedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.file(
                  display.userUploadedImage!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => _buildPlaceholderImage(),
                ),
              )
            else if (display.diseaseSpecificImageUrl != null &&
                display.diseaseSpecificImageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  display.diseaseSpecificImageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (c, e, s) => _buildUserUploadedImageOrPlaceholder(
                        display.userUploadedImage,
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
            else
              _buildPlaceholderImage(),

            if (!compact) ...[
              const SizedBox(height: 24),
              if (!(fetchCare && careLoading)) ...[
                if (display.symptoms.trim().isNotEmpty) ...[
                  _buildSectionCard(
                    context,
                    icon: Icons.healing_outlined,
                    title: 'อาการที่พบ',
                    content:
                        _buildMultiLineTextContent(context, display.symptoms),
                  ),
                  const SizedBox(height: 16),
                ],

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
                  content: _buildMultiLineTextContent(context, display.remedy),
                ),

                _buildSectionCard(
                  context,
                  icon: Icons.eco_outlined,
                  title: 'การควบคุมดูแล',
                  content:
                      _buildMultiLineTextContent(context, display.treatment),
                ),

                const SizedBox(height: 30),
              ],
            ],
            if (compact) const SizedBox(height: 24),

            if (showCompactApiInfo) ...[
              _buildCompactApiInfoCard(context, compactInfoTrimmed),
              const SizedBox(height: 16),
            ],

            _newDiagnosisButton(context, ref),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactApiInfoCard(BuildContext context, String message) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 24,
                  color: riceSafeDarkGreen,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'คำแนะจากระบบ',
                    style: textTheme.titleMedium?.copyWith(
                      color: riceSafeDarkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              message,
              style: textTheme.bodyLarge?.copyWith(
                color: riceSafeTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newDiagnosisButton(BuildContext context, WidgetRef ref) {
    return Center(
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
