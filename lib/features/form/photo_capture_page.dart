import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:image/image.dart' as img;

class PhotoCapturePage extends StatefulWidget {
  final String? formId;

  const PhotoCapturePage({
    super.key,
    this.formId,
  });

  @override
  State<PhotoCapturePage> createState() => _PhotoCapturePageState();
}

class _PhotoCapturePageState extends State<PhotoCapturePage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  String? _errorMessage;
  File? _capturedImage;
  bool _hasShownGuidelines = false; // Track if modal was shown

  // Photo size requirements (from backend in future)
  static const int _photoWidthMM = 35; // Width in millimeters
  static const int _photoHeightMM = 45; // Height in millimeters
  static const double _photoAspectRatio = 35 / 45; // ~0.778

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      // Find back camera only
      final backCamera = _cameras?.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      if (backCamera == null) {
        setState(() {
          _errorMessage = 'No camera found on this device';
          _isInitializing = false;
        });
        return;
      }

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });

        // Show guidelines modal after camera is ready
        if (!_hasShownGuidelines) {
          _hasShownGuidelines = true;
          // Small delay to let the UI settle
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _showGuidelinesModal();
            }
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: ${e.toString()}';
        _isInitializing = false;
      });
    }
  }

  void _showGuidelinesModal() {
    final theme = ShadTheme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false, // User must click OK
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              CupertinoIcons.info_circle,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Photo Guidelines',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please follow these guidelines for a perfect ID photo:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _buildModalInstructionItem(
                'Center your face within the circle outline',
                CupertinoIcons.scope,
              ),
              const SizedBox(height: 12),
              _buildModalInstructionItem(
                'Keep good lighting in front of you',
                CupertinoIcons.light_max,
              ),
              const SizedBox(height: 12),
              _buildModalInstructionItem(
                'Use a plain background if possible',
                CupertinoIcons.rectangle_fill_on_rectangle_fill,
              ),
              const SizedBox(height: 12),
              _buildModalInstructionItem(
                'Position your face within the frame',
                CupertinoIcons.person_crop_square,
              ),
              const SizedBox(height: 12),
              _buildModalInstructionItem(
                'Look directly at the camera',
                CupertinoIcons.eye,
              ),
              const SizedBox(height: 12),
              _buildModalInstructionItem(
                'Wear the official uniform',
                CupertinoIcons.person_2,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.photo,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Required Size: $_photoWidthMM mm × $_photoHeightMM mm',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ShadButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it, Let\'s Start'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalInstructionItem(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      // Capture the photo
      final image = await _controller!.takePicture();

      // Crop to correct aspect ratio
      final croppedImage = await _cropToAspectRatio(image.path);

      setState(() {
        _capturedImage = croppedImage;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<File> _cropToAspectRatio(String imagePath) async {
    // Read the image
    final bytes = await File(imagePath).readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      return File(imagePath); // Return original if decode fails
    }

    // Calculate crop dimensions for aspect ratio
    const targetAspectRatio = _photoAspectRatio;
    final currentAspectRatio = originalImage.width / originalImage.height;

    int cropWidth;
    int cropHeight;
    int offsetX = 0;
    int offsetY = 0;

    if (currentAspectRatio > targetAspectRatio) {
      // Image is too wide, crop width
      cropHeight = originalImage.height;
      cropWidth = (cropHeight * targetAspectRatio).round();
      offsetX = ((originalImage.width - cropWidth) / 2).round();
    } else {
      // Image is too tall, crop height
      cropWidth = originalImage.width;
      cropHeight = (cropWidth / targetAspectRatio).round();
      offsetY = ((originalImage.height - cropHeight) / 2).round();
    }

    // Crop the image from center
    final croppedImage = img.copyCrop(
      originalImage,
      x: offsetX,
      y: offsetY,
      width: cropWidth,
      height: cropHeight,
    );

    // Save the cropped image
    final croppedPath = imagePath.replaceAll('.jpg', '_cropped.jpg');
    final croppedFile = File(croppedPath);
    await croppedFile.writeAsBytes(img.encodeJpg(croppedImage, quality: 95));

    // Delete original uncropped image
    await File(imagePath).delete();

    return croppedFile;
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
    });
  }

  void _confirmPhoto() {
    if (_capturedImage != null) {
      // Navigate back with the captured image
      context.pop(_capturedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: theme.colorScheme.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.colorScheme.background,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: Icon(
            CupertinoIcons.back,
            color: theme.colorScheme.foreground,
          ),
        ),
        middle: Text(
          'ID Card Photo',
          style: TextStyle(
            color: theme.colorScheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showGuidelinesModal,
          child: Icon(
            CupertinoIcons.info_circle,
            color: theme.colorScheme.foreground,
          ),
        ),
      ),
      child: SafeArea(
        child:
            _capturedImage != null ? _buildPreviewView() : _buildCameraView(),
      ),
    );
  }

  Widget _buildCameraView() {
    final theme = ShadTheme.of(context);

    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Camera Error',
                style: theme.textTheme.h3,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.p,
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: Text('Camera not available'),
      );
    }

    return Column(
      children: [
        // Camera Preview Section - Full screen
        Expanded(
          child: Container(
            color: Colors.black,
            width: double.infinity,
            child: Stack(
              children: [
                // Camera preview - full width, proper aspect
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.previewSize!.height,
                      height: _controller!.value.previewSize!.width,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),

                // Face circle guide overlay
                Center(
                  child: CustomPaint(
                    size: Size(
                      MediaQuery.of(context).size.width * 0.75,
                      MediaQuery.of(context).size.height * 0.4,
                    ),
                    painter: FaceOutlinePainter(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),

                // Size requirement badge at top
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.photo,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Required: $_photoWidthMM mm × $_photoHeightMM mm',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Capture Button Bar at Bottom
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Center(
            child: GestureDetector(
              onTap: _capturePhoto,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 4,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewView() {
    final theme = ShadTheme.of(context);

    return Column(
      children: [
        // Image Preview
        Expanded(
          child: Center(
            child: Image.file(
              _capturedImage!,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // Action Buttons
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.border,
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ShadButton(
                  onPressed: _confirmPhoto,
                  child: const Text('Use This Photo'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ShadButton.outline(
                  onPressed: _retakePhoto,
                  child: const Text('Retake Photo'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom painter for face outline guide
class FaceOutlinePainter extends CustomPainter {
  final Color color;

  FaceOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final center = Offset(size.width / 2, size.height / 2);

    // Position circle higher up
    final circleCenter = Offset(
      center.dx,
      center.dy - (size.height * 0.15),
    );

    // Circle diameter should be about 60% of the container width
    final circleDiameter = size.width * 0.6;
    final circleRadius = circleDiameter / 2;

    // Draw the main circle
    canvas.drawCircle(circleCenter, circleRadius, paint);

    // Guide text at top
    final textSpan = TextSpan(
      text: 'Center your face here',
      style: TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        circleCenter.dy - circleRadius - 35,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
