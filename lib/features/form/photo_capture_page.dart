import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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

  // Photo size requirements (from backend in future)
  static const int _photoWidthMM = 54; // Width in millimeters
  static const int _photoHeightMM = 86; // Height in millimeters
  static const double _photoAspectRatio = 54 / 86; // ~0.628

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
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: ${e.toString()}';
        _isInitializing = false;
      });
    }
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
      final image = await _controller!.takePicture();
      setState(() {
        _capturedImage = File(image.path);
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
        // Camera Preview Section - More space
        // Camera Preview Section - More space
        Expanded(
          flex: 5,
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

                // Face outline overlay - centered
                Center(
                  child: CustomPaint(
                    size: Size(
                      MediaQuery.of(context).size.width * 0.8,
                      MediaQuery.of(context).size.height * 0.5,
                    ),
                    painter: FaceOutlinePainter(
                      color: Colors.white.withOpacity(0.9),
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
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
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

        // Instructions Section - Scrollable, less space
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.info_circle,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Photo Guidelines',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.foreground,
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable instructions
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildInstructionItem(
                          'Keep good lighting in front of you',
                          CupertinoIcons.light_max,
                        ),
                        const SizedBox(height: 10),
                        _buildInstructionItem(
                          'Use a plain background if possible',
                          CupertinoIcons.rectangle_fill_on_rectangle_fill,
                        ),
                        const SizedBox(height: 10),
                        _buildInstructionItem(
                          'Position your face within the frame',
                          CupertinoIcons.person_crop_square,
                        ),
                        const SizedBox(height: 10),
                        _buildInstructionItem(
                          'Look directly at the camera',
                          CupertinoIcons.eye,
                        ),
                        const SizedBox(height: 10),
                        _buildInstructionItem(
                          'Wear the official uniform',
                          CupertinoIcons.person_2,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Capture Button - Always visible at bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String text, IconData icon) {
    final theme = ShadTheme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.mutedForeground,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.mutedForeground,
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

    // Use passport photo proportions (54mm x 86mm = ~0.628 ratio)
    // Head should take about 70-80% of photo height
    final headWidth = size.width * 0.5;
    final headHeight = size.height * 0.42;

    final headRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - size.height * 0.08),
      width: headWidth,
      height: headHeight,
    );

    canvas.drawOval(headRect, paint);

    // Neck
    final neckTop = headRect.bottom;
    final neckBottom = neckTop + size.height * 0.1;
    final neckWidth = headWidth * 0.35;

    // Left neck line
    canvas.drawLine(
      Offset(center.dx - neckWidth / 2, neckTop),
      Offset(center.dx - neckWidth / 2 - 8, neckBottom),
      paint,
    );

    // Right neck line
    canvas.drawLine(
      Offset(center.dx + neckWidth / 2, neckTop),
      Offset(center.dx + neckWidth / 2 + 8, neckBottom),
      paint,
    );

    // Shoulders
    final shoulderPath = Path();
    final shoulderTop = neckBottom;
    final shoulderBottom = shoulderTop + size.height * 0.15;

    // Left shoulder
    shoulderPath.moveTo(center.dx - neckWidth / 2 - 8, shoulderTop);
    shoulderPath.quadraticBezierTo(
      center.dx - size.width * 0.25,
      shoulderTop + 20,
      center.dx - size.width * 0.35,
      shoulderBottom,
    );

    // Right shoulder
    shoulderPath.moveTo(center.dx + neckWidth / 2 + 8, shoulderTop);
    shoulderPath.quadraticBezierTo(
      center.dx + size.width * 0.25,
      shoulderTop + 20,
      center.dx + size.width * 0.35,
      shoulderBottom,
    );

    canvas.drawPath(shoulderPath, paint);

    // Photo frame border (shows actual photo boundaries)
    final frameRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.72,
      height: (size.width * 0.72) / 0.628, // 54:86 ratio
    );

    final framePaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.square;

    // Draw corner brackets instead of full rectangle
    final cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      frameRect.topLeft,
      Offset(frameRect.left + cornerLength, frameRect.top),
      framePaint,
    );
    canvas.drawLine(
      frameRect.topLeft,
      Offset(frameRect.left, frameRect.top + cornerLength),
      framePaint,
    );

    // Top-right corner
    canvas.drawLine(
      frameRect.topRight,
      Offset(frameRect.right - cornerLength, frameRect.top),
      framePaint,
    );
    canvas.drawLine(
      frameRect.topRight,
      Offset(frameRect.right, frameRect.top + cornerLength),
      framePaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      frameRect.bottomLeft,
      Offset(frameRect.left + cornerLength, frameRect.bottom),
      framePaint,
    );
    canvas.drawLine(
      frameRect.bottomLeft,
      Offset(frameRect.left, frameRect.bottom - cornerLength),
      framePaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      frameRect.bottomRight,
      Offset(frameRect.right - cornerLength, frameRect.bottom),
      framePaint,
    );
    canvas.drawLine(
      frameRect.bottomRight,
      Offset(frameRect.right, frameRect.bottom - cornerLength),
      framePaint,
    );

    // Guide text at top
    final textSpan = TextSpan(
      text: 'Align your face here',
      style: TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.5),
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
        frameRect.top - 35,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
