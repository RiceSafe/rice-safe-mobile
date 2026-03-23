import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';

/// Fullscreen in-app camera: shutter, close, flip (if available), flash (back only),
/// and a corner control to open the gallery (returns path via [Navigator.pop]).
class DiagnosisCameraCaptureScreen extends StatefulWidget {
  const DiagnosisCameraCaptureScreen({super.key});

  @override
  State<DiagnosisCameraCaptureScreen> createState() =>
      _DiagnosisCameraCaptureScreenState();
}

class _DiagnosisCameraCaptureScreenState
    extends State<DiagnosisCameraCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  bool _initializing = true;
  String? _initError;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _initializing = false;
            _initError = 'ไม่พบกล้องบนอุปกรณ์นี้';
          });
        }
        return;
      }
      await _initController(0);
    } catch (e) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _initError = userFacingMessage(
            e,
            contextFallback: 'เปิดกล้องไม่สำเร็จ',
          );
        });
      }
    }
  }

  Future<void> _initController(int index) async {
    if (_cameras.isEmpty) return;
    setState(() => _initializing = true);

    final previous = _controller;
    _controller = null;
    if (previous != null) {
      await previous.dispose();
    }

    final cam = _cameras[index];
    final c = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await c.initialize();
      if (cam.lensDirection == CameraLensDirection.back) {
        await c.setFlashMode(FlashMode.auto);
      } else {
        await c.setFlashMode(FlashMode.off);
      }
    } catch (e) {
      await c.dispose();
      if (mounted) {
        setState(() {
          _initializing = false;
          _initError = userFacingMessage(
            e,
            contextFallback: 'เปิดกล้องไม่สำเร็จ',
          );
        });
      }
      return;
    }

    if (!mounted) {
      await c.dispose();
      return;
    }

    setState(() {
      _controller = c;
      _cameraIndex = index;
      _initializing = false;
      _initError = null;
    });
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2 || _initializing) return;
    final next = (_cameraIndex + 1) % _cameras.length;
    await _initController(next);
  }

  Future<void> _cycleFlash() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _initializing) return;
    if (c.description.lensDirection != CameraLensDirection.back) return;

    final FlashMode next;
    switch (c.value.flashMode) {
      case FlashMode.off:
        next = FlashMode.auto;
        break;
      case FlashMode.auto:
        next = FlashMode.always;
        break;
      case FlashMode.always:
        next = FlashMode.torch;
        break;
      case FlashMode.torch:
        next = FlashMode.off;
        break;
    }

    try {
      await c.setFlashMode(next);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  IconData _flashIcon() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return Icons.flash_off;
    }
    switch (c.value.flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.highlight;
      case FlashMode.off:
        return Icons.flash_off;
    }
  }

  Future<void> _openGallery() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 4096,
        maxHeight: 4096,
        imageQuality: 90,
      );
      if (x != null && mounted) {
        Navigator.of(context).pop(x.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userFacingMessage(
              e,
              contextFallback: 'เลือกรูปภาพไม่สำเร็จ',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) {
      return;
    }
    try {
      final file = await c.takePicture();
      if (mounted) Navigator.of(context).pop(file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userFacingMessage(
              e,
              contextFallback: 'ถ่ายรูปไม่สำเร็จ',
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_initError != null && _controller == null) {
      return _buildFallback(_initError!);
    }

    if (_initializing && _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final size = MediaQuery.of(context).size;
    double ratio = c.value.aspectRatio;
    // Ensure the ratio matches the device orientation
    if (size.width < size.height && ratio > 1.0) {
      ratio = 1.0 / ratio;
    } else if (size.width > size.height && ratio < 1.0) {
      ratio = 1.0 / ratio;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: Colors.black,
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: size.width,
                height: size.width / ratio,
                child: CameraPreview(c),
              ),
            ),
          ),
        ),
        if (_initializing)
          const ColoredBox(
            color: Color(0x66000000),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        _topBar(c),
        _bottomBar(),
      ],
    );
  }

  Widget _buildFallback(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _openGallery,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('เลือกจากแกลเลอรี่'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _topBar(CameraController c) {
    final canFlip = _cameras.length > 1;
    final showFlash = c.description.lensDirection == CameraLensDirection.back;

    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _initializing ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            tooltip: 'ปิด',
          ),
          if (canFlip)
            IconButton(
              onPressed: _initializing ? null : _flipCamera,
              icon: const Icon(Icons.cameraswitch, color: Colors.white, size: 26),
              tooltip: 'สลับกล้อง',
            )
          else
            const SizedBox(width: 48),
          if (showFlash)
            IconButton(
              onPressed: _initializing ? null : _cycleFlash,
              icon: Icon(_flashIcon(), color: Colors.white, size: 26),
              tooltip: 'แฟลช',
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _initializing ? null : _openGallery,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                    color: Colors.black38,
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: _initializing ? null : _takePhoto,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: Colors.white24,
                ),
                child: Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 56),
          ],
        ),
      ),
    );
  }
}
