import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:ricesafe_app/core/config/app_config.dart';
import 'result_screen.dart';
import 'main.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final String _apiEndpoint = "${AppConfig.apiBaseUrl}/predict/";

  void _resetInputFields() {
    setState(() {
      _selectedImage = null;
      _descriptionController.clear();
    });
  }

  Future<void> _pickImageFromGallery() async {
    if (_isLoading) return;
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
      print("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการเลือกรูปภาพ: $e')),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _callPredictApi(
    File imageFile,
    String description,
  ) async {
    var uri = Uri.parse(_apiEndpoint);
    var request = http.MultipartRequest('POST', uri);
    request.fields['description'] = description;
    var stream = http.ByteStream(imageFile.openRead());
    stream.cast();
    var length = await imageFile.length();
    var multipartFile = http.MultipartFile(
      'image',
      stream,
      length,
      filename: imageFile.path.split('/').last,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);
    print("Sending request to: $uri");
    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 90),
      );
      final response = await http.Response.fromStream(streamedResponse);
      print("API Response Status (InputScreen): ${response.statusCode}");
      print("API Response Body (InputScreen): ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
      } else {
        String errorMessage =
            'ข้อผิดพลาดจากเซิร์ฟเวอร์: ${response.statusCode}.';
        try {
          var errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          if (errorBody is Map && errorBody.containsKey('detail')) {
            errorMessage += ' ${errorBody['detail']}';
          }
        } catch (e) {
          /* Ignore parsing error body */
        }
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
        return null;
      }
    } catch (e) {
      print('Exception during API call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ: $e')),
        );
      }
      return null;
    }
  }

  void _diagnoseDisease() async {
    String description = _descriptionController.text.trim();
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

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic>? apiResponseData = await _callPredictApi(
      _selectedImage!,
      description,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (apiResponseData != null) {
        Map<String, dynamic> diseaseDataForScreen = {
          'name': apiResponseData['prediction'] ?? 'N/A',
          'confidence': apiResponseData['confidence'] ?? 'N/A',
          'remedy': apiResponseData['remedy'] ?? 'ไม่มีข้อมูลวิธีการรักษา',
          'treatment':
              apiResponseData['treatment'] ?? 'ไม่มีข้อมูลการควบคุมดูแล',
          'userUploadedImage': _selectedImage,
          'diseaseSpecificImageUrl': apiResponseData['imageUrl'],
        };

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ResultScreen(diseaseData: diseaseDataForScreen),
          ),
        );

        if (result == 'diagnose_new') {
          _resetInputFields();
        }
      } else {
        print("Failed to get data from API or widget unmounted.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                    _isLoading ? null : _pickImageFromGallery,
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
                                    _isLoading
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
                enabled: !_isLoading,
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
                  (_isLoading || _selectedImage == null)
                      ? null
                      : _diagnoseDisease,
              child:
                  _isLoading
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

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
